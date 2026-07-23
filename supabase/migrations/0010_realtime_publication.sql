-- Habilita Realtime sobre las tablas de la semana activa, para que dos
-- dispositivos vean los cambios del otro sin recargar manualmente (ver
-- ShiftsRemoteDatasource.watchChanges). Envuelto en un guard idempotente
-- porque `alter publication ... add table` falla si la tabla ya está.
do $$
declare
  t text;
begin
  foreach t in array array[
    'asignacion_diaria',
    'asignacion_semanal',
    'presencia_dia',
    'semana_generada'
  ] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
