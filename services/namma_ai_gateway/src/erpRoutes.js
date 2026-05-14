'use strict';

const { canInvokeTool } = require('./policy');
const { runToolRedacted } = require('./tools');
const { appendAudit } = require('./audit');

function parseCtx(req) {
  const h = req.headers['x-namma-ai-context'];
  if (!h || typeof h !== 'string') return null;
  try {
    const json = Buffer.from(h, 'base64url').toString('utf8');
    return JSON.parse(json);
  } catch {
    try {
      const json = Buffer.from(h, 'base64').toString('utf8');
      return JSON.parse(json);
    } catch {
      return null;
    }
  }
}

/**
 * @param {import('http').IncomingMessage} req
 * @param {import('http').ServerResponse} res
 * @param {URL} url
 */
function handleErpAnalytics(req, res, url) {
  const ctx = parseCtx(req);
  if (!ctx) {
    res.writeHead(401, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'missing_context' }));
  }

  const tail = url.pathname.replace('/v1/erp/analytics/', '');
  let toolId = '';
  if (tail === 'institution-health') toolId = 'institutional_health_snapshot';
  else if (tail === 'fee-aging') toolId = 'fee_aging_summary';
  else if (tail === 'department-performance') toolId = 'department_performance_summary';
  else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'unknown_report' }));
  }

  if (!canInvokeTool(toolId, ctx)) {
    appendAudit('ai.erp.denied', ctx, { toolId });
    res.writeHead(403, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'forbidden' }));
  }

  appendAudit('ai.erp.analytics', ctx, { toolId });
  const payload = runToolRedacted(toolId, ctx, '');
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ ok: true, data: payload }));
}

module.exports = { handleErpAnalytics };
