# Reglas de negocio (v2)

Implementadas en [turnos_engine.dart](../lib/features/turnos/domain/services/turnos_engine.dart)
y verificadas por [turnos_engine_test.dart](../test/features/turnos/domain/turnos_engine_test.dart).

**Dureza de las reglas:**

- **Dura**: el algoritmo automático nunca la viola.
- **Blanda**: se relaja con advertencia si no hay alternativa.
- Toda regla puede romperse **manualmente** (regla 8): la app lo permite
  y muestra la advertencia; el usuario manda.

| # | Regla | Dureza |
|---|---|---|
| 1 | **Mínimo 4 presentes** para asignar la gaseosa de un día. Si no se cumple, el día queda sin asignar y se advierte. | Dura (auto) |
| 2 | **Nadie repite gaseosa el día hábil siguiente.** Cruza el fin de semana: el del viernes no repite el lunes. | Blanda |
| 3 | **Vasos una sola vez por semana**: una única persona para lunes–viernes, elegida entre la unión de presentes de los 5 días. | — |
| 4 | **Quien lleva los vasos NO compra gaseosa esa semana.** | Dura (auto), advertencia en manual |
| 5 | **Reparto justo**: siempre gana quien menos veces le ha tocado en TODO el historial (gaseosa por días, vasos por semanas). Empates al azar. | — |
| 6 | Al elegir vasos automáticamente se **evita repetir a la persona de la semana anterior**. | Blanda |
| 7 | **Bloqueo 🔒**: cada día (gaseosa) y la semana completa (vasos) pueden bloquearse; "Generar semana" no los sobreescribe. | — |
| 8 | **Edición manual** siempre permitida; el sistema advierte en vez de bloquear. Al fijar vasos manualmente, los días de gaseosa de esa persona se liberan y reasignan (los bloqueados solo se marcan con advertencia). | — |
| 9 | **Costo**: solo se contabiliza la gaseosa ($7.000 COP por día asignado). Los vasos se cuentan por frecuencia, no en dinero. | — |

## Orden de generación de una semana

`TurnosEngine.generateWeek(state, lunesIso)`:

1. **Defaults**: crea los registros que falten; la presencia por defecto
   de cada día son los participantes **activos**.
2. **Limpieza**: borra gaseosa/advertencias de los días **sin bloquear**
   (para re-repartir sin sesgo de la corrida anterior).
3. **Vasos primero** (`pickWeeklyVasos`): respeta el 🔒 semanal; excluye a
   quien ya tenga gaseosa en un día bloqueado (protege la regla 4); evita
   al de la semana pasada (regla 6, blanda); decide por fairness (regla 5).
4. **Gaseosa día por día** (`autoAssignGaseosaDay`, lunes→viernes):
   respeta 🔒 del día; exige 4 presentes (regla 1); excluye al de los
   vasos (regla 4); evita al comprador del día hábil anterior/siguiente
   (regla 2, blanda); decide por fairness (regla 5).

## Detalles del fairness

- Los conteos consideran **todo el historial guardado**, no solo la
  semana visible; el historial es indefinido a propósito.
- Al re-generar, el pick vigente del propio día/semana se descuenta antes
  de contar, para no sesgar la re-elección.
- Empates se resuelven con `Random` (inyectable para tests deterministas).

## Advertencias (mensajes exactos)

Constantes en `TurnosEngine`: menos de 4 presentes, sin candidatos,
relajación de "no repetir día seguido", conflicto vasos/día bloqueado,
repetición de vasos de la semana pasada, y semana sin presentes. La
edición manual compone mensajes por cada regla rota (vasos, día
anterior/siguiente, no presente, menos de 4).
