# Layout Game Neon + 3 Novas Abas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesenhar a home/vitrine em estilo game neon e adicionar 3 abas novas (Loja de Moedas, Provas de Entrega, Ajuda/FAQ) à loja LOLI Ups.

**Architecture:** Mudanças concentradas em `/workspace/index.html` (e cópia byte-idêntica `/workspace/porto-das-frutas.html`). CSS/HTML para o tema neon; novas constantes `DEFAULT_COINS` e `DEFAULT_PROOFS` com persistência em `settings` (Supabase/localStorage); funções `renderCoins()`, `renderProofs()`; 3 seções + 3 botões de nav; 2 painéis admin novos.

**Tech Stack:** HTML5 + CSS3 + JS ES5 puro (sem dependências). Persistência: Supabase (`site_config.data`) com fallback localStorage.

## Global Constraints

- Arquivos: `/workspace/index.html` (fonte) e `/workspace/porto-das-frutas.html` (deve permanecer byte-idêntico ao final de cada task).
- JS em ES5 (`var`, funções declaradas) — proibido arrow functions, template literals, `?.` opcional em código novo (o código existente usa `?.` em 2 lugares, mas não adicionar novos).
- IDs existentes NÃO podem ser renomeados/removidos: `heroTitle`, `heroTagline`, `packGrid`, `beaconCore`, `beaconLabel`, `heroWhatsBtn`, `checkoutOpenBtn`, painéis admin `panelOrders`/`panelUsers`/`panelReviews`/`panelEvents`/`panelMessages`/`panelEditor`/`panelSettings`.
- Título/marca do site: "LOLI Ups" (não alterar).
- Termos de serviço verbatim NÃO podem ser alterados.
- Validação ao final de cada task que mexe em JS: `node --check` do script inline extraído; checagem de IDs `$('id')` sem missing; `node --test netlify/functions/*.test.mjs` (6 testes).
- Commits com co-autoria: `Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>`.

---

### Task 1: Tokens neon + hero neon

**Files:**
- Modify: `/workspace/index.html:13` (início do `<style>`), `/workspace/index.html:220-258` (CSS hero/beacon)
- Test: `/workspace/index.html`

**Interfaces:**
- Consumes: nada novo.
- Produces: variáveis CSS `--neon-cyan`, `--neon-pink`, `--neon-violet`, `--neon-glow-*`; classe `.neon-grid-bg` no `<section id="home">`; keyframes `neonPulse`.

- [ ] **Step 1: Adicionar tokens neon no `:root`**

Após a linha `--glow-gold:0 0 30px -4px rgba(255,182,200,0.5);` (linha ~71), inserir:

```css
    --neon-cyan:#00f0ff;
    --neon-pink:#ff2fd6;
    --neon-violet:#7c5cff;
    --neon-glow-cyan:0 0 24px -2px rgba(0,240,255,0.55);
    --neon-glow-pink:0 0 24px -2px rgba(255,47,214,0.55);
    --neon-glow-violet:0 0 24px -2px rgba(124,92,255,0.55);
```

- [ ] **Step 2: Adicionar keyframes + estilo do grid neon e glow no hero**

Inserir imediatamente antes do bloco `.hero{padding:80px 0 64px;...}` (linha 220):

```css
  .neon-grid-bg{position:absolute; inset:0; z-index:0; pointer-events:none;
    background-image:
      linear-gradient(rgba(0,240,255,0.06) 1px, transparent 1px),
      linear-gradient(90deg, rgba(0,240,255,0.06) 1px, transparent 1px);
    background-size:44px 44px;
    -webkit-mask-image:radial-gradient(circle at 50% 40%, #000 0%, transparent 78%);
    mask-image:radial-gradient(circle at 50% 40%, #000 0%, transparent 78%);
  }
  @keyframes neonPulse{
    0%,100%{opacity:.55; text-shadow:0 0 12px var(--neon-pink), 0 0 32px rgba(255,47,214,0.55);}
    50%{opacity:1; text-shadow:0 0 18px var(--neon-pink), 0 0 48px rgba(255,47,214,0.8);}
  }
  .hero{position:relative;}
  .hero-grid,.hero-trust,.hero-ctas{position:relative; z-index:1;}
```

