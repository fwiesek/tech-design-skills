# 0003. Buffer click writes off the redirect path

**Status:** accepted
**Date:** 2026-10-25

## Context

The redirect must stay under 50 ms p95 at 50 req/s. SQLite serialises writes (ADR 0001), so one synchronous insert per redirect puts every visitor behind the write lock and fsync.

## Decision

The redirect handler pushes click events to an in-memory buffer and responds right away. The buffer flushes in one transaction every 1 s or 200 events, and on graceful shutdown.

## Alternatives considered

- **Synchronous insert per redirect**: simplest and lossless, but it couples redirect latency to disk writes and lock contention.
- **External queue (Redis, NATS)**: durable and decoupled, but a second service to run for one maintainer and no real need at this volume.
- **Append to a log file, ingest later**: durable, but a second ingestion pipeline to build and monitor.

## Consequences

- Redirect latency is independent of the database's write path.
- A crash or kill -9 loses at most ~1 s of clicks. Accepted: analytics are indicative, not billing-grade.
- Only one App instance can own the buffer, which matches the single-node constraint.
