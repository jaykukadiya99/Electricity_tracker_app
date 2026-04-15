# Settings

**Screen:** `settings_screen.dart`

## User Profile Block
At the top of the screen, a profile tile shows:
- A person avatar icon (tinted with the app's primary color).
- The **currently logged-in user's email** pulled from `FirebaseAuth.instance.currentUser?.email`.
- A "Currently Logged In" subtitle.

## Options

### Dark Mode Toggle
- A `SwitchListTile` linked to `ThemeController`.
- Instantly switches between light and dark mode app-wide.
- Preference is persisted via `SharedPreferences` — survives app restarts.

### Reset All Data
- Opens a confirmation `AlertDialog` before proceeding.
- Calls `DatabaseHelper.instance.clearAllData()` which deletes all meters, billing history, and billing records from Firestore for the current user.
- After reset, routes to `/setup` so the user can start fresh.

> **Warning:** This action is irreversible and permanently removes all cloud data for the account.

### Logout
- Calls `AuthController.logout()` → `FirebaseAuth.signOut()`.
- Routes to `/login` via `Get.offAllNamed`.