- [ ] **Step 3: Aplicar fundo de grid e glow no hero (HTML)**

Em `<section id="home" style="padding-top:0;">` (linha 715), adicionar dentro da section, antes de `<div class="container hero">`:

```html
  <div class="neon-grid-bg"></div>
```

E adicionar a classe de glow ao `h1` — alterar a regra CSS `.hero h1{...}` (linha 223) para incluir glow neon no grad-text:

```css
  .hero h1 .grad-text{animation:neonPulse 2.6s ease-in-out infinite;}
```

- [ ] **Step 4: Sync porto-das-frutas + validação + commit**

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
```

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "style: neon grid hero and glow tokens

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 2: Vitrine de pacotes neon

**Files:**
- Modify: `/workspace/index.html:362-380` (CSS pack-grid/pack-card)
- Test: `/workspace/index.html`

**Interfaces:**
- Produces: seletores `.pack-card` com moldura neon animada (keyframe `neonBorder`), selo `.pack-tag` neon, hover com glow.

- [ ] **Step 1: Adicionar keyframe neonBorder**

Inserir antes do bloco `.pack-grid{...}` (linha 362):

```css
  @keyframes neonBorder{
    0%,100%{border-color:var(--neon-pink); box-shadow:0 0 0 1px rgba(255,47,214,0.35), 0 18px 44px -16px rgba(255,47,214,0.4);}
    50%{border-color:var(--neon-cyan); box-shadow:0 0 0 1px rgba(0,240,255,0.35), 0 18px 44px -16px rgba(0,240,255,0.4);}
  }
```

- [ ] **Step 2: Restilizar pack-card**

Substituir as regras `.pack-card{...}`, `.pack-card:hover{...}`, `.pack-card.featured{...}` (linhas 363-368) por:

```css
  .pack-card{
    background:linear-gradient(160deg, rgba(124,92,255,0.10), rgba(255,47,214,0.08) 55%, rgba(0,240,255,0.08));
    border:1px solid rgba(255,47,214,0.35); border-radius:var(--radius);
    padding:22px; position:relative; transition:transform .2s, box-shadow .2s;
  }
  .pack-card:hover{transform:translateY(-5px); animation:neonBorder 2.2s ease-in-out infinite;}
  .pack-card.featured{border-color:var(--neon-cyan); box-shadow:0 0 0 1px rgba(0,240,255,0.35), 0 18px 44px -16px rgba(0,240,255,0.45);}
```

- [ ] **Step 3: Restilizar o selo Popular**

Substituir `.pack-card .pack-tag{...}` (linha 369) por:

```css
  .pack-card .pack-tag{
    position:absolute; top:-11px; right:14px; padding:4px 12px; border-radius:999px;
    background:linear-gradient(120deg, var(--neon-pink), var(--neon-violet));
    color:#fff; font-family:var(--font-mono); font-size:0.7rem; letter-spacing:0.08em;
    box-shadow:var(--neon-glow-pink); text-transform:uppercase;
  }
```

- [ ] **Step 4: Preço com brilho**

Substituir a regra `.pack-price` (linha ~379) — localizar e alterar `.pack-price .now` para:

```css
  .pack-price .now{color:var(--neon-cyan); text-shadow:0 0 14px rgba(0,240,255,0.45);}
```

- [ ] **Step 5: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html && diff -q index.html porto-das-frutas.html && echo SYNCED
```

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "style: neon pack showcase cards

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 3: Nav buttons + seções HTML (moedas, provas, faq)

**Files:**
- Modify: `/workspace/index.html:690-700` (navlinks), `/workspace/index.html:851` (antes da seção avaliacoes), `/workspace/index.html:883` (antes da seção ranking), `/workspace/index.html:917` (antes de termos)

**Interfaces:**
- Consumes: nada.
- Produces: IDs de seção `moedas`, `provas`, `faq`; `#coinGrid`, `#proofGrid`; botões `data-nav="moedas"|"provas"|"faq"`; containers FAQ estáticos `#faqSteps` e acordeões com classes `.faq-item`.

