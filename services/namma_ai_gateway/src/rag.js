'use strict';

const { embedText, cosineTopK } = require('./rag_embedding');

/** @type {{ id: string, tenant_id: string, text: string, vec: number[], meta: Record<string,string> }[]} */
const CORPUS = [];

function seedCorpus() {
  if (CORPUS.length) return;
  const rows = [
    {
      id: 'pol-1',
      tenant_id: '*',
      text: 'Fee refund requests must be approved by the principal within 10 working days.',
      meta: { type: 'policy', sensitivity: 'internal' },
    },
    {
      id: 'cir-1',
      tenant_id: 'SCH_001',
      text: 'Annual day rehearsal for Grade 8-10 is scheduled next Friday after school.',
      meta: { type: 'circular', sensitivity: 'public' },
    },
  ];
  for (const r of rows) {
    CORPUS.push({ ...r, vec: embedText(r.text) });
  }
}

/**
 * @param {Record<string, unknown>} body
 */
function ingestSnippet(body) {
  seedCorpus();
  const text = String(body.text || '');
  const tenant_id = String(body.tenant_id || '*');
  const id = String(body.id || 'ing_' + Math.random().toString(36).slice(2));
  CORPUS.push({
    id,
    tenant_id,
    text,
    vec: embedText(text),
    meta: body.meta && typeof body.meta === 'object' ? body.meta : {},
  });
}

/**
 * @param {string} tenantId
 * @param {string} query
 * @param {import('../policy').AiContext} ctx
 */
function searchRag(tenantId, query, ctx) {
  seedCorpus();
  const qv = embedText(query);
  const scoped = CORPUS.filter(
    (c) => c.tenant_id === tenantId || c.tenant_id === '*',
  );
  return cosineTopK(qv, scoped, 4).map((c) => ({
    id: c.id,
    snippet: c.text.slice(0, 280),
    meta: c.meta,
  }));
}

module.exports = { ingestSnippet, searchRag, CORPUS };
