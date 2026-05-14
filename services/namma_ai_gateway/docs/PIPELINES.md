# Namma AI — future feature pipelines

These capabilities are **not** implemented in the app runtime today. Each pipeline should emit **derived, tenant-scoped rows** (or document chunks) consumed only through the **Namma AI Gateway** tool and RAG interfaces — never by attaching raw streams to the LLM.

## 1. Face attendance anomaly

- **Inputs:** biometric / CCTV frames (where legally permitted), enrollment reference photos.
- **Outputs:** `attendance_anomaly_scores` table: `tenant_id`, `student_id`, `session_id`, `score`, `review_status`.
- **AI tool:** `attendance_anomaly_list` (principal/admin, confidential).

## 2. Classroom engagement scoring

- **Inputs:** LMS clickstream, quiz attempts, optional on-device gaze proxies.
- **Outputs:** `engagement_daily` aggregates per class section.
- **AI tool:** `engagement_summary` (teacher: assigned class; HOD: department).

## 3. Smart CCTV insights

- **Inputs:** edge analytics boxes (crowd density, perimeter crossing).
- **Outputs:** `safety_incidents` summaries — no frame URLs in vector index.
- **AI tool:** `safety_pulse` (admin/principal only).

## 4. AI career & placement

- **Outputs:** `student_skill_vectors` from projects and marks (PII-minimized).
- **AI tool:** `career_fit_suggestions` (student self; counsellor wider scope).

## 5. Accreditation pack generator

- **Inputs:** curated policy docs, outcomes data already in ERP.
- **Outputs:** draft SAR sections as versioned documents in object storage.
- **AI tool:** `accreditation_draft_section` (approval-gated writes).

---

**Rule:** each pipeline registers with the same **policy engine** as chat tools; scheduled jobs call `runToolRedacted` equivalents server-side and write **alerts** (see `src/alertsJob.js`).
