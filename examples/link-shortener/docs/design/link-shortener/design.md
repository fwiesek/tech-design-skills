---
title: Self-hosted link shortener
slug: link-shortener
kind: greenfield
status: refining
builds-on: []
updated: 2026-10-25
---

# Self-hosted link shortener

## Goal

A link shortener for a small team, self-hosted on our own VPS, that turns long URLs into short `go.example.com/<code>` links and shows how each link is used, without sending visitor data to a third party.

Success criteria:

- [ ] A team member creates a short link from the web UI or the API in under 1 s.
- [ ] Visiting a short link redirects with server-side latency p95 < 50 ms at 50 req/s.
- [ ] Per-link analytics show clicks per day, top referrers and top countries.
- [ ] The whole system runs on one 2 vCPU / 4 GB VPS with `docker compose up`.

## Non-goals and constraints

**Non-goals:** public sign-up / multi-tenant SaaS, per-user custom domains, link-in-bio pages, real-time dashboards, QR code generation.

**Constraints:**

- One VPS (2 vCPU, 4 GB RAM), Docker Compose, one maintainer.
- TypeScript on Node.js; no paid external services.
- Scale: ~1k links, ~100k redirects/month, peaks of 50 req/s.

## Context

```mermaid
flowchart LR
  member([Team member])
  visitor([Visitor])
  geo[[GeoLite2 database]]
  subgraph sys [Link shortener]
    app[Link shortener]
  end
  member -->|"manages links, reads analytics · HTTPS"| app
  visitor -->|"opens short link · HTTPS"| app
  app -->|"looks up country · local file"| geo
```

- **Team member**: creates and manages links, reads analytics.
- **Visitor**: anyone opening a short link; never logs in.
- **GeoLite2 database**: MaxMind's free IP-to-country file, read locally, so no visitor data leaves the server.

## Components

```mermaid
flowchart LR
  member([Team member])
  visitor([Visitor])
  geo[[GeoLite2 database]]
  subgraph sys [Link shortener]
    proxy[Reverse proxy<br/>Caddy]
    app[App<br/>Node.js · Hono]
    ui[Admin UI<br/>static SPA]
    db[(Database<br/>SQLite)]
  end
  member -->|"loads UI · HTTPS"| proxy
  visitor -->|"GET /code · HTTPS"| proxy
  proxy -->|"forwards · HTTP"| app
  app -->|"serves · HTTP"| ui
  ui -->|"calls API · HTTPS/JSON"| proxy
  app -->|"reads/writes · SQL"| db
  app -->|"country lookup · mmdb"| geo
```

| Component | Responsibility | Tech |
| --- | --- | --- |
| Reverse proxy | TLS termination, HTTP→HTTPS, forwards everything to the app | Caddy |
| App | Redirects (from an in-memory link cache), link CRUD API, analytics API, member auth, click buffer, nightly rollup job, serves the admin UI, member CLI | Node.js, Hono |
| Admin UI | Create/edit links, view analytics | Static SPA served by the app |
| Database | Links and clicks | SQLite file on a Docker volume |

## Data

```mermaid
erDiagram
  MEMBER ||--o{ LINK : creates
  MEMBER ||--o{ SESSION : has
  MEMBER ||--o{ API_TOKEN : has
  LINK ||--o{ CLICK : receives
  LINK ||--o{ CLICK_DAILY : "rolled up into"
  MEMBER {
    integer id PK
    text email
    text password_hash
  }
  SESSION {
    text id_hash PK
    integer member_id FK
    datetime expires_at
  }
  API_TOKEN {
    text token_hash PK
    integer member_id FK
    text label
  }
  LINK {
    text code PK
    text target_url
    integer created_by FK
    datetime created_at
  }
  CLICK {
    integer id PK
    text code FK
    datetime at
    text referrer_host
    text country
    boolean is_bot
  }
  CLICK_DAILY {
    text code PK
    date day PK
    text referrer_host PK
    text country PK
    boolean is_bot PK
    integer count
  }
```

| Entity | Owner | Store | Notes |
| --- | --- | --- | --- |
| Member | App | SQLite | Handful of rows; argon2id hash; created via CLI |
| Session | App | SQLite | Opaque ID, stored hashed; 30-day sliding expiry |
| API token | App | SQLite | Shown once, stored as SHA-256 hash |
| Link | App | SQLite | ~1k rows; `code` is 7 random base62 chars; cached in App memory |
| Click | App | SQLite | Raw events, ~100k/month, kept 90 days; no IP or user agent stored |
| Click daily | App | SQLite | Per-day aggregates, kept indefinitely |

Capture, retention and query detail: [areas/analytics.md](areas/analytics.md).

## Key flows

### Create a link

Proves: create a link in under 1 s.

```mermaid
sequenceDiagram
  actor Member as Team member
  participant UI as Admin UI
  participant App
  participant DB as Database
  Member->>UI: paste long URL
  UI->>App: POST /api/links {target_url} + session cookie
  App->>DB: look up session
  App->>App: validate target is http(s), generate code
  App->>DB: INSERT link
  App-->>UI: 201 {code, short_url}
```

