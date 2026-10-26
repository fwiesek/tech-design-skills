<img src="assets/icon.svg" width="64" height="64" alt="">

# tech-design-skills

Agent skills for designing technical architecture iteratively and producing documentation for it.

The loop: start a **small base design** that covers a goal end to end, refine it **one area at a time**, review it for readiness, then publish clean docs.

```
start ──► refine ──► refine ──► … ──► review ──► publish
            ▲                           │
            └──── findings → backlog ◄──┘
```

| Skill | Does | Writes |
| --- | --- | --- |
| `start` | One intake round, then a complete thin v0 | `docs/design/<slug>/design.md`, `iterations.md` |
| `refine` | Proposes ranked targets, grills you on the one you pick until it's settled, writes it back | design sections, `decisions/NNNN-*.md`, `areas/*.md`, `iterations.md` |
| `review` | Readiness checks plus a critique; accepted findings go to the backlog | the design's Open questions and risks |
| `publish` | Engineering doc + stakeholder one-pager + index | `docs/architecture/` |

Designs are Markdown with Mermaid diagrams, living in the repo they describe. Two layers:

- **Working design** (`docs/design/<slug>/`): one folder per goal, with a backlog of open questions and risks, ADRs, and an iteration log, so a new session picks up where the last one stopped.
- **Published docs** (`docs/architecture/`): generated from the working design, never edited by hand.

The full rules (layout, sections, statuses, readiness checks, diagram style) are in [`conventions/CONVENTIONS.md`](conventions/CONVENTIONS.md). For a worked example (start, four refines, two reviews, publish), see [`examples/link-shortener/`](examples/link-shortener/).

## Install

### Claude Code

```
/plugin install tech-design --marketplace fwiesek/tech-design-skills
```

Or add the marketplace first (`/plugin marketplace add fwiesek/tech-design-skills`, or a local path to this repo), then `/plugin install tech-design@tech-design-skills`.

Invoke them explicitly as `/tech-design:start`, `/tech-design:refine`, `/tech-design:review` and `/tech-design:publish`, or just say "let's design …", "refine the design" or "publish the architecture docs".

### Other agents (Codex, …) or a plain skills folder

```sh
scripts/install-portable.sh ~/.agents/skills   # or your agent's skills directory
```

This copies each skill as `tech-design-<skill>`, with a self-contained folder and a unique name. The skills only need file read/write. Subagents and structured question tools get used when the harness has them.

## Developing

`conventions/CONVENTIONS.md` is canonical. Each skill folder carries a copy so it works standalone. After editing the canonical file:

```sh
scripts/sync-conventions.sh          # copy into every skill
scripts/sync-conventions.sh --check  # fail if any copy has drifted
```

`examples/link-shortener/` was produced by running the skills, and serves as the regression fixture. When you change a skill, re-run it on the example and review the diff. To check diagrams, render them all: `npx -p @mermaid-js/mermaid-cli mmdc -i <file> -o /tmp/out.md`.
