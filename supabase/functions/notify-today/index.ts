// Manda "hoy te toca comprar gaseosa" al participante asignado hoy, vía
// FCM HTTP v1. Lo dispara pg_cron (ver migración 0012_notify_today_cron.sql)
// todos los días hábiles a las 7am Bogotá — si no hay asignación para hoy
// (fin de semana, festivo, nadie generó la semana todavía) no hace nada.
//
// Requiere el secret `FIREBASE_SERVICE_ACCOUNT` (JSON del service account
// de Firebase, con permiso de Firebase Cloud Messaging API) configurado en
// el proyecto: `supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat sa.json)"`
// o desde el dashboard (Edge Functions → Secrets). `SUPABASE_URL` y
// `SUPABASE_ANON_KEY` ya vienen inyectados automáticamente por Supabase.

import { createClient } from 'npm:@supabase/supabase-js@2';

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id: string;
}

function base64url(input: Uint8Array | string): string {
  const bytes =
    typeof input === 'string' ? new TextEncoder().encode(input) : input;
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/// Cambia el JSON del service account por un access token OAuth2 con scope
/// de FCM, firmando un JWT RS256 a mano (Web Crypto) — no hay Admin SDK
/// disponible en el runtime de Edge Functions.
async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claim = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };
  const signingInput = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claim))}`;

  const pemBody = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    keyBytes.buffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );
  const jwt = `${signingInput}.${base64url(new Uint8Array(signature))}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    throw new Error(`token exchange failed: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();
  return json.access_token as string;
}

Deno.serve(async (_req: Request) => {
  try {
    const saRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    if (!saRaw) {
      return new Response(
        JSON.stringify({ error: 'FIREBASE_SERVICE_ACCOUNT no configurado' }),
        { status: 500 },
      );
    }
    const sa: ServiceAccount = JSON.parse(saRaw);

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
    );

    const today = new Date().toLocaleDateString('en-CA', {
      timeZone: 'America/Bogota',
    });

    const { data: asignaciones, error: asignacionesError } = await supabase
      .from('asignacion_diaria')
      .select('participante_id')
      .eq('producto_id', 'gaseosa')
      .eq('fecha', today)
      .not('participante_id', 'is', null);
    if (asignacionesError) throw asignacionesError;
    if (!asignaciones || asignaciones.length === 0) {
      return new Response(
        JSON.stringify({ notified: 0, reason: 'sin asignación hoy' }),
        { status: 200 },
      );
    }

    const participantIds = [
      ...new Set(asignaciones.map((a) => a.participante_id as string)),
    ];

    const { data: tokens, error: tokensError } = await supabase
      .from('push_tokens')
      .select('token')
      .in('participante_id', participantIds);
    if (tokensError) throw tokensError;
    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ notified: 0, reason: 'sin token registrado' }),
        { status: 200 },
      );
    }

    const accessToken = await getAccessToken(sa);

    let sent = 0;
    for (const { token } of tokens) {
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token,
              notification: {
                title: 'SodaTurn',
                body: 'Hoy te toca comprar gaseosa 🥤',
              },
            },
          }),
        },
      );
      if (res.ok) {
        sent++;
      } else {
        console.error('FCM send failed', token, await res.text());
      }
    }

    return new Response(JSON.stringify({ notified: sent }), { status: 200 });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
