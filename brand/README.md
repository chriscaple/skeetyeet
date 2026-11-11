# SkeetYeet brand

SkeetYeet is a party, not a purge: lively, festive and tropical, celebrating letting go. See [Brand and tone in SCOPE.md](../SCOPE.md#brand-and-tone) for the personality and voice.

## Files

| File | Use |
| --- | --- |
| `logo/logo.svg` / `.png` | Horizontal lockup: mark + wordmark |
| `logo/mark.svg` / `.png` | Rounded mark (avatars, favicon, Windows icon) |
| `logo/wordmark.svg`, `wordmark-on-dark.svg` | Wordmark alone, outlined (no font needed) |
| `icon/icon.svg`, `icon-1024.png` | Square, full-bleed app icon (iOS, store listings) |
| `icon/icon-macos.svg` / `.png` | macOS icon on Apple's 824/1024 grid |
| `icon/android-background.*`, `android-foreground.*` | Android adaptive icon layers |
| `illustrations/hero-sunset.svg` | Website hero: phone resting on the beach, posts drifting away |
| `illustrations/touch-grass.svg` | Empty and celebration states |
| `fonts/LilitaOne-Regular.ttf` | Display font ([SIL OFL](fonts/OFL.txt)) |

The SVGs are the sources. After editing them, re-export the PNGs with `rsvg-convert` (for example `rsvg-convert icon/icon.svg -o icon/icon-1024.png`), then run `dart run flutter_launcher_icons` in `app/`.

## Palette

| Name | Hex | Use |
| --- | --- | --- |
| Hibiscus | `#FF3E7F` | Brand accent, logo |
| Mango | `#FF9F1C` | Highlights, progress |
| Sunshine | `#FFD23F` | Celebrations, badges |
| Palm | `#2EC27E` | Success, touch-grass moments |
| Lagoon | `#00B4C6` | Links on dark, secondary accents |
| Deep sea | `#1B2A49` | Text, dark backgrounds |
| Sand | `#FFF4E0` | Light backgrounds |

**Accessible variants for fills that carry text** (WCAG AA, 4.5:1 or better):

| Name | Hex | Pairing |
| --- | --- | --- |
| Hibiscus deep | `#D6246E` | White text, 4.8:1. Primary buttons in light mode |
| Hibiscus light | `#FF6B9D` | Deep sea text, 5.3:1. Primary buttons in dark mode |

Bright Hibiscus with white text is only 3.4:1, so use it for shapes and large display type, not for button labels.

## Rules

- Original artwork only. Nothing that resembles Bluesky's butterfly or its blue.
- Body text sits on Sand or Deep sea, never on bright fills.
- Confetti and motion respect reduced-motion settings.
