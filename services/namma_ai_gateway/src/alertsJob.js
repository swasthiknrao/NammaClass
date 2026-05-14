'use strict';

const fs = require('fs');
const path = require('path');
const { appendAudit } = require('./audit');
const { runToolRedacted } = require('./tools');
const { canInvokeTool } = require('./policy');

const DATA_DIR = path.join(__dirname, '..', 'data');
const ALERTS_FILE = path.join(DATA_DIR, 'alerts.jsonl');

function ensureDir() {
  try {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  } catch (_) {}
}

/** @type {import('./policy').AiContext} */
const SYSTEM_CTX = {
  user_id: 'system_scheduler',
  tenant_id: 'SCH_001',
  role: 'admin',
  permissions: ['students:read', 'fees:read', 'web:access', 'approvals:write'],
  features: ['ai_insights', 'transport', 'library'],
  allowed_tool_ids: [],
};

function runChecks() {
  ensureDir();
  const samples = [
    { type: 'fee_risk', tool: 'fee_aging_summary' },
    { type: 'attendance_risk', tool: 'department_performance_summary' },
    { type: 'dropout_risk', tool: 'department_performance_summary' },
  ];
  for (const s of samples) {
    if (!canInvokeTool(s.tool, SYSTEM_CTX)) continue;
    const data = runToolRedacted(s.tool, SYSTEM_CTX, 'risk scan');
    const row = {
      ts: new Date().toISOString(),
      tenant_id: SYSTEM_CTX.tenant_id,
      alert_type: s.type,
      preview: JSON.stringify(data).slice(0, 400),
    };
    fs.appendFileSync(ALERTS_FILE, JSON.stringify(row) + '\n', 'utf8');
    appendAudit('ai.automation.alert', SYSTEM_CTX, { alert_type: s.type });
  }
}

function startAlertScheduler() {
  const intervalMs = Number(process.env.NAMMA_AI_ALERT_INTERVAL_MS || 300_000);
  setInterval(runChecks, intervalMs);
}

/**
 * @param {string} tenantId
 */
function readPendingAlerts(tenantId) {
  ensureDir();
  if (!fs.existsSync(ALERTS_FILE)) return [];
  const lines = fs.readFileSync(ALERTS_FILE, 'utf8').trim().split('\n').filter(Boolean);
  const out = [];
  for (let i = lines.length - 1; i >= 0 && out.length < 20; i--) {
    try {
      const row = JSON.parse(lines[i]);
      if (row.tenant_id === tenantId || tenantId === 'unknown') out.push(row);
    } catch (_) {}
  }
  return out;
}

module.exports = { startAlertScheduler, readPendingAlerts, runChecks };
