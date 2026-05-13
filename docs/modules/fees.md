# Module spec — Fees

## 1. Summary

| Field | Value |
|--------|--------|
| Module key | `fees` + `online_payment` flag |
| One-liner | Invoicing, receipts, defaulters, and gateway settlement per tenant. |
| UX anchor | **Stripe Dashboard** for finance ops; parent flow like **phone recharge**. |

## 2. Screens & routes

| Screen | Route | Roles | Gate |
|--------|-------|-------|------|
| Parent fees | `/parent/fees` | parent | `online_payment` for pay CTA |
| Student summary | `/student/fees` | student | — |
| Web ledger | `/web/finance/...` | accountant, admin | — |

## 3. Widgets & states

- Skeleton: `fee_list_bones`; error states for payment timeout
- No optimistic **payment success**—only optimistic “intent created”

## 4. Permissions

| Permission | Roles |
|------------|-------|
| `fees.view_own` | student, parent |
| `fees.manage_structure` | admin, accountant |
| `fees.record_cash` | accountant |
| `fees.waive` | principal (approval chain) |

## 5. API

| Method | Path | Notes |
|--------|------|--------|
| GET | `/v1/tenants/{id}/fees/invoices` | keyset by `due_date` |
| POST | `/v1/tenants/{id}/fees/payment-intents` | idempotency |
| GET | `/v1/tenants/{id}/fees/receipts/{id}` | PDF URL |

## 6. Offline & sync

- Read cache: last statement per student; stale badge
- Writes: queue **cash** entries only; gateway flows require online

## 7. Validations

- Double-entry integrity; no negative balance without adjustment type

## 8. Reports

- Bursar summary, GST report (if applicable), donor/scholarship tagging

## 9. Events

- `fee.invoice_issued`, `fee.payment_recorded`, `fee.waiver_approved`

## 10. Integrations

- Razorpay, Stripe India, NEFT file export
