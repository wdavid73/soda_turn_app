-- Histórico append-only: fuente de verdad del reparto justo pasado (regla
-- 5). Se materializa cuando una semana pasa a `completada`; conserva el
-- participante_id aunque el participante se elimine después (soft delete
-- en `participantes`, nunca se rompe esta referencia).
create table historico (
  id uuid primary key default gen_random_uuid(),
  semana_id uuid not null references semana_generada(id),
  fecha date not null,
  producto_id text not null references productos(id),
  participante_id text references participantes(id),
  presentes_snapshot text[] not null default '{}',
  warning text,
  creado_en timestamptz not null default now(),
  unique (semana_id, fecha, producto_id)
);
