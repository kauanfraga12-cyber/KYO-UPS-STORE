# Redesign Luxe Sharp + Notificação Social Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the LOLI Ups store visual to Luxe Sharp (square corners, thin borders, premium) and add a social review notification popup system.

**Architecture:** Single-file HTML (`index.html`) with inline CSS/JS. All changes edit `index.html`; after each task, sync `porto-das-frutas.html` byte-identical via `cp`. JS is ES5 (`var`/function), no arrow functions/template literals. Final deploy is automatic via GitHub Pages workflow.

**Tech Stack:** Plain HTML/CSS/JS, no build step, no new dependencies.

## Global Constraints

- JS ES5 only: `var`/function declarations, no arrow functions, no template literals.
- `index.html` and `porto-das-frutas.html` must stay byte-identical after every task (`cp index.html porto-das-frutas.html` + `cmp`).
- Preserve all existing IDs, section IDs (13 sections), admin panel IDs, Supabase/PIX/mascot/splash behavior.
- Terms of service section verbatim unmodified.
- `prefers-reduced-motion` media query must keep disabling animations.
- Commit message style: `feat:`/`fix:`/`style:`/`docs:` prefix, with `Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>`.
- After each commit: `git push origin main`.

---

### Task 1: Luxe Sharp design tokens

**Files:**
- Modify: `index.html:36-78` (the `:root` block)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: current CSS variables.
- Produces: new color/radius/glow variables used by all later tasks: `--radius` (6px), `--radius-sm` (4px), `--bg` `#181022`, `--bg-alt` `#241732`, `--surface` `#2e1d3f`, `--surface-2` `#382352`, `--surface-3` `#4a2f66`, `--pink` `#f77eb4`, `--violet` `#a78bfa`, `--gold` `#f5d9a8`, `--gold-2` `#e8b76a`, `--gold-bright` `#fce8c8`, `--border` `rgba(167,139,250,0.16)`, `--border-strong` `rgba(245,217,168,0.38)`, `--glow-gold` (soft), `--glow-violet` (soft).

- [ ] **Step 1: Replace the `:root` block**

Replace lines 36-78 (`:root{...}`) with:

```css
  :root{
    --bg:#181022;
    --bg-alt:#1f1428;
    --surface:#241732;
    --surface-2:#2e1d3f;
    --surface-3:#382352;
    --border:rgba(167,139,250,0.16);
    --border-strong:rgba(245,217,168,0.38);
    --parchment:#fff6fa;
    --ink:#2b0f26;
    --gold:#f5d9a8;
    --gold-2:#e8b76a;
    --gold-bright:#fce8c8;
    --teal:#f77eb4;
    --teal-deep:#d95f96;
    --violet:#a78bfa;
    --violet-deep:#8a5cf6;
    --pink:#f77eb4;
    --coral:#f0a580;
    --green:#7ce8a5;
    --text:#f6edf7;
    --text-dim:#c9b6d4;
    --text-faint:#8f7a9c;
    --ok:#7ce8a5;
    --warn:#f5d9a8;
    --danger:#ff6b8b;
    --font-display:'Fredoka', sans-serif;
    --font-pirate:'Fredoka', sans-serif;
    --font-body:'Manrope', sans-serif;
    --font-mono:'IBM Plex Mono', monospace;
    --radius:6px;
    --radius-sm:4px;
    --shadow-lg:0 24px 60px -20px rgba(0,0,0,0.65);
    --shadow-md:0 12px 32px -12px rgba(0,0,0,0.55);
    --glow-teal:0 0 26px -6px rgba(247,126,180,0.45);
    --glow-gold:0 0 26px -6px rgba(245,217,168,0.45);
    --glow-violet:0 0 26px -6px rgba(167,139,250,0.45);
    --neon-cyan:#a78bfa;
    --neon-pink:#f77eb4;
    --neon-violet:#8a5cf6;
    --neon-glow-cyan:0 0 20px -6px rgba(167,139,250,0.45);
    --neon-glow-pink:0 0 20px -6px rgba(247,126,180,0.45);
    --neon-glow-violet:0 0 20px -6px rgba(138,92,246,0.45);
  }
```

Note: keep the `--neon-*` names (re-pointed to muted colors) so later rules that reference them still parse.

