# NammaClass — INR subscription & metering catalog (template)

**Disclaimer:** Figures are **indicative planning bands** for product/finance calibration—not quotes. Add applicable **GST** and state levies as per Indian tax advice.

## Commercial structure

- **Primary index:** active **student MAU** (monthly active unique students with ≥1 meaningful session), billed in **slabs** (e.g. 0–1k, 1k–5k, 5k–15k, 15k+).
- **Staff seats:** bundled base seats + purchasable add-on packs (teachers/admin).
- **Modules:** independently toggleable SKUs; annual contracts typically **12–15% discount** vs monthly run-rate.
- **Professional services:** data migration, hardware (RFID/GPS), accreditation reports—**quoted separately**.

## Plan tiers (bundles + caps)

Maps to `plan_tier` in [entitlement_snapshot.schema.json](schemas/entitlement_snapshot.schema.json).

| Tier | Target | Included modules (typical) | Limits (typical) |
|------|--------|----------------------------|------------------|
| **Basic** | Small schools | Attendance, Communication (SMS light), Notices | 1 campus, low API rate, 5 GB storage |
| **Standard** | + Fees, Academics | + Fees, Timetable, basic Reports | 3 campuses, 25 GB, WhatsApp optional add-on |
| **Premium** | Full ops | + LMS connector, Events, Library, Complaints | 10 campuses, 100 GB, higher API rate |
| **Enterprise** | Groups / universities | + Hostel, Transport, Inventory, HR/Payroll depth, SSO | SLA, dedicated shard option, unlimited campuses (fair use) |
| **AI Ultra** | Enterprise + AI | All Enterprise + AI Insights, chatbot, doc tools | AI token pool + guardrails, audit export |

## Module SKUs — indicative monthly (INR per 1,000 student MAU band)

Per-module **toggle** updates `entitlement_snapshot.modules.{key}.enabled`.

| Module key | Low (₹/1k MAU/mo) | High (₹/1k MAU/mo) | Setup (one-time, ₹) | Notes |
|------------|-------------------|--------------------|----------------------|--------|
| attendance | 8,000 | 18,000 | 50,000–150,000 | QR/biometric integration extra |
| fees | 12,000 | 28,000 | 80,000–250,000 | Payment gateway pass-through |
| academics | 15,000 | 35,000 | 75,000–200,000 | Gradebook, syllabus |
| timetable | 6,000 | 14,000 | 40,000–120,000 | Solver AI = AI meter |
| lms | 10,000 | 25,000 | 60,000–180,000 | LTI connectors |
| hostel | 18,000 | 45,000 | 100,000–350,000 | Per-bed optional pricing |
| transport | 15,000 | 40,000 | 120,000–400,000 | GPS device integration |
| library | 8,000 | 20,000 | 50,000–150,000 | RFID optional |
| inventory | 7,000 | 18,000 | 50,000–140,000 | |
| payroll / hr | 20,000 | 55,000 | 150,000–500,000 | Statutory filings = services |
| communication | 5,000 | 12,000 | 25,000–80,000 | Channel costs metered below |
| ai_insights | 15,000 | 60,000+ | 100,000–300,000 | Pairs with AI token pack |
| canteen | 6,000 | 15,000 | 40,000–100,000 | Payment wallet ops |
| events | 4,000 | 10,000 | 25,000–75,000 | |
| placement | 8,000 | 22,000 | 50,000–150,000 | |
| research | 10,000 | 30,000 | 75,000–250,000 | |
| accreditation | 12,000 | 35,000 | 100,000–300,000 | Report packs |
| alumni | 5,000 | 12,000 | 40,000–100,000 | |
| visitor mgmt | 4,000 | 10,000 | 30,000–80,000 | |
| complaints | 3,000 | 8,000 | 20,000–60,000 | |
| online_exam | 12,000 | 35,000 | 80,000–250,000 | Proctoring third-party |
| admission_crm | 15,000 | 40,000 | 100,000–350,000 | |
| digital_id | 5,000 | 14,000 | 60,000–180,000 | Card printers |
| face_recognition | 10,000 | 28,000 | 120,000–400,000 | GPU/edge optional |
| qr_attendance | (often under attendance) | — | — | SKU flag on attendance |
| gps_tracking | (bundled in transport) | — | — | |
| health_records | 6,000 | 16,000 | 40,000–120,000 | |
| counselling | 5,000 | 14,000 | 35,000–100,000 | |
| scholarship | 5,000 | 12,000 | 30,000–90,000 | |
| internship_tracking | 6,000 | 15,000 | 40,000–110,000 | |

**Maintenance (AMC):** typically **12–18%** of annual license for Standard+; includes minor upgrades and support tickets within SLA.

## Usage meters (pass-through + platform margin)

| Meter | Unit | Indicative INR | Notes |
|-------|------|----------------|-------|
| SMS | per 160-char segment | TRAI/regulated tariff + 5–15% | Routed per tenant DLT template |
| WhatsApp | per template / conversation | Meta BSP pricing + margin | Template governance per tenant |
| Object storage | GB-month | ₹15–₹45 / GB | Hot vs archive tier |
| AI tokens | 1k token blocks | vendor cost + 20–40% | Local models = different SKU |
| API overrun | per 10k calls | ₹50–₹200 | Soft limit → upsell |

## Snapshot → client

- Billing updates **`snapshot_version`**; clients refetch [`GET /v1/tenants/{id}/entitlements` per API_STYLE_GUIDE](API_STYLE_GUIDE.md) or embedded snapshot on profile.
- Hard blocks: `403 module_disabled` when server rejects toggled-off routes.
