-- Corrige el warning de seguridad "Function Search Path Mutable" para las
-- funciones agregadas en 0008: fija search_path para que no dependan (ni
-- puedan ser hijackeadas vía) el search_path del rol que las invoque.
alter function easter_sunday(int) set search_path = public, pg_temp;
alter function next_monday_on_or_after(date) set search_path = public, pg_temp;
alter function colombian_holidays(int) set search_path = public, pg_temp;
alter function es_festivo(date) set search_path = public, pg_temp;
alter function es_dia_generable(date) set search_path = public, pg_temp;
alter function ultimo_dia_generable(date, date) set search_path = public, pg_temp;
alter function estado_semana_de(date, date, date) set search_path = public, pg_temp;
alter function close_completed_weeks(date) set search_path = public, pg_temp;
