# Namma AI Gateway

Institutional AI plane for NammaClass: **role-aware tools**, **SSE streaming**, optional **OpenAI** completion, in-process **RAG** (tenant-scoped), **JSONL audit**, **rate limits**, and **alert cron** hooks.

## Run locally

```bash
cd services/namma_ai_gateway
npm install
# optional: export OPENAI_API_KEY=sk-...
npm start
```

Default port **8787**. Flutter: `--dart-define=NAMMA_AI_BASE_URL=http://127.0.0.1:8787`

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/health` | Liveness |
| POST | `/v1/ai/chat` | SSE stream (`text/event-stream`) |
| GET | `/v1/erp/analytics/institution-health` | RBAC aggregate (JWT context headers) |
| POST | `/v1/rag/ingest` | Dev-only: index snippet (requires `X-Admin-Token`) |
| GET | `/v1/ai/alerts/pending` | Latest automation alerts |
| POST | `/v1/ai/actions/draft-notice/approve` | Stub approval for write-gated drafts |

## Security model

The Flutter app sends a signed-in **context** document (demo). Production: replace with signed JWT verification and call ERP services with service credentials — never trust client-supplied row scope without server-side membership checks against the ERP database.
