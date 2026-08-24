import test from 'node:test';
import assert from 'node:assert';
import { handler } from '../../netlify/functions/pix-create.mjs';

function fakeFetch(status, body){
  return async () => ({ ok: status < 400, status, json: async () => body });
}

test('returns fallback when MP_ACCESS_TOKEN missing', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  delete process.env.MP_ACCESS_TOKEN;
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ amount: 10, order_id: 'KYO-1' }) });
    assert.equal(res.statusCode, 200);
    assert.deepEqual(JSON.parse(res.body), { fallback: true, pix_manual: true });
  } finally {
    if (old !== undefined) process.env.MP_ACCESS_TOKEN = old;
  }
});

test('creates PIX charge when token present in body', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  delete process.env.MP_ACCESS_TOKEN;
  globalThis.fetch = fakeFetch(201, {
    id: 50000000001,
    status: 'pending',
    point_of_interaction: { transaction_data: { qr_code: '0002012658...', qr_code_base64: 'iVBORw0KGgo=' } }
  });
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ amount: 25.9, description: 'UPS Teste', order_id: 'KYO-2', mp_token: 'TEST-123' }) });
    const data = JSON.parse(res.body);
    assert.equal(res.statusCode, 200);
    assert.equal(data.id, 50000000001);
    assert.equal(data.status, 'pending');
    assert.equal(data.copy_paste, '0002012658...');
    assert.equal(data.qr_base64, 'iVBORw0KGgo=');
  } finally {
    delete globalThis.fetch;
    if (old !== undefined) process.env.MP_ACCESS_TOKEN = old;
  }
});

test('returns 400 for invalid amount', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  process.env.MP_ACCESS_TOKEN = 'TEST-123';
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ amount: 0, order_id: 'KYO-3' }) });
    assert.equal(res.statusCode, 400);
  } finally {
    if (old !== undefined) process.env.MP_ACCESS_TOKEN = old;
  }
});
