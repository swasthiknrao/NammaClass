'use strict';

/**
 * @param {unknown} payload
 * @param {string} role
 */
function redactToolPayload(payload, role) {
  const hideSalary = !['admin', 'superAdmin', 'accountant'].includes(role);
  const str = JSON.stringify(payload);
  let out = str.replace(/\b\d{10}\b/g, '**********');
  if (hideSalary) {
    out = out.replace(/"salary"[^,}]+/gi, '"salary":"[redacted]"');
  }
  try {
    return JSON.parse(out);
  } catch {
    return { summary: '[redacted]' };
  }
}

module.exports = { redactToolPayload };
