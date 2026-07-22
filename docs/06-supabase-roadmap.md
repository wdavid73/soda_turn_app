# Phase 2 — Supabase + generic product model

> **Status: implemented, pending connection of your own project.** The
> code is ready (schema, generic rules engine, data layer); all that's
> left is to create a project in Supabase, run the migrations, and paste
> your credentials into `lib/core/config/supabase_config.dart`.

## How to connect your project

1. Create a project at https://supabase.com.
2. Run the migrations in `supabase/migrations/` in order (Supabase CLI
   `supabase db push`, or by pasting each file into the dashboard's SQL
   Editor, from `0001` to `0007`).
3. In the dashboard: **Settings → API**, copy the "Project URL" and the
   public key (`anon`/`publishable`) and replace the placeholders in
   `lib/core/config/supabase_config.dart`.
4. Run the app. `shiftsRepositoryProvider`
   (`lib/features/shifts/presentation/providers/shifts_providers.dart`)
   automatically detects that `SupabaseConfig.isConfigured` is `true` and
   uses `ShiftsSupabaseRepository` instead of the local repository — no
   code changes needed.
5. If you already had local MVP data (`shared_preferences`), run the
   migration once with `LocalToSupabaseMigration`
   (`lib/features/shifts/data/migration/local_to_supabase_migration.dart`)
   before using the app in remote mode — it never deletes the local
   backup.

## Guiding principle

`ShiftsRepository` (domain) remains the only persistence contract,
unchanged: `ShiftsSupabaseRepository` implements it the same way
`ShiftsRepositoryImpl` (local) does. The UI, the ViewModel, the usecases,
and the rules engine don't change.

## Why there's no authentication in this phase

A single shared group: the whole team already trusts everyone (as the
app works today), so the `groups`/`group_members` table and the login
proposed by an earlier version of this document were omitted. The tables
have RLS **enabled with explicit "allow all" policies**
(`supabase/migrations/0007_rls_allow_all.sql`) instead of being left
without RLS, so this is documented as a conscious decision — the `anon
key` travels embedded in the APK, so anyone with the APK can read/write.
If multi-team support or protecting data from outsiders is needed in the
future, auth (magic link or anonymous) will need to be added and a
`group_id` reintroduced per row.

## Table schema

See the complete DDL in `supabase/migrations/0001` through `0007`.
Summary:

- **`participantes`**: soft delete (`eliminado_en`), never deleted if it
  has history.
- **`productos` + `condicion_producto`**: replaces hardcoded soda/cups.
  Each product has a condition (frequency, minimum present, cost, whether
  it avoids repeating the previous period).
- **`producto_exclusiones`**: generalizes the rule "whoever brings cups
  doesn't buy soda that week" to any pair of products.
- **`semana_generada` + `semana_participantes`**: configuration and state
  of each week (`planificada`/`en_curso`/`completada`, derived in code by
  `WeekStateService`, not blindly trusted from the column).
- **`presencia_dia`**: who had lunch each day.
- **`asignacion_diaria` / `asignacion_semanal`**: assignments for the
  **active** week only (planned or in progress).
- **`historico`**: append-only, source of truth for past fair
  distribution. Filled in when a week transitions to `completada`.

See [02-business-rules.md](02-business-rules.md) for how the rules
engine uses these tables, and [04-data-model.md](04-data-model.md) for
the equivalent domain entities.

## Sync strategy

1. **Remote as source of truth** (implemented): `load()` reconstructs
   the complete aggregate from Supabase (including `historico` folded
   into `assignments` so fairness can see it); `save()` upserts the live
   tables. `shared_preferences` remains a best-effort offline-startup
   fallback (`ShiftsSupabaseRepository` falls back to it if Supabase
   doesn't respond).
2. **Realtime** (pending, next phase): subscription to changes in the
   live tables so two phones see the current week update live.
3. **Offline-first** (pending, later): a mutation queue with per-row
   last-write-wins.

## Local state migration

`LocalToSupabaseMigration` (see the source file for the complete detail)
reads the `shared_preferences` blob, seeds `participantes`/`productos`/
`condicion_producto`/`producto_exclusiones` with the MVP values, creates
a `semana_generada` (`completada`) for each week that existed, and dumps
every past assignment directly into `historico` (never into the "live"
tables, which are only for the active week). It verifies that the
`historico` counts match exactly what `FairPickerService` computed over
the local blob before considering itself successful.

It is not a `dart run` script: `shared_preferences` needs Flutter's
binding and the device's platform channel, so it's invoked from inside
the app (for example, a temporary button in Settings).
