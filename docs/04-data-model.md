# Data model

> This document describes the **v3** model (generic products +
> Supabase). The v2 model (hardcoded soda/cups, a single JSON blob in
> `shared_preferences`) is still documented in the git history if it
> needs to be consulted.

## Domain entities

```dart
ParticipantEntity        { id: String, name: String, active: bool }

ProductEntity             { id: String, name: String, active: bool }

enum ProductFrequency     { daily, weeklyOnce, monthly, rotating }

ProductConditionEntity    { productId: String, frequency: ProductFrequency,
                            minPresent: int, costCop: int?,
                            avoidRepeatingPreviousPeriod: bool }

enum ExclusionScope       { week, day }
enum ExclusionStrictness  { hard, soft }
ProductExclusionEntity    { productA: String, productB: String,
                            scope: ExclusionScope, strictness: ExclusionStrictness }

// An assignment of ONE product in ONE period (ISO date for daily
// products, ISO Monday for weekly/monthly ones). The period key lives
// in the containing map, not in the entity.
AssignmentEntity          { participantId: String?, locked: bool, warning: String? }

enum WeekState            { planned, inProgress, completed }
WeekParticipantEntity      { participantId: String, addedAt: String, removedAt: String? }
GeneratedWeekEntity        { monday: String, friday: String, state: WeekState,
                            participants: List<WeekParticipantEntity> }

ShiftsStateEntity {
  participants:     List<ParticipantEntity>,
  products:          List<ProductEntity>,
  conditions:        Map<String, ProductConditionEntity>,        // productId
  assignments:       Map<String, Map<String, AssignmentEntity>>, // productId -> periodId -> Assignment
  presenceByDay:     Map<String, List<String>>,                  // ISO date -> present ids
  exclusions:        List<ProductExclusionEntity>,
  weeks:             Map<String, GeneratedWeekEntity>,           // ISO Monday
}
```

`ShiftsStats` is a derived value (not persisted as such, it's rebuilt
from `historical` + live assignments): `counts: Map<String, Map<String,int>>`
(`productId` → `participantId` → complete historical count).

## Persistence

Two backends behind the same `ShiftsRepository` contract:

- **`ShiftsRepositoryImpl`** (local): serializes the complete
  `ShiftsStateEntity` as a single JSON blob under the
  `AppConstants.storageKey` key (`almuerzo-turnos-v2`) via
  `ShiftsStateModel` — see
  `lib/features/shifts/data/models/shifts_state_model.dart` for the
  exact JSON schema (participants/products/conditions/assignments/
  presenceByDay/exclusions/weeks).
- **`ShiftsSupabaseRepository`** (remote): normalized across the tables
  in `supabase/migrations/`, with `shared_preferences` as a best-effort
  offline-startup fallback. See
  [06-supabase-roadmap.md](06-supabase-roadmap.md) for the complete SQL
  schema and how `ShiftsRemoteDatasource` reconstructs the aggregate.

Notes carried over from the MVP:

- A participant's `id` is a **stable slug**; renaming doesn't change it
  (history is preserved). Deleting is a **soft delete**
  (`removed_at`/`active=false`): the history never loses the name.
- The history is **unbounded**: it's never pruned, because historical
  fair distribution (rule 5) counts all usage over time.

## Initial seed

If nothing has been saved, `LoadShiftsUseCase` starts with
`ShiftsStateEntity.seed()`: the group's 8 participants and the two
default products (daily soda, weekly-once cups) that reproduce the
MVP's behavior.
