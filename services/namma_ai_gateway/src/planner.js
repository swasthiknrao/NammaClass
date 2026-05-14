'use strict';

const { canInvokeTool } = require('./policy');
const { appendAudit } = require('./audit');
const { searchRag } = require('./rag');

function pickTools(message, ctx) {
  const m = (message || '').toLowerCase();
  const picks = [];
  if (m.includes('fee') || m.includes('dues')) picks.push('fee_aging_summary');
  if (m.includes('department') || m.includes('class performance')) picks.push('department_performance_summary');
  if (m.includes('health') || m.includes('institution')) picks.push('institutional_health_snapshot');
  if (m.includes('library') || m.includes('overdue')) picks.push('library_overdues_summary');
  if (m.includes('bus') || m.includes('transport')) picks.push('transport_delay_summary');
  if (m.includes('notice') || m.includes('circular')) picks.push('draft_notice');
  if (m.includes('attendance') || m.includes('ward') || m.includes('child')) {
    if (ctx.role === 'parent') picks.push('ward_attendance_summary');
    else if (ctx.role === 'student') picks.push('my_attendance_summary');
    else picks.push('department_performance_summary');
  }
  if (!picks.length) {
    if (ctx.role === 'parent') picks.push('ward_attendance_summary');
    else if (ctx.role === 'student') picks.push('my_attendance_summary');
    else picks.push('institutional_health_snapshot');
  }
  const uniq = [...new Set(picks)];
  return uniq.filter((t) => canInvokeTool(t, ctx));
}

/**
 * @param {string} message
 * @param {import('./policy').AiContext} ctx
 * @param {import('./tools').runToolRedacted} runToolRedacted
 */
async function planAndExecute(message, ctx, runToolRedacted) {
  const tools = pickTools(message, ctx);
  const results = [];
  for (const t of tools.slice(0, 3)) {
    appendAudit('ai.tool.call', ctx, { tool: t });
    results.push(await Promise.resolve(runToolRedacted(t, ctx, message)));
  }
  const rag = searchRag(ctx.tenant_id, message, ctx);
  if (rag.length) appendAudit('ai.retrieval', ctx, { hits: rag.length });
  return { tools, results, rag };
}

module.exports = { pickTools, planAndExecute };
