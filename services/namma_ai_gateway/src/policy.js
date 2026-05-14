'use strict';

/** @typedef {{ user_id: string, tenant_id: string, role: string, permissions: string[], features: string[], ward_student_ids?: string[], department_ids?: string[], branch_id?: string, allowed_tool_ids?: string[] }} AiContext */

const TOOLS = {
  ward_attendance_summary: {
    scopes: ['students:read', 'messages:read'],
    modules: [],
  },
  my_attendance_summary: {
    scopes: ['students:read'],
    modules: [],
  },
  fee_aging_summary: {
    scopes: ['fees:read'],
    modules: [],
  },
  department_performance_summary: {
    scopes: ['students:read'],
    modules: [],
  },
  institutional_health_snapshot: {
    scopes: ['students:read', 'web:access'],
    modules: [],
  },
  library_overdues_summary: {
    scopes: ['library:read'],
    modules: ['library'],
  },
  transport_delay_summary: {
    scopes: ['transport:read', 'students:read'],
    modules: ['transport'],
  },
  draft_notice: {
    scopes: ['web:access'],
    modules: [],
    extra: (ctx) =>
      ['students:write', 'support:write', 'approvals:write'].some((s) =>
        (ctx.permissions || []).includes(s),
      ),
  },
};

function hasAiInsights(ctx) {
  return (ctx.features || []).includes('ai_insights');
}

function hasPerm(ctx, p) {
  return (ctx.permissions || []).includes(p);
}

function hasModule(ctx, m) {
  return (ctx.features || []).includes(m);
}

/**
 * @param {string} toolId
 * @param {AiContext} ctx
 */
function canInvokeTool(toolId, ctx) {
  if (!hasAiInsights(ctx)) return false;
  if (ctx.allowed_tool_ids && ctx.allowed_tool_ids.length) {
    if (!ctx.allowed_tool_ids.includes(toolId)) return false;
  }
  const def = TOOLS[toolId];
  if (!def) return false;
  if (def.modules && def.modules.length) {
    for (const m of def.modules) {
      if (!hasModule(ctx, m)) return false;
    }
  }
  if (def.scopes && def.scopes.length) {
    const ok = def.scopes.some((s) => hasPerm(ctx, s));
    if (!ok) return false;
  }
  if (typeof def.extra === 'function' && !def.extra(ctx)) return false;
  return true;
}

/**
 * @param {AiContext} ctx
 */
function listAllowedTools(ctx) {
  return Object.keys(TOOLS).filter((t) => canInvokeTool(t, ctx));
}

module.exports = { TOOLS, canInvokeTool, listAllowedTools };
