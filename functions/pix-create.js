const MP_API = 'https://api.mercadopago.com/v1/payments';

async function parseBody(request){
  try { return await request.json(); } catch (e) { return {}; }
}

function json(body, code){
  return new Response(JSON.stringify(body), {
    status: code || 200,
    headers: { 'Content-Type': 'application/json' }
  });
}

export async function onRequest(context){
  const request = context.request;
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  const b = await parseBody(request);
  const token = b.mp_token || (context.env && context.env.MP_ACCESS_TOKEN);
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
