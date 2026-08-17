# Blox Fruits Tab + Mascote Animada + Vida no Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar uma aba dedicada Blox Fruits, uma mascote loli animada com reações, mais vida no hero, e corrigir o cadastro com "Confirm email" desativado.

**Architecture:** Single-file app `index.html` (JS ES5). Novos dados `settings.bfPackages`/`settings.bfCoins` seguem o padrão de `packages`/`coins` (defaults + merge Supabase/local). Mascote é HTML/CSS/JS puro com balão e animações CSS. `index.html` e `porto-das-frutas.html` permanecem byte-idênticos.

**Tech Stack:** Vanilla JS ES5, CSS, Supabase (auth + site_config), Netlify Functions (inalteradas).

## Global Constraints

- JavaScript em ES5: `var`, `function`, concat com `+`. PROIBIDO arrow functions, template literals, `?.`.
- `index.html` e `porto-das-frutas.html` devem ser byte-idênticos (sync via `cp` a cada task).
- Não renomear/remover IDs existentes: `heroTitle`, `heroTagline`, `packGrid`, `beaconCore`, `beaconLabel`, `heroWhatsBtn`, `panelOrders`, `panelUsers`, `panelReviews`, `panelEvents`, `panelMessages`, `panelEditor`, `panelSettings`, `panelCoins`, `panelProofs`.
- Termos de serviço verbatim não podem ser alterados.
- Commits com co-autoria: `Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>`.
- Validação padrão de cada task: `node --check` do script inline + `diff -q index.html porto-das-frutas.html`.

---
### Task 1: Dados DEFAULT_BF_PACKAGES / DEFAULT_BF_COINS + merge no settings

**Files:**
- Modify: `/workspace/index.html` (após linha 1431 `];` do DEFAULT_EVENTS; linha 1448 settings; 1491 sbConfigData; 1504-1505 loadConfigSupabase; 1725-1726 loadAll)

**Interfaces:**
- Consumes: padrão de `DEFAULT_PACKAGES`/`DEFAULT_COINS`.
- Produces: `DEFAULT_BF_PACKAGES`, `DEFAULT_BF_COINS`, `settings.bfPackages`, `settings.bfCoins`, incluídos em `sbConfigData()` e nos merges.

- [ ] **Step 1: Adicionar constantes default**

Inserir imediatamente após a linha `];` do `DEFAULT_EVENTS` (linha 1431):

```js

  var DEFAULT_BF_PACKAGES = [
    { id:"bf-iniciante", icon:"🌱", name:"Blox Iniciante", desc:"Começo forte: maestria + níveis + fragmentos.", featured:false,
      items:[{name:"500 Maestria", qty:1},{name:"1.000 Níveis", qty:1},{name:"10k Fragmentos", qty:1},{name:"100 Desvios", qty:1}],
      total:26.00, value:32.50 },
    { id:"bf-bounty", icon:"💀", name:"Blox Bounty", desc:"Foco em bounty e combate para subir de posto.", featured:true,
      items:[{name:"5M de Bounty", qty:1},{name:"Death Step", qty:1},{name:"1k Fragmentos", qty:1},{name:"500 Maestria", qty:1}],
      total:34.00, value:43.40 },
    { id:"bf-leviata", icon:"🐋", name:"Blox Leviatã", desc:"Coração de Leviatã + cooldown resetado no mar.", featured:false,
      items:[{name:"Coração Leviatã (1 Levi)", qty:1},{name:"Tirar Cooldown", qty:1},{name:"5 Scrolls Lendários", qty:1},{name:"10k Fragmentos", qty:1}],
      total:26.50, value:33.00 },
    { id:"bf-race", icon:"⚡", name:"Blox Raças V4", desc:"Raças V4 completas para dominar o combate.", featured:true,
      items:[{name:"6 Raças V4 Full", qty:1},{name:"God Human", qty:1},{name:"30M de Bounty", qty:1},{name:"10 Scrolls Míticos", qty:1}],
      total:390.00, value:490.00 }
  ];

  var DEFAULT_BF_COINS = [
    { id:"bf-robux100", icon:"🪙", name:"100 Robux", desc:"Crédito de 100 Robux direto na sua conta.", qty:100, price:7.00 },
    { id:"bf-robux400", icon:"🪙", name:"400 Robux", desc:"Crédito de 400 Robux com desconto.", qty:400, price:24.00 },
    { id:"bf-frag1k", icon:"💎", name:"1.000 Fragmentos", desc:"Fragmentos para desbloquear raças e habilidades.", qty:1000, price:15.00 },
    { id:"bf-frag5k", icon:"💎", name:"5.000 Fragmentos", desc:"Pacote grande de fragmentos com melhor preço.", qty:5000, price:55.00 },
    { id:"bf-belly1b", icon:"💰", name:"1 Bilhão de Bellys", desc:"Bellys para comprar tudo o que precisar.", qty:1000000000, price:35.00 },
    { id:"bf-gemas", icon:"💠", name:"1.000 Gemas", desc:"Gemas para itens exclusivos.", qty:1000, price:20.00 }
  ];
```

