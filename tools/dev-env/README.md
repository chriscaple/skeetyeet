# Local AT Protocol test network

SkeetYeet's integration tests must never touch real Bluesky accounts. Instead, they run against a throwaway local network: a PLC directory, a PDS and an app view, all on your machine.

Bluesky's [`atproto`](https://github.com/bluesky-social/atproto) repo ships this as `packages/dev-env`.

> **Status:** these instructions are the starting point for Phase 0's test harness. They haven't been wired into CI or the core package yet.

## Running it

Requires Node.js 18+, pnpm and Docker (the dev env uses Postgres and Redis containers).

```sh
cd tools/dev-env
git clone --depth 1 https://github.com/bluesky-social/atproto.git   # git-ignored
cd atproto
make deps
make build
make run-dev-env
```

The dev env prints the local PDS URL and creates test accounts (`alice.test`, `bob.test` and others). Point SkeetYeet's integration tests at that PDS URL.

## Next steps

- Seed script: create accounts with posts, replies, quotes, reposts, likes, follows and media covering every filter in SCOPE.md.
- `skeetyeet_core` integration tests that run a full scan → select → archive → delete cycle against the seeded accounts.
- A CI job that starts the dev env in a container.
