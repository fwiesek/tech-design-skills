# 0001. SQLite is the only data store

**Status:** accepted
**Date:** 2026-10-25

## Context

The system runs on one small VPS with one maintainer and no paid services. Volume is ~1k links and ~100k clicks a month, with write peaks around 50/s. The store must hold links and click events and answer simple per-link aggregations.

## Decision

Use one SQLite database file in WAL mode on a Docker volume, accessed only by the app process.

## Alternatives considered

- **PostgreSQL container**: more headroom and concurrent writers, but a second service to run, upgrade and back up, for a load SQLite handles comfortably.
- **SQLite for links + a time-series store for clicks**: better analytics queries at scale, but two stores at a scale where one suffices.

## Consequences

- One file to back up; no extra containers.
- Only one app instance can write, so scaling out means a migration to a server database.
- Writes are serialised, so the redirect path must keep write transactions short.
