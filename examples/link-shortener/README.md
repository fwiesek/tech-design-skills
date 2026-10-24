# Example: self-hosted link shortener

A design produced by running the tech-design skills end to end on the goal "self-hosted link shortener with analytics". The user's answers to intake and grilling rounds were the skills' recommended answers.

| Step | Skill | Result |
| --- | --- | --- |
| 0 | start | Base design: 4 components, 3 key flows, ADR 0001, backlog Q1–Q6, R1–R2 |
| 1 | refine: analytics | Click buffer, 302 redirects, no-PII retention; ADRs 0002–0004; detail split into `areas/analytics.md` |
| 2 | refine: auth | Built-in member accounts; ADR 0005; Access control section |
| — | review | **Not ready**: criterion 4 unproven, stale component row, no backups (R3) |
| 3 | refine: ops | Deployment section, GeoIP updater, Litestream backups; ADR 0006 |
| 4 | refine: links | Custom codes, disable/expire, 404/410 behaviour |
| — | review | Ready |
| — | publish | `docs/architecture/` |

Each step is its own commit, so `git log -p -- examples/link-shortener` replays the loop.

- **Working design:** [`docs/design/link-shortener/`](docs/design/link-shortener/)
- **Published docs:** [`docs/architecture/`](docs/architecture/)
