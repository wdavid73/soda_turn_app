-- Productos genéricos (reemplaza gaseosa/vasos hardcodeados) y sus
-- condiciones de negocio, más las exclusiones entre productos (generaliza
-- la regla 4 del MVP: "quien lleva los vasos no compra gaseosa esa semana").
create type frecuencia_producto as enum
  ('diario', 'semanal_unico', 'mensual', 'rotativo');

create table productos (
  id text primary key,
  nombre text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

create table condicion_producto (
  id uuid primary key default gen_random_uuid(),
  producto_id text not null references productos(id) on delete cascade,
  frecuencia frecuencia_producto not null,
  min_presentes int not null default 1,
  costo_cop int,
  evita_repetir_periodo_anterior boolean not null default false,
  config jsonb not null default '{}',
  unique (producto_id)
);

-- Fila no dirigida: producto_a < producto_b evita duplicados si a futuro
-- se permite crear exclusiones libremente desde la UI.
create table producto_exclusiones (
  producto_a text not null references productos(id) on delete cascade,
  producto_b text not null references productos(id) on delete cascade,
  alcance text not null default 'semana' check (alcance in ('semana', 'dia')),
  dureza text not null default 'dura' check (dureza in ('dura', 'blanda')),
  primary key (producto_a, producto_b),
  check (producto_a < producto_b)
);
