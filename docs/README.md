# Documentation — SodaTurn (turn_soda)

Flutter app to decide, Monday through Friday, who buys the lunch **soda**
(~$7,000 COP) and who buys the **cups** (once a week), with fair rotation,
business rules, and local persistence.

| Document | Content |
|---|---|
| [01-contexto.md](01-contexto.md) | Goal, participants, and project history (web v1/v2 → Flutter) |
| [02-business-rules.md](02-business-rules.md) | The 9 v2 rules, their strictness, and warning behavior |
| [03-architecture.md](03-architecture.md) | Clean Architecture, folder structure, Riverpod, and the Either/Failure flow |
| [04-data-model.md](04-data-model.md) | Entities, persisted JSON schema (web v2 compatible), and storage key |
| [05-design-system.md](05-design-system.md) | SodaTurn design system and its mapping to `ThemeData` |
| [06-supabase-roadmap.md](06-supabase-roadmap.md) | Phase 2: cloud persistence with Supabase (implemented, still needs your project connected) |
| [07-colombian-holidays.md](07-colombian-holidays.md) | Local Colombian holiday calculator (Emiliani Law + Easter) |

## Quick commands

The project uses FVM (`stable` channel):

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run          # Android device/emulator
```

## MVP scope

Includes: generating the week, the complete v2 rules, locks 🔒, manual
editing with warnings, participant management, and statistics.

## Phase 2 (this state of the repo)

Generic product model (v3 rules, see
[02-business-rules.md](02-business-rules.md)), Colombian holidays,
generation strictly for the current day (never whole weeks ahead of time),
and Supabase backend — see
[06-supabase-roadmap.md](06-supabase-roadmap.md) to connect your own
project.

**Pending** (next phases): Settings screen (export/import backup, reset
data, dark mode), the mockup's History tab, Realtime, and offline-first
sync.
