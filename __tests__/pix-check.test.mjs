import test from 'node:test';
import assert from 'node:assert';
import { handler } from '../netlify/functions/pix-check.mjs';

function fakeFetch(status, body){
  return async () => ({ ok: status < 400, status, json: async () => body });
}

test('returns fallback when MP_ACCESS_TOKEN missing', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  delete process.env.MP_ACCESS_TOKEN;
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ id: 1 }) });
    assert.equal(JSON.parse(res.body).fallback, true);
  } finally {
    if (old !== undefined) process.env.MP_ACCESS_TOKEN = old;
  }
});

test('maps MP status to paid', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  process.env.MP_ACCESS_TOKEN = 'TEST-123';
  globalThis.fetch = fakeFetch(200, { id: 500, status: 'approved' });
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ id: 500 }) });
    assert.equal(JSON.parse(res.body).status, 'paid');
  } finally {
    delete globalThis.fetch;
    if (old !== undefined) process.env.MP_ACCESS_TOKEN = old;
  }
});

test('maps pending MP status', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  process.env.MP_ACCESS_TOKEN = 'TEST-123';
  globalThis.fetch = fakeFetch(200, { id: 500, status: 'pending' });
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ id: 500 }) });
    assert.equal(JSON.parse(res.body).status, 'pending');
  } finally {
    delete globalThis.fetch;
    if (old !== undefined) process.env.MP_ACCESS_TOKEN = old;
  }
});
