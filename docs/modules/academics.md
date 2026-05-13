# Module spec — Academics

## 1. Summary

| Field | Value |
|--------|--------|
| Module key | `academics` (cross-cutting: grades, syllabus, assignments) |
| One-liner | Curriculum delivery, gradebook, and progress analytics. |
| UX anchor | **Notion**-clean resource pages + **Canvas/Instructure**-style gradebook density. |

## 2. Screens & routes

| Screen | Route | Roles | Gate |
|--------|-------|-------|------|
| Teacher gradebook | `/teacher/...` | teacher | — |
| Student progress | `/student/...` | student | `lms_integration` deep links |
| Web academics / reports | `/web/...` | hod, admin | — |

## 3. Widgets & states

- Chart widgets (`fl_chart`); skeletons for class overview

## 4. Permissions

| Permission | Roles |
|------------|-------|
| `grades.read` | student, parent, teacher |
| `grades.write` | teacher |
| `grades.lock_term` | hod, principal |

## 5. API

| Method | Path | Notes |
|--------|------|--------|
| GET | `/v1/tenants/{id}/courses/{courseId}/grades` | ETag |
| PUT | `/v1/tenants/{id}/grades/bulk` | revision check |

## 6. Offline & sync

- Cache term roster and latest grades; writes queued with conflict UI on lock

## 7. Validations

- Weighted components must sum to 100%; cannot edit locked terms

## 8. Reports

- Report cards PDF; board format exports

## 9. Events

- `grade.updated`, `term.locked`

## 10. Integrations

- LMS LTI, SCORM (future)
