# Super Admin console — architecture decision

## Recommendation

Ship **two surfaces**:

1. **Platform Super Admin** — **separate web app** (or `admin.nammaclass.in`) built in Flutter Web **or** internal React/Next for speed. Uses **platform JWT** with `scope=platform`, **no tenant data** in default queries.
2. **Institution Owner console** — **inside main app** under a privileged role (`admin`/`principal` + billing flags) for day-to-day module toggles **only if** delegated by platform (many institutions should **not** self-toggle paid modules—only Super Admin).

This minimizes blast radius: platform operators do not install the same APK as schools; reduces accidental feature leakage in mobile builds.

## When to use in-app Super Admin

- Early-stage single-team startup: flag **`kDebugMode` + hidden gesture** only—not for production.
- If shipping one binary: isolate routes with **`/platform/*`** + compile-time `dart-define` enabling the route tree.

## Capabilities (platform)

- Tenant CRUD, suspend/reactivate
- Subscription plan + **per-module** toggles, read-only effective `EntitlementSnapshot`
- Role pack assignment and **break-glass** restrictions (e.g. disable `fees.waive` until training)
- Global theme marketplace defaults; tenant override preview
- **AI:** model routing, token caps, kill switch per tenant
- **Audit:** immutable append-only log; SIEM export
- **Backup/restore:** orchestration per shard; tenant export GDPR/DPDP pack
- **Impersonation (break-glass):**

  - `POST /v1/platform/impersonation/start` → short-lived **delegated** token
  - Requires **MFA + ticket id**; auto-expires ≤ 60 minutes
  - Every API call tagged `X-Impersonator-Admin-Id`; full payload audit
  - **Read-only** default; writes need elevated sub-scope

## Audit fields (minimum)

- `actor_id`, `actor_type` (`platform_admin` | `tenant_user`)
- `tenant_id`, `action`, `resource`, `before`, `after`, `ip`, `user_agent`, `request_id`

## Client alignment

- Flutter app **never** stores platform-admin tokens in student builds.
- [`route_guard.dart`](../lib/routing/route_guard.dart) remains tenant-scoped; platform routes are not linked from institution shells.
