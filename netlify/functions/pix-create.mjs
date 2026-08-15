const MP_API = 'https://api.mercadopago.com/v1/payments';

function parseBody(raw){
  try { return JSON.parse(raw || '{}'); } catch (e) { return {}; }
}

function error(body, code){
  return { statusCode: code, body: JSON.stringify(body) };
}

export async function handler(event){
  if (event.httpMethod !== 'POST') return error({ error: 'Method not allowed' }, 405);
  const b = parseBody(event.body);
  const token = b.mp_token || process.env.MP_ACCESS_TOKEN;
  if (!token) return { statusCode: 200, body: JSON.stringify({ fallback: true, pix_manual: true }) };

  const amount = Number(b.amount);
  if (!amount || amount <= 0) return error({ error: 'Invalid amount' }, 400);

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
    if (!r.ok) return error({ error: 'MP error', detail: data }, 502);

    const tx = data.point_of_interaction && data.point_of_interaction.transaction_data;
    return {
      statusCode: 200,
      body: JSON.stringify({
        id: data.id,
        status: data.status,
        copy_paste: tx ? tx.qr_code : null,
        qr_base64: tx ? tx.qr_code_base64 : null
      })
    };
  } catch (e) {
    return error({ error: 'MP request failed', detail: String(e && e.message || e) }, 502);
  }
}
