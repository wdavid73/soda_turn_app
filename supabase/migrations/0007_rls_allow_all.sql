-- Sin autenticación en esta fase (un solo grupo compartido, todo el equipo
-- confía en todos, como ya funciona la app hoy). Se habilita RLS con
-- políticas "allow all" EXPLÍCITAS en vez de dejar las tablas sin RLS, para
-- que quede documentado como decisión consciente y no un olvido -- la anon
-- key viaja embebida en el APK, así que esto no es más ni menos abierto de
-- lo que ya era, pero queda declarado.
alter table participantes enable row level security;
alter table productos enable row level security;
alter table condicion_producto enable row level security;
alter table producto_exclusiones enable row level security;
alter table semana_generada enable row level security;
alter table semana_participantes enable row level security;
alter table presencia_dia enable row level security;
alter table asignacion_diaria enable row level security;
alter table asignacion_semanal enable row level security;
alter table historico enable row level security;

create policy allow_all_participantes on participantes for all using (true) with check (true);
create policy allow_all_productos on productos for all using (true) with check (true);
create policy allow_all_condicion_producto on condicion_producto for all using (true) with check (true);
create policy allow_all_producto_exclusiones on producto_exclusiones for all using (true) with check (true);
create policy allow_all_semana_generada on semana_generada for all using (true) with check (true);
create policy allow_all_semana_participantes on semana_participantes for all using (true) with check (true);
create policy allow_all_presencia_dia on presencia_dia for all using (true) with check (true);
create policy allow_all_asignacion_diaria on asignacion_diaria for all using (true) with check (true);
create policy allow_all_asignacion_semanal on asignacion_semanal for all using (true) with check (true);
create policy allow_all_historico on historico for all using (true) with check (true);
