# ERP delivery roadmap — phases, team, infra (INR bands)

## Phases

| Phase | Duration (typical) | Scope | Exit criteria |
|-------|---------------------|-------|----------------|
| **0 — Foundation** | 4–6 weeks | Tenant profile + entitlements in API; `snapshot_version` propagation; Flutter parse path live ([`TenantProfile`](../lib/domain/entities/tenant_profile.dart)) | Toggle module off → 403 + UI hides nav |
| **1 — Pilot modules** | 8–12 weeks | Harden Attendance, Fees, Communication + outbox | 3 design partners on prod; crash-free &gt; 99.5% |
| **2 — Academics + reports** | 8–10 weeks | Gradebook, PDF report cards, exports | Load test 5k CCU |
| **3 — Ops** | 10–14 weeks | Hostel, Transport, Inventory, HR depth | Larges tables paginated; role matrix signed off |
| **4 — Enterprise** | ongoing | SSO, dedicated shard, SLA playbook, DR drills | RPO/RTO agreed |
| **5 — AI governance** | parallel | Orchestrator, PII scrub, budgets, audit ([`SUPER_ADMIN_CONSOLE.md`](SUPER_ADMIN_CONSOLE.md)) | AI Ultra SKU in billing |

## Team (steady state, rough FTE)

- Mobile Flutter: 2–3
- Backend API: 2–4
- SRE / DevOps: 0.5–1
- ML/AI engineer: 0.5–1 (phase 5+)
- Product design: 1
- QA automation: 1

## Infra cost bands (indicator INR / month, cloud-agnostic)

| Scale (MAU students) | Compute + DB | Storage + CDN | Observability | Total band |
|----------------------|--------------|-----------------|---------------|------------|
| &lt; 5k | 15k–45k | 5k–15k | 5k–12k | **25k–70k** |
| 5k–30k | 45k–150k | 15k–40k | 12k–30k | **70k–220k** |
| 30k–100k | 150k–450k | 40k–120k | 30k–80k | **220k–650k** |

Add **23% GST** on Indian vendor invoices as applicable; excludes SMS/WhatsApp pass-through.

## Competitive advantages (execution)

- Offline attendance + outbox in **one** student/teacher app
- **Single-click** white-label via `theme_tokens` + `nav_graph`
- **EntitlementSnapshot** avoids forked binaries per institution
