# Authentication

**Controller:** `AuthController` (`lib/controllers/auth_controller.dart`)  
**Screen:** `LoginScreen`

## Flow
1. App launches → `AppController.checkSetupStatus()` checks if meters are already configured for the current user.
2. If no user is logged in, the auth middleware redirects to `/login`.
3. On successful login, the app routes to `/main` (if setup complete) or `/setup` (first-time user).

## Login
- Email + Password via `FirebaseAuth.signInWithEmailAndPassword`.
- On success, waits a short delay (`300ms`) for auth state to propagate before routing.
- The `isLoading` flag is set immediately on tap to prevent double-submission.
- Specific error codes (`user-not-found`, `wrong-password`, `invalid-credential`, etc.) return user-friendly snackbar messages.

## Logout
- Calls `FirebaseAuth.signOut()` and navigates to `/login` via `Get.offAllNamed`.

## Auth Middleware (`auth_middleware.dart`)
- Attached to all protected routes.
- Checks `FirebaseAuth.instance.currentUser` — redirects unauthenticated users to `/login`.
