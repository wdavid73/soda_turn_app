# Modelo de datos

## Entidades de dominio

```dart
ParticipantEntity   { id: String, name: String, active: bool }

// Un registro por día hábil (clave del mapa: fecha ISO yyyy-MM-dd)
DayAssignmentEntity { present: List<String>,  // ids presentes ese día
                      gaseosa: String?,       // id del comprador (o null)
                      locked: bool,           // 🔒 no lo pisa "Generar semana"
                      warning: String? }      // regla relajada/rota

// Un registro por semana (clave del mapa: lunes ISO de esa semana)
WeeklyVasosEntity   { personId: String?, locked: bool, warning: String? }

TurnosStateEntity   { participants: List<ParticipantEntity>,
                      assignments: Map<String, DayAssignmentEntity>,
                      weeklyVasos: Map<String, WeeklyVasosEntity> }
```

`TurnosStats` es un valor derivado (no se persiste): conteos por persona
de días de gaseosa y semanas de vasos sobre todo el historial.

## Esquema persistido (JSON)

Clave de `shared_preferences`: **`almuerzo-turnos-v2`** — el mismo nombre
y esquema del `localStorage` de la versión web v2, para compatibilidad de
respaldos entre ambas versiones:

```json
{
  "participants": [
    { "id": "wilson", "name": "Wilson", "active": true }
  ],
  "assignments": {
    "2026-07-13": {
      "present": ["wilson", "pedro", "hector", "natalia"],
      "gaseosa": "pedro",
      "locked": false,
      "warning": null
    }
  },
  "weeklyVasos": {
    "2026-07-13": { "personId": "natalia", "locked": false, "warning": null }
  }
}
```

Notas:

- Las **fechas viajan como String ISO** (`yyyy-MM-dd`) y son las claves de
  los mapas; no hay objetos DateTime serializados.
- `id` de participante es un **slug estable** derivado del nombre
  (`Héctor` → `hector`); ante duplicados se sufija `-2`, `-3`, …
  Renombrar a alguien **no** cambia su id (el historial se conserva).
- Eliminar a un participante no borra su historial en
  `assignments`/`weeklyVasos`; su id huérfano se muestra tal cual si
  aparece en semanas pasadas.
- El historial es **indefinido**: nunca se poda, porque el fairness
  (regla 5) cuenta todo el tiempo de uso.

## Semilla inicial

Si no hay nada guardado, `LoadTurnosUseCase` arranca con los 8
participantes del grupo (`TurnosStateEntity.seed()`) y sin semanas.