- [ ] **Step 2: Sync and verify**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
```

- [ ] **Step 3: Commit**

```bash
git add index.html porto-das-frutas.html
git commit -m "style: Luxe Sharp design tokens (square corners, deep palette)
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 2: Body, buttons, forms, nav base styling

**Files:**
- Modify: `index.html` (body block ~85-97, buttons ~202-223, inputs ~101-111, nav ~158-199, statusbar ~129-155, mascot ~695-711)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: new tokens from Task 1.
- Produces: consistent square/crisp base styling used everywhere.

- [ ] **Step 1: Update body background**

Replace the body block (lines 85-97) with:

```css
  body{
    margin:0;
    overflow-x:hidden;
    background:
      radial-gradient(900px 520px at 12% -8%, rgba(247,126,180,0.13), transparent 60%),
      radial-gradient(800px 500px at 95% 4%, rgba(167,139,250,0.12), transparent 55%),
      radial-gradient(600px 460px at 50% 110%, rgba(245,217,168,0.08), transparent 60%),
      var(--bg);
    color:var(--text);
    font-family:var(--font-body);
    line-height:1.55;
    -webkit-font-smoothing:antialiased;
  }
```

- [ ] **Step 2: Buttons — square corners + sweep shine**

Replace the `.btn` block (lines 202-223) with:

```css
  .btn{
    display:inline-flex; align-items:center; justify-content:center; gap:8px; padding:13px 24px; border-radius:var(--radius-sm);
    border:1px solid transparent; font-weight:800; font-size:0.92rem; text-decoration:none; transition:transform .15s, box-shadow .15s, background .15s, filter .15s;
    position:relative; overflow:hidden;
  }
  .btn:active{transform:translateY(1px) scale(0.99);}
  .btn svg{width:17px; height:17px;}
  .btn::after{
    content:''; position:absolute; top:0; left:-120%; width:70%; height:100%;
    background:linear-gradient(100deg, transparent, rgba(255,255,255,0.35), transparent);
    transform:skewX(-20deg); transition:left .45s ease; pointer-events:none;
  }
  .btn:hover::after{left:140%;}
  .btn-primary{background:linear-gradient(120deg,var(--gold),var(--coral)); color:#2b0f26; box-shadow:0 10px 26px -10px rgba(245,217,168,0.5);}
  .btn-primary:hover{filter:brightness(1.07); box-shadow:0 14px 32px -10px rgba(245,217,168,0.65);}
  .btn-teal{background:linear-gradient(120deg,var(--teal),var(--violet)); color:#2b0f26; box-shadow:0 10px 26px -10px rgba(247,126,180,0.5);}
  .btn-teal:hover{filter:brightness(1.07); box-shadow:var(--glow-teal);}
  .btn-ghost{background:transparent; border-color:var(--border-strong); color:var(--text);}
  .btn-ghost:hover{background:var(--surface); border-color:var(--gold);}
  .btn-whats{
    background:linear-gradient(120deg,#25d366,#128c7e); color:#04150c; box-shadow:0 10px 26px -10px rgba(37,211,102,0.5);
  }
  .btn-whats:hover{filter:brightness(1.08);}
  .btn-sm{padding:8px 14px; font-size:0.8rem; border-radius:var(--radius-sm);}
  .btn-danger-outline{background:transparent; border:1px solid rgba(251,113,133,0.5); color:var(--danger);}
  .btn-danger-outline:hover{background:rgba(251,113,133,0.12);}
  .btn-block{width:100%;}
  .btn:disabled{opacity:0.5; cursor:not-allowed; filter:grayscale(0.4);}
```

- [ ] **Step 3: Inputs — crisp focus**

Replace the input/focus blocks (lines 101-111) with:

```css
  input,select,textarea{
    font-family:var(--font-body); color:var(--text); background:var(--surface-2);
    border:1px solid var(--border-strong); border-radius:var(--radius-sm); padding:11px 13px; font-size:0.95rem;
    transition:border-color .15s, box-shadow .15s;
  }
  input:focus,select:focus,textarea:focus{
    outline:none; border-color:var(--violet); box-shadow:0 0 0 3px rgba(167,139,250,0.2);
  }
  input:focus-visible,select:focus-visible,textarea:focus-visible,button:focus-visible,a:focus-visible{
    outline:2px solid var(--violet); outline-offset:2px;
  }
```

