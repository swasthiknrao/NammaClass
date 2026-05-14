'use strict';

const DIM = 64;

/**
 * Deterministic pseudo-embedding for demo (no external API).
 * @param {string} text
 */
function embedText(text) {
  const v = new Array(DIM).fill(0);
  const s = text.toLowerCase();
  for (let i = 0; i < s.length; i++) {
    v[i % DIM] += s.charCodeAt(i) / 255;
  }
  const norm = Math.sqrt(v.reduce((a, x) => a + x * x, 0)) || 1;
  return v.map((x) => x / norm);
}

function dot(a, b) {
  let t = 0;
  for (let i = 0; i < a.length; i++) t += a[i] * b[i];
  return t;
}

/**
 * @param {number[]} qv
 * @param {{ vec: number[] }[]} docs
 * @param {number} k
 */
function cosineTopK(qv, docs, k) {
  return docs
    .map((d) => ({ d, s: dot(qv, d.vec) }))
    .sort((a, b) => b.s - a.s)
    .slice(0, k)
    .map((x) => x.d);
}

module.exports = { embedText, cosineTopK };
