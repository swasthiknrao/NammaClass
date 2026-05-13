# NammaClass — API style guide

Conventions for REST APIs backing the Flutter client ([`lib/core/network`](../lib/core/network/), [`dio`](../pubspec.yaml)). Aligns with JSON schemas in [schemas/](schemas/).

## Versioning

- **URL prefix:** `/v1/` for all public resources. Bump to `/v2/` only for breaking changes.
- **Schema versioning:** Payloads include `schema_version` (integer). Clients MUST reject unknown major versions or downgrade gracefully per product policy.
- **Entitlements:** `EntitlementSnapshot.snapshot_version` increments when billing or Super Admin changes modules/limits. Clients MUST refetch tenant bundle when `snapshot_version` increases.

## Multi-tenancy

- **JWT claim:** `tenant_id` (required for institution users). Platform **Super Admin** uses separate issuer or `scope=platform`.
- **Headers (recommended):**
  - `X-Tenant-Id` — duplicate of claim for gateways that strip JWT.
  - `Idempotency-Key` — UUID for POST that create financial or attendance records.
- **Path style:** Prefer `/v1/tenants/{tenantId}/...` for explicit resources; short forms (`/attendance/...`) MUST resolve tenant from JWT only.

## Errors

Unified error envelope:

```json
{
  "error": {
    "code": "string_machine_code",
    "message": "Human readable",
    "details": {},
    "request_id": "uuid"
  }
}
```

| HTTP | code examples | When |
|------|---------------|------|
| 400 | `validation_error`, `invalid_idempotency` | Bad input |
| 401 | `unauthorized` | Missing/invalid token |
| 403 | `forbidden`, `module_disabled`, `role_denied` | RBAC / entitlements |
| 404 | `not_found` | Missing resource |
| 409 | `conflict`, `stale_revision` | Optimistic concurrency |
| 429 | `rate_limited` | Tenant/API limits from snapshot |
| 500 | `internal_error` | Server fault |

## Pagination

- **Query:** `cursor` (opaque), `limit` (default 20, max 100).
- **Response:**

```json
{
  "data": [],
  "next_cursor": "string or null",
  "has_more": false
}
```

- **Ledger / fee lines:** Prefer **keyset** pagination (`after_id` + `sort`) for stable ordering under concurrent writes.

## Concurrency

- **ETag:** Optional on GET; client sends `If-Match` on PUT.
- **`updated_at` + `revision`:** Resources MAY expose `revision` integer; reject PUT if mismatch (`409 stale_revision`).

## Idempotency

- **Header:** `Idempotency-Key` required for `POST` affecting money, attendance batch, inventory movement.
- Server stores key → response mapping for 24h; duplicates return same status/body.

## Tenant config endpoints

| Method | Path | Notes |
|--------|------|--------|
| GET | `/v1/tenants/{tenantId}/profile` | [tenant_profile.schema.json](schemas/tenant_profile.schema.json) |
| PATCH | `/v1/tenants/{tenantId}/profile` | Institution Owner scoped fields only |
| GET | `/v1/tenants/{tenantId}/entitlements` | [entitlement_snapshot.schema.json](schemas/entitlement_snapshot.schema.json) |
| GET | `/v1/platform/role-packs/{packId}` | [role_pack.schema.json](schemas/role_pack.schema.json) (Super Admin / internal) |

**Legacy alias:** `GET /tenant/config?tenantId=` MAY return the same shape as profile for backward compatibility with [`tenant_repository_impl.dart`](../lib/data/repositories/tenant_repository_impl.dart).

## Roles and module coupling

Institution users receive **`allowed_role_keys`** on [EntitlementSnapshot](schemas/entitlement_snapshot.schema.json) (or equivalent JWT claim `allowed_roles` for invite-only flows). Keys MUST match Dart [`UserRole.name`](../lib/core/models/user_model.dart) (e.g. `canteenStaff`, `librarian`).

**Server rules:**

1. Before **`POST /v1/tenants/{tenantId}/users`** (invite) or **`PATCH`** on user role, verify every required module for that role is enabled on the tenant snapshot. Policy table: [role_module_requirements.json](schemas/role_module_requirements.json) (mirrors [role_module_requirements.dart](../lib/core/tenant/role_module_requirements.dart)).
2. On **`403`**, use error code **`invalid_role_for_tenant`** or **`module_disabled`** with `details.missing_modules: ["library", ...]` when the client attempted a role that needs a disabled SKU.
3. When provisioning toggles a module **off**, platform SHOULD recompute `allowed_role_keys` (or reject publish until conflicting users are demoted).

**Client:** Invite UI MUST use `allowed_role_keys` when present; otherwise derive with `assignableRolesForInvite` (module-aware).

**Bundled policy (Flutter):** Runtime copies live under `assets/config/` — `role_module_requirements.json`, `role_entitlement_aliases.json`, `feature_route_gates.json`, `theme_presets.json`; user-management demo rows in `assets/data/web_user_management_demo.json`. Loaded at startup via `TenantPolicyLoader.loadAll()` in `lib/main.dart`. Schema reference: [role_module_requirements.json](schemas/role_module_requirements.json).

## ThemeTokens (client parsing)

Optional nested object on profile; semantic keys (not raw widget code):

| Key | Type | Description |
|-----|------|-------------|
| `preset_id` | string | One of: apple_glass, modern_university, neo_minimal, dark_professional, futuristic_ai, nothing_inspired, pixel_inspired, corporate_premium, academic_classic, luxury_gold |
| `density` | string | `comfortable` \| `compact` |
| `font_family_primary` | string | Google Fonts id |
| `font_family_body` | string | Google Fonts id |
| `radius_scale` | number | 0.8–1.2 multiplier |
| `motion_level` | string | `reduced` \| `standard` \| `expressive` |
| `colors` | object | Semantic: `primary`, `on_primary`, `surface`, `danger`, etc. (hex strings) |

## Webhooks & events (future)

- Event names: dot.case e.g. `attendance.marked`, `fee.payment_recorded`.
- Payload includes `tenant_id`, `event_id`, `occurred_at`, `data`.

## Security

- TLS 1.2+; rotate JWT signing keys; short-lived access + refresh.
- **Super Admin** impersonation: `POST /v1/platform/impersonation` with break-glass audit log (see [SUPER_ADMIN_CONSOLE.md](SUPER_ADMIN_CONSOLE.md)).
