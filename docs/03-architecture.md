# Architecture

**Feature-first** Clean Architecture with Riverpod, `dartz`
(`Either<Failure, T>`), and hand-written Dart classes (no Freezed or
codegen).

The domain is a single aggregate (participants + daily assignments +
weekly cups share state and fairness), so it lives in **a single
`shifts` feature** with several presentation screens.

```
lib/
├── main.dart                        # ProviderScope + MaterialApp.router
├── config/routes/app_router.dart    # GoRouter (provider) + 4-tab shell
├── core/
│   ├── constants/app_constants.dart # $7,000, minimum 4, storage key
│   ├── errors/failures.dart         # Failure, CacheFailure
│   ├── theme/app_theme.dart         # SodaTurn tokens → ThemeData
│   └── utils/                       # business days, slug, COP formatting
├── features/shifts/
│   ├── domain/
│   │   ├── entities/                # Participant, Product, ProductCondition,
│   │   │                            # ProductExclusion, Assignment, GeneratedWeek,
│   │   │                            # ShiftsState (aggregate), ShiftsStats
│   │   ├── repositories/            # ShiftsRepository (load/save contract)
│   │   ├── services/                # FairPickerService, ShiftsEngine, WeekStateService
│   │   └── usecases/                # 1 class per operation (generate_today, …)
│   ├── data/
│   │   ├── models/                  # *_model.dart fromJson/toJson and fromRow/toRow (Supabase)
│   │   ├── datasources/             # ShiftsLocalDatasource + ShiftsRemoteDatasource
│   │   ├── migration/               # LocalToSupabaseMigration (one-time)
│   │   └── repositories/            # ShiftsRepositoryImpl / ShiftsSupabaseRepository
│   └── presentation/
│       ├── providers/               # shifts_providers + ShiftsViewModel
│       ├── screens/                 # home, week, participants, stats
│       └── widgets/                 # feature cards, sheets, chips
└── shared/widgets/                  # AppScaffold (bottom nav), avatar, tiles
```

## Data flow

```
UI (screens/widgets)
  → ShiftsViewModel (StateNotifier<ShiftsUiState>)
    → usecases (pure: ShiftsStateEntity → ShiftsStateEntity)
      → ShiftsEngine + FairPickerService  (all the rules live here)
    → SaveShiftsUseCase → ShiftsRepository → datasource (shared_preferences)
```

Key points:

- **The engine is pure.** `ShiftsEngine` knows nothing about Flutter or
  persistence: it receives a state and returns a new one. That's why the
  9 rules are tested without mocks in `test/features/shifts/domain/`.
- **The ViewModel is the only thing that persists.** Every mutation goes
  through `_commit(next)`: it updates the in-memory state and saves with
  `SaveShiftsUseCase`; if it fails, it exposes `error` in the
  `ShiftsUiState`.
- **`Either<Failure, T>` only crosses the boundary with data** (load/save).
  Pure domain operations don't fail, so they don't need it.
- **The router is a provider** (`appRouterProvider`): each `ProviderScope`
  (app or test) gets its own GoRouter instance, so navigation state
  doesn't leak between trees.
- **100% Riverpod DI**: `sharedPreferencesProvider` is overridden in
  `main()` with the real instance, and in tests with the mock.

## Main providers

| Provider | Type | Role |
|---|---|---|
| `shiftsViewModelProvider` | `StateNotifierProvider` | Global state (data + selected week + loading/error) |
| `shiftsStatsProvider` | Derived `Provider` | Historical counts recalculated when state changes |
| `shiftsUseCasesProvider` | `Provider` | Usecase bundle injected into the ViewModel |
| `appRouterProvider` | `Provider` | GoRouter with `StatefulShellRoute` (4 tabs) |

## Testing

- **Unit (domain)**: rules 1–8 of the engine with a seeded `Random`;
  properties verified over 20 seeds where applicable.
- **Unit (data)**: model JSON round-trip, parsing of the web v2 schema,
  repository with a fake in-memory datasource, and a corrupted-JSON case.
- **Widget**: startup smoke test + navigation across the 4 tabs, and an
  end-to-end "Generate Week" flow with mocked `SharedPreferences`.
