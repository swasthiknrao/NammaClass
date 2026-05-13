# Module spec — Communication

## 1. Summary

| Field | Value |
|--------|--------|
| Module key | `communication` (maps `parent_chat`, `whatsapp_bot`, SMS) |
| One-liner | Notices, chat, and outbound channels with policy and spend caps. |
| UX anchor | **Slack**-quick threads + **Intercom**-style broadcast + delivery receipts. |

## 2. Screens & routes

| Screen | Route | Roles | Gate |
|--------|-------|-------|------|
| Parent chat | `/parent/chat` | parent | `parent_chat` |
| Notices | shared `/notifications`, `/parent/home` cards | all | — |
| Web comms analytics | `/web/communication/...` | admin | Enterprise |

## 3. Widgets & states

- `chat_bones`, `notice_bones`; failed send retry

## 4. Permissions

| Permission | Roles |
|------------|-------|
| `comm.broadcast` | admin, principal |
| `comm.direct.student` | teacher (policy) |
| `comm.view_threads` | participant |

## 5. API

| Method | Path | Notes |
|--------|------|--------|
| GET | `/v1/tenants/{id}/threads` | cursor |
| POST | `/v1/tenants/{id}/messages` | rate limits from snapshot |
| POST | `/v1/tenants/{id}/broadcasts` | approval workflow |

## 6. Offline & sync

- `send_chat` outbox ([`SyncOperation.sendChat`](../lib/application/sync/sync_queue_service.dart)); optimistic bubble → failed state

## 7. Validations

- DLT template approval for SMS; WhatsApp template namespace per tenant

## 8. Reports

- Delivery analytics, read receipts export

## 9. Events

- `message.sent`, `broadcast.scheduled`, `whatsapp.delivered`

## 10. Integrations

- SMS aggregator, WhatsApp BSP, email SES
