-- Cierre automático de semanas vía pg_cron (ya habilitado en el proyecto):
-- reimplementa en SQL la misma lógica de `WeekStateService`/
-- `ShiftsRemoteDatasource.closeCompletedWeeks` (lib/features/shifts) para
-- que una semana se materialice a `historico` aunque nadie abra la app. El
-- trigger client-side (`ShiftsViewModel._init`) queda como respaldo: ambos
-- caminos son idempotentes y pueden convivir sin pisarse.

-- ── Festivos de Colombia (puerto 1:1 de lib/core/utils/colombian_holidays.dart) ──

create or replace function easter_sunday(y int) returns date as $$
declare
  a int; b int; c int; d int; e int; f int; g int; h int; i int; k int; l int; m int;
  month int; day int;
begin
  a := y % 19;
  b := y / 100;
  c := y % 100;
  d := b / 4;
  e := b % 4;
  f := (b + 8) / 25;
  g := (b - f + 1) / 3;
  h := (19 * a + b - d - g + 15) % 30;
  i := c / 4;
  k := c % 4;
  l := (32 + 2 * e + 2 * i - h - k) % 7;
  m := (a + 11 * h + 22 * l) / 451;
  month := (h + l - 7 * m + 114) / 31;
  day := ((h + l - 7 * m + 114) % 31) + 1;
  return make_date(y, month, day);
end;
$$ language plpgsql immutable;

-- [date] si ya es lunes; si no, el lunes siguiente (Ley Emiliani).
create or replace function next_monday_on_or_after(d date) returns date as $$
  select d + ((1 - extract(isodow from d)::int + 7) % 7);
$$ language sql immutable;

create or replace function colombian_holidays(y int) returns setof date as $$
declare
  fixed date[] := array[
    make_date(y, 1, 1),   -- Año Nuevo
    make_date(y, 5, 1),   -- Día del Trabajo
    make_date(y, 7, 20),  -- Independencia
    make_date(y, 8, 7),   -- Batalla de Boyacá
    make_date(y, 12, 8),  -- Inmaculada Concepción
    make_date(y, 12, 25)  -- Navidad
  ];
  emiliani date[] := array[
    make_date(y, 1, 6),   -- Reyes Magos
    make_date(y, 3, 19),  -- San José
    make_date(y, 6, 29),  -- San Pedro y San Pablo
    make_date(y, 8, 15),  -- Asunción de la Virgen
    make_date(y, 10, 12), -- Día de la Raza
    make_date(y, 11, 1),  -- Todos los Santos
    make_date(y, 11, 11)  -- Independencia de Cartagena
  ];
  easter date := easter_sunday(y);
  d date;
begin
  foreach d in array fixed loop
    return next d;
  end loop;
  foreach d in array emiliani loop
    return next next_monday_on_or_after(d);
  end loop;
  return next (easter - 3); -- Jueves Santo
  return next (easter - 2); -- Viernes Santo
  return next next_monday_on_or_after(easter + 39); -- Ascensión del Señor
  return next next_monday_on_or_after(easter + 60); -- Corpus Christi
  return next next_monday_on_or_after(easter + 68); -- Sagrado Corazón
end;
$$ language plpgsql immutable;

create or replace function es_festivo(d date) returns boolean as $$
  select exists (
    select 1 from colombian_holidays(extract(year from d)::int) h where h = d
  );
$$ language sql stable;

-- Día hábil (lunes-viernes) y no festivo.
create or replace function es_dia_generable(d date) returns boolean as $$
  select extract(isodow from d) between 1 and 5 and not es_festivo(d);
$$ language sql stable;

-- Último día generable de la semana, sin cruzar hacia atrás del lunes.
create or replace function ultimo_dia_generable(p_monday date, p_friday date) returns date as $$
declare
  d date := p_friday;
begin
  while not es_dia_generable(d) and d > p_monday loop
    d := d - 1;
  end loop;
  return d;
end;
$$ language plpgsql stable;

create or replace function estado_semana_de(p_monday date, p_friday date, p_today date) returns estado_semana as $$
declare
  ultimo date;
begin
  if p_today < p_monday then
    return 'planificada'::estado_semana;
  end if;
  ultimo := ultimo_dia_generable(p_monday, p_friday);
  if p_today > ultimo then
    return 'completada'::estado_semana;
  end if;
  return 'en_curso'::estado_semana;
end;
$$ language plpgsql stable;

-- ── Cierre de semana ─────────────────────────────────────────────────────

-- [p_today] por defecto usa la fecha calendario de Bogotá (no la del
-- servidor, que corre en UTC) para que el corte de "hoy" coincida con el
-- que ven los dispositivos del equipo.
create or replace function close_completed_weeks(
  p_today date default (now() at time zone 'America/Bogota')::date
) returns void as $$
declare
  semana record;
begin
  for semana in select id, monday, friday from semana_generada loop
    if estado_semana_de(semana.monday, semana.friday, p_today) <> 'completada'::estado_semana then
      continue;
    end if;

    -- Idempotencia: sin filas vivas, esta semana ya se materializó antes.
    if not exists (select 1 from asignacion_diaria where semana_id = semana.id)
       and not exists (select 1 from asignacion_semanal where semana_id = semana.id) then
      continue;
    end if;

    insert into historico (semana_id, fecha, producto_id, participante_id, warning, presentes_snapshot)
    select
      ad.semana_id,
      ad.fecha,
      ad.producto_id,
      ad.participante_id,
      ad.warning,
      coalesce(array_agg(pd.participante_id) filter (where pd.presente), '{}')
    from asignacion_diaria ad
    left join presencia_dia pd
      on pd.semana_id = ad.semana_id and pd.fecha = ad.fecha
    where ad.semana_id = semana.id
    group by ad.semana_id, ad.fecha, ad.producto_id, ad.participante_id, ad.warning
    on conflict (semana_id, fecha, producto_id) do nothing;

    -- Productos semanales (ej. vasos): fecha = lunes, snapshot = unión de
    -- presencia de toda la semana (igual que LocalToSupabaseMigration).
    insert into historico (semana_id, fecha, producto_id, participante_id, warning, presentes_snapshot)
    select
      asem.semana_id,
      semana.monday,
      asem.producto_id,
      asem.participante_id,
      asem.warning,
      coalesce((
        select array_agg(distinct pd2.participante_id)
        from presencia_dia pd2
        where pd2.semana_id = asem.semana_id
          and pd2.fecha between semana.monday and semana.friday
          and pd2.presente
      ), '{}')
    from asignacion_semanal asem
    where asem.semana_id = semana.id
    on conflict (semana_id, fecha, producto_id) do nothing;

    delete from asignacion_diaria where semana_id = semana.id;
    delete from asignacion_semanal where semana_id = semana.id;

    update semana_generada
      set estado = 'completada', updated_at = now()
      where id = semana.id;
  end loop;
end;
$$ language plpgsql;

-- ── Programación ─────────────────────────────────────────────────────────

-- 11:00 UTC = 06:00 Bogotá: corre temprano, antes de que el equipo empiece
-- a usar la app, para que la semana ya quede cerrada. `cron.schedule` con
-- job_name repetido actualiza el job existente en vez de duplicarlo, así
-- que esta migración es segura de re-aplicar.
select cron.schedule(
  'close-completed-weeks',
  '0 11 * * *',
  $$select close_completed_weeks()$$
);
