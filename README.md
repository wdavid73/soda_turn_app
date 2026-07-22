# SodaTurn (turn_soda)

Flutter app to decide who buys the lunch **soda** every business day and
who buys the week's **cups**, with fair rotation, business rules, and
local persistence.

- 📚 **Full documentation**: [docs/](docs/README.md)
- 🎨 **Mockups and design system**: [design/](design/)

## Running the project

Requires Flutter (the project uses FVM, `stable` channel):

```bash
fvm flutter pub get
fvm flutter run       # Android emulator or device
```

## Quality

```bash
fvm flutter analyze
fvm flutter test
```

## Stack

Flutter + Riverpod (StateNotifier) + GoRouter + dartz, feature-first
Clean Architecture, persistence with `shared_preferences` (phase 2
planned: Supabase — see [docs/06-supabase-roadmap.md](docs/06-supabase-roadmap.md)).
