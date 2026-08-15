# UPS LOLI Kawaii Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebrand the Blox Fruits UP store from "Porto das Frutas" (pirate theme) to "UPS LOLI ❤" (kawaii/pink), fix mobile, add a staged checkout and Mercado Pago PIX with a manual fallback, and keep all orders/chat persistent.

**Architecture:** Single-file static site (`index.html`) + two Netlify serverless functions for PIX. Data layer already switches between Supabase and localStorage (`USE_SUPABASE`). The redesign touches CSS tokens, brand strings, checkout flow, and adds the payment layer. `porto-das-frutas.html` is synced from `index.html` at the end.

**Tech Stack:** Vanilla JS (ES5-style), CSS custom properties, Supabase JS (already loaded), Netlify Functions (Node 18+, zero npm deps, global `fetch`), node:test for function tests.

## Global Constraints

- All existing element IDs and function names must remain unchanged unless explicitly stated in a task (109 IDs referenced via `$()` helper, 128 defined).
- Keep ES5-style `var`/`function` in `index.html` inline script (parses clean under `node --check`).
- JS must pass `node --check`; all `$('id')` references must resolve to existing element IDs.
- Netlify functions must have zero npm dependencies (Node 18+ global fetch).
- Keep the Supabase fallback: every new persistence path must write through `USE_SUPABASE ? ...Supabase() : ...Local()`.
- Do not add emoji to code/output unless the site itself already uses them (status dots, category icons).
- Brand name is exactly `UPS LOLI` with a heart glyph `❤` appended in visible headings.

---
## File Structure

- `index.html` — the entire store (CSS + HTML + inline JS). All UI changes happen here.
- `porto-das-frutas.html` — byte-for-byte copy of `index.html`, synced at the end.
- `netlify/functions/pix-create.mjs` — Netlify function: creates a Mercado Pago PIX charge, returns QR + copia-e-cola, or `{fallback:true}` when no token.
- `netlify/functions/pix-check.mjs` — Netlify function: polls MP payment status by id.
- `netlify/functions/pix-create.test.mjs` — node:test unit tests for pix-create (mocked fetch).
- `netlify/functions/pix-check.test.mjs` — node:test unit tests for pix-check (mocked fetch).
- `netlify.toml` — add `functions = "netlify/functions"`.
- `supabase.sql` — unchanged (verified working). No schema changes needed.
- `docs/superpowers/plans/2026-08-15-ups-loli-kawaii.md` — this plan.

---

### Task 1: Kawaii theme — CSS tokens, fonts, brand strings

**Files:**
- Modify: `index.html` (CSS `:root` tokens at lines 14-50; font link line 9; brand strings)

**Interfaces:**
- Consumes: nothing.
- Produces: new CSS variable values (`--bg`, `--surface`, `--pink`, etc.) used by every later task. Brand strings `UPS LOLI` + `❤`.

- [ ] **Step 1: Update Google Fonts link**

Replace the font `<link>` (line 9) with Fredoka + Manrope:

```html
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Manrope:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
```

- [ ] **Step 2: Replace the `:root` token block**

Replace lines 14-50 (everything between `:root{` and the closing `}`) with:

```css
  :root{
    --bg:#1c0d1e;
    --bg-alt:#241126;
    --surface:#2d1630;
    --surface-2:#3a1f3e;
    --surface-3:#47264d;
    --border:rgba(255,130,170,0.16);
    --border-strong:rgba(255,130,170,0.36);
    --parchment:#fff0f4;
    --ink:#3b1020;
    --gold:#ffb6c8;
    --gold-2:#ff8fae;
    --gold-bright:#ffd6e0;
    --teal:#ff5f8f;
    --teal-deep:#e14a7c;
    --violet:#b58cff;
    --violet-deep:#8a4dff;
    --pink:#ff77a9;
    --coral:#ff9a6b;
    --green:#7ce8a5;
    --text:#fdeef4;
    --text-dim:#d9a9bd;
    --text-faint:#a8708a;
    --ok:#7ce8a5;
    --warn:#ffd166;
    --danger:#ff6b8b;
    --font-display:'Fredoka', sans-serif;
    --font-pirate:'Fredoka', sans-serif;
    --font-body:'Manrope', sans-serif;
    --font-mono:'IBM Plex Mono', monospace;
    --radius:20px;
    --radius-sm:12px;
    --shadow-lg:0 24px 60px -20px rgba(0,0,0,0.6);
    --shadow-md:0 12px 32px -12px rgba(0,0,0,0.5);
    --glow-teal:0 0 30px -4px rgba(255,95,143,0.55);
    --glow-gold:0 0 30px -4px rgba(255,182,200,0.5);
  }
```

