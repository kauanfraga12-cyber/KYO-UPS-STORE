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

export async function onRequest(context){
  const request = context.request;
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  const b = await parseBody(request);
  const token = b.mp_token || (context.env && context.env.MP_ACCESS_TOKEN);
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