### Follow a link

Proves: redirect p95 < 50 ms. The click write happens off the redirect path ([analytics](areas/analytics.md#click-capture)).

```mermaid
sequenceDiagram
  actor Visitor
  participant App
  participant Geo as GeoLite2 database
  participant DB as Database
  Visitor->>App: GET /{code}
  App->>App: target from link cache
  App->>Geo: country for IP
  App->>App: push click to buffer
  App-->>Visitor: 302 Location: target_url
  App->>DB: flush buffered clicks (every 1 s / 200 events)
```

### View analytics

Proves: clicks per day, top referrers, top countries.

```mermaid
sequenceDiagram
  actor Member as Team member
  participant UI as Admin UI
  participant App
  participant DB as Database
  Member->>UI: open link stats
  UI->>App: GET /api/links/{code}/stats
  App->>DB: CLICK_DAILY for past days + CLICK for today, bots excluded
  App-->>UI: stats JSON
```

## Access control

- **Public:** `GET /{code}` only. Everything under `/api/*` and `/admin/*` needs a member session cookie or an API token. See [ADR 0005](decisions/0005-built-in-accounts.md).
- **Members** are added, removed and reset with `app member add|remove|reset <email>`. There's no sign-up, so link creation is never open to the public.
- **Mutating API calls** need `Content-Type: application/json`. Combined with `SameSite=Lax` cookies, this blocks cross-site form posts.
- **Targets** must be `http` or `https` URLs. Every link records its creator, so abuse can be traced and the link disabled.
- **Login** is limited to 5 failures per 15 min per email and IP, tracked in App memory.

## Decisions

| # | Decision | Choice | ADR |
| --- | --- | --- | --- |
| 1 | Primary store | SQLite on a volume, single node | [0001](decisions/0001-sqlite-as-the-only-store.md) |
| 2 | Code format | 7 random base62 chars, retry on collision (3.5 × 10¹² space vs ~1k links) | — |
| 3 | Process layout | One app process serves redirects, API and UI; split only if the redirect path needs it | — |
| 4 | Geo lookup | Local GeoLite2 file, keeps visitor IPs on the server | — |
| 5 | Redirect status | 302, not cacheable, so every click is counted | [0002](decisions/0002-redirect-with-302.md) |
| 6 | Click write path | In-memory buffer, batch flush; up to ~1 s of clicks lost on crash | [0003](decisions/0003-buffer-click-writes.md) |
| 7 | Visitor data | No IP/UA stored; raw clicks 90 days, daily rollups forever | [0004](decisions/0004-click-retention.md) |
| 8 | Member auth | Built-in accounts, session cookies for the UI, hashed API tokens for scripts | [0005](decisions/0005-built-in-accounts.md) |

## Open questions and risks

- [x] **Q1** (blocking) How are clicks recorded without slowing the redirect? — _area: analytics_ — settled in ADR 0003
- [x] **Q2** (blocking) How do team members authenticate to the UI and API? — _area: auth_ — settled in ADR 0005
- [x] **Q3** (major) 301 or 302 redirect? — _area: analytics_ — settled in ADR 0002
- [x] **Q4** (major) What visitor data is stored, and for how long? — _area: analytics_ — settled in ADR 0004
- [ ] **Q5** (minor) How is the SQLite file backed up? Tracked by R3. — _area: ops_
- [ ] **Q6** (minor) Should members be able to choose custom codes? If so, they must not collide with `api`, `admin` or `login`. — _area: links_
- [ ] **Q7** (major) Can links be disabled or expire, and what does a visitor see for an unknown or disabled code? Access control already assumes abusive links can be disabled. — _area: links_
- [ ] **Q8** (minor) How is the GeoLite2 file kept up to date (MaxMind licence key, refresh schedule)? — _area: ops_
- [x] **R1** (major) Bots and link-preview crawlers inflate click counts. — _area: analytics_ — mitigation: clicks flagged `is_bot` and excluded from stats by default (areas/analytics.md)
- [ ] **Q9** (blocking) Success criterion 4 is unproven: no section describes the Compose services, volumes, config and secrets that make `docker compose up` work. — _area: ops_
- [ ] **Q10** (minor) The Database component row says "Links and clicks", but it also holds members, sessions, tokens and rollups. — _area: ops_
- [ ] **Q11** (minor) If the App is down at rollup time, that day is never rolled up and its raw clicks expire at 90 days. — _area: analytics_
- [ ] **Q12** (minor) What gets stored as the country when the GeoIP lookup fails (private IP, missing file)? — _area: analytics_
- [x] **R2** (major) The shortener is abused to disguise phishing or malware links. — _area: auth_ — mitigation: members-only creation, http(s) targets only, creator recorded per link (Access control)
- [ ] **R3** (major) Losing the VPS disk loses every link and all analytics history: there's no backup. — _area: ops_ — mitigation: none yet
