<p align="center">
  <img src="brand/logo/logo.png" alt="SkeetYeet" width="420">
</p>

<p align="center"><strong>Yeet your old skeets. Keep the memories. Go touch grass.</strong></p>

SkeetYeet is a free, open-source app for iOS, macOS, Android and Windows that bulk-deletes posts, reposts, replies and likes, and bulk-unfollows accounts, across one or more [Bluesky](https://bsky.app) accounts. It uses filters you combine, saves a copy first, and runs entirely on your device: no server, no analytics, no tracking.

Website: **[skeetyeet.app](https://skeetyeet.app)**

> **Status: early development (Phase 0).** The core filter engine, app shell, brand and website are in place. Sign-in and deletion arrive in Phase 1. See [SCOPE.md](SCOPE.md) for the full plan.

## What it will do

- **Bulk delete** posts, replies, quote posts, reposts and likes, with pause and resume.
- **Filter** by date range, target account, keywords, regex, hashtags, linked domains, images, video, GIFs, language, missing alt text and engagement. Combine them with AND / OR / NOT, and add "keep" rules that always win.
- **Bulk unfollow**: everyone, specific accounts, inactive accounts, or accounts that don't follow back.
- **Archive before deleting**, and **export your whole account** (repo CAR, media, JSON and DMs) to a folder you can browse offline.
- **Multiple accounts**, and cleanups that run across all of them at once.

## Repository layout

| Path | What's there |
| --- | --- |
| [`packages/skeetyeet_core`](packages/skeetyeet_core) | Pure-Dart core: AT URIs, record classification, the filter engine (jobs, sessions and archives come next) |
| [`app`](app) | Flutter app for iOS, macOS, Android and Windows |
| [`website`](website) | The static site for skeetyeet.app, plus the OAuth client metadata |
| [`brand`](brand) | Logo, icons, illustrations, palette and font |
| [`tools/dev-env`](tools/dev-env) | Notes for running a local AT Protocol network for testing |
| [`SCOPE.md`](SCOPE.md) | Product scope, decisions and roadmap |

## Getting started

You'll need [Flutter](https://docs.flutter.dev/get-started/install) (stable channel; Dart 3.9 or newer).

```sh
# Core package
cd packages/skeetyeet_core
dart pub get
dart test

# App
cd ../../app
flutter pub get
flutter test
flutter run -d macos   # or ios, android, windows
```

To build for iOS or macOS you need Xcode; for Android, Android Studio; for Windows, Visual Studio with the "Desktop development with C++" workload.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and our [Code of Conduct](CODE_OF_CONDUCT.md). Report security issues privately, as described in [SECURITY.md](SECURITY.md).

## Support the project

SkeetYeet is free, with every feature unlocked. If it brings you joy, you can [leave a tip on GitHub Sponsors](https://github.com/sponsors/chriscaple).

## Licence

[MIT](LICENSE) © 2026 Carmel Avenue Media. The Lilita One font is under the [SIL Open Font License](brand/fonts/OFL.txt).

SkeetYeet is not affiliated with or endorsed by Bluesky Social PBC.
