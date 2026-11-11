# SkeetYeet — Product Scope

*Updated 2026-11-11*

## Summary

SkeetYeet is a free, open-source app for iOS, macOS, Android and Windows that bulk-deletes posts, reposts, replies and likes, and bulk-unfollows accounts, across one or more Bluesky accounts, using filters the user combines. Before deleting anything it can archive the selected items locally, and it can export a whole account, including DMs.

Everything runs on the user's device: there is no SkeetYeet server, no analytics, and no credentials leave the device except to the user's own Bluesky server (PDS). The product website, [skeetyeet.app](https://skeetyeet.app), explains the app and links to every store and to GitHub. [Carmel Avenue Media](https://www.carmelavenuemedia.ca) is the publisher on every store.

## Goals and non-goals

**Goals**

- Delete exactly the content, and unfollow exactly the accounts, the user selects, and nothing else, across one or more connected accounts.
- Let users build selections from combinable filters (account, type, date, media, keywords, engagement) and preview the result before deleting.
- Archive selected content before deletion, and export an entire account on demand.
- Ship native-feeling apps on iOS, macOS, Android and Windows from one codebase.
- Be fully open source, auditable and reproducible from GitHub.

**Non-goals (v1)**

- No hosted service, account, sync or cloud backup run by SkeetYeet.
- No posting, feed reading or general Bluesky client features.
- No "restore" that republishes deleted posts. Re-created posts would get new URIs and lose likes, replies and quotes.
- No deleting other people's content, or anything the account does not own.
- No guarantee that deleted content disappears from third-party mirrors, firehose consumers or screenshots.

## Brand and tone

SkeetYeet is a party, not a purge. The brand is lively, colourful and festive, in tropical colours, and it celebrates letting go: posts are ephemeral, the past can wash away like a sandcastle, and the best thing to do after a cleanup is put the device down and go touch all the grass.

**Personality:** joyful, warm, a little cheeky, never preachy. It invites people out of being Too Online and posting too much; it never shames them for it.

**Palette** (a starting point; Claude designs the logo, app icon and illustrations in Phase 0)

| Name | Hex | Use |
| --- | --- | --- |
| Hibiscus | `#FF3E7F` | Primary actions, logo |
| Mango | `#FF9F1C` | Highlights, progress |
| Sunshine | `#FFD23F` | Celebrations, badges |
| Palm | `#2EC27E` | Success, touch-grass moments |
| Lagoon | `#00B4C6` | Links, secondary actions |
| Deep sea | `#1B2A49` | Text, dark-mode background |
| Sand | `#FFF4E0` | Light-mode background |

**Motifs:** sunsets, waves washing over sandcastles, confetti, palm fronds, drifting balloons, a hammock. A finished job ends on a celebration screen and a gentle nudge to go outside.

**Voice examples**

| Moment | Copy |
| --- | --- |
| Empty state | Your timeline, your rules. What are we letting go of today? |
| Delete button | Yeet 4,812 skeets |
| Job running | Waving goodbye… 1,204 of 4,812. Grab a drink, this takes a while. |
| Job done | 4,812 skeets set free. The grass is calling. |
| Unfollow done | 312 accounts released into the wild. |
| Full export done | Memories packed. Now go make some new ones offline. |

**Guardrails**

- The fun stops at the confirmation step: destructive actions use plain, unambiguous wording and exact counts.
- Bright colours still meet WCAG AA contrast; text sits on Sand or Deep sea, not on bright fills.
- Animations and confetti respect reduced-motion settings.
- Original artwork only; nothing resembling Bluesky's butterfly or its blue.

## Platforms and distribution

| Platform | Minimum target | Distribution | Developer cost |
| --- | --- | --- | --- |
| iOS / iPadOS | iOS 16+ | App Store | Apple Developer Program, $99/yr (covers macOS too) |
| macOS | macOS 13+ (Apple silicon + Intel) | Mac App Store + notarized DMG on GitHub Releases | Included above |
| Android | Android 8.0+ (API 26) | Google Play, F-Droid, APK on GitHub Releases | Google Play, $25 one-time |
| Windows | Windows 10 21H2+ / 11 (x64, ARM64) | Microsoft Store (MSIX) + signed installer on GitHub Releases | Code-signing certificate or Azure Trusted Signing (roughly $10/month) |
| Website | Any modern browser | Static site on Vercel | skeetyeet.app (registered) |

All store listings are published under **Carmel Avenue Media**. A Linux desktop build and a web build come almost free with Flutter and can be listed as stretch goals. Costs are approximate and should be checked before purchase.

## Accounts and sign-in

- **Multiple accounts.** Users connect any number of Bluesky accounts and switch between them. Each account has its own index, archive folder, saved filters and job history. A rule can run on one account or on all connected accounts at once. An "all accounts" run queues one job per account, each with its own preview, rate-limit budget and report, under a single combined confirmation.
- **Any PDS.** Resolve handle → DID → DID document → PDS endpoint, so accounts on `bsky.social` and self-hosted or third-party PDSes both work.
- **OAuth (primary).** AT Protocol OAuth (PKCE + PAR + DPoP) as a public native client. The client metadata JSON is hosted at `https://skeetyeet.app/oauth/client-metadata.json`. The app requests only the scopes it needs, and the scope to read DMs only when the user turns on DM export.
- **App password (fallback).** For PDSes without OAuth, or for users who prefer it. The UI explains how to create an app password and warns users never to enter their main password. DM export requires an app password created with "Allow access to your direct messages".
- **Secure storage.** Tokens are kept in the platform keystore (Keychain, Android Keystore, Windows Credential Manager) and never in plain files. Signing out revokes the session and deletes local tokens. The user chooses whether to keep or delete the local archive.

## Selection filters

Users build a rule from any combination of the filters below, joined with AND / OR and negated with NOT. Rules can be saved as named presets, per account or shared across all accounts.

| Category | Filter | Notes / data source |
| --- | --- | --- |
| Content type | Original posts, replies, quote posts, reposts, likes | Record collection plus `reply` and `embed` fields |
| Target account | Reposts of account X | Repost `subject` URI → author DID |
| Target account | Replies to account X (direct parent, or anywhere in a thread X started) | `reply.parent` / `reply.root` URI → DID |
| Target account | Quote posts of account X; posts mentioning account X | Embed record URI; mention facets |
| Target account | Likes of account X's posts | Like `subject` URI → DID |
| Date | Before date, after date, between dates, older than N days/weeks/months | Record `createdAt` |
| Media | Has images, has video, has GIF, has external link card, has no media | `embed` type (`images`, `video`, `external`, `recordWithMedia`) |
| Media | Images missing alt text | Image `alt` field |
| Text | Contains any / all keywords, exact phrase, regex, case-sensitive option | Post `text` |
| Text | Hashtags, links to a domain | Facets |
| Language | Post language(s) | `langs` field |
| Engagement | Likes / reposts / replies / quotes fewer or more than N | App view `getPosts` counts, fetched at scan time |
| Thread | Whole self-threads; only replies that are part of a self-thread | Root / parent analysis |
| Labels | Posts carrying self-labels (e.g. adult content) | `labels` field |
| Follows | Unfollow all, specific accounts, accounts inactive for N months, accounts that don't follow back, accounts followed before a date | `app.bsky.graph.follow` records + app view profiles and relationships |

**Keep rules (exclusions)** always win over delete rules:

- Keep the pinned post.
- Keep posts with at least N likes or reposts.
- Keep posts on a manual "never delete" list (picked in the preview).
- Keep posts newer than N days.
- Keep posts with selected keywords or hashtags.

## Deletion workflow and safety

1. **Scan.** Page through the account's repo (`com.atproto.repo.listRecords` for posts, reposts, likes and follows, or a full `getRepo` CAR download) and build a local SQLite index. Later scans are incremental.
2. **Build the rule.** The filter builder shows a live count as filters change.
3. **Preview.** A list of matching items, grouped by type, with counts, date range and media thumbnails. Users can open any item and deselect it, or add it to "never delete".
4. **Archive (optional, on by default).** Saves the selected items and their media to the local archive before anything is deleted, and checks that the archive is complete.
5. **Confirm.** A summary ("Delete 4,812 items from @handle") and a typed confirmation (the count or the handle). A dry-run mode does everything except the delete.
6. **Execute.** Deletes in batches with `com.atproto.repo.applyWrites`, falling back to `deleteRecord`. Shows a progress bar and ETA, with pause, resume and cancel.
7. **Report.** Results by type, any failures (with retry) and a CSV/JSON log of every deleted URI.

**Rate limits and resumability**

- The PDS limits writes by points: on `bsky.social`, deletes and unfollows cost 1 point each, with roughly 5,000 points per hour and 35,000 per day (approximate; to be confirmed against current Bluesky docs). Large jobs therefore take hours or days.
- Jobs are persisted, so they survive app restarts, sleep and crashes, and continue where they left off. The scheduler reads `RateLimit-*` response headers and backs off.
- Desktop: jobs keep running in the background or tray. Mobile: jobs run in the foreground with the screen kept awake, and continue opportunistically through OS background tasks (`BGProcessingTask` on iOS, WorkManager on Android). The app says clearly that a large job is faster on desktop.

**Scheduled rules (phase 3):** optional recurring rules, such as "every day, delete posts older than 90 days, except pinned posts and posts with 50+ likes". These run while the desktop app or tray agent is running.

## Archive and full account export

**Archive before delete:** every deletion or unfollow job can write the selected items (or the follow list) to the account's archive folder first.

**Full account export:** on demand, independent of deletion.

| Content | Source | Notes |
| --- | --- | --- |
| Entire repo (posts, reposts, likes, follows, blocks, lists, profile, threadgates, etc.) | `com.atproto.sync.getRepo` → CAR file | The canonical, re-importable backup |
| Images and videos | `com.atproto.sync.listBlobs` + `getBlob` | Original files, deduplicated by CID |
| Readable JSON | Decoded from the CAR | One JSON file per collection |
| Direct messages | `chat.bsky.convo.listConvos` + `getMessages` via the chat proxy | Needs DM permission; export only. Bluesky allows deleting DMs only on your own side. |
| Bookmarks, mutes, preferences | `app.bsky.actor.getPreferences`, mute lists | Where the API exposes them |

**Archive format:** a plain folder (optionally zipped) that is readable without SkeetYeet.

```
SkeetYeet Archive/
  @handle.bsky.social (did-plc-xxxx)/
    2026-11-11T10-30-00Z-full-export/
      repo.car
      manifest.json         # versions, counts, checksums, export options
      records/
        app.bsky.feed.post.json
        app.bsky.feed.repost.json
        app.bsky.feed.like.json
        app.bsky.graph.follow.json
      blobs/<cid>.<ext>
      chat/<convo-id>.json
      index.html            # offline, browsable viewer
    deletion-jobs/
      2026-11-12-job-0042/  # items archived before that deletion job
```

The bundled `index.html` viewer lets users browse and search their archive offline in any browser. Archives can also be re-opened in SkeetYeet. The archive location is user-configurable (for example iCloud Drive, Dropbox or an external disk) and can optionally be encrypted with a passphrase (phase 3).

## Architecture and tech stack

**Decision: Flutter (Dart) for all four apps, with a pure-Dart core package.**

- One UI codebase builds production apps for iOS, macOS, Android and Windows (Linux and web for free).
- Mature AT Protocol libraries exist in Dart (`atproto` / `bluesky` packages); a protocol layer can be added where they fall short.
- Secure storage, SQLite (`drift`), background work and file pickers all have well-supported plugins.

**Alternative considered and set aside: TypeScript.** Expo / React Native for mobile and Tauri or Electron for desktop, sharing a TypeScript core built on the official `@atproto/api`. It uses the reference SDK, but needs two UI shells and has weaker Windows/macOS support in React Native.

| Layer | Responsibility |
| --- | --- |
| `skeetyeet_core` (pure Dart, no Flutter) | Identity resolution, OAuth / app-password sessions, repo scanning, CAR parsing, filter engine, job queue, rate-limit scheduler, archive writer |
| Local store | SQLite index per account, job state, saved rules, settings |
| `skeetyeet_app` (Flutter) | Screens: accounts, scan, rule builder, preview, jobs, archive browser, settings |
| Platform glue | Keychain / Keystore / Credential Manager, background tasks, notifications, tray (desktop), in-app purchase (tips) |
| Optional CLI | Same core as a command-line tool, for power users and automated tests |

**Quality**

- Unit tests for the filter engine against fixture repos.
- Integration tests against a local PDS (the official `atproto` dev environment) so CI never touches real accounts.
- Golden and widget tests for key screens.
- Accessibility: screen readers, Dynamic Type / font scaling, full keyboard navigation on desktop.
- Localization-ready from day one (English first).

## Product website

A single, fast, static site (Astro or plain HTML) at **skeetyeet.app**, hosted on Vercel, source in the same repo under `/website`.

- **Hero:** name, one-line pitch ("Yeet your old skeets. Keep the memories. Go touch grass."), sunny illustrated hero in the brand palette, download buttons detected per platform.
- **What it does:** cards for bulk delete, bulk unfollow, smart filters, archive before delete, full export with DMs, multiple accounts and all-accounts runs.
- **Privacy:** on-device only, no server, no tracking, open source; link to the code.
- **How it works:** connect → filter → preview → archive → let go.
- **Downloads:** App Store, Mac App Store / DMG, Google Play / F-Droid / APK, Microsoft Store / installer, all versioned via GitHub Releases.
- **Tip jar:** links to the tip options below.
- **FAQ:** rate limits and why big jobs take time; what deletion does and does not remove; app passwords vs OAuth; is it official? (No.)
- **Footer:** GitHub, changelog, privacy policy, terms, © Carmel Avenue Media with a link to carmelavenuemedia.ca, "not affiliated with Bluesky Social PBC" disclaimer.
- **Hosting:** also serves the OAuth client metadata and the deep-link files (`apple-app-site-association`, `assetlinks.json`).

## Tip jar

SkeetYeet is free with every feature unlocked. Tips are optional and unlock nothing.

- **App Store (iOS, macOS) and Google Play:** consumable in-app purchase tips in three tiers (for example $2.99 / $4.99 / $9.99), because store rules require their own billing for tips to the developer.
- **Direct downloads, F-Droid and the website:** GitHub Sponsors ([github.com/sponsors/chriscaple](https://github.com/sponsors/chriscaple) for now). The F-Droid build leaves out the in-app purchase SDK.
- **When it appears:** once on the celebration screen after a successful job, and always in Settings. Never during a job, never as a nag.
- **Privacy:** the store or tip platform handles payment; SkeetYeet stores nothing. Tips go to Carmel Avenue Media.

## Open source and repo setup

- **Licence:** MIT (recommended). It is simple and compatible with App Store distribution; GPL-family licences conflict with Apple's store terms. Apache-2.0 is the alternative if an explicit patent grant is wanted.
- **GitHub:** public repo at [github.com/chriscaple/skeetyeet](https://github.com/chriscaple/skeetyeet) for now, moving to a Carmel Avenue Media organization later (GitHub redirects the old URL); `README`, `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md` (private vulnerability reporting), issue and PR templates, Discussions for questions.
- **CI (GitHub Actions):** lint, test and build on every PR. Tagged releases build signed artifacts for every platform, publish to GitHub Releases, and push to stores (via fastlane for Apple and Google).
- **Reproducibility:** pinned toolchains, documented build steps, F-Droid-compatible Android build (no proprietary dependencies).
- **Privacy policy:** states that no data is collected; required by every store.

**Proposed repo layout**

```
skeetyeet/
  SCOPE.md
  README.md
  LICENSE
  packages/
    skeetyeet_core/     # pure Dart: protocol, filters, jobs, archive
  app/                  # Flutter app (ios/, macos/, android/, windows/)
  cli/                  # optional command-line tool
  website/              # product site + OAuth client metadata
  docs/                 # architecture notes, archive format spec
  .github/              # workflows, templates
```

## Phased roadmap

Desktop goes first because large jobs run for hours, which suits always-on machines. Mobile follows once the core is proven.

| Phase | Scope | Exit criteria |
| --- | --- | --- |
| 0 — Foundations | Repo, MIT licence, CI, core package skeleton, local PDS test harness, brand identity (logo, palette, illustrations), skeetyeet.app placeholder serving the OAuth client metadata | CI green; can sign in to a test PDS from the CLI |
| 1 — MVP (macOS + Windows) | Multiple accounts and all-accounts runs, OAuth + app password, scan and index, core filters (type, target account, date range, before date, images, video, keywords), likes deletion and bulk unfollow, preview, archive before delete, resumable jobs with rate-limit handling, report | A 10,000-post test account cleaned with a chosen rule and nothing else deleted; archive opens in the offline viewer |
| 2 — Mobile + full export | iOS and Android apps, full account export (CAR, blobs, JSON, DMs), offline archive viewer, product website live, store listings under Carmel Avenue Media, tip jar | Apps approved in all four stores; website live with working download links |
| 3 — Power features | Engagement and language filters, saved presets, scheduled rules, archive encryption, archive import/search, CLI release, localization | Feature-complete v1.x |

## Risks and constraints

| Risk | Mitigation |
| --- | --- |
| Rate limits: large accounts take days to clean | Persistent, resumable jobs; clear ETAs; desktop-first |
| Irreversibility: deletes cannot be undone | Archive on by default, preview, typed confirmation, dry run, keep rules |
| API changes: AT Protocol OAuth scopes and chat APIs are still evolving | Protocol code isolated in the core package; integration tests against a local PDS |
| Mobile background limits: iOS and Android may suspend long jobs | Foreground execution, background tasks where allowed, resume on launch |
| Store review: Apple may question bulk-delete tools or third-party sign-in | Clear app description, privacy policy, OAuth sign-in, no Bluesky branding |
| Trademark: "Bluesky" and its butterfly logo belong to Bluesky Social PBC | Descriptive use only, non-affiliation disclaimer, original branding |
| Deleted is not gone: relays, app views and third parties may keep copies | Stated plainly in the app and on the website |

## Decisions

Agreed on 2026-11-11.

| Question | Decision |
| --- | --- |
| Tech stack | Flutter (Dart) for all four apps |
| Domain | skeetyeet.app (registered) |
| Store publisher | Carmel Avenue Media ([carmelavenuemedia.ca](https://www.carmelavenuemedia.ca)) |
| Pricing | Free, with an optional tip jar |
| Tips outside the stores | GitHub Sponsors |
| Likes and unfollowing | In scope for v1 |
| All-accounts runs | Allowed |
| Branding | Lively, festive, tropical; celebrates letting go and touching grass (see Brand and tone) |
| Logo, app icon, illustrations | Designed by Claude in Phase 0 |
| GitHub home | github.com/chriscaple/skeetyeet for now; move to a Carmel Avenue Media organization later |
| Minimum OS versions | As listed under Platforms and distribution |
| Website hosting | Vercel |

No open questions remain.