- [ ] **Step 1: Adicionar botões no nav**

Após o botão `data-nav="pacotes"` (linha 693), adicionar:

```html
      <button data-nav="moedas"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v10M9.5 9.5h5M9.5 14.5h5"/></svg>Moedas</button>
```

Após o botão `data-nav="avaliacoes"` (linha 695), adicionar:

```html
      <button data-nav="provas"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>Provas</button>
```

Após o botão `data-nav="chat"` (linha 698), adicionar:

```html
      <button data-nav="faq"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>FAQ</button>
```

- [ ] **Step 2: Seção Loja de Moedas**

Inserir antes da seção `<section id="avaliacoes">` (linha 851):

```html
<!-- ============ LOJA DE MOEDAS ============ -->
<section id="moedas" class="section-bg">
  <div class="container">
    <div class="section-head">
      <div class="eyebrow">Loja de Moedas</div>
      <h2>Moedas e <span class="grad-text-teal">fragmentos</span> direto na sua conta</h2>
      <p>Compre Robux, fragmentos, Bellys e muito mais. Adicione ao carrinho e finalize com PIX.</p>
    </div>
    <div class="pack-grid" id="coinGrid"></div>
  </div>
</section>
```

- [ ] **Step 3: Seção Provas de Entrega**

Inserir antes da seção `<section id="ranking">` (linha 883):

```html
<!-- ============ PROVAS DE ENTREGA ============ -->
<section id="provas">
  <div class="container">
    <div class="section-head">
      <div class="eyebrow">Provas de Entrega</div>
      <h2>Entregas <span class="grad-text">concluídas</span></h2>
      <p>Veja alguns prints de entregas que já realizamos para nossos clientes.</p>
    </div>
    <div class="proof-grid" id="proofGrid"></div>
  </div>
</section>
```

- [ ] **Step 4: Seção Ajuda/FAQ**

Inserir antes da seção `<section id="termos">` (linha 917):

```html
<!-- ============ AJUDA / FAQ ============ -->
<section id="faq" class="section-bg">
  <div class="container">
    <div class="section-head">
      <div class="eyebrow">Ajuda &amp; FAQ</div>
      <h2>Como <span class="grad-text">comprar</span> e tirar dúvidas</h2>
    </div>
    <div class="faq-steps" id="faqSteps">
      <div class="faq-step"><span class="faq-num">1</span><div><b>Simule ou escolha</b><p>Monte sua upagem no Simulador, escolha um Pacote ou Moedas.</p></div></div>
      <div class="faq-step"><span class="faq-num">2</span><div><b>Finalize o pedido</b><p>Revise o carrinho, informe seus dados e gere o PIX.</p></div></div>
      <div class="faq-step"><span class="faq-num">3</span><div><b>Pague via PIX</b><p>Pague o código gerado e envie o comprovante no WhatsApp.</p></div></div>
      <div class="faq-step"><span class="faq-num">4</span><div><b>Receba sua upagem</b><p>Nossa equipe inicia o serviço e combina a entrega no privado.</p></div></div>
    </div>
    <div class="faq-list">
      <details class="faq-item"><summary>O que é upagem?</summary><p>É um serviço em que nossa equipe evolui sua conta do Blox Fruits (maestria, níveis, fragmentos, hakis e muito mais) de forma segura e rápida.</p></details>
      <details class="faq-item"><summary>Quanto tempo demora a entrega?</summary><p>Depende do serviço escolhido. Em geral, maestrias e níveis levam de algumas horas a poucos dias. Atualizações ou quedas do Roblox podem estender o prazo.</p></details>
      <details class="faq-item"><summary>Quais formas de pagamento vocês aceitam?</summary><p>Somente PIX. A upagem é iniciada após a confirmação do pagamento.</p></details>
      <details class="faq-item"><summary>É seguro?</summary><p>Sim. Trabalhamos com upers de confiança, monitoramos todos os tickets e combinamos o acesso com segurança no privado.</p></details>
      <details class="faq-item"><summary>Preciso fornecer minha senha?</summary><p>Sim, o acesso é necessário para realizar o serviço, mas os dados são combinados com segurança no privado do uper responsável e você deve trocar sua senha após a entrega.</p></details>
      <details class="faq-item"><summary>E se eu desistir do serviço?</summary><p>Dependendo da situação, você poderá receber metade do reembolso ou nenhum, conforme os termos de serviço.</p></details>
    </div>
  </div>
</section>
```

