# Iterations: Self-hosted link shortener

## 0. 2026-10-25 — base design

- **Changed:** created design.md (all sections)
- **Decided:** ADR 0001; Decisions rows 2–4
- **New open items:** Q1–Q6, R1–R2

## 1. 2026-10-25 — analytics

- **Changed:** Data (new fields, CLICK_DAILY), Follow a link and View analytics flows, Components (link cache, click buffer, rollup job in App); detail moved to areas/analytics.md
- **Decided:** ADRs 0002, 0003, 0004; Decisions row 5
- **New open items:** Q7, Q8

## 2. 2026-10-25 — auth

- **Changed:** new Access control section; Data (Member, Session, API token, Link.created_by); Create a link flow; App component row
- **Decided:** ADR 0005; Decisions row 8
- **New open items:** none (Q6 extended with reserved paths)
