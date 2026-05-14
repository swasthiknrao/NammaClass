'use strict';

const windows = new Map();

const WINDOW_MS = 60_000;
const MAX_REQ = 60;

/**
 * @param {string} userId
 */
function checkRateLimit(userId) {
  const now = Date.now();
  let w = windows.get(userId);
  if (!w || now - w.start > WINDOW_MS) {
    w = { start: now, count: 0 };
    windows.set(userId, w);
  }
  w.count += 1;
  if (w.count > MAX_REQ) {
    return { ok: false, resetInMs: WINDOW_MS - (now - w.start) };
  }
  return { ok: true };
}

module.exports = { checkRateLimit };