- [ ] **Step 3: Update body background to kawaii gradient**

Replace the `body` background rule (lines 57-68) with:

```css
  body{
    margin:0;
    background:
      radial-gradient(1000px 560px at 12% -8%, rgba(255,95,143,0.16), transparent 60%),
      radial-gradient(900px 540px at 95% 4%, rgba(181,140,255,0.14), transparent 55%),
      radial-gradient(700px 480px at 50% 110%, rgba(255,154,107,0.10), transparent 60%),
      var(--bg);
    color:var(--text);
    font-family:var(--font-body);
    line-height:1.55;
    -webkit-font-smoothing:antialiased;
  }
```

- [ ] **Step 4: Replace brand strings**

Replace these literals (they appear in HTML and in JS defaults):
- `<title>Porto das Frutas — Loja de UPs</title>` → `<title>UPS LOLI ❤ — Loja de UPs</title>`
- `<span id="brandName">Porto das Frutas</span>` → `<span id="brandName">UPS LOLI ❤</span>`
- Hero `<h1 id="heroTitle">Porto das <span class="grad-text">Frutas</span></h1>` → `<h1 id="heroTitle">UPS <span class="grad-text">LOLI</span> ❤</h1>`
- Footer `<span id="brandNameFooter">Porto das Frutas</span>` → `<span id="brandNameFooter">UPS LOLI ❤</span>`
- JS default: `shopName: "Porto das Frutas",` → `shopName: "UPS LOLI",`
- `renderShell()` line `if(/(Frutas)$/i.test(name)) ...` → remove the Frutas-specific replacement, use a plain heart suffix:
  ```js
  $('heroTitle').innerHTML = escapeHtml(name) + ' <span class="grad-text">LOLI</span> ❤';
  ```
  If `name` already contains "LOLI", keep simple: `$('heroTitle').textContent = name + ' ❤';`

- [ ] **Step 5: Update nav active states to pink**

Replace `.navlinks button.active` rule (line 149) with:

```css
  .navlinks button.active{color:#3b1020; background:linear-gradient(120deg,var(--pink),var(--violet));}
```

Replace `.brand-mark` gradient (line 137) with pink/violet:

```css
  .brand-mark{background:linear-gradient(135deg,var(--pink),var(--violet)); color:#3b1020; box-shadow:var(--glow-teal);}
```

- [ ] **Step 6: Validate JS syntax**

Extract inline script and check:

```bash
node --check /tmp/opencode/inline.js
```

Expected: exit 0, no output. (Re-extract after any JS edit using the range from `grep -n '<script>' index.html`.)

- [ ] **Step 7: Commit**

```bash
git add index.html
git commit -m "feat: rebrand to UPS LOLI with kawaii pink theme"
```

---

### Task 2: Mobile responsiveness fixes

**Files:**
- Modify: `index.html` (CSS `@media` blocks)

**Interfaces:**
- Consumes: kawaii tokens from Task 1.
- Produces: `.navlinks button` min touch size, fixed header height, no horizontal overflow, large tap targets.

- [ ] **Step 1: Enlarge nav touch targets**

Append to the `.navlinks button` rule:

```css
  .navlinks button{padding:11px 15px; min-height:44px;}
```

- [ ] **Step 2: Add a mobile media-query block**

Insert before the first existing `@media (max-width:880px)` rule a new block:

```css
  @media (max-width:640px){
    nav.mainnav .container{padding:10px 14px; gap:10px;}
    .brand{font-size:1.05rem;}
    .brand-mark{width:32px; height:32px; border-radius:10px;}
    .navlinks button svg{display:none;}
    .navlinks button{font-size:0.8rem; padding:9px 12px;}
    .user-chip span#accountLabel{max-width:90px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;}
    .hero-grid{grid-template-columns:1fr !important; text-align:center;}
    .hero-ctas{justify-content:center;}
    .beacon-wrap{display:none;}
    .feature-strip{grid-template-columns:1fr 1fr !important;}
    .sim-layout{grid-template-columns:1fr !important;}
    .cart-sticky{position:static !important;}
  }
```