- [ ] **Step 4: Nav — square brand mark, underline links, gold cart hover**

Replace `.brand-mark` (line 164-167) radius `12px`→`var(--radius-sm)` and box-shadow `var(--glow-teal)`→`var(--glow-violet)`. Replace `.cart-btn` radius `12px`→`var(--radius-sm)`. Replace `.cart-btn:hover` box-shadow with `var(--glow-gold)`. Keep everything else.

- [ ] **Step 5: Mascot — square corners**

Replace `.mascot-img` border-radius `50%`→`12px` and bubble `border-radius` to `10px 10px 4px 10px` (lines 696-698).

- [ ] **Step 6: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "style: Luxe Sharp buttons, forms, nav and mascot
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 3: Hero redesign (soft glow, trust pills, remove wave divider)

**Files:**
- Modify: `index.html` (hero CSS ~225-311, hero HTML ~792-840)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: tokens + base styles.
- Produces: `.hero-trust span` pill styling, animated counter hook `data-count` on `#beaconLabel`, removal of `.wave-divider`.

- [ ] **Step 1: Replace hero neon CSS with soft glow**

Replace lines 225-268 (neon-grid-bg, neonPulse, hero rules) with:

```css
  .hero{position:relative; overflow:hidden;}
  .hero-grid,.hero-trust,.hero-ctas{position:relative; z-index:1;}
  .hero::before{
    content:''; position:absolute; top:-180px; right:-160px; width:520px; height:520px; border-radius:50%;
    background:radial-gradient(circle, rgba(167,139,250,0.20), transparent 65%); pointer-events:none; z-index:0;
  }
  .hero::after{
    content:''; position:absolute; bottom:-140px; left:-120px; width:420px; height:420px; border-radius:50%;
    background:radial-gradient(circle, rgba(247,126,180,0.16), transparent 65%); pointer-events:none; z-index:0;
  }
  @keyframes gradShift{0%,100%{background-position:0% 50%}50%{background-position:100% 50%}}
  .hero{padding:80px 0 64px;}
  .hero-grid{display:grid; grid-template-columns:1.15fr 0.85fr; gap:48px; align-items:center;}
  @media (max-width:860px){ .hero-grid{grid-template-columns:1fr;} }
  .hero h1{font-size:clamp(2.6rem, 6vw, 4.2rem); line-height:1.06; text-shadow:0 2px 24px rgba(0,0,0,0.45);}
  .hero h1 .grad-text{background-size:200% 200%; animation:gradShift 5s ease-in-out infinite;}
  .hero-particle{position:absolute; bottom:-20px; font-size:1.15rem; opacity:0; animation:floatUp linear infinite; pointer-events:none; z-index:0;}
  @keyframes floatUp{0%{opacity:0; transform:translateY(0) rotate(0)}15%{opacity:.5}85%{opacity:.35}100%{opacity:0; transform:translateY(-560px) rotate(35deg)}}
  .feature-card{transition:transform .22s ease, box-shadow .22s ease, border-color .22s ease;}
  .feature-card:hover{transform:translateY(-5px); box-shadow:0 16px 34px -12px rgba(150,120,255,.45); border-color:var(--violet);}
  .hero p.tagline{font-size:1.06rem; color:var(--text-dim); max-width:46ch; margin-top:18px;}
  .hero-ctas{display:flex; gap:12px; margin-top:30px; flex-wrap:wrap;}
  .hero-trust{display:flex; gap:14px; flex-wrap:wrap; margin-top:30px; font-family:var(--font-mono); font-size:0.74rem; color:var(--text-dim);}
  .hero-trust span{
    display:inline-flex; align-items:center; gap:7px; padding:8px 14px;
    background:var(--surface); border:1px solid var(--border-strong); border-radius:var(--radius-sm);
  }
  .hero-trust svg{width:15px; height:15px; color:var(--gold);}
```

- [ ] **Step 2: Remove the neon grid div and wave divider**

In HTML: delete line 793 `<div class="neon-grid-bg"></div>`. Replace the `.wave-divider` block (lines 833-840) by removing the entire `<div class="wave-divider">...</div>` block. Keep `</section>`.

- [ ] **Step 3: Beacon — square core + label counter hook**

