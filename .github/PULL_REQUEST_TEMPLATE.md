## What this changes

<!-- A sentence or two. Link the issue if there is one: Fixes #123 -->

## How it was tested

<!-- e.g. new unit tests in skeetyeet_core, ran against the local dev environment, tried on macOS -->

## Checklist

- [ ] `dart test` passes in `packages/skeetyeet_core`, and `flutter test` passes in `app`
- [ ] Anything that deletes or unfollows is covered by a test, and can't run without the user's confirmation
- [ ] No tracking, analytics or new network destinations beyond the user's own PDS and Bluesky's services
