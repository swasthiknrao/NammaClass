# Module spec — Attendance

## 1. Summary

| Field | Value |
|--------|--------|
| Module key | `attendance` (maps `NcFeature.biometric`, `face_recognition`, QR flows as flags) |
| One-liner | Mark, correct, and audit attendance with offline-first class sessions. |
| UX anchor | Precision utility: **Square Register** clarity + calendar density like **Google Calendar**. |

## 2. Screens & routes

| Screen | Route | Roles | Gate |
|--------|-------|-------|------|
| Teacher session picker | `/teacher/attendance` | teacher | — |
| Calendar / bulk mark | `/teacher/attendance/calendar` | teacher | biometric optional |
| Student view | `/student/attendance` | student | — |
| Parent child view | `/parent/attendance` | parent | — |
| Admin corrections | `/web/...` (reports) | admin, principal | — |

## 3. Widgets & states

- Skeleton: `attendance_bones` ([`lib/core/loading/bones/attendance_bones.dart`](../lib/core/loading/bones/attendance_bones.dart))
- Offline: banner “Queued marks will sync”
- Optimistic row flips; rollback on 409

## 4. Permissions

| Permission | Roles |
|------------|-------|
| `attendance.mark` | teacher |
| `attendance.correct` | admin, principal |
| `attendance.view_class` | teacher, hod |
| `attendance.view_own` | student, parent |

## 5. API

| Method | Path | Notes |
|--------|------|--------|
| GET | `/v1/tenants/{id}/attendance/sessions` | cursor |
| POST | `/v1/tenants/{id}/attendance/batch` | `Idempotency-Key` |
| PATCH | `/v1/tenants/{id}/attendance/marks/{markId}` | correction |

## 6. Offline & sync

- **Outbox:** `mark_attendance` ([`SyncOperation.markAttendance`](../lib/application/sync/sync_queue_service.dart))
- **Conflict:** server wins on audit records; teacher corrections create new revision rows

## 7. Validations

- Cannot mark future dates unless policy allows; session must belong to teacher’s timetable

## 8. Reports

- Daily/monthly PDF; defaulter list XLSX

## 9. Events

- `attendance.session_opened`, `attendance.marked`, `attendance.corrected`

## 10. Integrations

- RFID/QR scanners; face API edge device