- [ ] **Step 5: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html && diff -q index.html porto-das-frutas.html && echo SYNCED
```

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: add coins, proofs and faq navigation sections

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 4: Dados DEFAULT_COINS e DEFAULT_PROOFS + merge de settings

**Files:**
- Modify: `/workspace/index.html:1306` (após DEFAULT_PACKAGES), `/workspace/index.html:1370-1392` (sbConfigData/loadConfigSupabase), `/workspace/index.html:1591-1617` (loadAll)

**Interfaces:**
- Produces: `var DEFAULT_COINS` (array de `{id,icon,name,desc,qty,price}`), `var DEFAULT_PROOFS` (array de `{id,img,title,desc,date,status}`); `settings.coins`, `settings.proofs` sempre arrays.

- [ ] **Step 1: Definir DEFAULT_COINS e DEFAULT_PROOFS**

Inserir após o fechamento de `DEFAULT_PACKAGES` (após linha 1305):

```js
  var DEFAULT_COINS = [
    { id:"coin-robux100", icon:"🪙", name:"100 Robux", desc:"Crédito de 100 Robux direto na sua conta.", qty:100, price:7.00 },
    { id:"coin-robux400", icon:"🪙", name:"400 Robux", desc:"Crédito de 400 Robux com desconto.", qty:400, price:24.00 },
    { id:"coin-frag1k", icon:"💎", name:"1.000 Fragmentos", desc:"Fragmentos para desbloquear raças e habilidades.", qty:1000, price:15.00 },
    { id:"coin-frag5k", icon:"💎", name:"5.000 Fragmentos", desc:"Pacote grande de fragmentos com melhor preço.", qty:5000, price:55.00 },
    { id:"coin-belly1b", icon:"💰", name:"1 Bilhão de Bellys", desc:"Bellys para comprar tudo o que precisar.", qty:1000000000, price:35.00 },
    { id:"coin-gemas", icon:"💠", name:"1.000 Gemas", desc:"Gemas para itens exclusivos.", qty:1000, price:20.00 }
  ];

  var DEFAULT_PROOFS = [
    { id:"pr1", img:"https://picsum.photos/seed/loli1/400/260", title:"Maestria 500", desc:"Entrega concluída em 1 dia para Kaito_br.", date:"2026-08-10", status:"concluido" },
    { id:"pr2", img:"https://picsum.photos/seed/loli2/400/260", title:"Pack Lendário", desc:"Leviatã + scrolls entregues para FrutasLord.", date:"2026-08-08", status:"concluido" },
    { id:"pr3", img:"https://picsum.photos/seed/loli3/400/260", title:"Nível Máximo", desc:"Nível 2600+ entregue para MarujoX.", date:"2026-08-05", status:"concluido" }
  ];
```

- [ ] **Step 2: Incluir coins/proofs no sbConfigData**

Substituir a linha 1371:

```js
    return { config: settings.config, prices: settings.prices, packages: settings.packages, events: settings.events, coins: settings.coins, proofs: settings.proofs, admin: settings.admin };
```

- [ ] **Step 3: Merge no loadConfigSupabase**

No objeto `settings = {...}` de `loadConfigSupabase` (linhas 1379-1385), adicionar após a linha de `events`:

```js
          coins: (d.coins && d.coins.length) ? d.coins : JSON.parse(JSON.stringify(DEFAULT_COINS)),
          proofs: (d.proofs && d.proofs.length) ? d.proofs : JSON.parse(JSON.stringify(DEFAULT_PROOFS)),