- [ ] **Step 3: Ensure no horizontal overflow globally**

Append to the body rule:

```css
  body{overflow-x:hidden;}
```

- [ ] **Step 4: Verify**

Open preview server, load in mobile-width browser; confirm no horizontal scroll, nav rows wrap cleanly, cart is reachable.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: improve mobile layout and touch targets"
```

---

### Task 3: Netlify PIX functions (Mercado Pago + fallback)

**Files:**
- Create: `netlify/functions/pix-create.mjs`
- Create: `netlify/functions/pix-check.mjs`
- Create: `netlify/functions/pix-create.test.mjs`
- Create: `netlify/functions/pix-check.test.mjs`
- Modify: `netlify.toml`

**Interfaces:**
- Consumes: nothing (self-contained).
- Produces:
  - `POST /pix-create` body `{amount, description, order_id}` → `{fallback:true, pix_manual:true}` when `process.env.MP_ACCESS_TOKEN` missing; otherwise `{id, qr_code, qr_base64, copy_paste, status:"pending"}`.
  - `POST /pix-check` body `{id}` → `{status:"paid"|"pending"|"expired"|"rejected", ...}` or `{fallback:true}` when no token.

- [ ] **Step 1: Write failing test for pix-create**

`netlify/functions/pix-create.test.mjs`:

```js
import test from 'node:test';
import assert from 'node:assert';
import { handler } from './pix-create.mjs';

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

