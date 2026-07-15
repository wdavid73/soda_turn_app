# Arquitectura

Clean Architecture **feature-first** con Riverpod, `dartz`
(`Either<Failure, T>`) y clases Dart manuales (sin Freezed ni codegen).

El dominio es un solo agregado (participantes + asignaciones diarias +
vasos semanales comparten estado y fairness), así que vive en **una sola
feature `turnos`** con varias pantallas en presentación.

```
lib/
├── main.dart                        # ProviderScope + MaterialApp.router
├── config/routes/app_router.dart    # GoRouter (provider) + shell de 4 tabs
├── core/
│   ├── constants/app_constants.dart # $7.000, mínimo 4, clave de storage
│   ├── errors/failures.dart         # Failure, CacheFailure
│   ├── theme/app_theme.dart         # tokens SodaTurn → ThemeData
│   └── utils/                       # fechas hábiles, slug, formato COP
├── features/turnos/
│   ├── domain/
│   │   ├── entities/                # Participant, DayAssignment, WeeklyVasos,
│   │   │                            # TurnosState (agregado), TurnosStats
│   │   ├── repositories/            # TurnosRepository (contrato load/save)
│   │   ├── services/                # FairPickerService, TurnosEngine (reglas)
│   │   └── usecases/                # 1 clase por operación (generate_week, …)
│   ├── data/
│   │   ├── models/                  # *_model.dart fromJson/toJson (esquema web v2)
│   │   ├── datasources/             # TurnosLocalDatasource (shared_preferences)
│   │   └── repositories/            # TurnosRepositoryImpl (Either)
│   └── presentation/
│       ├── providers/               # turnos_providers + TurnosViewModel
│       ├── screens/                 # home, week, participants, stats
│       └── widgets/                 # cards, sheets, chips del feature
└── shared/widgets/                  # AppScaffold (bottom nav), avatar, tiles
```

## Flujo de datos

```
UI (screens/widgets)
  → TurnosViewModel (StateNotifier<TurnosUiState>)
    → usecases (puros: TurnosStateEntity → TurnosStateEntity)
      → TurnosEngine + FairPickerService  (todas las reglas viven aquí)
    → SaveTurnosUseCase → TurnosRepository → datasource (shared_preferences)
```

Puntos clave:

- **El motor es puro.** `TurnosEngine` no conoce Flutter ni persistencia:
  recibe un estado y devuelve uno nuevo. Por eso las 9 reglas se testean
  sin mocks en `test/features/turnos/domain/`.
- **El ViewModel es el único que persiste.** Cada mutación pasa por
  `_commit(next)`: actualiza el estado en memoria y guarda con
  `SaveTurnosUseCase`; si falla, expone `error` en el `TurnosUiState`.
- **`Either<Failure, T>` solo cruza la frontera con datos** (load/save).
  Las operaciones de dominio puras no fallan, así que no lo necesitan.
- **El router es un provider** (`appRouterProvider`): cada `ProviderScope`
  (app o test) recibe su propia instancia de GoRouter y no se filtra
  estado de navegación entre árboles.
- **DI 100 % Riverpod**: `sharedPreferencesProvider` se sobreescribe en
  `main()` con la instancia real, y en tests con el mock.

## Providers principales

| Provider | Tipo | Rol |
|---|---|---|
| `turnosViewModelProvider` | `StateNotifierProvider` | Estado global (data + semana seleccionada + loading/error) |
| `turnosStatsProvider` | `Provider` derivado | Conteos históricos recalculados al cambiar el estado |
| `turnosUseCasesProvider` | `Provider` | Bundle de usecases inyectado al ViewModel |
| `appRouterProvider` | `Provider` | GoRouter con `StatefulShellRoute` (4 tabs) |

## Testing

- **Unit (dominio)**: reglas 1–8 del engine con `Random` sembrado;
  propiedades verificadas sobre 20 semillas donde aplica.
- **Unit (data)**: round-trip JSON del modelo, parsing del esquema web
  v2, repositorio con datasource falso en memoria y caso de JSON corrupto.
- **Widget**: smoke test de arranque + navegación por las 4 pestañas y
  flujo "Generar Semana" end-to-end con `SharedPreferences` mockeado.