```

- [ ] **Step 4: Merge no loadAll local + defaults no objeto settings inicial**

Na inicialização de `settings` (linha 1328), adicionar `coins` e `proofs` com defaults:

```js
  var settings = { config:Object.assign({}, DEFAULT_CONFIG), prices:JSON.parse(JSON.stringify(DEFAULT_PRICES)), packages:JSON.parse(JSON.stringify(DEFAULT_PACKAGES)), coins:JSON.parse(JSON.stringify(DEFAULT_COINS)), proofs:JSON.parse(JSON.stringify(DEFAULT_PROOFS)), events:JSON.parse(JSON.stringify(DEFAULT_EVENTS)), admin:{ salt:null, hash:null } };
```

No ramo local de `loadAll` (após linha 1602), adicionar:

```js
      if(!settings.coins || settings.coins.length===0) settings.coins = JSON.parse(JSON.stringify(DEFAULT_COINS));
      if(!settings.proofs || settings.proofs.length===0) settings.proofs = JSON.parse(JSON.stringify(DEFAULT_PROOFS));
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
```

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: coin and proof data with settings persistence

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 5: renderCoins() e renderProofs() + wiring no init

**Files:**
- Modify: `/workspace/index.html:1791` (após renderPackages), `/workspace/index.html:2681-2695` (init)

**Interfaces:**
- Consumes: `settings.coins`, `settings.proofs`, `addToCart(catId,name,price,qty)` (assinatura existente na linha 1684), `formatBRL`, `escapeHtml`.
- Produces: `renderCoins()` (usa `#coinGrid`), `renderProofs()` (usa `#proofGrid`).

- [ ] **Step 1: Implementar renderCoins()**

Inserir após a função `renderPackages()` (após linha 1791):

```js
  function renderCoins(){
    var grid = $('coinGrid');
    grid.innerHTML = settings.coins.map(function(c){
      return '<div class="pack-card"><div class="pack-icon">' + c.icon + '</div>' +
        '<h4>' + escapeHtml(c.name) + '</h4>' +
        '<p class="pack-desc">' + escapeHtml(c.desc||'') + '</p>' +
        '<div class="pack-price"><span class="now">' + formatBRL(c.price) + '</span></div>' +
        '<button class="btn btn-teal btn-sm" style="width:100%; margin-top:12px;" data-coin-add="' + escapeHtml(c.id) + '">Adicionar ao carrinho</button></div>';
    }).join('');
    grid.querySelectorAll('[data-coin-add]').forEach(function(btn){
      btn.addEventListener('click', function(){
        var c = settings.coins.find(function(x){ return x.id===btn.dataset.coinAdd; });
        if(!c) return;
        addToCart('moedas', c.name, c.price, 1);
        renderCart(); renderSimItems(); renderPriceTable();
        showToast(c.name + ' adicionado ao carrinho!', true);
      });
    });
  }
```

- [ ] **Step 2: Implementar renderProofs()**

Inserir após `renderCoins()`:

```js
  function renderProofs(){
    var grid = $('proofGrid');
    if(settings.proofs.length===0){ grid.innerHTML = '<div class="empty-state">Nenhuma prova cadastrada ainda.</div>'; return; }
    grid.innerHTML = settings.proofs.map(function(p){
      return '<div class="proof-card"><div class="proof-img"><img src="' + escapeHtml(p.img) + '" alt="' + escapeHtml(p.title) + '" loading="lazy" onerror="this.style.display=\'none\'"></div>' +
        '<div class="proof-body"><div class="proof-top"><h4>' + escapeHtml(p.title) + '</h4><span class="proof-badge">' + (p.status==='concluido'?'Concluído':'Entregue') + '</span></div>' +
        '<p>' + escapeHtml(p.desc||'') + '</p>' +
        '<div class="proof-date">' + escapeHtml(p.date||'') + '</div></div></div>';
    }).join('');
  }
```

- [ ] **Step 3: Chamar renderCoins() e renderProofs() no init()**

Em `init()` (linhas 2685-2687), adicionar após `renderPackages();`:

```js
    renderPackages();
    renderCoins();
    renderProofs();
```

- [ ] **Step 4: CSS das provas**

