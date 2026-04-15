# Architecture & Tech Stack

## Framework
- **Flutter** (Dart) — cross-platform mobile app targeting Android & iOS.

## State Management
- **GetX (`get: ^4.7.x`)** — used for controllers, reactive state (`Rx`/`.obs`), routing (`Get.toNamed`), and snackbars/dialogs.

## Backend & Database
- **Firebase Auth** (`firebase_auth`) — email/password authentication. All data operations are tied to the authenticated user's UID.
- **Cloud Firestore** (`cloud_firestore`) — all persistent data is stored in Firestore under per-user collection paths. No local SQLite is used.
- **`DatabaseHelper`** — singleton service (`lib/db/database_helper.dart`) that wraps all Firestore interactions. All screens and controllers go through this class — no direct Firestore calls elsewhere.

## Theming
- **`ThemeController`** — GetX controller that persists theme preference via `SharedPreferences` and applies it using `Get.changeThemeMode`.
- **`AppTheme`** (`lib/theme/app_theme.dart`) — defines `lightTheme` and `darkTheme` `ThemeData` objects. All UI uses `Theme.of(context)` — no hardcoded colors.

## Key Packages
| Package | Purpose |
|---|---|
| `get` | State management & routing |
| `firebase_core` + `firebase_auth` | Authentication |
| `cloud_firestore` | Cloud database |
| `screenshot` | Capture bill widget as an image |
| `share_plus` | Native file/image sharing |
| `pdf` | Generate multi-page PDF reports |
| `path_provider` | Write PDF to device filesystem |
| `intl` | Date formatting |
| `shared_preferences` | Persist theme preference |
| `google_fonts` | Typography |

## Directory Structure
```
lib/
├── controllers/      # GetX controllers (one per screen)
├── db/               # DatabaseHelper — all Firestore logic
├── services/         # PdfService — PDF generation & sharing
├── theme/            # AppTheme light/dark definitions
├── views/            # All screen widgets
└── main.dart         # App entry, routing, theme registration
```
