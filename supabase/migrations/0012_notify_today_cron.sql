-- Dispara la Edge Function `notify-today` (ver
-- supabase/functions/notify-today/index.ts) todos los días hábiles a las
-- 7:00 Bogotá (12:00 UTC, sin DST). La función misma es un no-op silencioso
-- si no hay asignación para hoy (fin de semana, festivo colombiano, o la
-- semana todavía no se generó), así que no hace falta replicar el
-- calendario de festivos acá.
--
-- El Bearer usado es el `anon key` público del proyecto (el mismo que ya
-- viaja embebido en el APK, ver 0007_rls_allow_all.sql) — alcanza porque
-- Edge Functions solo valida que sea un JWT firmado por el proyecto, no un
-- rol específico; la función internamente también usa el anon key contra
-- tablas con RLS "allow all".
create extension if not exists pg_net;

select cron.schedule(
  'notify-today',
  '0 12 * * 1-5',
  $$
  select net.http_post(
    url := 'https://ataygcxcaizycoueujwz.supabase.co/functions/v1/notify-today',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0YXlnY3hjYWl6eWNvdWV1and6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2ODEwMDksImV4cCI6MjEwMDI1NzAwOX0.mAQuyJtmmI7w6UVYDsE27iJWCBvvjYojpF140ZY9WkY'
    ),
    body := '{}'::jsonb
  ) as request_id;
  $$
);
