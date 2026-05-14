'use strict';

const { redactToolPayload } = require('./redact');

/**
 * Mock ERP aggregates — replace with HTTP calls to erp-api.
 * @param {string} toolId
 * @param {import('./policy').AiContext} ctx
 * @param {string} message
 */
function runTool(toolId, ctx, message) {
  const lower = (message || '').toLowerCase();
  switch (toolId) {
    case 'ward_attendance_summary': {
      const sid = (ctx.ward_student_ids && ctx.ward_student_ids[0]) || 'STU_UNKNOWN';
      return {
        tool: toolId,
        student_id: sid,
        period_days: 30,
        present_pct: 78,
        class_avg_pct: 85,
        at_risk: lower.includes('risk') || 78 < 80,
      };
    }
    case 'my_attendance_summary':
      return {
        tool: toolId,
        student_id: ctx.student_entity_id || ctx.user_id,
        period_days: 30,
        present_pct: 82,
        streak_days: 5,
      };
    case 'fee_aging_summary':
      return {
        tool: toolId,
        buckets: [
          { label: '0-30d', amount_inr: 1_20_000 },
          { label: '31-60d', amount_inr: 45_000 },
          { label: '60d+', amount_inr: 12_000 },
        ],
        phone: '9876543210',
      };
    case 'department_performance_summary':
      return {
        tool: toolId,
        departments: [
          { id: 'CSE', pass_pct: 88, at_risk_count: 6 },
          { id: 'ECE', pass_pct: 81, at_risk_count: 11 },
        ],
      };
    case 'institutional_health_snapshot':
      return {
        tool: toolId,
        attendance_institution_pct: 91,
        fee_collection_pct: 87,
        open_complaints: 4,
        salary: 45000,
      };
    case 'library_overdues_summary':
      return {
        tool: toolId,
        overdue_count: 23,
        top_titles: ['Physics XII', 'Python Basics'],
      };
    case 'transport_delay_summary':
      return {
        tool: toolId,
        delayed_routes: 2,
        fuel_litres_week: 1240,
      };
    case 'draft_notice': {
      const id = 'draft_' + Math.random().toString(36).slice(2, 10);
      return {
        tool: toolId,
        draft_id: id,
        title: 'PTM schedule — draft',
        body_markdown:
          'Dear parents,\n\nThis is an AI-generated draft for review before broadcast.\n\n— Namma AI',
        requires_approval: true,
      };
    }
    default:
      return { error: 'unknown_tool', toolId };
  }
}

/**
 * @param {string} toolId
 * @param {import('./policy').AiContext} ctx
 * @param {string} message
 */
function runToolRedacted(toolId, ctx, message) {
  const raw = runTool(toolId, ctx, message);
  return redactToolPayload(raw, ctx.role);
}

module.exports = { runTool, runToolRedacted };
