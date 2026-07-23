-- Un participante puede tener varios dispositivos (token único por
-- dispositivo); se usa para mandarle el push "hoy te toca" al asignado del
-- día. El cliente todavía no escribe acá (llega en el próximo paso, cuando
-- se cablee firebase_messaging) — esta migración solo deja la tabla lista.
create table push_tokens (
  id uuid primary key default gen_random_uuid(),
  participante_id text not null references participantes(id) on delete cascade,
  token text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table push_tokens enable row level security;

-- Mismo criterio que 0007_rls_allow_all.sql: un solo grupo compartido, sin
-- autenticación en esta fase.
create policy allow_all_push_tokens on push_tokens for all using (true) with check (true);
