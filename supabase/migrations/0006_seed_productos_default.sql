-- Siembra los dos productos del MVP como filas de datos, para no perder el
-- comportamiento actual al migrar a un modelo de productos configurables.
insert into productos (id, nombre) values
  ('gaseosa', 'Gaseosa'),
  ('vasos', 'Vasos');

insert into condicion_producto (producto_id, frecuencia, min_presentes, costo_cop, evita_repetir_periodo_anterior)
values
  ('gaseosa', 'diario', 4, 7000, true),
  ('vasos', 'semanal_unico', 1, null, true);

insert into producto_exclusiones (producto_a, producto_b, alcance, dureza)
values ('gaseosa', 'vasos', 'semana', 'dura');
