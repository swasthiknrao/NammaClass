'use strict';

const { appendAudit } = require('./audit');
const { planAndExecute } = require('./planner');
const { runToolRedacted } = require('./tools');
const { completeStreaming } = require('./llmRouter');

function sse(res) {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream; charset=utf-8',
    'Cache-Control': 'no-cache, no-transform',
    Connection: 'keep-alive',
  });
}

function writeEvent(res, event, data) {
  res.write(`event: ${event}\n`);
  res.write(`data: ${JSON.stringify(data)}\n\n`);
}

/**
 * @param {import('http').IncomingMessage} req
 * @param {import('http').ServerResponse} res
 * @param {Record<string, unknown>} body
 */
async function handleChatSse(req, res, body) {
  sse(res);
  const ctx = /** @type {import('./policy').AiContext} */ (body.context || {});
  const message = String(body.message || '');
  appendAudit('ai.session.start', ctx, {
    conversation_id: body.conversation_id,
    msg_len: message.length,
  });

  writeEvent(res, 'scope', {
    tenant_id: ctx.tenant_id,
    role: ctx.role,
    branch_id: ctx.branch_id,
    ward_student_ids: ctx.ward_student_ids,
  });

  const plan = await planAndExecute(message, ctx, runToolRedacted);
  writeEvent(res, 'tool_result', { results: plan.results, rag: plan.rag });

  let charCount = 0;
  const route = await completeStreaming(message, plan, ctx, (chunk) => {
    charCount += chunk.length;
    writeEvent(res, 'token', { t: chunk });
  });
  appendAudit('ai.llm.route', ctx, { route });
  appendAudit('ai.response', ctx, { approx_chars: charCount });
  writeEvent(res, 'done', {});
  res.end();
}

module.exports = { handleChatSse };
