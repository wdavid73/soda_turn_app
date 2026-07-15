# Contexto del proyecto

## Objetivo

Repartir de forma justa, entre un grupo fijo de compañeros de almuerzo,
dos responsabilidades de lunes a viernes:

- **Gaseosa**: una persona por día (~$7.000 COP el día que le toca).
- **Vasos**: una sola persona por semana completa.

La app decide automáticamente con un algoritmo de rotación justa, pero el
usuario siempre tiene la última palabra: todo se puede editar a mano y el
sistema responde con advertencias, no con bloqueos.

## Participantes iniciales

Brayan Díaz, Brayan Valderrama, Héctor, Wilson, Pedro, Sebastián, Walter
y Natalia. Son editables desde la pantalla **Equipo**: se pueden agregar,
renombrar, eliminar, o marcar como inactivos (vacaciones) sin perder su
historial.

## Historia: de la web a Flutter

1. **Web v1** (HTML/CSS/JS, sin frameworks): gaseosa y vasos se asignaban
   ambos a diario, con la única restricción cruzada de que quien compraba
   vasos un día no podía comprar gaseosa al día siguiente.
2. **Web v2** (regla actual): los vasos pasaron a ser **semanales**, y
   quien los compra queda excluido de la gaseosa **toda esa semana**.
   Esto separó el registro semanal `weeklyVasos` del registro diario y
   cambió el orden de generación (primero vasos, luego gaseosa día a
   día). La clave de almacenamiento migró a `almuerzo-turnos-v2`.
3. **Flutter (este repo)**: port nativo con Clean Architecture + Riverpod,
   manteniendo las reglas v2 y **el mismo esquema JSON** del estado, de
   modo que un respaldo de la web es interpretable por la app y viceversa.
   El diseño visual cambió: de la estética "ticket de recibo" de la web al
   design system **SodaTurn** (ver [05-design-system.md](05-design-system.md)
   y la carpeta `design/` con los mockups).

## Persistencia

MVP: local con `shared_preferences` (un JSON con el estado completo bajo
la clave `almuerzo-turnos-v2`), sin backend. La fase 2 planea Supabase
para sincronizar entre dispositivos (ver
[06-roadmap-supabase.md](06-roadmap-supabase.md)).
