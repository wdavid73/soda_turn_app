-- Participantes del grupo. Soft delete: nunca se borra la fila si tiene
-- historial (ver docs/02-reglas-negocio.md); "eliminar" desde la app
-- equivale a fijar eliminado_en y activo = false.
create table participantes (
  id text primary key,
  nombre text not null,
  activo boolean not null default true,
  eliminado_en timestamptz,
  created_at timestamptz not null default now()
);
