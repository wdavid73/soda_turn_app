-- Semana configurada: rango de fechas, estado y quiénes participan. El
-- estado persistido es solo cache para queries; la fuente de verdad se
-- deriva en código (ver WeekStateService) comparando la fecha de hoy
-- contra monday/friday, para no depender de un festivo en el viernes.
create type estado_semana as enum ('planificada', 'en_curso', 'completada');

create table semana_generada (
  id uuid primary key default gen_random_uuid(),
  monday date not null unique,
  friday date not null,
  estado estado_semana not null default 'planificada',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Participantes configurados para una semana; pueden añadirse/quitarse
-- durante la semana (agregado_en/retirado_en acotan su elegibilidad).
create table semana_participantes (
  semana_id uuid not null references semana_generada(id) on delete cascade,
  participante_id text not null references participantes(id),
  agregado_en date not null default current_date,
  retirado_en date,
  primary key (semana_id, participante_id)
);

-- Presencia diaria (quién almorzó ese día), independiente del producto.
create table presencia_dia (
  semana_id uuid not null references semana_generada(id) on delete cascade,
  fecha date not null,
  participante_id text not null references participantes(id),
  presente boolean not null default true,
  primary key (semana_id, fecha, participante_id)
);
