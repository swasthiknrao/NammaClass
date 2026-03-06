# NammaClass

Production-ready Flutter frontend for a large-scale application (50+ screens). Built for Android, iOS, Web, and Desktop with a responsive layout, design system, and clean architecture. No backend or database integration yet—ready to connect when needed.

## Structure

```
lib/
├── main.dart              # Entry: ProviderScope + App
├── app.dart               # MaterialApp.router, theme, go_router
├── core/                  # Config, theme, constants, utils, extensions
├── shared/                # Reusable widgets, models, service interfaces
├── features/              # Feature modules (shell, home, auth, dashboard, settings)
└── routing/               # go_router, route guard, page transitions
```

## Adding a new screen

1. **Route constant**  
   Add the path in `lib/core/config/route_config.dart`.

2. **Feature folder**  
   Create `lib/features/<feature>/presentation/<feature>_screen.dart` and implement the screen (use `ConstrainedContent`, `ResponsiveBuilder`, and shared widgets from `lib/shared/widgets/`).

3. **Register route**  
   In `lib/routing/app_router.dart`:
   - For a **shell tab**: add a `GoRoute` under the existing `ShellRoute` with `path` and `pageBuilder` (or `builder`).
   - For a **full-screen** route (e.g. login): add a top-level `GoRoute` and use `fadeSlideTransition` in `pageBuilder` if you want custom transitions.

4. **Navigation**  
   Use `context.go(path)` or `context.push(path)` with the path from `RouteConfig`.

## Adding a new feature module

- Create `lib/features/<name>/presentation/` and put screens and feature-specific widgets there.
- Reuse `lib/shared/widgets/` and `lib/core/theme/` for consistency.
- Optionally add `lib/features/<name>/<name>_routes.dart` and export route definitions for the router to import.

## Design system

- **Theme**: `lib/core/theme/app_theme.dart` (light/dark), `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`.
- **Config**: Breakpoints and layout in `lib/core/config/app_config.dart`. Change in one place to affect the app.
- **Components**: Buttons, inputs, cards, navigation, feedback (skeleton, dialog, snackbar), layout (ResponsiveBuilder, AdaptiveScaffold, ConstrainedContent), tables under `lib/shared/widgets/`.

## Responsiveness

- **Breakpoints**: xs 0, sm 600, md 900, lg 1200, xl 1600 (see `AppConfig`).
- **Shell**: Bottom navigation on mobile, navigation rail on tablet/desktop (`AdaptiveScaffold`).
- **Content**: Use `ConstrainedContent` for max width and centering on large screens; use `ResponsiveBuilder` when layout depends on breakpoint.

## Security (frontend)

- Validators in `lib/core/utils/validators.dart` (required, email, password, maxLength, combine).
- Sanitization in `lib/core/utils/sanitization.dart` (trim, max length, email).
- Route guard in `lib/routing/route_guard.dart` redirects unauthenticated users to login (uses `isAuthenticatedProvider`). Replace with real auth when backend is added.
- No secrets in code; use `EnvConfig` and build-time env for API URLs/keys.

## Running

```bash
flutter pub get
flutter run
```

Target a platform with `-d chrome`, `-d windows`, etc.

## Backend integration (later)

- Add API client and inject via Riverpod (e.g. `final apiClientProvider = Provider((ref) => ApiClient(EnvConfig.apiBaseUrl))`).
- Implement `AuthRepository` (and others) in `lib/shared/services/` and wire to `isAuthenticatedProvider` and login/logout.
- Use `Result<T>` or `AsyncValue<T>` patterns already prepared in the UI for loading/error states.
