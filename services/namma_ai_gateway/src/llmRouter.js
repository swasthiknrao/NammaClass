'use strict';

const https = require('https');

function localNarrative(message, plan, ctx) {
  const role = ctx.role || 'user';
  let t = `**Namma AI** (${role})\n\n`;
  t += `Here is what I can share from authorized institutional data for your question:\n\n`;
  for (const r of plan.results) {
    t += '- ' + JSON.stringify(r).slice(0, 400) + '\n';
  }
  if (plan.rag && plan.rag.length) {
    t += '\n**From institutional knowledge base:**\n';
    for (const h of plan.rag) {
      t += '- ' + h.snippet + '\n';
    }
  }
  t += '\n*All figures are demo aggregates; production uses live ERP with full audit.*\n';
  return t;
}

/**
 * @param {string} message
 * @param {{ results: unknown[], rag: unknown[] }} plan
 * @param {Record<string, unknown>} ctx
 */
function cloudComplete(message, plan, ctx) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) return Promise.resolve(localNarrative(message, plan, ctx));

  const body = JSON.stringify({
    model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
    messages: [
      {
        role: 'system',
        content:
          'You are Namma AI, an institutional assistant. Only use the JSON tool results and RAG snippets provided; never invent private student data. Be concise, Markdown.',
      },
      {
        role: 'user',
        content: `User question: ${message}\n\nTool JSON: ${JSON.stringify(plan.results)}\n\nRAG: ${JSON.stringify(plan.rag)}`,
      },
    ],
    temperature: 0.3,
  });

  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: 'api.openai.com',
        path: '/v1/chat/completions',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer ' + apiKey,
          'Content-Length': Buffer.byteLength(body),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (c) => (data += c));
        res.on('end', () => {
          try {
            const j = JSON.parse(data);
            const txt = j.choices?.[0]?.message?.content;
            resolve(txt || localNarrative(message, plan, ctx));
          } catch (e) {
            resolve(localNarrative(message, plan, ctx));
          }
        });
      },
    );
    req.on('error', () => resolve(localNarrative(message, plan, ctx)));
    req.write(body);
    req.end();
  });
}

/**
 * @param {string} message
 * @param {{ results: unknown[], rag: unknown[] }} plan
 * @param {Record<string, unknown>} ctx
 * @param {(s: string) => void} onChunk
 */
async function completeStreaming(message, plan, ctx, onChunk) {
  const route = process.env.OPENAI_API_KEY ? 'cloud' : 'local';
  onChunk('');
  const text = await cloudComplete(message, plan, ctx);
  for (const ch of text) {
    onChunk(ch);
    await new Promise((r) => setTimeout(r, 2));
  }
  return route;
}

module.exports = { completeStreaming, localNarrative };
