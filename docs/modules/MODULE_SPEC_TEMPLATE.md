# Module spec sheet — template

Use one file per module under `docs/modules/`. Anchor UX to a world-class product metaphor for design clarity.

## 1. Summary

| Field | Value |
|--------|--------|
| Module key | `snake_case` (matches `NcFeature.key` or billing SKU) |
| One-liner | |
| UX anchor | e.g. “Stripe-style ledger”, “Slack-style threads” |

## 2. Screens & routes

| Screen | Route (example) | Roles | Feature gate |
|--------|-------------------|-------|--------------|
| … | … | … | … |

## 3. Widgets & UX states

- Loading: skeleton / shimmer pattern IDs
- Empty / error / stale-offline banner copy keys
- Primary actions (FAB, batch bar)

## 4. Permissions (resource.action)

| Permission | Roles |
|------------|-------|
| … | … |

## 5. API (REST)

| Method | Path | Notes |
|--------|------|--------|
| … | `/v1/tenants/{tenantId}/…` | pagination, ETag |

## 6. Offline & sync

- **Read cache:** Drift tables + TTL
- **Write path:** outbox operation key, idempotency, optimistic rules
- **Conflict:** LWW vs merge UI

## 7. Validations & business rules

- …

## 8. Reports & exports

- PDF / XLSX / govt formats

## 9. Events (realtime / webhooks)

- `module.action` names

## 10. Integrations

- Third-party / hardware
