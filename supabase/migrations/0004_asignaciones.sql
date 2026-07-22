-- Asignaciones de la semana activa. Solo existen para la semana
-- planificada/en_curso; lo pasado vive en `historico` (ver 0005).
create table asignacion_diaria (
  id uuid primary key default gen_random_uuid(),
  semana_id uuid not null references semana_generada(id) on delete cascade,
  producto_id text not null references productos(id),
  fecha date not null,
  participante_id text references participantes(id),
  locked boolean not null default false,
  warning text,
  updated_at timestamptz not null default now(),
  unique (semana_id, producto_id, fecha)
);

create table asignacion_semanal (
  id uuid primary key default gen_random_uuid(),
  semana_id uuid not null references semana_generada(id) on delete cascade,
  producto_id text not null references productos(id),
  participante_id text references participantes(id),
  locked boolean not null default false,
  warning text,
  updated_at timestamptz not null default now(),
  unique (semana_id, producto_id)
);
