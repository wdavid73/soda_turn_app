# SodaTurn (turn_soda)

Flutter app to decide who buys the lunch **soda** every business day and
who buys the week's **cups**, with fair rotation, business rules, and
cloud persistence.

- 📚 **Full documentation**: [docs/](docs/README.md)
- 🎨 **Mockups and design system**: [design/](design/)

## Features

- Fair, rule-based automatic assignment (see
  [How day assignment works](#how-day-assignment-works) below) plus
  always-available manual override.
- Cloud backend on Supabase with Realtime sync for the active week and
  a Historial tab with completed weeks grouped by month.
- Push notifications (FCM) with per-device registration and a daily
  "who's up today" reminder.
- Colombian holiday awareness (Emiliani Law + Easter) when computing
  generable business days.
- Runs on Android and Web from the same codebase, with
  platform-specific screens/widgets where needed.

## Running the project

Requires Flutter (the project uses FVM, `stable` channel):

```bash
fvm flutter pub get
fvm flutter run       # Android emulator or device
fvm flutter run -d chrome   # Web
```

## Quality

```bash
fvm flutter analyze
fvm flutter test
```

## Stack

Flutter + Riverpod (StateNotifier) + GoRouter + dartz, feature-first
Clean Architecture, cloud persistence and Realtime sync with Supabase
(see [docs/06-supabase-roadmap.md](docs/06-supabase-roadmap.md)),
push notifications via Firebase Cloud Messaging.

## How day assignment works

Each generable day (business day, skipping weekends and Colombian
holidays) needs a participant assigned per product (soda daily, cups
weekly). Two ways to set it:

### Auto-assign

Tapping **"Auto-asignar"** runs `ShiftsEngine.autoAssignProducto`,
which narrows the pool of candidates in order until one is left:

1. **Presence** — start from whoever is marked present that day (or,
   for weekly products, the union of everyone present across the
   week).
2. **Exclusions** — remove anyone who already holds a product that's
   configured as mutually exclusive with this one.
3. **Minimum present** — daily products require a configured minimum
   headcount; below it, the day is left unassigned with a warning.
4. **Don't repeat the previous period** — soft filter, skipped if it
   would empty the pool.
5. **Weekly balance** — prefer whoever has had the product the fewest
   times *this week*, so it doesn't stack disproportionately on one
   person.
6. **Historical fair distribution** — the final and decisive rule:
   whoever has had the product the fewest times across all recorded
   history (ties broken randomly) wins.

The full rule set, strictness (hard/soft), and warning behavior are
documented in [docs/02-business-rules.md](docs/02-business-rules.md).

In the UI, auto-assign spins an on-screen wheel ([spin_wheel.dart](lib/features/shifts/presentation/widgets/spin_wheel.dart))
while the real assignment resolves in the background, then decelerates
and lands exactly on the winner — so the animation never has to "jump"
once the actual pick comes back from Supabase. A single present
participant skips the wheel and assigns directly. A checkmark
confirmation animation plays once the assignment saves successfully.

### Manual edit

Any participant can be picked by hand from the day's chip list at any
time — manual edits are never blocked, only warned about if they
break a rule (e.g. picking someone who isn't marked present). Setting
a weekly product manually also releases and reassigns any daily
products left in conflict by exclusion rules.
