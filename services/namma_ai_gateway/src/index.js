'use strict';

const http = require('http');
const { URL } = require('url');

const { handleChatSse } = require('./chat');
const { appendAudit } = require('./audit');
const { checkRateLimit } = require('./ratelimit');
const { handleErpAnalytics } = require('./erpRoutes');
const { ingestSnippet, searchRag } = require('./rag');
const { readPendingAlerts } = require('./alertsJob');
const { startAlertScheduler } = require('./alertsJob');

const PORT = Number(process.env.PORT || 8787);
const ADMIN_TOKEN = process.env.NAMMA_AI_ADMIN_TOKEN || '';

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', (c) => {
      raw += c;
      if (raw.length > 2_000_000) reject(new Error('payload too large'));
    });
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        resolve(JSON.parse(raw));
      } catch (e) {
        reject(e);
      }
    });
  });
}

function sendJson(res, code, obj) {
  res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(obj));
}

function setCors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

const server = http.createServer(async (req, res) => {
  setCors(res);
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  const url = new URL(req.url || '/', `http://${req.headers.host}`);

  try {
    if (req.method === 'GET' && url.pathname === '/health') {
      return sendJson(res, 200, { ok: true, service: 'namma-ai-gateway' });
    }

    if (req.method === 'GET' && url.pathname === '/v1/ai/alerts/pending') {
      const tenantId = url.searchParams.get('tenant_id') || 'unknown';
      return sendJson(res, 200, { alerts: readPendingAlerts(tenantId) });
    }

    if (req.method === 'GET' && url.pathname.startsWith('/v1/erp/analytics/')) {
      return handleErpAnalytics(req, res, url);
    }

    if (req.method === 'POST' && url.pathname === '/v1/rag/ingest') {
      const token = req.headers['x-admin-token'];
      if (!ADMIN_TOKEN || token !== ADMIN_TOKEN) {
        return sendJson(res, 401, { error: 'unauthorized' });
      }
      const body = await readJsonBody(req);
      ingestSnippet(body);
      return sendJson(res, 200, { ok: true });
    }

    if (req.method === 'POST' && url.pathname === '/v1/ai/chat') {
      const body = await readJsonBody(req);
      const ctx = body.context || {};
      const uid = ctx.user_id || 'anon';
      const rl = checkRateLimit(uid);
      if (!rl.ok) {
        appendAudit('ai.rate_limited', ctx, { resetInMs: rl.resetInMs });
        return sendJson(res, 429, { error: 'rate_limited', resetInMs: rl.resetInMs });
      }
      return handleChatSse(req, res, body);
    }

    if (req.method === 'POST' && url.pathname === '/v1/ai/actions/draft-notice/approve') {
      const body = await readJsonBody(req);
      appendAudit('ai.action.approve_stub', body.context || {}, { draftId: body.draft_id });
      return sendJson(res, 200, { ok: true, status: 'queued' });
    }

    sendJson(res, 404, { error: 'not_found' });
  } catch (e) {
    console.error(e);
    sendJson(res, 500, { error: 'internal_error' });
  }
});

server.listen(PORT, () => {
  console.log(`Namma AI Gateway listening on :${PORT}`);
  startAlertScheduler();
});