Replace `.beacon` border-radius `50%`→`14px`, `.beacon::before`/`::after` border-radius to `14px` (lines 279-296). Replace `.beacon-core` `border-radius:50%`→`14px` (line 298). Keep the sweep/spin animations. Update beacon-label border-radius `999px`→`var(--radius-sm)`.

- [ ] **Step 4: Add data-count to beacon label HTML**

Find the beacon-label div and add a counter attribute. Current markup (line 828):
`<div class="beacon-label" id="beaconLabel">Loja Aberta</div>`
Replace with:
`<div class="beacon-label" id="beaconLabel" data-count="2400">Loja Aberta</div>`

- [ ] **Step 5: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "style: Luxe Sharp hero with soft glow and trust pills
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 4: Cards, badges, sections, proofs

**Files:**
- Modify: `index.html` (pack-card CSS ~408-435, proof CSS ~240-249, faq CSS ~250-260, section-bg ~692, modal ~566-569, feature-card ~320-331)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: tokens.
- Produces: `.pack-badge` styles (MAIS VENDIDO / LANÇAMENTO / PROMO), rectangular section dividers.

- [ ] **Step 1: Pack cards — Luxe + badges**

Replace lines 408-435 (neonBorder + pack-card block) with:

```css
  .pack-grid{display:grid; grid-template-columns:repeat(auto-fill,minmax(250px,1fr)); gap:18px;}
  .pack-card{
    background:linear-gradient(160deg, var(--surface), var(--bg-alt));
    border:1px solid var(--border-strong); border-radius:var(--radius);
    padding:22px; position:relative; transition:transform .2s, box-shadow .2s, border-color .2s;
  }
  .pack-card:hover{transform:translateY(-4px); border-color:var(--gold); box-shadow:var(--glow-gold);}
  .pack-card.featured{border-color:var(--gold); box-shadow:0 0 0 1px rgba(245,217,168,0.3), 0 18px 44px -16px rgba(245,217,168,0.35);}
  .pack-card .pack-tag{
    position:absolute; top:-11px; right:14px; padding:4px 12px; border-radius:var(--radius-sm);
    background:linear-gradient(120deg, var(--pink), var(--violet));
    color:#fff; font-family:var(--font-mono); font-size:0.7rem; letter-spacing:0.08em;
    box-shadow:var(--glow-violet); text-transform:uppercase;
  }
  .pack-card .pack-icon{font-size:2.2rem; margin-bottom:12px;}
  .pack-card h4{font-size:1.15rem; margin-bottom:8px;}
  .pack-card .pack-desc{font-size:0.84rem; color:var(--text-dim); min-height:40px;}
  .pack-card ul{list-style:none; margin:12px 0 0; padding:0; font-size:0.82rem; color:var(--text-dim);}
  .pack-card li{display:flex; align-items:center; gap:8px; padding:4px 0;}
  .pack-card li::before{content:''; width:6px; height:6px; border-radius:50%; background:var(--teal); flex-shrink:0;}
  .pack-price{display:flex; align-items:baseline; justify-content:space-between; margin-top:16px; padding-top:14px; border-top:1px solid var(--border);}
  .pack-price .now{color:var(--gold-bright); font-weight:700; font-size:1.05rem;}
  .pack-price .was{font-family:var(--font-mono); font-size:0.8rem; color:var(--text-faint); text-decoration:line-through;}
  .pack-badge{
    display:inline-block; padding:3px 9px; margin-top:10px; border-radius:var(--radius-sm);
    font-family:var(--font-mono); font-size:0.66rem; letter-spacing:0.06em; text-transform:uppercase; font-weight:700;
  }
  .pack-badge.bestseller{background:linear-gradient(120deg,var(--gold),var(--gold-2)); color:#3a2408;}
  .pack-badge.launch{background:linear-gradient(120deg,var(--violet),var(--violet-deep)); color:#fff;}
  .pack-badge.promo{background:linear-gradient(120deg,var(--coral),var(--pink)); color:#3a1008;}
```

- [ ] **Step 2: Proof cards — remove neon hover, gold border**

Replace `.proof-card:hover` (line 242) box-shadow to `var(--glow-gold)`. Replace `.proof-badge` (line 248) color to `var(--gold)`, border `rgba(245,217,168,0.4)`, border-radius `var(--radius-sm)`.

