'use strict';

const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');
const AUDIT_FILE = path.join(DATA_DIR, 'audit.jsonl');

function ensureDir() {
  try {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  } catch (_) {}
}

/**
 * @param {string} action
 * @param {import('./policy').AiContext} ctx
 * @param {Record<string, unknown>} [extra]
 */
function appendAudit(action, ctx, extra = {}) {
  ensureDir();
  const row = {
    action,
    ts: new Date().toISOString(),
    tenant_id: ctx.tenant_id,
    user_id: ctx.user_id,
    role: ctx.role,
    ...extra,
  };
  fs.appendFileSync(AUDIT_FILE, JSON.stringify(row) + '\n', 'utf8');
}

module.exports = { appendAudit, AUDIT_FILE };
