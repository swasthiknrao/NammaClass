# NammaClass

Production-ready Flutter frontend for a large-scale application (50+ screens). Built for Android, iOS, Web, and Desktop with a responsive layout, design system, and clean architecture. No backend or database integration yet—ready to connect when needed.

## Structure

```
lib/
├── main.dart              # Entry: ProviderScope + App
├── app.dart               # MaterialApp.router, theme, go_router
├── core/                  # Config, theme, constants, utils, extensions, models, services
│   ├── config/            # EnvConfig, AppConfig
│   ├── constants/         # StorageKeys, AppConstants, ApiConstants
│   ├── models/            # Result, UserModel (single source of truth)
│   ├── services/          # SecureStorage, AuditLog
│   ├── mock/              # Mock data (replace with API)
│   └── widgets/           # Nc* design-system primitives
├── shared/                # Reusable widgets, service interfaces
│   ├── services/          # AuthService, ApiClient (abstract)
│   └── widgets/           # App* layout, feedback, tables
├── features/              # Feature modules (auth, parent, teacher, web, …)
└── routing/               # go_router; auth_routes, *_shell_routes, app_router
```

## Widget conventions

- **core/widgets (Nc\*)** — Design-system primitives: NcButton, NcInput, NcCard, NcShimmer, NcEmptyState, NcAvatar. Use for consistent forms and cards.
- **shared/widgets (App\*)** — Layout and feedback: ConstrainedContent, ResponsiveBuilder, AppCard, AppDialog, AppSkeleton, AppListView, AppDataTable. Use for page structure and list/table patterns.
- Prefer one convention per screen; most feature screens use Nc* components.

## Adding a new screen

1. **Route constant**  
   Add the path in `lib/routing/app_routes.dart` (single source of truth for routes).

2. **Feature folder**  
   Create `lib/features/<feature>/screens/<feature>_screen.dart` (or `presentation/` in some modules). Use `ConstrainedContent`, `ResponsiveBuilder`, and widgets from `lib/core/widgets/` or `lib/shared/widgets/`.

3. **Register route**  
   In the appropriate file under `lib/routing/`: `auth_routes.dart` for auth, `main_shell_routes.dart` for parent/teacher/student/admin, `web_shell_routes.dart` for web portal, or the matching shell. Add a `GoRoute` with `path` and `pageBuilder`. Compose in `app_router.dart` via the spread of route lists.

4. **Navigation**  
   Use `context.go(path)` or `context.push(path)` with constants from `AppRoutes` (e.g. `AppRoutes.parentHome`).

## Adding a new feature module

- Create `lib/features/<name>/presentation/` and put screens and feature-specific widgets there.
- Reuse `lib/shared/widgets/` and `lib/core/theme/` for consistency.
- Optionally add `lib/features/<name>/<name>_routes.dart` and export route definitions for the router to import.

## Design system

- **Theme**: `lib/core/theme/app_theme.dart` (light/dark), `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`.
- **Config**: Breakpoints and layout in `lib/core/config/app_config.dart`. Change in one place to affect the app.
- **Components**: Buttons, inputs, cards: use **core/widgets** (Nc*). Layout (ResponsiveBuilder, ConstrainedContent), feedback (skeleton, dialog, snackbar), tables: **shared/widgets** (App*).

## Responsiveness

- **Breakpoints**: xs 0, sm 600, md 900, lg 1200, xl 1600 (see `AppConfig`).
- **Shell**: Bottom navigation on mobile, navigation rail on tablet/desktop (role-specific shells in `MainShell` / `WebShell`).
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

- Add API client (implement `ApiClient` in `lib/shared/services/`) and inject via Riverpod.
- Implement `AuthRepository` (and others) in `lib/shared/services/` and wire to `isAuthenticatedProvider` and login/logout.
- Use `Result<T>` or `AsyncValue<T>` patterns already prepared in the UI for loading/error states.