- [ ] **Step 2: Adicionar ao objeto settings inicial**

Substituir a linha 1448 (settings inicial) para incluir `bfPackages`/`bfCoins`:

```js
  var settings = { config:Object.assign({}, DEFAULT_CONFIG), prices:JSON.parse(JSON.stringify(DEFAULT_PRICES)), packages:JSON.parse(JSON.stringify(DEFAULT_PACKAGES)), coins:JSON.parse(JSON.stringify(DEFAULT_COINS)), proofs:JSON.parse(JSON.stringify(DEFAULT_PROOFS)), events:JSON.parse(JSON.stringify(DEFAULT_EVENTS)), bfPackages:JSON.parse(JSON.stringify(DEFAULT_BF_PACKAGES)), bfCoins:JSON.parse(JSON.stringify(DEFAULT_BF_COINS)), admin:{ salt:null, hash:null } };
```

- [ ] **Step 3: Adicionar a sbConfigData()**

Substituir a linha 1491:

```js
    return { config: settings.config, prices: settings.prices, packages: settings.packages, events: settings.events, coins: settings.coins, proofs: settings.proofs, bfPackages: settings.bfPackages, bfCoins: settings.bfCoins, admin: settings.admin };
```

- [ ] **Step 4: Adicionar ao merge em loadConfigSupabase()**

Após a linha 1505 (`proofs: ...`), adicionar:

```js
          bfPackages: (d.bfPackages && d.bfPackages.length) ? d.bfPackages : JSON.parse(JSON.stringify(DEFAULT_BF_PACKAGES)),
          bfCoins: (d.bfCoins && d.bfCoins.length) ? d.bfCoins : JSON.parse(JSON.stringify(DEFAULT_BF_COINS)),
```

- [ ] **Step 5: Adicionar defaults em loadAll()**

Após a linha 1726 (`if(!settings.proofs ...)`), adicionar:

```js
      if(!settings.bfPackages || settings.bfPackages.length===0) settings.bfPackages = JSON.parse(JSON.stringify(DEFAULT_BF_PACKAGES));
      if(!settings.bfCoins || settings.bfCoins.length===0) settings.bfCoins = JSON.parse(JSON.stringify(DEFAULT_BF_COINS));
```

- [ ] **Step 6: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c "DEFAULT_BF_PACKAGES" index.html && grep -c "DEFAULT_BF_COINS" index.html
```
Esperado: OK, SYNCED, e contagens >= 4.

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: default Blox Fruits packages and coins data

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---
### Task 2: Nav + seção #bloxfruits HTML

**Files:**
- Modify: `/workspace/index.html` (nav linha 742-743; nova seção após linha 882 `</section>` de pacotes)

**Interfaces:**
- Consumes: Task 1 (`settings.bfPackages`, `settings.bfCoins`).
- Produces: botão `data-nav="bloxfruits"`, seção `#bloxfruits` com `#bfPackGrid` e `#bfCoinGrid`.

- [ ] **Step 1: Adicionar botão na nav**

Após a linha 742 (`<button data-nav="pacotes">...</button>`), inserir:

```html
      <button data-nav="bloxfruits"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8a6 6 0 0 0-6-6 6 6 0 0 0-6 6c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>Blox Fruits</button>
```