Inserir no `<style>` (antes de `/* ================= TOKENS ================= */` já usado na Task 1 — usar próximo ponto, após o bloco da Task 1):

```css
  .proof-grid{display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:18px;}
  .proof-card{background:var(--surface); border:1px solid var(--border-strong); border-radius:var(--radius); overflow:hidden; transition:transform .2s, box-shadow .2s;}
  .proof-card:hover{transform:translateY(-4px); box-shadow:var(--neon-glow-violet);}
  .proof-img{height:160px; overflow:hidden; background:linear-gradient(135deg, var(--surface-2), var(--surface-3)); display:flex; align-items:center; justify-content:center;}
  .proof-img img{width:100%; height:100%; object-fit:cover; display:block;}
  .proof-body{padding:16px;}
  .proof-top{display:flex; justify-content:space-between; align-items:center; gap:10px; margin-bottom:6px;}
  .proof-top h4{margin:0; font-size:1rem;}
  .proof-badge{font-family:var(--font-mono); font-size:0.68rem; color:var(--neon-cyan); border:1px solid rgba(0,240,255,0.4); border-radius:999px; padding:3px 9px;}
  .proof-date{font-family:var(--font-mono); font-size:0.72rem; color:var(--text-faint); margin-top:8px;}
  .faq-steps{display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:14px; margin-bottom:36px;}
  .faq-step{display:flex; gap:14px; align-items:flex-start; background:var(--surface); border:1px solid var(--border-strong); border-radius:var(--radius-sm); padding:16px;}
  .faq-num{flex:none; width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center; font-family:var(--font-mono); font-weight:800; color:#fff; background:linear-gradient(135deg, var(--neon-pink), var(--neon-violet)); box-shadow:var(--neon-glow-pink);}
  .faq-step b{display:block; margin-bottom:4px;}
  .faq-step p{margin:0; color:var(--text-dim); font-size:0.85rem;}
  .faq-list{max-width:720px; margin:0 auto; display:flex; flex-direction:column; gap:10px;}
  .faq-item{background:var(--surface); border:1px solid var(--border-strong); border-radius:var(--radius-sm); padding:14px 18px;}
  .faq-item summary{cursor:pointer; font-weight:700; color:var(--text); list-style:none; display:flex; justify-content:space-between; align-items:center;}
  .faq-item summary::after{content:'+'; font-family:var(--font-mono); color:var(--neon-cyan); font-size:1.2rem;}
  .faq-item[open] summary::after{content:'–';}
  .faq-item p{margin:10px 0 4px; color:var(--text-dim); font-size:0.9rem; line-height:1.6;}
```

