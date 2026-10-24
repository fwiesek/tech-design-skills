# 0004. Store no IPs; keep raw clicks 90 days, rollups forever

**Status:** accepted
**Date:** 2026-10-25

## Context

Analytics need clicks per day, referrers and countries. Storing visitor IPs or full user agents makes the click table personal data, with GDPR obligations, for no gain in those three views. Raw clicks also grow without bound.

## Decision

- Derive country and `is_bot` in memory, then discard IP and user agent. Store the referrer host, never the full URL.
- Keep raw `CLICK` rows for 90 days. A nightly job rolls them into `CLICK_DAILY` (code, day, referrer host, country, is_bot → count), which is kept indefinitely.

## Alternatives considered

- **Store raw IP and UA**: allows unique-visitor counts and later re-analysis, but makes the database personal data for metrics nobody asked for.
- **Hash the IP for unique visitors**: still personal data under GDPR when the salt is static; rotating salts add complexity for a metric outside the goal.
- **Raw clicks forever**: simplest, but unbounded growth and slower stats over time.

## Consequences

- The database holds no visitor personal data, so there is nothing to export or delete on request.
- Unique-visitor counts are impossible. Revisit only with a new goal.
- Stats older than 90 days are per-day granularity only.
