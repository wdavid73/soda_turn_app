# Colombian holidays

Implemented in
[colombian_holidays.dart](../lib/core/utils/colombian_holidays.dart),
with no external dependencies or static table to maintain by hand — it's
calculated algorithmically, works offline, and requires no yearly
updates.

## Categories

1. **Fixed** (never move, even on weekends): New Year's Day (Jan 1),
   Labor Day (May 1), Independence Day (Jul 20), Battle of Boyacá (Aug
   7), Immaculate Conception (Dec 8), Christmas (Dec 25).
2. **Emiliani Law** (Law 51 of 1983): if the civil date doesn't fall on a
   Monday, it's moved to the following Monday. Epiphany (Jan 6), Saint
   Joseph's Day (Mar 19), Saint Peter and Saint Paul (Jun 29), Assumption
   of Mary (Aug 15), Columbus Day (Oct 12), All Saints' Day (Nov 1),
   Cartagena's Independence Day (Nov 11).
3. **Movable** (depend on Easter, calculated with the Gauss/computus
   algorithm): Holy Thursday (Easter − 3 days) and Good Friday (Easter −
   2 days) **are not moved**; Ascension (Easter + 39), Corpus Christi
   (Easter + 60), and Sacred Heart (Easter + 68) do apply the Emiliani
   Law (they move to the following Monday).

It's normal for two "Emiliani"/movable holidays to coincide on the same
date in some years (e.g. 2025: Saint Peter and Saint Paul and Sacred
Heart both fall on June 30) — the calculation is correct; the official
Colombian calendar simply also reports that day as a double holiday.

## How it's used

`AppDateUtils.esDiaGenerable(iso)` combines business day (Monday-Friday)
and non-holiday. It's the integration point with the rules engine: a
holiday is treated exactly like a weekend — no assignment row is created
that day, with no need for an "is holiday" column in the database (the
absence of a row already says so). `previousGenerableDay`/
`nextGenerableDay` extend the concept of "previous/next business day"
(rules 2/6) to also skip holidays, not just weekends.

## Verification

`test/core/utils/colombian_holidays_test.dart` verifies the complete
official 2024 calendar (18 holidays), the 2025 coincidence, and general
properties (Emiliani shifts always fall on a Monday, Holy Thursday and
Good Friday are 3 and 2 days before Easter) against known dates from the
real Colombian calendar.