- [ ] **Step 5: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
ids=set(re.findall(r'id="([^"]+)"', html))
refs=set(re.findall(r"\$\('([^']+)'\)", html))
print('missing:', sorted(r for r in refs if r not in ids))
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
node --test netlify/functions/*.test.mjs 2>&1 | tail -5
diff -q index.html porto-das-frutas.html && echo SYNCED
```

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: render coins and proofs sections

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 6: Painéis admin de Moedas e Provas

**Files:**
- Modify: `/workspace/index.html:991-999` (admin-tabs), `/workspace/index.html:1001-1010` (admin-panels), `/workspace/index.html:2366-2368` (renderAdminAll)

**Interfaces:**
- Consumes: `settings.coins`, `settings.proofs`, `saveSettings()`, `genId`, `renderAdminEvents` como modelo.
- Produces: `renderAdminCoins()` (usa `#coinsListAdmin`), `renderAdminProofs()` (usa `#proofsListAdmin`); adicionados a `renderAdminAll()`.

- [ ] **Step 1: Adicionar abas no admin-tabs**

Após `<button data-panel="panelEditor">Editor de Preços</button>` (linha 997), adicionar:

```html
        <button data-panel="panelCoins">Moedas</button>
        <button data-panel="panelProofs">Provas</button>
```

- [ ] **Step 2: Adicionar painéis admin**

Após o painel `panelEditor` (linha 1010), adicionar:

```html
      <div class="admin-panel" id="panelCoins"><div id="coinsListAdmin"></div></div>
      <div class="admin-panel" id="panelProofs"><div id="proofsListAdmin"></div></div>
```

- [ ] **Step 3: Implementar renderAdminCoins() e renderAdminProofs()**

Inserir após `renderAdminEvents()` (após linha 2477):

```js
  function renderAdminCoins(){
    var wrap = $('coinsListAdmin');
    wrap.innerHTML = settings.coins.map(function(c){
      return '<div class="row-card"><div class="row-top"><div class="rid">' + escapeHtml(c.id) + '</div>' +
        '<button class="btn btn-danger-outline btn-sm" data-cact="delete" data-cid="' + escapeHtml(c.id) + '">Excluir</button></div>' +
        '<div class="field-row"><div class="field"><label>Nome</label><input value="' + escapeHtml(c.name) + '" data-cfield="name" data-cid="' + escapeHtml(c.id) + '"></div>' +
        '<div class="field"><label>Preço (R$)</label><input type="number" step="0.01" value="' + c.price + '" data-cfield="price" data-cid="' + escapeHtml(c.id) + '"></div></div>' +
        '<div class="field" style="margin:0;"><label>Descrição</label><textarea data-cfield="desc" data-cid="' + escapeHtml(c.id) + '">' + escapeHtml(c.desc) + '</textarea></div></div>';
    }).join('');
    wrap.querySelectorAll('[data-cfield]').forEach(function(inp){
      inp.addEventListener('change', async function(e){
        var c = settings.coins.find(function(x){ return x.id===inp.dataset.cid; });
        if(c){
          c[inp.dataset.cfield] = inp.dataset.cfield==='price' ? Number(e.target.value) : e.target.value;
          await saveSettings(); renderCoins();
        }
      });
    });
    wrap.querySelectorAll('[data-cact="delete"]').forEach(function(b){
      b.addEventListener('click', async function(){
        settings.coins = settings.coins.filter(function(x){ return x.id!==b.dataset.cid; });
        await saveSettings(); renderAdminCoins(); renderCoins();
        showToast('Moeda removida.');
      });
    });
    var addBtn = document.createElement('button');
    addBtn.className = 'btn btn-ghost btn-sm';
    addBtn.textContent = '+ Nova moeda';
    addBtn.addEventListener('click', async function(){
      settings.coins.unshift({ id: genId('coin').toLowerCase(), icon:'🪙', name:'Nova moeda', desc:'Descrição da moeda', qty:1, price:10.00 });
      await saveSettings(); renderAdminCoins(); renderCoins();
    });
    wrap.appendChild(addBtn);
  }
  function renderAdminProofs(){
    var wrap = $('proofsListAdmin');
    wrap.innerHTML = settings.proofs.map(function(p){
      return '<div class="row-card"><div class="row-top"><div class="rid">' + escapeHtml(p.id) + '</div>' +
        '<button class="btn btn-danger-outline btn-sm" data-pact="delete" data-pid="' + escapeHtml(p.id) + '">Excluir</button></div>' +
        '<div class="field"><label>URL da imagem</label><input value="' + escapeHtml(p.img) + '" data-pfield="img" data-pid="' + escapeHtml(p.id) + '"></div>' +
        '<div class="field-row"><div class="field"><label>Título</label><input value="' + escapeHtml(p.title) + '" data-pfield="title" data-pid="' + escapeHtml(p.id) + '"></div>' +
        '<div class="field"><label>Data</label><input type="date" value="' + p.date + '" data-pfield="date" data-pid="' + escapeHtml(p.id) + '"></div></div>' +
        '<div class="field" style="margin:0;"><label>Descrição</label><textarea data-pfield="desc" data-pid="' + escapeHtml(p.id) + '">' + escapeHtml(p.desc) + '</textarea></div></div>';
    }).join('');
    wrap.querySelectorAll('[data-pfield]').forEach(function(inp){
      inp.addEventListener('change', async function(e){
        var p = settings.proofs.find(function(x){ return x.id===inp.dataset.pid; });
        if(p){ p[inp.dataset.pfield] = e.target.value; await saveSettings(); renderProofs(); }
      });
    });
    wrap.querySelectorAll('[data-pact="delete"]').forEach(function(b){
      b.addEventListener('click', async function(){
        settings.proofs = settings.proofs.filter(function(x){ return x.id!==b.dataset.pid; });
        await saveSettings(); renderAdminProofs(); renderProofs();
        showToast('Prova removida.');
      });
    });
    var addBtn = document.createElement('button');
    addBtn.className = 'btn btn-ghost btn-sm';
    addBtn.textContent = '+ Nova prova';
    addBtn.addEventListener('click', async function(){
      settings.proofs.unshift({ id: genId('pr').toLowerCase(), img:'https://picsum.photos/seed/' + Date.now() + '/400/260', title:'Nova prova', desc:'Descrição da entrega', date:new Date().toISOString().slice(0,10), status:'concluido' });
      await saveSettings(); renderAdminProofs(); renderProofs();
    });
    wrap.appendChild(addBtn);
  }
```

- [ ] **Step 4: Incluir em renderAdminAll()**

Substituir a linha 2367:

```js
    renderAdminStats(); renderAdminOrders(); renderAdminUsers(); renderAdminReviews(); renderAdminEvents(); renderAdminMessages(); renderAdminEditor(); renderAdminCoins(); renderAdminProofs();
```

- [ ] **Step 5: Sync + validação + commit**

```bash
cd /workspace && cp index.html porto-das-frutas.html
python3 - <<'EOF'
import re
html=open('index.html').read()
ids=set(re.findall(r'id="([^"]+)"', html))
refs=set(re.findall(r"\$\('([^']+)'\)", html))
print('missing:', sorted(r for r in refs if r not in ids))
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo OK
node --test netlify/functions/*.test.mjs 2>&1 | tail -5
diff -q index.html porto-das-frutas.html && echo SYNCED
```

```bash
cd /workspace && git add index.html porto-das-frutas.html && git commit -m "feat: admin panels for coins and proofs

Co-authored-by: monkeycode-ai <monkeycode-ai@chaitin.com>"
```

---

### Task 7: Revisão final e publicação

**Files:**
- Test: `/workspace/index.html`, `/workspace/porto-das-frutas.html`, `netlify/functions/*.test.mjs`

**Interfaces:**
- Consumes: todas as tasks anteriores.
- Produces: entrega final validada e publicada.

- [ ] **Step 1: Validação completa**

```bash
cd /workspace && python3 - <<'EOF'
import re
html=open('index.html').read()
ids=set(re.findall(r'id="([^"]+)"', html))
refs=set(re.findall(r"\$\('([^']+)'\)", html))
missing=sorted(r for r in refs if r not in ids)
print('IDs faltando:', missing)
m=re.search(r'<script>(.*?)</script>', html, re.S)
open('/tmp/opencode/inline.js','w').write(m.group(1))
EOF
node --check /tmp/opencode/inline.js && echo SYNTAX_OK
node --test netlify/functions/*.test.mjs 2>&1 | grep -E "^# (pass|fail)"
diff -q index.html porto-das-frutas.html && echo SYNCED
grep -c 'data-nav="moedas"\|data-nav="provas"\|data-nav="faq"\|renderCoins\|renderProofs\|DEFAULT_COINS\|DEFAULT_PROOFS' index.html
```

- [ ] **Step 2: Push e deploy**

```bash
cd /workspace && git status --short && git log --oneline -8
```

```bash
cd /workspace && git push origin main 2>&1 | tail -3
```

- [ ] **Step 3: Smoke test no preview**

Confirmar que o servidor de preview (porta 8000) ainda responde e o HTML servido contém as novas seções:

```bash
curl -s http://localhost:8000/index.html | grep -o 'id="moedas"\|id="provas"\|id="faq"' | sort -u
```

- [ ] **Step 4: Commit final de qualquer pendência (se houver)**

```bash
cd /workspace && git status --short
```
Se houver mudanças não commitadas, commitá-las com o padrão co-autoria e push. Se limpo, não fazer nada.
