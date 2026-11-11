# Contributing to SkeetYeet

Thanks for helping people let go of their old posts! Here's how to get going.

## Ground rules

- **Safety first.** SkeetYeet deletes things that can't be brought back. Any code that deletes or unfollows must be covered by tests, and must never run without the user's explicit confirmation.
- **Privacy always.** No analytics, tracking, crash reporting or new network destinations. The app talks only to the user's own PDS and Bluesky's public services.
- **Never use real accounts in tests.** Use fixtures, or the local network in [`tools/dev-env`](tools/dev-env).

## Setup

Install [Flutter](https://docs.flutter.dev/get-started/install) (stable), then:

```sh
cd packages/skeetyeet_core && dart pub get && dart test
cd ../../app && flutter pub get && flutter test
```

## Before you open a pull request

Run these in both `packages/skeetyeet_core` and `app`:

```sh
dart format .
dart analyze      # or: flutter analyze, in app/
dart test         # or: flutter test, in app/
```

CI runs the same checks, and builds the app for Android, iOS, macOS and Windows.

## Where things go

- Protocol logic, filters, jobs and archive code go in `packages/skeetyeet_core`, with no Flutter imports, so they can be tested quickly.
- UI goes in `app/lib`.
- Brand changes go in `brand/`. Regenerate the app icons afterwards with `dart run flutter_launcher_icons` in `app/`.

## Tone

User-facing copy follows the brand voice in [SCOPE.md](SCOPE.md#brand-and-tone): warm, playful and never preachy. Confirmation screens for destructive actions are the exception: they stay plain and exact.

## Licence

By contributing, you agree that your contributions are licensed under the [MIT licence](LICENSE).