- [ ] **Step 3: FAQ — soft accents**

Replace `.faq-num` (line 252) gradient to `var(--pink), var(--violet)` and box-shadow to `var(--glow-violet)`. Replace `.faq-item summary::after` (line 258) color to `var(--violet)`.

- [ ] **Step 4: Section dividers — straight**

Replace `.section-bg` (line 692) to use straight borders with `--border` and `background:rgba(31,20,40,0.6)`.

- [ ] **Step 5: Modal — square corners**

Replace `.modal` (line 567) border-radius to `var(--radius)`. Replace `.auth-tabs`/`.auth-tabs button` radius (lines 555-559) to `var(--radius-sm)`.

- [ ] **Step 6: Feature cards — gold hover**

Replace `.feature-card:hover` (line 324) to border-color `var(--gold)`, box-shadow `var(--glow-gold)`.

- [ ] **Step 7: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "style: Luxe Sharp cards, badges, sections and proofs
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 5: Render badges in package/coin cards (JS)

**Files:**
- Modify: `index.html` (renderPackages ~1982, renderCoins ~2008, renderBfPacks ~2029, renderBfCoins ~2055)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: `.pack-badge` CSS from Task 4.
- Produces: badge spans rendered in cards using `p.badge` field values `'bestseller'|'launch'|'promo'`.

- [ ] **Step 1: Add badge helper + render in renderPackages**

After `formatDateShort` (line 1553 area) add helper:

```js
  function packBadge(label, type){
    if(!label) return '';
    return '<span class="pack-badge ' + (type||'bestseller') + '">' + label + '</span>';
  }
```

In `renderPackages`, replace the card template string (lines 1985-1992) with one that inserts the badge after `</ul>`:

```js
      return '<div class="pack-card' + (p.featured?' featured':'') + '">' +
        (p.featured ? '<span class="pack-tag">Popular</span>' : '') +
        '<div class="pack-icon">' + p.icon + '</div>' +
        '<h4>' + escapeHtml(p.name) + '</h4>' +
        '<p class="pack-desc">' + escapeHtml(p.desc||'') + '</p>' +
        '<ul>' + (p.items||[]).map(function(i){ return '<li>' + escapeHtml(i.name) + (i.qty>1 ? ' <b style="color:var(--gold);">×'+i.qty+'</b>' : '') + '</li>'; }).join('') + '</ul>' +
        packBadge(p.badge_label, p.badge_type) +
        '<div class="pack-price"><span class="now">' + formatBRL(p.total) + '</span>' + (p.value ? '<span class="was">' + formatBRL(p.value) + '</span>' : '') + '</div>' +
        '<button class="btn btn-primary btn-sm" style="width:100%; margin-top:12px;" data-pack-add="' + escapeHtml(p.id) + '">Adicionar ao carrinho</button></div>';
```

- [ ] **Step 2: Same in renderCoins**

Replace the coin card template (lines 2011-2015) to add `packBadge(c.badge_label, c.badge_type)` after the description.

- [ ] **Step 3: Same in renderBfPacks**

Replace the BF pack card template (lines 2032-2039) with the same badge insertion as renderPackages.

- [ ] **Step 4: Same in renderBfCoins**

Replace the BF coin card template (lines 2058-2062) to add `packBadge(c.badge_label, c.badge_type)`.

- [ ] **Step 5: Add badge fields to DEFAULT packages**

Locate `DEFAULT_PACKAGES` definition and add `badge_label:'Mais Vendido', badge_type:'bestseller'` to the featured package (the one with `featured:true`); add `badge_label:'Lançamento', badge_type:'launch'` to the first BF package in `DEFAULT_BF_PACKAGES` that has `featured:true`; add `badge_label:'Promo', badge_type:'promo'` to the first coin in `DEFAULT_COINS` and first in `DEFAULT_BF_COINS`. If a package object already has other fields, add the two new keys.

- [ ] **Step 6: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "feat: render bestseller/launch/promo badges in package cards
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 6: Social notification popup system (CSS + HTML)

**Files:**
- Modify: `index.html` (add CSS near toast block ~590-596; add HTML near mascot ~1311)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: `reviews` array (Task 7 reads it), `settings.packages` for simulated purchases.
- Produces: DOM nodes `#socialNote`, CSS classes `.social-note`, `.social-note.show`, `.social-note .sn-avatar`, `.sn-stars`, `.sn-close`. JS control functions `startSocialNotes()`, `stopSocialNotes()`.

