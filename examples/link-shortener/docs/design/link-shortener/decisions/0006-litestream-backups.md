# 0006. Continuous off-host backups with Litestream

**Status:** accepted
**Date:** 2026-10-25

## Context

All state is one SQLite file on one VPS disk (ADR 0001). Losing that disk loses every link, which breaks every short link already shared, and all analytics history. There's no budget for paid services, and the one maintainer needs a restore they can run from memory.

## Decision

Run Litestream as a sidecar container that continuously replicates the SQLite WAL to an S3-compatible bucket on a free tier (Backblaze B2, well under its 10 GB free allowance), with 30 days of snapshots kept. To restore, run `litestream restore` into the data volume before starting the App.

## Alternatives considered

- **Nightly `VACUUM INTO` on the same disk**: trivial to set up, but useless when the disk itself is lost.
- **VPS provider snapshots**: whole-machine and easy, but paid on most providers, daily at best, and tied to the provider.
- **Nightly `sqlite3 .backup` + restic to the bucket**: works, but loses up to a day of data and needs a scheduler plus two tools instead of one.

## Consequences

- RPO is about one second; RTO is minutes (restore, then `docker compose up`).
- The bucket credentials are a secret on the VPS, kept in `.env` and never in the repo.
- The bucket is an external dependency, but only for backup: the system serves traffic without it.
