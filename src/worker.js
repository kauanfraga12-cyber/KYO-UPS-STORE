const MP_API = 'https://api.mercadopago.com/v1/payments';

function json(body, code){
  return new Response(JSON.stringify(body), {
    status: code || 200,
    headers: { 'Content-Type': 'application/json' }
  });
}

async function parseBody(request){
  try { return await request.json(); } catch (e) { return {}; }
}

function mapStatus(s){
  switch (s) {
    case 'approved': return 'paid';
    case 'rejected':
    case 'cancelled':
    case 'charged_back': return 'rejected';
    case 'expired': return 'expired';
    default: return 'pending';
  }
}

async function pixCreate(request, env){
  const b = await parseBody(request);
  const token = b.mp_token || env.MP_ACCESS_TOKEN;
  if (!token) return json({ fallback: true, pix_manual: true });

  const amount = Number(b.amount);
  if (!amount || amount <= 0) return json({ error: 'Invalid amount' }, 400);

  const payload = {
    transaction_amount: amount,
    description: String(b.description || 'Pedido UPS LOLI ' + (b.order_id || '')),
    payment_method_id: 'pix',
    payer: { email: String(b.email || 'cliente@kyo.store') },
    external_reference: String(b.order_id || '')
  };

  try {
    const r = await fetch(MP_API, {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json',
        'X-Idempotency-Key': String(b.order_id || 'KYO-' + Date.now())
      },
      body: JSON.stringify(payload)
    });
    const data = await r.json();
    if (!r.ok) return json({ error: 'MP error', detail: data }, 502);

    const tx = data.point_of_interaction && data.point_of_interaction.transaction_data;
    return json({
      id: data.id,
      status: data.status,
      copy_paste: tx ? tx.qr_code : null,
      qr_base64: tx ? tx.qr_code_base64 : null
    });
  } catch (e) {
    return json({ error: 'MP request failed', detail: String(e && e.message || e) }, 502);
  }
}

async function pixCheck(request, env){
  const b = await parseBody(request);
  const token = b.mp_token || env.MP_ACCESS_TOKEN;
  if (!token) return json({ fallback: true });

  const id = Number(b.id);
  if (!id) return json({ error: 'Invalid id' }, 400);

  try {
    const r = await fetch(MP_API + '/' + id, {
      method: 'GET',
      headers: { 'Authorization': 'Bearer ' + token }
    });
    const data = await r.json();
    if (!r.ok) return json({ error: 'MP error', detail: data }, 502);
    return json({ id: data.id, status: mapStatus(data.status) });
  } catch (e) {
    return json({ error: 'MP request failed', detail: String(e && e.message || e) }, 502);
  }
}

export default {
  async fetch(request, env){
    const url = new URL(request.url);
    const path = url.pathname;

    if (path === '/pix-create' && request.method === 'POST') {
      return pixCreate(request, env);
    }
    if (path === '/pix-check' && request.method === 'POST') {
      return pixCheck(request, env);
    }

    return env.ASSETS.fetch(request);
  }
};