- [ ] **Step 2: Adicionar seção #bloxfruits**

Após a `</section>` de `#pacotes` (linha 882), inserir:

```html

<!-- ============ BLOX FRUITS ============ -->
<section id="bloxfruits" class="section-bg">
  <div class="container">
    <div class="section-head">
      <div class="eyebrow">Blox Fruits</div>
      <h2>Upagem exclusiva de <span class="grad-text">Blox Fruits</span></h2>
      <p>Pacotes e moedas pensados para o Blox Fruits. Simule, adicione ao carrinho e pague via PIX.</p>
    </div>
    <div class="pack-grid" id="bfPackGrid"></div>
    <div class="section-head" style="margin-top:48px;">
      <div class="eyebrow">Moedas Blox Fruits</div>
      <h3 style="margin:0;">Robux, fragmentos e Bellys</h3>
    </div>
    <div class="pack-grid" id="bfCoinGrid"></div>
  </div>
</section>
```

- [ ] **Step 3: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c 'id="bfPackGrid"\|id="bfCoinGrid"\|data-nav="bloxfruits"' index.html
```
Esperado: OK, SYNCED, count = 3.

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: Blox Fruits section and nav

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---
### Task 3: renderBfPacks() + renderBfCoins() + chamadas no init()

**Files:**
- Modify: `/workspace/index.html` (inserir funções antes de `function renderProofs()` linha 1937; chamadas em `init()` linhas 2908-2910)

**Interfaces:**
- Consumes: `settings.bfPackages`, `settings.bfCoins`, `$`, `escapeHtml`, `formatBRL`, `addToCart`, `renderCart`, `renderSimItems`, `renderPriceTable`, `showToast`.
- Produces: `renderBfPacks()`, `renderBfCoins()`.

- [ ] **Step 1: Implementar renderBfPacks() e renderBfCoins()**

Inserir imediatamente antes de `function renderProofs(){` (linha 1937):

```js

  function renderBfPacks(){
    var grid = $('bfPackGrid');
    grid.innerHTML = settings.bfPackages.map(function(p){
      return '<div class="pack-card' + (p.featured?' featured':'') + '">' +
        (p.featured ? '<span class="pack-tag">Popular</span>' : '') +
        '<div class="pack-icon">' + p.icon + '</div>' +
        '<h4>' + escapeHtml(p.name) + '</h4>' +
        '<p class="pack-desc">' + escapeHtml(p.desc||'') + '</p>' +
        '<ul>' + (p.items||[]).map(function(i){ return '<li>' + escapeHtml(i.name) + (i.qty>1 ? ' <b style="color:var(--gold);">×'+i.qty+'</b>' : '') + '</li>'; }).join('') + '</ul>' +
        '<div class="pack-price"><span class="now">' + formatBRL(p.total) + '</span>' + (p.value ? '<span class="was">' + formatBRL(p.value) + '</span>' : '') + '</div>' +
        '<button class="btn btn-primary btn-sm" style="width:100%; margin-top:12px;" data-bfpack-add="' + escapeHtml(p.id) + '">Adicionar ao carrinho</button></div>';
    }).join('');
    grid.querySelectorAll('[data-bfpack-add]').forEach(function(btn){
      btn.addEventListener('click', function(){
        var p = settings.bfPackages.find(function(x){ return x.id===btn.dataset.bfpackAdd; });
        if(!p) return;
        (p.items||[]).forEach(function(i){
          var cat = settings.prices.find(function(c){ return c.items.some(function(it){ return it.name===i.name; }); });
          if(cat){ var it = cat.items.find(function(x){ return x.name===i.name; }); addToCart(cat.id, i.name, it.price, i.qty||1); }
        });
        renderCart(); renderSimItems(); renderPriceTable();
        showToast('Pacote "' + p.name + '" adicionado ao carrinho!', true);
      });
    });
  }

  function renderBfCoins(){
    var grid = $('bfCoinGrid');
    grid.innerHTML = settings.bfCoins.map(function(c){
      return '<div class="pack-card"><div class="pack-icon">' + c.icon + '</div>' +
        '<h4>' + escapeHtml(c.name) + '</h4>' +
        '<p class="pack-desc">' + escapeHtml(c.desc||'') + '</p>' +
        '<div class="pack-price"><span class="now">' + formatBRL(c.price) + '</span></div>' +
        '<button class="btn btn-teal btn-sm" style="width:100%; margin-top:12px;" data-bfcoin-add="' + escapeHtml(c.id) + '">Adicionar ao carrinho</button></div>';
    }).join('');
    grid.querySelectorAll('[data-bfcoin-add]').forEach(function(btn){
      btn.addEventListener('click', function(){
        var c = settings.bfCoins.find(function(x){ return x.id===btn.dataset.bfcoinAdd; });
        if(!c) return;
        addToCart('moedas', c.name, c.price, 1);
        renderCart(); renderSimItems(); renderPriceTable();
        showToast(c.name + ' adicionado ao carrinho!', true);
      });
    });
  }
```

- [ ] **Step 2: Chamadas no init()**

Após a linha 2910 (`renderProofs();`), adicionar:

```js
    renderBfPacks();
    renderBfCoins();
```

- [ ] **Step 3: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c "renderBfPacks" index.html && grep -c "renderBfCoins" index.html
```
Esperado: OK, SYNCED, contagens >= 2.

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: render Blox Fruits packs and coins

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---
### Task 4: Painéis admin Blox Fruits

**Files:**
- Modify: `/workspace/index.html` (admin-tabs linhas 1098-1100; painéis linhas 1114-1115; funções admin após `renderAdminProofs`; `renderAdminAll` linha 2522)

**Interfaces:**
- Consumes: Task 1 (`settings.bfPackages`, `settings.bfCoins`), `saveSettings()`, `genId`, `renderBfPacks`, `renderBfCoins`, `showToast`, `escapeHtml`.
- Produces: `renderAdminBfPacks()` (usa `#bfPacksListAdmin`), `renderAdminBfCoins()` (usa `#bfCoinsListAdmin`), incluídos em `renderAdminAll()`.

- [ ] **Step 1: Abas no admin-tabs**

Após a linha 1100 (`<button data-panel="panelProofs">Provas</button>`), inserir:

```html
        <button data-panel="panelBfPacks">Blox Pacotes</button>
        <button data-panel="panelBfCoins">Blox Moedas</button>
```

- [ ] **Step 2: Painéis admin**

Após a linha 1115 (`<div class="admin-panel" id="panelProofs">...</div>`), inserir:

```html
      <div class="admin-panel" id="panelBfPacks"><div id="bfPacksListAdmin"></div></div>
      <div class="admin-panel" id="panelBfCoins"><div id="bfCoinsListAdmin"></div></div>
```

- [ ] **Step 3: Implementar renderAdminBfPacks() e renderAdminBfCoins()**

Inserir após o fechamento de `renderAdminProofs()` (após a linha 2720):

```js

  function renderAdminBfPacks(){
    var wrap = $('bfPacksListAdmin');
    wrap.innerHTML = settings.bfPackages.map(function(p){
      return '<div class="row-card"><div class="row-top"><div class="rid">' + escapeHtml(p.id) + '</div>' +
        '<button class="btn btn-danger-outline btn-sm" data-bpcact="delete" data-bpcid="' + escapeHtml(p.id) + '">Excluir</button></div>' +
        '<div class="field-row"><div class="field"><label>Nome</label><input value="' + escapeHtml(p.name) + '" data-bpcfield="name" data-bpcid="' + escapeHtml(p.id) + '"></div>' +
        '<div class="field"><label>Total (R$)</label><input type="number" step="0.01" value="' + p.total + '" data-bpcfield="total" data-bpcid="' + escapeHtml(p.id) + '"></div></div>' +
        '<div class="field" style="margin:0;"><label>Descrição</label><textarea data-bpcfield="desc" data-bpcid="' + escapeHtml(p.id) + '">' + escapeHtml(p.desc) + '</textarea></div></div>';
    }).join('');
    wrap.querySelectorAll('[data-bpcfield]').forEach(function(inp){
      inp.addEventListener('change', async function(e){
        var p = settings.bfPackages.find(function(x){ return x.id===inp.dataset.bpcid; });
        if(p){
          p[inp.dataset.bpcfield] = inp.dataset.bpcfield==='total' ? Number(e.target.value) : e.target.value;
          await saveSettings(); renderBfPacks();
        }
      });
    });
    wrap.querySelectorAll('[data-bpcact="delete"]').forEach(function(b){
      b.addEventListener('click', async function(){
        settings.bfPackages = settings.bfPackages.filter(function(x){ return x.id!==b.dataset.bpcid; });
        await saveSettings(); renderAdminBfPacks(); renderBfPacks();
        showToast('Pacote removido.');
      });
    });
    var addBtn = document.createElement('button');
    addBtn.className = 'btn btn-ghost btn-sm';
    addBtn.textContent = '+ Novo pacote';
    addBtn.addEventListener('click', async function(){
      settings.bfPackages.unshift({ id: genId('bfp').toLowerCase(), icon:'🎮', name:'Novo pacote', desc:'Descrição do pacote', items:[{name:'1k Fragmentos', qty:1}], total:10.00, value:12.00 });
      await saveSettings(); renderAdminBfPacks(); renderBfPacks();
    });
    wrap.appendChild(addBtn);
  }

  function renderAdminBfCoins(){
    var wrap = $('bfCoinsListAdmin');
    wrap.innerHTML = settings.bfCoins.map(function(c){
      return '<div class="row-card"><div class="row-top"><div class="rid">' + escapeHtml(c.id) + '</div>' +
        '<button class="btn btn-danger-outline btn-sm" data-bccact="delete" data-bccid="' + escapeHtml(c.id) + '">Excluir</button></div>' +
        '<div class="field-row"><div class="field"><label>Nome</label><input value="' + escapeHtml(c.name) + '" data-bccfield="name" data-bccid="' + escapeHtml(c.id) + '"></div>' +
        '<div class="field"><label>Preço (R$)</label><input type="number" step="0.01" value="' + c.price + '" data-bccfield="price" data-bccid="' + escapeHtml(c.id) + '"></div></div>' +
        '<div class="field" style="margin:0;"><label>Descrição</label><textarea data-bccfield="desc" data-bccid="' + escapeHtml(c.id) + '">' + escapeHtml(c.desc) + '</textarea></div></div>';
    }).join('');
    wrap.querySelectorAll('[data-bccfield]').forEach(function(inp){
      inp.addEventListener('change', async function(e){
        var c = settings.bfCoins.find(function(x){ return x.id===inp.dataset.bccid; });
        if(c){
          c[inp.dataset.bccfield] = inp.dataset.bccfield==='price' ? Number(e.target.value) : e.target.value;
          await saveSettings(); renderBfCoins();
        }
      });
    });
    wrap.querySelectorAll('[data-bccact="delete"]').forEach(function(b){
      b.addEventListener('click', async function(){
        settings.bfCoins = settings.bfCoins.filter(function(x){ return x.id!==b.dataset.bccid; });
        await saveSettings(); renderAdminBfCoins(); renderBfCoins();
        showToast('Moeda removida.');
      });
    });
    var addBtn = document.createElement('button');
    addBtn.className = 'btn btn-ghost btn-sm';
    addBtn.textContent = '+ Nova moeda';
    addBtn.addEventListener('click', async function(){
      settings.bfCoins.unshift({ id: genId('bfc').toLowerCase(), icon:'🪙', name:'Nova moeda', desc:'Descrição da moeda', qty:1, price:10.00 });
      await saveSettings(); renderAdminBfCoins(); renderBfCoins();
    });
    wrap.appendChild(addBtn);
  }
```

- [ ] **Step 4: Incluir em renderAdminAll()**

Substituir a linha 2522:

```js
    renderAdminStats(); renderAdminOrders(); renderAdminUsers(); renderAdminReviews(); renderAdminEvents(); renderAdminMessages(); renderAdminEditor(); renderAdminCoins(); renderAdminProofs(); renderAdminBfPacks(); renderAdminBfCoins();
```

- [ ] **Step 5: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c 'id="panelBfPacks"' index.html && grep -c 'id="panelBfCoins"' index.html
```
Esperado: OK, SYNCED, contagens = 1.

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: admin panels for Blox Fruits packs and coins

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---
### Task 5: Mascote animada com reações

**Files:**
- Modify: `/workspace/index.html` (CSS antes de `</style>`; HTML antes de `</body>` linha 2922; JS antes da seção NAVEGAÇÃO linha 2870)
- Usa: `/workspace/assets/mascot.jpg` (já commitado no repo)

**Interfaces:**
- Consumes: `$`, `showToast` (não obrigatório), eventos de `addToCart`, checkout, `setAuthError`, `init`.
- Produces: `mascotSay(text, cls)`, `mascotReact(kind)` com kinds `'welcome'|'cart'|'buy'|'error'|'click'`, `#mascot`, `#mascotBubble`, `#mascotHearts`.

- [ ] **Step 1: CSS da mascote**

Inserir antes do fechamento `</style>`:

```css

  /* ---- MASCOTE LOLI ---- */
  #mascot{position:fixed; right:18px; bottom:18px; z-index:9999; cursor:pointer;}
  #mascot .mascot-img{width:104px; height:104px; border-radius:50%; object-fit:cover; border:3px solid var(--violet); box-shadow:0 0 26px -4px rgba(150,120,255,.9); animation:mascotFloat 3.4s ease-in-out infinite; background:#fff;}
  @keyframes mascotFloat{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
  #mascotBubble{position:absolute; bottom:118px; right:0; max-width:230px; background:#fff; color:#3a2a55; font-size:.82rem; padding:9px 12px; border-radius:14px 14px 4px 14px; box-shadow:0 10px 26px -8px rgba(0,0,0,.45); border:2px solid var(--violet); display:none; line-height:1.4;}
  #mascotBubble::after{content:''; position:absolute; top:100%; right:22px; border:7px solid transparent; border-top-color:var(--violet);}
  #mascotHearts{position:absolute; bottom:100px; right:14px; font-size:1.15rem; opacity:0; pointer-events:none;}
  #mascotHearts.pop{animation:mascotHeartsUp .9s ease-out;}
  @keyframes mascotHeartsUp{0%{opacity:0; transform:translateY(0) scale(.6)}30%{opacity:1}100%{opacity:0; transform:translateY(-36px) scale(1.2)}}
  #mascot.jump .mascot-img{animation:mascotJump .45s ease-in-out 2;}
  @keyframes mascotJump{0%,100%{transform:translateY(0)}50%{transform:translateY(-18px)}}
  #mascot.wave .mascot-img{animation:mascotWave .7s ease-in-out;}
  @keyframes mascotWave{0%,100%{transform:rotate(0)}25%{transform:rotate(-12deg)}75%{transform:rotate(10deg)}}
  #mascot.sad .mascot-img{animation:mascotSad .8s ease-in-out;}
  @keyframes mascotSad{0%,100%{transform:translateY(0) rotate(0)}40%{transform:translateY(4px) rotate(-6deg)}}
  #mascot.heart .mascot-img{animation:mascotHeart .6s ease-in-out;}
  @keyframes mascotHeart{0%,100%{transform:scale(1)}50%{transform:scale(1.18)}}
  @media (max-width:600px){ #mascot .mascot-img{width:80px; height:80px;} #mascotBubble{max-width:190px; font-size:.75rem;} }
```

- [ ] **Step 2: HTML da mascote**

Inserir antes de `</body>` (linha 2922):

```html

<!-- ============ MASCOTE LOLI ============ -->
<div id="mascot" title="LOLI-chan">
  <div id="mascotBubble"></div>
  <img class="mascot-img" src="assets/mascot.jpg" alt="Mascote LOLI-chan">
  <div id="mascotHearts">💕</div>
</div>
```

- [ ] **Step 3: JS da mascote**

Inserir antes da seção `/* NAVEGAÇÃO */` (linha 2870):

```js

  /* ============================================================
     MASCOTE LOLI
     ============================================================ */
  var MASCOT_PHRASES = [
    'Oii, eu sou a LOLI-chan! 💕',
    'Escolheu bem! ✨',
    'Espero que goste da lojinha! 🌸',
    'Pode me clicar sempre que quiser!',
    'Pixinho aprovado = felicidade 💖'
  ];
  var mascotTimer = null;
  function mascotSay(text, cls){
    var b = $('mascotBubble');
    b.textContent = text;
    b.style.display = 'block';
    var m = $('mascot');
    m.className = cls ? cls : '';
    clearTimeout(mascotTimer);
    mascotTimer = setTimeout(function(){
      b.style.display = 'none';
      m.className = '';
    }, 3200);
  }
  function mascotHeartsPop(){
    var h = $('mascotHearts');
    h.classList.remove('pop');
    void h.offsetWidth;
    h.classList.add('pop');
  }
  function mascotReact(kind){
    if(kind === 'cart'){ mascotSay('Adicionei ao carrinho! 💕', 'jump'); }
    else if(kind === 'buy'){ mascotSay('Pedido confirmado! 💖', 'heart'); mascotHeartsPop(); }
    else if(kind === 'error'){ mascotSay('Ops! Deu um errozinho 🥺', 'sad'); }
    else if(kind === 'click'){
      var i = Math.floor(Math.random()*MASCOT_PHRASES.length);
      mascotSay(MASCOT_PHRASES[i], 'wave');
      mascotHeartsPop();
    }
    else { mascotSay('Bem-vindo(a) à LOLI Ups! 🌸', 'wave'); }
  }
  $('mascot').addEventListener('click', function(){ mascotReact('click'); });
```

- [ ] **Step 4: Hooks de reação**

4a. Em `addToCart` (linha 1808-1815), após `renderCartBadge();`, adicionar `mascotReact('cart');`.

4b. No checkout, após `showChkStep(3); startPixPayment(order);` (linha 2015-2016), adicionar `mascotReact('buy');`.

4c. Em `setAuthError` (linha 2302), após `el.style.display = 'block';`, adicionar `mascotReact('error');`.

4d. Em `init()` (após `renderAdminStats();` linha 2917), adicionar `mascotReact('welcome');`.

- [ ] **Step 5: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c "mascotReact" index.html && grep -c "assets/mascot.jpg" index.html
```
Esperado: OK, SYNCED, `mascotReact` >= 7 (função + 5 kinds no corpo + 4 hooks + listener), `assets/mascot.jpg` = 1.

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: animated LOLI mascot with reactions

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---
### Task 6: Mais vida no hero (partículas + gradiente animado + hover)

**Files:**
- Modify: `/workspace/index.html` (CSS no bloco do hero; HTML da section #home)

**Interfaces:**
- Consumes: estrutura `.hero`, `.grad-text`, `.feature-card`.
- Produces: partículas flutuantes, gradiente animado, hover elevado.

- [ ] **Step 1: CSS de vida no hero**

1a. Substituir a regra `.hero h1 .grad-text{animation:neonPulse 2.6s ease-in-out infinite;}` (linha 265) por:

```css
  .hero h1 .grad-text{background-size:200% 200%; animation:neonPulse 2.6s ease-in-out infinite, gradShift 5s ease-in-out infinite;}
```

1b. Inserir logo após essa regra:

```css
  @keyframes gradShift{0%,100%{background-position:0% 50%}50%{background-position:100% 50%}}
  .hero-particle{position:absolute; bottom:-20px; font-size:1.3rem; opacity:0; animation:floatUp linear infinite; pointer-events:none; z-index:0;}
  @keyframes floatUp{0%{opacity:0; transform:translateY(0) rotate(0)}15%{opacity:.55}85%{opacity:.4}100%{opacity:0; transform:translateY(-560px) rotate(35deg)}}
  .feature-card{transition:transform .22s ease, box-shadow .22s ease, border-color .22s ease;}
  .feature-card:hover{transform:translateY(-5px); box-shadow:0 16px 34px -12px rgba(150,120,255,.55); border-color:var(--violet);}
```

- [ ] **Step 2: HTML das partículas**

Inserir dentro da `<div class="container hero">` (linha 769), logo após a abertura, adicionar spans decorativos:

```html
    <span class="hero-particle" style="left:8%; animation-duration:9s;">💖</span>
    <span class="hero-particle" style="left:22%; animation-duration:12s; animation-delay:2s;">✨</span>
    <span class="hero-particle" style="left:47%; animation-duration:10s; animation-delay:1s;">🌸</span>
    <span class="hero-particle" style="left:70%; animation-duration:13s; animation-delay:3s;">💫</span>
    <span class="hero-particle" style="left:88%; animation-duration:11s; animation-delay:0.5s;">💖</span>
```

- [ ] **Step 3: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c "hero-particle" index.html
```
Esperado: OK, SYNCED, count = 7 (5 spans HTML + 2 CSS).

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "style: animated particles and glow in hero

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---
### Task 7: Fix cadastro + validação final + publicação

**Files:**
- Modify: `/workspace/index.html` (registerSupabase linhas 1624-1642)
- Test: `/workspace/index.html`, `porto-das-frutas.html`, `netlify/functions/*.test.mjs`

**Interfaces:**
- Consumes: Task 5 (mascotReact), tasks 1-6.
- Produces: cadastro robusto; entrega validada e publicada.

- [ ] **Step 1: Melhorar registerSupabase**

Substituir o corpo de `registerSupabase` (linhas 1624-1642) por:

```js
  async function registerSupabase(name, pass){
    if(name.toLowerCase() === SPECIAL_ADMIN.name.toLowerCase() && pass !== SPECIAL_ADMIN.pass){
      throw new Error('Este nome de usuário já existe.');
    }
    var res = await sb.auth.signUp({ email: sbEmailFor(name), password: pass, options: { data: { username: name } } });
    if(res.error){
      var msg = res.error.message || 'Erro ao criar conta.';
      if(/already|exists|registered/i.test(msg)) throw new Error('Este nome de usuário já existe.');
      throw new Error(msg);
    }
    if(!res.data.session){
      try{
        await loginSupabase(name, pass);
        return;
      }catch(e){}
      throw new Error('Conta criada, mas o Supabase está com "Confirm email" ativo. Desative em Authentication > Providers > Email e tente novamente.');
    }
    currentUser = { id: res.data.user.id, name: name };
    if(name.toLowerCase() === SPECIAL_ADMIN.name.toLowerCase() && pass === SPECIAL_ADMIN.pass){
      isAdmin = true;
      await promoteAdminSupabase();
    }
  }
```

- [ ] **Step 2: Validação completa**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
ids=set(re.findall(r'id="([^"]+)"', html))
refs=set(re.findall(r"\$\('([^']+)'\)", html))
print('IDs faltando:', sorted(r for r in refs if r not in ids))
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo SYNTAX_OK
node --test netlify/functions/*.test.mjs 2>&1 | grep -E "^# (pass|fail)"
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c 'data-nav="bloxfruits"\|renderBfPacks\|renderBfCoins\|mascotReact\|DEFAULT_BF_PACKAGES\|DEFAULT_BF_COINS' index.html
```
Esperado: IDs faltando vazio, SYNTAX_OK, # pass 6 / # fail 0, SYNCED, count >= 6.

- [ ] **Step 3: Teste real do cadastro (Supabase)**

```bash
cd /workspace && curl -s -X POST "https://ukhzidvkiydovbmjxywf.supabase.co/auth/v1/signup" \
 -H "apikey: sb_publishable_396uuJYxGgyVrVX2hnjD8A_4_226onb" \
 -H "Content-Type: application/json" \
 -d '{"email":"verif_final_19@kyo-ups-store.netlify.app","password":"teste12345","data":{"username":"verif19"}}' | python3 -c "import json,sys; d=json.load(sys.stdin); print('SESSION_OK' if 'access_token' in d else 'NO_SESSION: '+str(d))"
```
Esperado: SESSION_OK.

- [ ] **Step 4: Commit + push**

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "fix: robust account creation when confirm email is off

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

```bash
cd /workspace && git status --short && git log --oneline -10 && git push origin main 2>&1 | tail -3
```

- [ ] **Step 5: Smoke test no preview**

```bash
curl -s http://localhost:8000/index.html | grep -o 'id="bloxfruits"\|id="mascot"\|data-nav="bloxfruits"' | sort -u
```
Esperado: 3 linhas.
