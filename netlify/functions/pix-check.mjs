const MP_API = 'https://api.mercadopago.com/v1/payments';

function parseBody(raw){
  try { return JSON.parse(raw || '{}'); } catch (e) { return {}; }
}

function error(body, code){
  return { statusCode: code, body: JSON.stringify(body) };
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

export async function handler(event){
  if (event.httpMethod !== 'POST') return error({ error: 'Method not allowed' }, 405);
  const b = parseBody(event.body);
  const token = b.mp_token || process.env.MP_ACCESS_TOKEN;
  if (!token) return { statusCode: 200, body: JSON.stringify({ fallback: true }) };

  const id = Number(b.id);
  if (!id) return error({ error: 'Invalid id' }, 400);

  try {
    const r = await fetch(MP_API + '/' + id, {
      method: 'GET',
      headers: { 'Authorization': 'Bearer ' + token }
    });
    const data = await r.json();
    if (!r.ok) return error({ error: 'MP error', detail: data }, 502);
    return { statusCode: 200, body: JSON.stringify({ id: data.id, status: mapStatus(data.status) }) };
  } catch (e) {
    return error({ error: 'MP request failed', detail: String(e && e.message || e) }, 502);
  }
}
