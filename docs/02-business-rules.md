# Business rules (v3 — generic products)

Implemented in [shifts_engine.dart](../lib/features/shifts/domain/services/shifts_engine.dart)
and verified by [shifts_engine_test.dart](../test/features/shifts/domain/shifts_engine_test.dart).

> The 9 v2 rules (hardcoded soda/cups) were generalized to
> **any product** configured in `products`/`product_condition`.
> Soda and cups remain the only two default products, but they are now
> data rows, not special cases in code.

**Rule strictness:**

- **Hard**: the automatic algorithm never violates it.
- **Soft**: it relaxes with a warning if there is no alternative.
- Any rule can be broken **manually** (rule 8): the app allows it and
  shows the warning; the user has the final say.

| # | Rule | Strictness | Before (v2) |
|---|---|---|---|
| 1 | **Minimum `min_present` present** to assign a daily product. If not met, the period is left unassigned and a warning is shown. | Hard (auto) | Fixed minimum of 4 for soda |
| 2 | **No one repeats a daily product in the next generable period** (business day, not a holiday; crosses weekends **and Colombian holidays**). | Soft | Only crossed weekends |
| 3 | **Weekly/monthly products are assigned only once per period**, chosen among the union of participants present on the period's generable days. | — | Cups, once a week |
| 4 | **Configurable exclusion between products** (`product_exclusions`): whoever has one product cannot have the other within the configured scope. | Hard or soft depending on the row | Cups excluded soda that week, hardcoded |
| 5 | **Historical fair distribution**: whoever has had that product the fewest times in the entire history (`historical` + live assignments) always wins. Ties are broken randomly. | — | Same, but only for soda/cups |
| 5b | **Weekly balance** (new): before the historical fair distribution, whoever has had the product the fewest times IN THE CURRENT WEEK is preferred; this is only ignored if it would empty the pool. The complete history (rule 5) remains the final tiebreaker — see "Reconciliation" below. | Soft | Did not exist |
| 6 | When automatically choosing a product, **avoid repeating whoever had it the previous period** (`avoid_repeating_previous_period`). | Soft | Only cups vs. the previous week |
| 7 | **Lock 🔒** per product and period; "Generate" does not overwrite it. | — | Same |
| 8 | **Manual editing** always allowed; the system warns instead of blocking. Manually setting a weekly product releases and reassigns any excluded daily products left in conflict (locked ones are only flagged with a warning). | — | Same |
| 9 | **Cost**: per product (`cost_cop`, nullable). Only soda has a cost today; other products are counted by frequency, not money. | — | Only soda, hardcoded to $7,000 |
| 10 | **A full week is never generated in advance** (new): participants and a week's date range are configured ahead of time, but "Generate" only computes the pending generable periods up to today (with catch-up for skipped days, never future ones). See `WeekStateService` and `ShiftsEngine.generateToday`. | Hard | Did not exist (`generateWeek` used to generate all 5 days at once) |
| 11 | **Colombian holidays** (new) count as non-generable, just like weekends: nothing is assigned that day. Calculated locally (Emiliani Law + Easter), see [07-colombian-holidays.md](07-colombian-holidays.md). | Hard | Did not exist |

## Generation order (`ShiftsEngine.generateToday`)

1. **Week defaults** (`ensureWeekDefaults`): creates the `generated_week`
   (active participants by default) and each generable day's default
   presence, if missing.
2. **Week state** (`WeekStateService.stateOf`): if today is before
   Monday, it does nothing (`planned`); if the last generable day has
   already passed, it also does nothing (`completed`, see rule 10).
3. **Weekly/monthly products** (once, if they still have no owner):
   `autoAssignProduct` with the pool = union of participants present
   during the week.
4. **Daily products**, day by day in chronological order, for every
   generable day ≤ today not yet assigned (catch-up): `autoAssignProduct`
   with the pool = participants present that day.

`autoAssignProduct` runs, in order: pool by presence → exclusions
(`product_exclusions`) → minimum present (rule 1, daily only) →
don't repeat the previous period (rule 6) → weekly balance (rule 5b,
daily only) → historical fair distribution (rule 5).

## Reconciliation: weekly balance (5b) vs. historical fair distribution (5)

Historical fair distribution remains the ultimate source of truth. Weekly
balance is a **soft filter applied earlier**, similar in spirit to rule 6:
it narrows the pool to whoever has the lowest count of this product IN
THE CURRENT WEEK, and it is only ignored if that would empty the pool.
This way, "no one gets stuck with the product twice in a week
disproportionately" is a preference, not a parallel metric competing
with the full history — it prevents someone who is genuinely behind
across the whole history from losing out to someone who simply hasn't
had a turn this week.

The weekly count excludes days before each participant's `added_at` in
`week_participants`, so as not to penalize someone who joined the week
late.

## Fairness details

- Counts consider **the entire saved history** (the `historical` table
  plus the current week's live assignments), not just the visible week;
  the history is intentionally unbounded.
- When re-generating, the period's current pick is subtracted before
  counting, so as not to bias the re-selection.
- Ties are resolved with `Random` (injectable for deterministic tests).

## Warnings (messages)

Constants in `ShiftsEngine`: minimum present, no candidates, relaxation
of "don't repeat previous period," exclusion conflict (locked or not),
week with no one present. Manual editing composes messages for each
broken rule.
