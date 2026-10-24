# 0002. Redirect with 302, never cached

**Status:** accepted
**Date:** 2026-10-25

## Context

Analytics must count every click. Browsers and proxies cache a `301` indefinitely, so repeat visits never reach the server. Links may also be edited to point somewhere new.

## Decision

Short links answer `302 Found` with `Cache-Control: private, max-age=0`.

## Alternatives considered

- **301 Moved Permanently**: marginally faster for repeat visitors and passes SEO weight, but hides repeat clicks and makes edits sticky in visitors' browsers.
- **307 Temporary Redirect**: same caching behaviour as 302 and preserves the method, but short links are only ever GET, so it adds nothing.

## Consequences

- Every click reaches the server and is counted; edited targets take effect immediately.
- Each repeat visit costs a round-trip to our server, which is cheap at this scale.