- [ ] **Step 1: Add CSS after the `.toast` block**

Insert after line 596 (`.toast.show{...}`):

```css
  .social-note{
    position:fixed; bottom:26px; left:26px; z-index:150; max-width:320px; width:calc(100vw - 52px);
    background:rgba(24,16,34,0.92); backdrop-filter:blur(8px); border:1px solid var(--border-strong);
    border-radius:var(--radius); box-shadow:var(--shadow-lg); padding:14px 16px;
    display:flex; gap:12px; align-items:flex-start; opacity:0; pointer-events:none;
    transform:translateX(-24px); transition:opacity .3s ease, transform .3s ease;
  }
  .social-note.show{opacity:1; pointer-events:auto; transform:translateX(0);}
  .social-note .sn-avatar{
    flex:none; width:38px; height:38px; border-radius:var(--radius-sm);
    background:linear-gradient(135deg, var(--violet), var(--pink));
    color:#fff; font-weight:800; font-size:1rem; display:flex; align-items:center; justify-content:center;
  }
  .social-note .sn-body{flex:1; min-width:0;}
  .social-note .sn-head{display:flex; align-items:center; gap:8px; flex-wrap:wrap;}
  .social-note .sn-name{font-weight:800; font-size:0.85rem; color:var(--text);}
  .social-note .sn-stars{color:var(--gold); font-size:0.8rem; letter-spacing:1px;}
  .social-note .sn-text{font-size:0.8rem; color:var(--text-dim); line-height:1.45; margin-top:4px;}
  .social-note .sn-close{
    background:none; border:none; color:var(--text-faint); font-size:1rem; line-height:1; padding:2px; cursor:pointer; flex:none;
  }
  .social-note .sn-close:hover{color:var(--text);}
```

- [ ] **Step 2: Add HTML near the mascot**

Insert before line 1311 `<div class="toast" id="toast"></div>`:

```html
<div class="social-note" id="socialNote" aria-live="polite">
  <div class="sn-avatar" id="snAvatar">A</div>
  <div class="sn-body">
    <div class="sn-head">
      <span class="sn-name" id="snName"></span>
      <span class="sn-stars" id="snStars"></span>
    </div>
    <div class="sn-text" id="snText"></div>
  </div>
  <button class="sn-close" id="snClose" aria-label="Fechar notificação">✕</button>
</div>
```

- [ ] **Step 3: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "feat: social review notification popup markup and styles
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 7: Social notification JS engine + toggle

**Files:**
- Modify: `index.html` (JS near showToast ~1560; init ~3144; reviews section HTML ~970-978)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: `reviews` array, `settings.packages`/`settings.coins` for purchase simulation, `localStorage` key `loli.socialNote` (value `'off'` disables), DOM from Task 6.
- Produces: `startSocialNotes()`, `stopSocialNotes()`, auto-start inside `init()` after `renderReviews()`, toggle button `#socialNoteToggle` in the reviews section.

- [ ] **Step 1: Add the engine after showToast**

Insert after line 1567 (end of `showToast`):