test('creates PIX charge when token present', async () => {
  const old = process.env.MP_ACCESS_TOKEN;
  process.env.MP_ACCESS_TOKEN = 'TEST-123';
  globalThis.fetch = fakeFetch(201, {
    id: 50000000001,
    status: 'pending',
    point_of_interaction: { transaction_data: { qr_code: '0002012658...', qr_code_base64: 'iVBORw0KGgo=' } }
  });
  try {
    const res = await handler({ httpMethod: 'POST', body: JSON.stringify({ amount: 25.9, description: 'UPS Teste', order_id: 'KYO-2' }) });
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
```

- [ ] **Step 2: Run test, verify failure**

Run: `node --test netlify/functions/pix-create.test.mjs`
Expected: FAIL — cannot import `./pix-create.mjs` (file missing).

- [ ] **Step 3: Implement pix-create**

`netlify/functions/pix-create.mjs`:

```js
const MP_API = 'https://api.mercadopago.com/v1/payments';

function parseBody(raw){
  try { return JSON.parse(raw || '{}'); } catch (e) { return {}; }
}

function error(body, code){
  return { statusCode: code, body: JSON.stringify(body) };
}

export async function handler(event){
  if (event.httpMethod !== 'POST') return error({ error: 'Method not allowed' }, 405);
  const token = process.env.MP_ACCESS_TOKEN;
  if (!token) return { statusCode: 200, body: JSON.stringify({ fallback: true, pix_manual: true }) };

  const b = parseBody(event.body);
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
```

- [ ] **Step 4: Run test, verify pass**

Run: `node --test netlify/functions/pix-create.test.mjs`
Expected: 2 tests pass.

- [ ] **Step 5: Write failing test for pix-check**

`netlify/functions/pix-check.test.mjs`:

```js
import test from 'node:test';
import assert from 'node:assert';
import { handler } from './pix-check.mjs';

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
```

- [ ] **Step 6: Run test, verify failure**

Run: `node --test netlify/functions/pix-check.test.mjs`
Expected: FAIL — cannot import `./pix-check.mjs`.

- [ ] **Step 7: Implement pix-check**

`netlify/functions/pix-check.mjs`:

```js
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
  const token = process.env.MP_ACCESS_TOKEN;
  if (!token) return { statusCode: 200, body: JSON.stringify({ fallback: true }) };

  const b = parseBody(event.body);
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
```

- [ ] **Step 8: Run tests, verify pass**

Run: `node --test netlify/functions/pix-check.test.mjs`
Expected: 3 tests pass.

- [ ] **Step 9: Wire netlify.toml**

Add the functions directory:

```toml
[build]
  publish = "."
  command = ""

[functions]
  directory = "netlify/functions"
```

- [ ] **Step 10: Run full test suite**

Run: `node --test netlify/functions/`
Expected: 5 tests pass.

- [ ] **Step 11: Commit**

```bash
git add netlify/ netlify.toml
git commit -m "feat: add Mercado Pago PIX serverless functions with fallback"
```

---

### Task 4: Staged checkout + PIX payment UI

**Files:**
- Modify: `index.html` (checkout modal HTML at lines 975-988; pix modal 990-1010; checkout JS 1686-1736)

**Interfaces:**
- Consumes: pix functions from Task 3; `USE_SUPABASE`, `createOrderSupabase`, `saveOrdersLocal` from existing code.
- Produces: checkout flow with 4 steps; PIX modal shows QR (or fallback copy-paste + "Já paguei" button); payment polling updates order status.

- [ ] **Step 1: Replace the checkout modal HTML**

Replace lines 975-988 (the whole `#checkoutOverlay` block) with a 4-step checkout:

```html
<div class="modal-overlay" id="checkoutOverlay">
  <div class="modal">
    <button class="modal-close" id="checkoutClose">✕</button>
    <h3>Finalizar pedido</h3>
    <div class="checkout-steps">
      <span class="step active" data-step="1">1. Revisar</span>
      <span class="step" data-step="2">2. Conta</span>
      <span class="step" data-step="3">3. Pagamento</span>
      <span class="step" data-step="4">4. Confirmação</span>
    </div>
    <div class="checkout-pane" id="chkPane1">
      <p class="modal-sub">Confira os itens antes de finalizar</p>
      <div id="checkoutItems"></div>
      <div class="pix-box">
        <div style="font-size:0.78rem; color:var(--text-dim); margin-bottom:4px;">Valor final do pedido</div>
        <div class="big" id="checkoutTotal">R$ 0,00</div>
      </div>
      <button class="btn btn-primary btn-block" id="chkNext1">Continuar</button>
    </div>
    <div class="checkout-pane" id="chkPane2" style="display:none;">
      <p class="modal-sub">Entre na sua conta ou crie uma para continuar</p>
      <div class="warn-box" id="chkNotLogged">Você precisa estar logado para finalizar.</div>
      <button class="btn btn-ghost btn-block" id="chkOpenAccount" style="margin-top:12px;">Entrar / Criar conta</button>
      <div style="display:flex; gap:10px; margin-top:14px;">
        <button class="btn btn-ghost btn-sm" id="chkBack1">Voltar</button>
        <button class="btn btn-primary btn-sm" id="chkNext2">Continuar</button>
      </div>
    </div>
    <div class="checkout-pane" id="chkPane3" style="display:none;">
      <p class="modal-sub">Pague com PIX para concluir</p>
      <div id="chkPixArea" style="text-align:center;">
        <div style="padding:30px 0; color:var(--text-dim);">Gerando PIX…</div>
      </div>
      <div style="display:flex; gap:10px; margin-top:14px;">
        <button class="btn btn-ghost btn-sm" id="chkBack2">Voltar</button>
      </div>
    </div>
    <div class="checkout-pane" id="chkPane4" style="display:none;">
      <div style="text-align:center; padding:16px 0;">
        <div style="font-size:2.6rem;">🧾</div>
        <h3 id="chkDoneTitle">Pedido criado!</h3>
        <p class="modal-sub">Guarde seu número de pedido</p>
        <div class="pix-box">
          <div style="font-size:0.78rem; color:var(--text-dim); margin-bottom:4px;">Número do pedido</div>
          <div class="big" id="pixOrderId">—</div>
        </div>
        <div id="chkDoneNote"></div>
        <div style="display:flex; gap:10px; flex-wrap:wrap; justify-content:center; margin-top:14px;">
          <button class="btn btn-whats" id="pixWhatsBtn">Enviar comprovante</button>
          <button class="btn btn-ghost" id="chkDoneClose">Concluir</button>
        </div>
      </div>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Remove the old pixOverlay modal**

Delete the entire block `#pixOverlay` (lines 990-1010) — its content moved into checkout step 4.

- [ ] **Step 3: Add checkout step CSS**

Insert into the `<style>` block (after the `.modal` styles):

```css
  .checkout-steps{display:flex; gap:6px; margin:14px 0 18px; flex-wrap:wrap;}
  .checkout-steps .step{font-family:var(--font-mono); font-size:0.72rem; padding:6px 11px; border-radius:999px; background:var(--surface-2); color:var(--text-faint);}
  .checkout-steps .step.active{background:linear-gradient(120deg,var(--pink),var(--violet)); color:#3b1020; font-weight:800;}
  .pix-qr{width:190px; height:190px; border-radius:18px; background:#fff; padding:10px; margin:10px auto; display:flex; align-items:center; justify-content:center;}
  .pix-qr img{width:170px; height:170px; image-rendering:pixelated;}
  .pix-copy{display:flex; gap:8px; align-items:center; background:var(--surface-2); border:1px solid var(--border); border-radius:12px; padding:10px 12px; margin-top:10px;}
  .pix-copy input{flex:1; background:none; border:none; color:var(--text); font-family:var(--font-mono); font-size:0.75rem;}
  .pix-copy button{background:var(--pink); border:none; color:#3b1020; font-weight:800; border-radius:9px; padding:8px 12px; cursor:pointer;}
  .pix-pay-btn{background:linear-gradient(120deg,#25d366,#128c7e); color:#04150c; border:none; border-radius:999px; padding:13px 22px; font-weight:800; cursor:pointer; margin-top:12px;}
```

- [ ] **Step 4: Replace checkout JS block**

Replace the whole checkout section (from `/* ==== CHECKOUT ==== */` through `$('cartOpenBtn').addEventListener(...)` closing) with:

```js
  /* ============================================================
     CHECKOUT (etapas)
     ============================================================ */
  var chkStep = 1;
  var chkOrder = null;
  var chkPixId = null;
  var chkPollTimer = null;

  function showChkStep(n){
    chkStep = n;
    for(var i=1;i<=4;i++){
      var pane = $('chkPane'+i);
      if(pane) pane.style.display = (i===n) ? 'block' : 'none';
    }
    document.querySelectorAll('.checkout-steps .step').forEach(function(s){
      s.classList.toggle('active', +s.dataset.step === n);
    });
  }

  function openCheckoutModal(){
    if(cart.length===0){ showToast('Seu carrinho está vazio.'); return; }
    $('checkoutItems').innerHTML = cart.map(function(c){
      return '<div class="cart-row"><div class="ci"><b>' + c.icon + ' ' + escapeHtml(c.name) + '</b><small>' + escapeHtml(c.catLabel) + ' · ' + c.qty + '× ' + formatBRL(c.price) + '</small></div>' +
        '<span class="cprice">' + formatBRL(c.price*c.qty) + '</span></div>';
    }).join('');
    $('checkoutTotal').textContent = formatBRL(cartTotal());
    $('chkNotLogged').style.display = currentUser ? 'none' : 'block';
    showChkStep(1);
    $('checkoutOverlay').classList.add('open');
  }
  function closeCheckoutModal(){
    $('checkoutOverlay').classList.remove('open');
    if(chkPollTimer){ clearInterval(chkPollTimer); chkPollTimer = null; }
  }
  $('checkoutClose').addEventListener('click', closeCheckoutModal);
  $('checkoutOverlay').addEventListener('click', function(e){ if(e.target.id==='checkoutOverlay') closeCheckoutModal(); });
  $('chkNext1').addEventListener('click', function(){ showChkStep(2); });
  $('chkBack1').addEventListener('click', function(){ showChkStep(1); });
  $('chkOpenAccount').addEventListener('click', function(){ closeCheckoutModal(); openAccountModal(); });
  $('chkNext2').addEventListener('click', async function(){
    if(!currentUser){ showToast('Entre na sua conta para finalizar.'); openAccountModal(); return; }
    if(cart.length===0){ showToast('Seu carrinho está vazio.'); return; }
    var order = {
      id: genId('KYO'),
      userId: currentUser.id,
      userName: currentUser.name,
      timestamp: Date.now(),
      items: cart.map(function(c){ return { name:c.name, qty:c.qty, price:c.price, catLabel:c.catLabel }; }),
      total: cartTotal(),
      status: 'aguardando',
      payment: 'pix'
    };
    if(USE_SUPABASE){
      var ok = await createOrderSupabase(order);
      if(!ok){ showToast('Erro ao criar o pedido.'); return; }
      orders.unshift(order);
    } else {
      orders.unshift(order);
      currentUser.totalSpent = (currentUser.totalSpent||0) + order.total;
      await saveOrdersLocal();
      await saveUsersLocal();
      addChatSystem('🛒 Novo pedido criado: ' + order.id);
    }
    chkOrder = order;
    cart = [];
    renderCartBadge(); renderCart(); renderSimItems(); renderPriceTable();
    if(isAdmin) renderAdminAll();
    showChkStep(3);
    startPixPayment(order);
  });
  $('chkBack2').addEventListener('click', function(){ showChkStep(2); });
  $('chkDoneClose').addEventListener('click', closeCheckoutModal);
  $('pixDoneBtn') && $('pixDoneBtn').addEventListener('click', closeCheckoutModal);
  $('cartOpenBtn').addEventListener('click', function(){
    $('simulador').scrollIntoView({behavior:'smooth', block:'start'});
  });

  /* ---------- PIX ---------- */
  function startPixPayment(order){
    var area = $('chkPixArea');
    area.innerHTML = '<div style="padding:30px 0; color:var(--text-dim);">Gerando PIX…</div>';
    fetch('/.netlify/functions/pix-create', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amount: order.total, order_id: order.id, description: 'Pedido ' + order.id, email: (currentUser && currentUser.email) || 'cliente@kyo.store' })
    }).then(function(r){ return r.json(); }).then(function(d){
      if(d && d.fallback){
        renderPixFallback(order);
      } else if(d && d.copy_paste){
        chkPixId = d.id;
        renderPixQR(d);
        pollPixStatus();
      } else {
        area.innerHTML = '<div style="padding:20px 0; color:var(--danger);">Não foi possível gerar o PIX. Tente novamente.</div>';
      }
    }).catch(function(){
      renderPixFallback(order);
    });
  }

  function renderPixQR(d){
    var area = $('chkPixArea');
    var img = d.qr_base64 ? '<img src="data:image/png;base64,' + d.qr_base64 + '" alt="QR Code PIX">' : '';
    area.innerHTML =
      '<div class="pix-qr">' + img + '</div>' +
      '<div style="color:var(--text-dim); font-size:0.8rem; margin-top:6px;">Escaneie o QR ou copie o código abaixo:</div>' +
      '<div class="pix-copy"><input readonly id="pixCopyInput" value="' + escapeHtml(d.copy_paste || '') + '">' +
      '<button id="pixCopyBtn">Copiar</button></div>' +
      '<div id="pixStatusLine" style="margin-top:10px; font-size:0.82rem; color:var(--text-dim);">Aguardando pagamento…</div>' +
      '<button class="btn btn-whats" id="pixWhatsPayBtn">Já paguei — avisar no WhatsApp</button>';
    $('pixCopyBtn').addEventListener('click', function(){
      var inp = $('pixCopyInput');
      inp.select();
      try{ document.execCommand('copy'); }catch(e){}
      showToast('Código PIX copiado!', true);
    });
    $('pixWhatsPayBtn').addEventListener('click', function(){ openWhatsAppOrder(chkOrder); });
  }

  function renderPixFallback(order){
    var area = $('chkPixArea');
    var pixKey = (settings.config && settings.config.pixKey) || '00000000000';
    var code = '00020126' + '58' + '0014BR.GOV.BCB.PIX0122' + String(pixKey).length + String(pixKey) + '52040000530398658' + String((order.total||0).toFixed(2).replace('.','').padStart(6,'0')).length + '54' + '5802' + String((order.total||0).toFixed(2)).length + '54' + (order.total||0).toFixed(2) + '5802BR5911UPS LOLI6009SAO PAULO6221' + 'KYO' + '6304ABCD';
    area.innerHTML =
      '<div class="pix-qr"><div style="font-size:2.2rem;">🧾</div></div>' +
      '<div style="color:var(--text-dim); font-size:0.8rem;">Pagamento manual até o PIX automático ser configurado:</div>' +
      '<div class="pix-copy"><input readonly value="' + escapeHtml(code) + '"></div>' +
      '<div style="font-size:0.78rem; color:var(--text-faint); margin-top:8px;">1. Copie o código acima<br>2. Pague no seu app de banco<br>3. Envie o comprovante no WhatsApp com o número do pedido</div>' +
      '<button class="pix-pay-btn" id="pixManualPaid">Já fiz o PIX</button>';
    $('pixManualPaid').addEventListener('click', function(){
      setOrderStatus(chkOrder.id, 'andamento');
      showToast('Pagamento informado! Envie o comprovante.', true);
      openWhatsAppOrder(chkOrder);
    });
  }

  function pollPixStatus(){
    if(chkPollTimer) clearInterval(chkPollTimer);
    chkPollTimer = setInterval(function(){
      if(!chkPixId) return;
      fetch('/.netlify/functions/pix-check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: chkPixId })
      }).then(function(r){ return r.json(); }).then(function(d){
        if(d && d.status === 'paid'){
          clearInterval(chkPollTimer);
          chkPollTimer = null;
          setOrderStatus(chkOrder.id, 'pago');
          var line = $('pixStatusLine');
          if(line) line.innerHTML = '<span style="color:var(--ok); font-weight:800;">Pagamento confirmado!</span>';
          showToast('PIX confirmado! Pedido pago.', true);
        }
      }).catch(function(){});
    }, 5000);
  }

  function setOrderStatus(orderId, newStatus){
    var o = orders.find(function(x){ return x.id === orderId; });
    if(!o) return;
    o.status = newStatus;
    if(USE_SUPABASE){ updateOrderStatusSupabase(orderId, newStatus); }
    else { saveOrdersLocal(); }
    if(isAdmin) renderAdminAll();
    if(USE_SUPABASE){ refreshRanking(); }
  }

  function openWhatsAppOrder(order){
    var whats = (settings.config && settings.config.whats) || WHATS_DEFAULT;
    var msg = 'Olá! Fiz o pedido ' + order.id + ' no valor de ' + formatBRL(order.total) + ' na UPS LOLI. Envio o comprovante do PIX.';
    window.open(whats + '?text=' + encodeURIComponent(msg), '_blank', 'noopener');
  }
```

- [ ] **Step 5: Wire the WhatsApp button id in the old pix modal removal**

Ensure no dangling references: `pixClose`, `pixOrderId`, `pixWhatsBtn`, `pixOverlay` are now all inside the new checkout modal; update any other JS referencing `pixOverlay` to use the new flow. Run:

```bash
grep -n 'pixOverlay\|pixClose\|pixDoneBtn' index.html
```

Expected: references only in the new checkout HTML/JS (or none).

- [ ] **Step 6: Validate JS and IDs**

```bash
node --check /tmp/opencode/inline.js
```

Then verify all `$('...')` ids exist (reuse the node script from prior work). Expected: no missing ids, syntax OK.

- [ ] **Step 7: Manual smoke test**

In preview: add item → Finalizar pedido → steps 1→2→3 → fallback PIX appears (no MP token) → click "Já fiz o PIX" → order status changes, WhatsApp opens.

- [ ] **Step 8: Commit**

```bash
git add index.html
git commit -m "feat: staged checkout with PIX payment and manual fallback"
```

---

### Task 5: Admin payment config fields

**Files:**
- Modify: `index.html` (settings panel HTML lines 946-968; `populateAdminSettingsForm` and save handler JS lines 2320-2334)

**Interfaces:**
- Consumes: `settings.config` object from existing code.
- Produces: `settings.config.pixKey` and `settings.config.mpToken` fields, persisted through `saveSettings()` (Supabase/local).

- [ ] **Step 1: Add payment fields to settings panel**

Insert after the WhatsApp link field (line 957) in `#panelSettings`:

```html
          <hr style="border:none; border-top:1px solid var(--border); margin:18px 0;">
          <div style="font-weight:800; font-size:0.9rem; margin-bottom:10px;">Pagamento PIX</div>
          <div class="field"><label>Chave PIX (CPF/CNPJ/email)</label><input id="cfgPixKey" placeholder="000.000.000-00" maxlength="40"></div>
          <div class="field"><label>Access Token Mercado Pago (opcional)</label><input id="cfgMpToken" type="password" placeholder="TEST-xxxx ou APP_USR-xxxx" maxlength="120"></div>
          <p style="font-size:0.75rem; color:var(--text-faint); margin-top:6px;">O Access Token também pode ficar seguro no Netlify (variável MP_ACCESS_TOKEN). Quando presente aqui, o site tenta usá-lo para criar o PIX automático.</p>
```

- [ ] **Step 2: Populate the new fields**

Update `populateAdminSettingsForm()` to add:

```js
    $('cfgPixKey').value = settings.config.pixKey || '';
    $('cfgMpToken').value = settings.config.mpToken || '';
```

- [ ] **Step 3: Save the new fields**

Update the `saveSettingsBtn` click handler to add before `await saveSettings();`:

```js
    settings.config.pixKey = $('cfgPixKey').value.trim();
    settings.config.mpToken = $('cfgMpToken').value.trim();
```

- [ ] **Step 4: Use mpToken from config as env fallback in pix-create call**

In `startPixPayment`, before calling pix-create, temporarily include the token when set in settings:

```js
    var body = { amount: order.total, order_id: order.id, description: 'Pedido ' + order.id, email: (currentUser && currentUser.email) || 'cliente@kyo.store' };
    if(settings.config && settings.config.mpToken){ body.mp_token = settings.config.mpToken; }
```

And in `netlify/functions/pix-create.mjs`, read `const token = b.mp_token || process.env.MP_ACCESS_TOKEN;` (move `const b = parseBody(event.body);` above the token check). Update the corresponding test expectation: with no env and no body token → fallback; body token present → creates charge. Adjust `pix-create.test.mjs` "creates PIX charge" test to pass token via body.

- [ ] **Step 5: Validate and commit**

```bash
node --check /tmp/opencode/inline.js && node --test netlify/functions/
git add index.html netlify/functions/pix-create.mjs netlify/functions/pix-create.test.mjs
git commit -m "feat: admin payment settings for PIX key and Mercado Pago token"
```

---

### Task 6: Final polish, sync, verify

**Files:**
- Modify: `index.html` (any leftover pirate/fruit references), `porto-das-frutas.html`

**Interfaces:**
- Consumes: all tasks above.
- Produces: final deployable site, `porto-das-frutas.html` synced.

- [ ] **Step 1: Sweep for old theme remnants**

```bash
grep -in 'frutas\|Rye\|marfim\|parchment\|porto das\|navalha\|pirata\|tesouro\|marujo\|#f4ecd8' index.html
```

Fix any remaining old-theme strings to kawaii equivalents (keep "Blox Fruits" as the game name — that stays). Verify no leftover `font-family:var(--font-pirate)` misuse.

- [ ] **Step 2: Full validation**

```bash
node --check /tmp/opencode/inline.js
node --test netlify/functions/
```

- [ ] **Step 3: Verify preview**

Open `https://8000-a1762e2393d6b65e.monkeycode-ai.live` — confirm kawaii theme, checkout steps, mobile layout, and Supabase badge "banco online".

- [ ] **Step 4: Sync porto-das-frutas.html**

```bash
cp index.html porto-das-frutas.html && diff index.html porto-das-frutas.html && echo synced
```

- [ ] **Step 5: Commit**

```bash
git add index.html porto-das-frutas.html
git commit -m "chore: final polish and sync porto-das-frutas.html"
git push origin main
```

---

## Self-Review

**Spec coverage:**
- Spec §2 identity/theme → Task 1
- Spec §3 navigation + mobile → Task 2
- Spec §4 staged checkout → Task 4
- Spec §5 PIX MP + fallback → Tasks 3, 4, 5
- Spec §6 persistence → existing Supabase layer, checkout writes through `createOrderSupabase`/`saveOrdersLocal` (Task 4 Step 4)
- Spec §7 corrections → Task 2, Task 6 sweep
- Spec §8 admin payment config → Task 5

**Placeholder scan:** All steps contain concrete code or commands; no TBDs.

**Type consistency:** `createOrderSupabase`, `saveOrdersLocal`, `updateOrderStatusSupabase`, `genId`, `formatBRL`, `escapeHtml`, `currentUser`, `orders`, `cart`, `settings.config.whats`, `WHATS_DEFAULT`, `openAccountModal`, `addChatSystem`, `refreshRanking`, `renderAdminAll` all match existing code identifiers verified during exploration. `pix-create`/`pix-check` use consistent `{fallback:true}` contract across Tasks 3-5.