```js
  var snTimer = null;
  var snIdx = 0;
  function starsStr(n){
    var s = '';
    for(var i=0;i<5;i++){ s += i < n ? '★' : '☆'; }
    return s;
  }
  function snPool(){
    var pool = reviews.slice(0, 12);
    var buys = [
      { name:'Ana L.', rating:5, text:'Comprei o ' + (settings.packages[0] ? settings.packages[0].name : 'pacote') + ' e foi rápido demais!' },
      { name:'Pedro M.', rating:5, text:'Pagamento via PIX e entrega no mesmo dia. Nota 10.' },
      { name:'Julia R.', rating:4, text:'Adorei o atendimento, o uper explica tudo certinho.' },
      { name:'Caio S.', rating:5, text:'Up limpo e seguro, sem ban. Recomendo!' },
      { name:'Bia K.', rating:5, text:'Minha maestria subiu bem rápido. Muito obrigado!' },
      { name:'Lucas T.', rating:4, text:'Bom preço e suporte atencioso no WhatsApp.' }
    ];
    buys.forEach(function(b){
      pool.push({ name:b.name, rating:b.rating, text:b.text, date:Date.now() });
    });
    return pool;
  }
  function showSocialNote(){
    var el = $('socialNote');
    if(!el) return;
    var pool = snPool();
    if(pool.length === 0) return;
    var item = pool[snIdx % pool.length];
    snIdx++;
    $('snAvatar').textContent = (item.name || '?').charAt(0).toUpperCase();
    $('snName').textContent = item.name || 'Cliente';
    $('snStars').textContent = starsStr(item.rating || 5);
    $('snText').textContent = item.text || '';
    el.classList.add('show');
    snTimer = setTimeout(function(){ el.classList.remove('show'); }, 5000);
  }
  function startSocialNotes(){
    stopSocialNotes();
    if(('' + localStorage.getItem('loli.socialNote')) === 'off') return;
    setTimeout(showSocialNote, 5000);
    snTimer = setInterval(function(){
      if(!document.hidden) showSocialNote();
    }, 12000);
  }
  function stopSocialNotes(){
    if(snTimer){ clearInterval(snTimer); snTimer = null; }
    var el = $('socialNote');
    if(el) el.classList.remove('show');
  }
  function setSocialNoteEnabled(on){
    if(on){ localStorage.removeItem('loli.socialNote'); } else { localStorage.setItem('loli.socialNote', 'off'); }
    startSocialNotes();
    var t = $('socialNoteToggle');
    if(t) t.textContent = on ? 'Desativar notificações' : 'Ativar notificações';
  }
  $('snClose').addEventListener('click', function(){
    var el = $('socialNote');
    if(el) el.classList.remove('show');
  });
```

- [ ] **Step 2: Add toggle button in reviews section**

Replace the submit button line (976) block to add a toggle below the form:

Current:
```html
      <button class="btn btn-teal" id="reviewSubmitBtn">Enviar avaliação</button>
    </div>
```
New:
```html
      <button class="btn btn-teal" id="reviewSubmitBtn">Enviar avaliação</button>
      <button class="btn btn-ghost btn-sm" id="socialNoteToggle" style="justify-self:start;">Desativar notificações</button>
    </div>
```

- [ ] **Step 3: Wire the toggle + start in init**

In `init()` (line 3170) right after `renderReviews(); renderStarInput();` add:

```js
    startSocialNotes();
    $('socialNoteToggle').addEventListener('click', function(){
      setSocialNoteEnabled(('' + localStorage.getItem('loli.socialNote')) === 'off');
    });
```

Note: because `setSocialNoteEnabled` calls `startSocialNotes()` which reads the new value from localStorage, passing `true` when currently off re-enables, and `false` when currently on disables — the expression `('' + localStorage.getItem('loli.socialNote')) === 'off'` evaluates to `true` when currently disabled (so enabling) and `false` when currently enabled (so disabling).

- [ ] **Step 4: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "feat: social review notification engine with toggle
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 8: Scroll fade-up + beacon counter animation

**Files:**
- Modify: `index.html` (CSS ~313-317 section rules; JS near init ~3144)
- Sync: `porto-das-frutas.html`

**Interfaces:**
- Consumes: `data-count` on `#beaconLabel` (Task 3), `prefers-reduced-motion` already present.
- Produces: `.fade-up` / `.fade-up.in` classes; animated beacon counter.

- [ ] **Step 1: Add CSS for fade-up**

Insert after `.section-head p` rule (line 316):

```css
  .fade-up{opacity:0; transform:translateY(18px); transition:opacity .6s ease, transform .6s ease;}
  .fade-up.in{opacity:1; transform:translateY(0);}
```

- [ ] **Step 2: Add JS for fade-up + counter**

Insert before the closing `init();` (line 3179) — i.e., after `mascotReact('welcome');` inside `init()`, add:

```js
    /* fade-up on scroll */
    var fadeEls = document.querySelectorAll('.section-head, .pack-card, .feature-card, .review-card, .proof-card, .faq-item, .faq-step');
    if('IntersectionObserver' in window){
      var fadeObs = new IntersectionObserver(function(entries){
        entries.forEach(function(en){
          if(en.isIntersecting){ en.target.classList.add('in'); fadeObs.unobserve(en.target); }
        });
      }, { threshold: 0.12 });
      fadeEls.forEach(function(el){ el.classList.add('fade-up'); fadeObs.observe(el); });
    } else {
      fadeEls.forEach(function(el){ el.classList.add('in'); });
    }
    /* beacon counter */
    var bl = $('beaconLabel');
    if(bl && bl.getAttribute('data-count')){
      var targetCount = parseInt(bl.getAttribute('data-count'), 10);
      var curCount = 0;
      var stepCount = Math.max(1, Math.round(targetCount / 40));
      var countTimer = setInterval(function(){
        curCount += stepCount;
        if(curCount >= targetCount){ curCount = targetCount; clearInterval(countTimer); }
        bl.innerHTML = 'Loja Aberta · <span style="font-weight:800; color:var(--gold);">' + curCount.toLocaleString('pt-BR') + '</span> serviços';
      }, 45);
    }
```

Note: the observer is set up inside `init()` after render functions; because elements are re-rendered by `renderPackages()` etc. BEFORE the observer runs, the query selector catches the final DOM. Elements added later (e.g. reviews after submit) are not observed — acceptable per design.

- [ ] **Step 3: Sync, sanity, commit**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "feat: scroll fade-up animations and animated beacon counter
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 9: Full validation, sync, push

**Files:**
- All files in repo.

**Interfaces:**
- Consumes: everything above.

- [ ] **Step 1: Extract and syntax-check JS**

```bash
cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html && echo SYNC_OK
node -e "const s=require('fs').readFileSync('index.html','utf8');const m=s.match(/<script>([\s\S]*?)<\/script>/);require('fs').writeFileSync('/tmp/opencode/site.js',m[1]);" && node --check /tmp/opencode/site.js && echo JS_OK
```

- [ ] **Step 2: Verify IDs and no missing references**

```bash
rg -o "\$\('([a-zA-Z0-9]+)'\)" index.html | sed -E "s/.*\('([a-zA-Z0-9]+)'\).*/\1/" | sort -u > /tmp/opencode/ids_used.txt
rg -o 'id="([a-zA-Z0-9]+)"' index.html | sed -E 's/id="([a-zA-Z0-9]+)"/\1/' | sort -u > /tmp/opencode/ids_def.txt
comm -23 /tmp/opencode/ids_used.txt /tmp/opencode/ids_def.txt
```

Expected: only known dynamically-created IDs (e.g. pixCopyInput, pixCopyBtn, pixStatusLine, pixWhatsPayBtn, pixManualPaid, accountLabel) — verify none of the NEW ids (`socialNote`, `snAvatar`, `snName`, `snStars`, `snText`, `snClose`, `socialNoteToggle`) appear in the missing list.

- [ ] **Step 3: Verify splash/init elements exist**

```bash
for id in splashEnterBtn splashPricesBtn socialNote snAvatar snName snStars snText snClose socialNoteToggle beaconLabel; do rg -q "id=\"$id\"" index.html && echo "OK $id" || echo "MISSING $id"; done
```

- [ ] **Step 4: Check no ES6 syntax leaked in JS block**

```bash
node -e "const s=require('fs').readFileSync('index.html','utf8');const m=s.match(/<script>([\s\S]*?)<\/script>/);const js=m[1];if(/=>/.test(js)||/`/.test(js)){console.log('ES6 DETECTED');process.exit(1);}else{console.log('ES5 OK');}"
```

- [ ] **Step 5: Regression sanity on production site**

After push, confirm the deployed site still serves and contains new markers:

```bash
git push origin main
sleep 3
curl -s https://kauanfraga12-cyber.github.io/KYO-UPS-STORE/ | rg -c 'id="socialNote"'
```

Expected: `1`.

- [ ] **Step 6: Final commit if any leftover changes**

```bash
git status --short
git add -A
git commit -m "chore: Luxe Sharp redesign final sync
Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>" || echo "nothing to commit"
git push origin main
```

---

## Self-Review Notes

- Spec sections mapped: tokens → Task 1; components → Tasks 2-4; badges → Task 4-5; social notifications → Tasks 6-7; animations → Task 8; validation → Task 9.
- `--neon-*` names kept (re-pointed) so legacy rules still parse; no dangling var references.
- All new JS is ES5; all string concat, no template literals.
- Byte-identical sync enforced after every task.
