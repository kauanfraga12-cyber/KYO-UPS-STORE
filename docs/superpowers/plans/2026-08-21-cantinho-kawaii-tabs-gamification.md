# Cantinho Do Loli — Redesign Kawaii Neon com Abas e Gamificação — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transformar a loja atual (tema Luxe Sharp, rolagem longa) em um painel kawaii neon com 5 abas (Início / Loja / Avaliações / Ranking / Admin), mantendo todas as funções e adicionando gamificação real (Diário, Metas, Entregas, Tarefas da loja, Lista de espera) salva no Supabase.

**Architecture:** Tudo em `index.html` (CSS no `<style>`, JS ES5 no `<script>`, seções em `<section>` trocadas via `showTab(id)`). Visual kawaii neon via design tokens; gamificação em tabelas Supabase novas com fallback localStorage. Mascote com 3 GIFs em `assets/`.

**Tech Stack:** HTML/CSS/JS ES5 puro, Supabase JS (v2, CDN), Google Fonts Nunito, Cloudflare Worker (já existente), jsdom (testes).

## Global Constraints

- JS ES5 puro: **proibido** arrow functions, template literals, `let`/`const`, optional chaining, `async/await` fora do necessário (já usado no código: manter o padrão `async function` existente).
- Não usar `window.storage` diferente do atual; `dbGet`/`dbSet` já existem.
- `index.html` e `porto-das-frutas.html` devem ser **byte-idênticos** ao final de cada task (`cp` + `cmp`).
- Nome da loja: **"Cantinho Do Loli ✦"** (subtítulo "LOLI UPS"). Nome atual vem de `settings.config.shopName` (Supabase tem "Porto das Frutas"); o novo nome padrão vai em `DEFAULT_CONFIG.shopName`.
- Paleta: fundo `#12041b`; `--neon-pink:#ff007f`, `--neon-pink-soft:#ff66b2`, `--neon-violet:#b14dff`, `--neon-cyan:#00e5ff`, `--panel:rgba(255,20,147,0.05)`, `--gold:#ffd700`.
- Cantos: painéis 20px, botões 25px (pílula), inputs 12px.
- Fonte Nunito (700/900); `--font-display`/`--font-body` apontam para Nunito.
- Mascote GIFs: `assets/mascot-teto.gif` (padrão), `assets/mascot-catgirl.gif` (feliz), `assets/mascot-momona.gif` (triste).
- Trailer de commit: **nunca** adicionar `Co-authored-by` manualmente; o hook `.git/hooks/prepare-commit-msg` adiciona automaticamente.
- Tabelas novas Supabase: `diary_notes`, `goals`, `shop_tasks`, `waitlist` — usar `public.is_admin()` (função SECURITY DEFINER já criada) nas políticas para evitar recursão.
- Testes jsdom: usar `NODE_PATH=/usr/local/lib/node_modules` e mockar `crypto.subtle` em `beforeParse` (não existe no jsdom; sem mock o `init()` falha no `sha256`). Não usar `resources:"usable"` (puxa CDN Supabase e pendura o init).

---

### Task 1: Design tokens kawaii neon + fonte Nunito

**Files:**
- Modify: `index.html:9` (fonte), `index.html:36-79` (tokens)
- Test: inline via jsdom smoke

**Interfaces:**
- Consumes: nada.
- Produces: tokens `--neon-pink`, `--neon-pink-soft`, `--neon-violet`, `--neon-cyan`, `--bg:#12041b`, `--panel`, cantos 20/25/12px, fontes Nunito; classe `.neon-box`.

- [ ] **Step 1: Trocar a fonte para Nunito**

Substituir a linha 9 (link do Google Fonts) por:

```html
<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@700;800;900&display=swap" rel="stylesheet">
```

- [ ] **Step 2: Atualizar os tokens no `:root`**

Substituir o bloco `:root{...}` (linhas 36-79) por:

```css
  :root{
    --bg:#12041b;
    --bg-alt:#1b0727;
    --surface:#221030;
    --surface-2:#2b1440;
    --surface-3:#341a4e;
    --border:rgba(255,102,178,0.22);
    --border-strong:rgba(255,0,127,0.45);
    --parchment:#fff0f6;
    --ink:#2b0f26;
    --gold:#ffd700;
    --gold-2:#ffb84d;
    --gold-bright:#ffe98a;
    --teal:#ff66b2;
    --teal-deep:#e04a9e;
    --violet:#b14dff;
    --violet-deep:#8a2be2;
    --pink:#ff007f;
    --coral:#ff5c8a;
    --green:#7ce8a5;
    --text:#fdf3fa;
    --text-dim:#d9b8d6;
    --text-faint:#a583a8;
    --ok:#7ce8a5;
    --warn:#ffd700;
    --danger:#ff6b8b;
    --font-display:'Nunito', sans-serif;
    --font-pirate:'Nunito', sans-serif;
    --font-body:'Nunito', sans-serif;
    --font-mono:'Nunito', monospace;
    --radius:20px;
    --radius-sm:12px;
    --shadow-lg:0 24px 60px -20px rgba(0,0,0,0.65);
    --shadow-md:0 12px 32px -12px rgba(0,0,0,0.55);
    --neon-pink:#ff007f;
    --neon-pink-soft:#ff66b2;
    --neon-violet:#b14dff;
    --neon-cyan:#00e5ff;
    --neon-glow-pink:0 0 10px #ff007f, 0 0 20px #ff007f;
    --neon-glow-violet:0 0 10px #b14dff, 0 0 20px #b14dff;
    --neon-glow-cyan:0 0 10px #00e5ff, 0 0 20px #00e5ff;
  }
```

Nota: manter `--glow-teal`, `--glow-gold`, `--glow-violet`, `--neon-cyan`, `--neon-violet` definidos para não quebrar regras legadas. `--neon-cyan` e `--neon-violet` já existiam.

- [ ] **Step 3: Adicionar a classe `.neon-box`**

Inserir logo após o fechamento do `:root` (após linha 79):

```css
  .neon-box{
    background-color:var(--panel);
    border:3px solid var(--neon-pink-soft);
    border-radius:20px;
    padding:20px;
    box-shadow:0 0 10px var(--neon-pink), 0 0 20px var(--neon-pink), inset 0 0 10px var(--neon-pink);
  }
```

- [ ] **Step 4: Smoke test — jsdom sem erro**

```bash
cd /workspace && NODE_PATH=/usr/local/lib/node_modules node -e '
const fs=require("fs"); const crypto=require("crypto");
const {JSDOM}=require("jsdom");
const dom=new JSDOM(fs.readFileSync("index.html","utf8"),{url:"https://kyo.test/",runScripts:"dangerously",pretendToBeVisual:true,beforeParse(w){
  if(w.crypto&&!w.crypto.subtle){Object.defineProperty(w.crypto,"subtle",{value:{digest:async function(a,b){return Buffer.from(crypto.createHash("sha256").update(Buffer.from(b)).digest("hex"),"hex");}}});}
}});
const errs=[]; dom.virtualConsole.on("jsdomError",e=>errs.push(String(e.message||e)));
setTimeout(()=>{ console.log("erros:",errs.length?errs.slice(0,4):"nenhum"); process.exit(0); },4000);
'
```
Expected: `erros: nenhum`

- [ ] **Step 5: Sync HTML e commit**

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "style: kawaii neon design tokens and Nunito font"
```

---

### Task 2: Estrutura de abas + header/nav + hero compacto

**Files:**
- Modify: `index.html:786-821` (nav), `index.html:824-865` (hero/home), `index.html:3234-3246` (navegação JS)
- Test: jsdom funcional

**Interfaces:**
- Consumes: tokens da T1.
- Produces: função `showTab(id)`; botões nav com `data-tab` (5 abas); wrapper de conteúdo `#tabInicio`, `#tabLoja`, `#tabAvaliacoes`, `#tabRanking`, `#tabAdmin`; `data-jump` para atalhos intra-aba (ex: "Ver Loja" vai para tab Loja).

- [ ] **Step 1: Substituir o `<nav>` pelos 5 botões de aba**

Substituir o bloco `.navlinks` (linhas 795-808) por:

```html
    <div class="navlinks">
      <button data-tab="inicio" class="active">🏠 Início</button>
      <button data-tab="loja">🛍️ Loja</button>
      <button data-tab="avaliacoes">⭐ Avaliações</button>
      <button data-tab="ranking">🏆 Ranking</button>
      <button data-tab="admin">🔐 Admin</button>
    </div>
```

Manter `.brand` (marca) e `.nav-actions` (carrinho + conta) intactos.

- [ ] **Step 2: Criar o sistema de abas no JS**

Substituir o bloco "NAVEGAÇÃO" (linhas 3234-3246) por:

```js
  /* ============================================================
     NAVEGAÇÃO — ABAS
     ============================================================ */
  var TAB_SECTIONS = {
    inicio:    ['home', 'gamification', 'chat'],
    loja:      ['simulador', 'pacotes', 'bloxfruits', 'tabela', 'moedas', 'eventos', 'checkout'],
    avaliacoes:['provas', 'avaliacoes', 'faq'],
    ranking:   ['ranking'],
    admin:     ['admin']
  };
  function showTab(tabId){
    var order = TAB_SECTIONS[tabId] || [];
    var all = document.querySelectorAll('.tab-section');
    for(var i=0;i<all.length;i++){ all[i].style.display = 'none'; }
    for(var j=0;j<order.length;j++){
      var el = document.getElementById(order[j]);
      if(el){ el.style.display = ''; }
    }
    document.querySelectorAll('.navlinks button').forEach(function(b){
      b.classList.toggle('active', b.getAttribute('data-tab') === tabId);
    });
  }
  document.querySelectorAll('[data-tab]').forEach(function(btn){
    btn.addEventListener('click', function(){
      showTab(btn.getAttribute('data-tab'));
    });
  });
  document.querySelectorAll('[data-jump]').forEach(function(btn){
    btn.addEventListener('click', function(){
      var t = btn.getAttribute('data-jump');
      var el = document.getElementById(t);
      if(el){ el.scrollIntoView({behavior:'smooth', block:'start'}); }
    });
  });
```

- [ ] **Step 3: Marcar as `<section>` com classe `.tab-section` e esconder as não-iniciais**

- Adicionar `class="tab-section"` às sections: `home`, `simulador`, `pacotes`, `bloxfruits`, `tabela`, `moedas`, `avaliacoes`, `eventos`, `provas`, `ranking`, `chat`, `faq`, `admin`.
- Manter `home` visível inicialmente; as demais recebem `style="display:none;"` inline (exceção: `chat` fica dentro de `#tabInicio` junto com gamification — ver T5).
- Em `init()`, após `loadAll()`, chamar `showTab('inicio')`.

Para reduzir risco, em vez de esconder 12 sections uma a uma, aplicar via JS no fim do `init()`:

```js
  var defaultHidden = ['simulador','pacotes','bloxfruits','tabela','moedas','avaliacoes','eventos','provas','ranking','chat','faq','admin'];
  defaultHidden.forEach(function(id){
    var el = document.getElementById(id);
    if(el){ el.style.display = 'none'; }
  });
```

- [ ] **Step 4: Ajustar o hero para compacto + botões com `data-jump`**

No hero (`home`, linhas 824-865), trocar o botão "Simular minha upagem" (`data-nav="simulador"`) por:

```html
          <button class="btn btn-primary" data-jump="simulador">✨ Simular minha upagem</button>
```

E o botão "Ver Pacotes" (`data-nav="pacotes"`) por:

```html
          <button class="btn btn-teal" data-jump="pacotes">🎁 Ver Pacotes</button>
```

Manter o WhatsApp. Adicionar título do hero com o novo nome:

```html
        <div class="eyebrow">Cantinho Do Loli — Loja de Upagem</div>
        <h1 id="heroTitle">Cantinho Do <span class="grad-text">Loli</span> ✦</h1>
```

Nota: `heroTitle` é sobrescrito por `renderShell()` com `settings.config.shopName`. Para o novo nome padrão, ver T3 (DEFAULT_CONFIG.shopName).

- [ ] **Step 5: Teste jsdom funcional**

```bash
cd /workspace && NODE_PATH=/usr/local/lib/node_modules node -e '
const fs=require("fs"); const crypto=require("crypto");
const {JSDOM}=require("jsdom");
const dom=new JSDOM(fs.readFileSync("index.html","utf8"),{url:"https://kyo.test/",runScripts:"dangerously",pretendToBeVisual:true,beforeParse(w){
  if(w.crypto&&!w.crypto.subtle){Object.defineProperty(w.crypto,"subtle",{value:{digest:async function(a,b){return Buffer.from(crypto.createHash("sha256").update(Buffer.from(b)).digest("hex"),"hex");}}});}
}});
dom.virtualConsole.on("jsdomError",e=>console.log("[err]",String(e.message||e)));
setTimeout(()=>{
  const doc=dom.window.document;
  console.log("nav_buttons:", doc.querySelectorAll(".navlinks button[data-tab]").length);  // 5
  console.log("home_display:", doc.getElementById("home").style.display);
  console.log("loja_nav_exists:", !!doc.querySelector("button[data-tab=loja]"));
  process.exit(0);
},4000);
'
```
Expected: `nav_buttons: 5`, `loja_nav_exists: true`

- [ ] **Step 6: Sync HTML e commit**

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "feat: 5-tab panel navigation with kawaii header"
```

---

### Task 3: Aba Loja — mover seções + renomear kawaii

**Files:**
- Modify: `index.html:1403` (`DEFAULT_CONFIG`), sections `simulador`/`pacotes`/`bloxfruits`/`tabela`/`moedas`/`eventos`, títulos de `<h2>`
- Test: jsdom smoke

**Interfaces:**
- Consumes: `showTab` da T2, tokens da T1.
- Produces: novo `DEFAULT_CONFIG.shopName = "Cantinho Do Loli ✦"`; seções renomeadas em kawaii; `data-jump` funcionando intra-aba.

- [ ] **Step 1: Atualizar `DEFAULT_CONFIG.shopName`**

Localizar `shopName:` dentro de `DEFAULT_CONFIG` (por volta da linha 1403) e alterar para:

```js
    shopName: "Cantinho Do Loli ✦",
```

Se o Supabase já tiver "Porto das Frutas" salvo, o site continuará mostrando o nome do banco. Para forçar o novo nome, atualizar a row `site_config` (ver nota final do plano).

- [ ] **Step 2: Renomear títulos de seção (kawaii)**

Alterar os textos de `<h2>`/títulos:
- `simulador`: título com "Simulador" → "Simulador Fofinho"
- `pacotes`: "Pacotes" → "Pacotes de Ups 🎁"
- `moedas`: "Moedas" → "Moedinhas 🪙"
- `provas`: "Provas" → "Provinhas 📸"
- `ranking`: "Ranking" → "Ranking Fofinho 🏆"

Aplicar via edições individuais de strings de título. Exemplo (pacotes):

```html
      <h2>Pacotes de <span class="grad-text">Ups</span> 🎁</h2>
```

- [ ] **Step 3: Verificar `data-nav` remanescentes dentro da Loja**

Substituir `data-nav="X"` remanescentes dentro das seções da aba Loja por `data-jump="X"` (só os que navegam entre seções da própria Loja). Usar:

```bash
cd /workspace && rg -n 'data-nav=' index.html
```
Corrigir cada ocorrência para `data-jump=` (se aponta para seção da aba Loja) ou remover (se redundante). Links de "Termos" podem apontar via `data-jump="termos"` ou abrir a aba mais próxima.

- [ ] **Step 4: Smoke test jsdom**

Repetir o comando de smoke da T1 Step 4. Expected: `erros: nenhum`.

- [ ] **Step 5: Sync e commit**

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "style: kawaii tab naming and shopName default"
```

---

### Task 4: Abas Avaliações + Ranking

**Files:**
- Modify: `index.html` sections `avaliacoes`/`provas`/`faq`/`ranking`
- Test: jsdom smoke

**Interfaces:**
- Consumes: `showTab` da T2.
- Produces: seções renomeadas; `#socialNoteToggle` continua visível; ranking renderiza dentro da aba.

- [ ] **Step 1: Verificar que as sections estão no mapa de abas**

Confirmar que `TAB_SECTIONS.avaliacoes = ['provas','avaliacoes','faq']` e `TAB_SECTIONS.ranking = ['ranking']` (já definido na T2).

- [ ] **Step 2: Ajustar títulos e títulos de painel kawaii**

- `avaliacoes`: adicionar emoji ao título (ex: "Avaliações ⭐")
- `provas`: "Provinhas 📸"
- `faq`: título "Perguntas Frequentes" manter, adicionar emoji (ex: "Perguntinhas Fofas 💬")
- `ranking`: "Ranking Fofinho 🏆"
- Verificar `socialNoteToggle` na seção avaliações continua presente.

- [ ] **Step 3: Smoke test + commit**

```bash
cd /workspace && NODE_PATH=/usr/local/lib/node_modules node -e 'const fs=require("fs");const crypto=require("crypto");const {JSDOM}=require("jsdom");const d=new JSDOM(fs.readFileSync("index.html","utf8"),{url:"https://kyo.test/",runScripts:"dangerously",pretendToBeVisual:true,beforeParse(w){if(w.crypto&&!w.crypto.subtle){Object.defineProperty(w.crypto,"subtle",{value:{digest:async function(a,b){return Buffer.from(crypto.createHash("sha256").update(Buffer.from(b)).digest("hex"),"hex");}}});}}});const errs=[];d.virtualConsole.on("jsdomError",e=>errs.push(String(e.message||e)));setTimeout(()=>{console.log("erros:",errs.length?errs.slice(0,4):"nenhum");console.log("toggle:",!!d.window.document.getElementById("socialNoteToggle"));process.exit(0);},4000);'
```
Expected: `erros: nenhum`, `toggle: true`

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "style: kawaii reviews and ranking tabs"
```

---

### Task 5: Gamificação — Diário, Metas, Entregas, Tarefas da loja, Lista de espera

**Files:**
- Create: `supabase.sql` — estender com 4 tabelas (anexar no final do arquivo)
- Modify: `index.html` — HTML da seção `gamification`, JS de gamificação, SQL loader
- Test: jsdom funcional (modo local) + verificação de SQL

**Interfaces:**
- Consumes: `dbGet`/`dbSet` (linha 1383-1390), `settings`, `orders`, `currentUser`, `isAdmin`.
- Produces: funções `renderGamification()`, `loadGamification()`, `saveGamification()`, helpers `goalsRender`, `diaryRender`, `waitlistRender`, `tasksRender`, `deliveriesRender`; estado `gam` (objeto de gamificação); tabelas SQL `diary_notes`, `goals`, `shop_tasks`, `waitlist`.

- [ ] **Step 1: Estender `supabase.sql` com as tabelas novas**

Anexar ao final de `supabase.sql`:

```sql
-- ------------------------------------------------------------
-- GAMIFICAÇÃO
-- ------------------------------------------------------------
create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  title text not null,
  current_value numeric default 0,
  target_value numeric,
  done boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.diary_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  order_id text not null,
  note text not null default '',
  created_at timestamptz default now()
);

create table if not exists public.shop_tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  done boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.waitlist (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  username text not null,
  game text not null default '',
  handled boolean default false,
  created_at timestamptz default now()
);

alter table public.goals enable row level security;
alter table public.diary_notes enable row level security;
alter table public.shop_tasks enable row level security;
alter table public.waitlist enable row level security;

drop policy if exists gl_select on public.goals;
create policy gl_select on public.goals for select using (auth.uid() = user_id or public.is_admin());
drop policy if exists gl_insert on public.goals;
create policy gl_insert on public.goals for insert with check (auth.uid() = user_id);
drop policy if exists gl_update on public.goals;
create policy gl_update on public.goals for update using (auth.uid() = user_id or public.is_admin());
drop policy if exists gl_delete on public.goals;
create policy gl_delete on public.goals for delete using (auth.uid() = user_id or public.is_admin());

drop policy if exists dn_select on public.diary_notes;
create policy dn_select on public.diary_notes for select using (auth.uid() = user_id or public.is_admin());
drop policy if exists dn_insert on public.diary_notes;
create policy dn_insert on public.diary_notes for insert with check (auth.uid() = user_id);
drop policy if exists dn_update on public.diary_notes;
create policy dn_update on public.diary_notes for update using (auth.uid() = user_id or public.is_admin());
drop policy if exists dn_delete on public.diary_notes;
create policy dn_delete on public.diary_notes for delete using (auth.uid() = user_id or public.is_admin());

drop policy if exists st_select on public.shop_tasks;
create policy st_select on public.shop_tasks for select using (public.is_admin());
drop policy if exists st_insert on public.shop_tasks;
create policy st_insert on public.shop_tasks for insert with check (public.is_admin());
drop policy if exists st_update on public.shop_tasks;
create policy st_update on public.shop_tasks for update using (public.is_admin());
drop policy if exists st_delete on public.shop_tasks;
create policy st_delete on public.shop_tasks for delete using (public.is_admin());

drop policy if exists wl_select on public.waitlist;
create policy wl_select on public.waitlist for select using (public.is_admin() or auth.uid() = user_id);
drop policy if exists wl_insert on public.waitlist;
create policy wl_insert on public.waitlist for insert with check (auth.uid() = user_id);
drop policy if exists wl_update on public.waitlist;
create policy wl_update on public.waitlist for update using (public.is_admin() or auth.uid() = user_id);
drop policy if exists wl_delete on public.waitlist;
create policy wl_delete on public.waitlist for delete using (public.is_admin() or auth.uid() = user_id);
```

- [ ] **Step 2: Adicionar a seção `#gamification` no HTML**

Inserir logo após o fechamento de `</section>` da `home` (após o hero), como uma nova `<section id="gamification" class="tab-section">`:

```html
<!-- ============ GAMIFICAÇÃO ============ -->
<section id="gamification" class="tab-section">
  <div class="container">
    <div style="display:grid; grid-template-columns:repeat(auto-fit,minmax(300px,1fr)); gap:20px;">

      <!-- DIÁRIO -->
      <div class="neon-box">
        <div class="panel-title">Meu Diário ✦</div>
        <div id="diaryList" style="display:flex; flex-direction:column; gap:10px; max-height:260px; overflow:auto;"></div>
      </div>

      <!-- METAS -->
      <div class="neon-box">
        <div class="panel-title">Minhas Metas 🎯</div>
        <div id="goalsList" style="display:flex; flex-direction:column; gap:10px; max-height:260px; overflow:auto;"></div>
        <div style="display:flex; gap:8px; margin-top:12px;">
          <input id="goalTitleInput" placeholder="Nova meta (ex: Maestria 600)" style="flex:1;">
          <button class="btn btn-primary btn-sm" id="goalAddBtn">Adicionar</button>
        </div>
      </div>

      <!-- ENTREGAS -->
      <div class="neon-box">
        <div class="panel-title">Entregas 📦</div>
        <div id="deliveriesList" style="display:flex; flex-direction:column; gap:10px; max-height:260px; overflow:auto;"></div>
      </div>

      <!-- TAREFAS DA LOJA (admin) -->
      <div class="neon-box" id="shopTasksPanel" style="display:none;">
        <div class="panel-title">Tarefas da Loja ✅</div>
        <div id="tasksList" style="display:flex; flex-direction:column; gap:10px; max-height:200px; overflow:auto;"></div>
        <div style="display:flex; gap:8px; margin-top:12px;">
          <input id="taskTitleInput" placeholder="Nova tarefa" style="flex:1;">
          <button class="btn btn-primary btn-sm" id="taskAddBtn">Adicionar</button>
        </div>
      </div>

      <!-- LISTA DE ESPERA -->
      <div class="neon-box">
        <div class="panel-title">Lista de Espera 🎀</div>
        <div id="waitlistList" style="display:flex; flex-direction:column; gap:10px; max-height:200px; overflow:auto;"></div>
        <div style="display:flex; gap:8px; margin-top:12px;">
          <input id="waitGameInput" placeholder="Jogo/pedido" style="flex:1;">
          <button class="btn btn-primary btn-sm" id="waitAddBtn">Entrar na fila</button>
        </div>
      </div>

    </div>
  </div>
</section>
```

Nota: adicionar CSS para `.panel-title` se não existir:

```css
  .panel-title{
    font-size:1.15rem; margin-bottom:12px; color:var(--neon-pink-soft);
    border-bottom:2px dashed var(--neon-pink); padding-bottom:8px; text-transform:uppercase; font-weight:900;
  }
```

- [ ] **Step 3: Adicionar o estado e carregamento da gamificação (JS)**

Inserir perto de `settings` (após a declaração de `var settings`):

```js
  var gam = { goals:[], diaryNotes:{}, tasks:[], waitlist:[] };
```

Inserir funções (após `loadAll`), com fallback local via `dbGet`/`dbSet`:

```js
  async function loadGamification(){
    if(USE_SUPABASE){
      var [g, dn, t, w] = await Promise.all([
        sb.from('goals').select('*').eq('user_id', currentUser ? currentUser.id : 'none'),
        sb.from('diary_notes').select('*').eq('user_id', currentUser ? currentUser.id : 'none'),
        sb.from('shop_tasks').select('*').order('created_at',{ascending:true}),
        sb.from('waitlist').select('*').order('created_at',{ascending:true})
      ]);
      gam.goals = (g.data||[]).filter(function(x){ return currentUser && x.user_id===currentUser.id; });
      gam.diaryNotes = {};
      (dn.data||[]).forEach(function(n){ gam.diaryNotes[n.order_id] = n.note; });
      gam.tasks = (t.data||[]);
      gam.waitlist = (w.data||[]);
    } else {
      gam.goals = await dbGet('shop.goals', []);
      gam.diaryNotes = await dbGet('shop.diaryNotes', {});
      gam.tasks = await dbGet('shop.tasks', []);
      gam.waitlist = await dbGet('shop.waitlist', []);
    }
  }
  async function saveGamification(){
    if(USE_SUPABASE) return;
    await dbSet('shop.goals', gam.goals);
    await dbSet('shop.diaryNotes', gam.diaryNotes);
    await dbSet('shop.tasks', gam.tasks);
    await dbSet('shop.waitlist', gam.waitlist);
  }
```

Nota: em modo Supabase, `loadGamification` não é chamado se não há `currentUser` (goals e diaryNotes não fazem sentido). Chamar só quando houver sessão (ver Step 5). Em modo local, chamar sempre.

- [ ] **Step 4: Implementar os renders (JS)**

Adicionar funções de render (ES5, sem arrow):

```js
  function fmtDate(ts){
    var d = new Date(ts);
    return String(d.getDate()).padStart(2,'0') + '/' + String(d.getMonth()+1).padStart(2,'0');
  }
  function diaryRender(){
    var el = $('diaryList'); if(!el) return;
    if(!currentUser){ el.innerHTML = '<p style="color:var(--text-dim);">Entre para ver seu diário 🌸</p>'; return; }
    var mine = orders.filter(function(o){ return o.userId === currentUser.id; }).slice().sort(function(a,b){ return b.timestamp - a.timestamp; });
    if(!mine.length){ el.innerHTML = '<p style="color:var(--text-dim);">Nenhuma compra ainda 💕</p>'; return; }
    el.innerHTML = mine.map(function(o){
      return '<div style="border-bottom:1px dashed var(--border); padding:6px 0; font-size:0.85rem;">' +
        '<b>' + fmtDate(o.timestamp) + '</b> — ' + (o.items&&o.items[0]?o.items[0].name:'Pedido') + ' · R$ ' + (Number(o.total)||0).toFixed(2) +
        ' <span style="color:var(--gold);">' + (o.status||'') + '</span>' +
        '<textarea data-diary="' + o.id + '" style="width:100%; margin-top:4px; font-size:0.75rem;" rows="1" placeholder="Nota...">' +
          (gam.diaryNotes[o.id] || '') + '</textarea></div>';
    }).join('');
    el.querySelectorAll('[data-diary]').forEach(function(ta){
      ta.addEventListener('change', function(){
        gam.diaryNotes[ta.getAttribute('data-diary')] = ta.value;
        saveGamification();
      });
    });
  }
  function goalsRender(){
    var el = $('goalsList'); if(!el) return;
    if(!gam.goals.length){ el.innerHTML = '<p style="color:var(--text-dim);">Nenhuma meta ainda 🎯</p>'; return; }
    el.innerHTML = gam.goals.map(function(g,i){
      var pct = (g.target_value) ? Math.min(100, Math.round(100*g.current_value/g.target_value)) : (g.done ? 100 : 0);
      return '<div style="border-bottom:1px dashed var(--border); padding:6px 0;">' +
        '<div style="display:flex; justify-content:space-between; align-items:center;">' +
          '<b style="' + (g.done ? 'text-decoration:line-through; color:var(--text-dim);' : '') + '">' + g.title + '</b>' +
          '<button data-goal-del="' + i + '" style="background:none; border:none; color:var(--danger); cursor:pointer;">✕</button>' +
        '</div>' +
        (g.target_value ? '<div style="height:8px; background:rgba(255,102,178,.15); border-radius:6px; margin:4px 0; overflow:hidden;">' +
          '<div style="height:100%; width:' + pct + '%; background:linear-gradient(90deg,var(--neon-pink),var(--neon-cyan));"></div></div>' +
          '<div style="display:flex; gap:6px; align-items:center; font-size:0.75rem;">' +
            '<input data-goal-cur="' + i + '" type="number" value="' + g.current_value + '" style="width:64px;"> / ' + g.target_value +
            '<button data-goal-done="' + i + '" class="btn btn-ghost btn-sm">' + (g.done?'Desfazer':'Concluir') + '</button>' +
          '</div>' : '') +
      '</div>';
    }).join('');
    el.querySelectorAll('[data-goal-del]').forEach(function(b){
      b.addEventListener('click', function(){ gam.goals.splice(Number(b.getAttribute('data-goal-del')),1); saveGamification(); goalsRender(); });
    });
    el.querySelectorAll('[data-goal-cur]').forEach(function(inp){
      inp.addEventListener('change', function(){
        var i = Number(inp.getAttribute('data-goal-cur'));
        gam.goals[i].current_value = Number(inp.value)||0;
        saveGamification(); goalsRender();
      });
    });
    el.querySelectorAll('[data-goal-done]').forEach(function(b){
      b.addEventListener('click', function(){
        var i = Number(b.getAttribute('data-goal-done'));
        gam.goals[i].done = !gam.goals[i].done;
        saveGamification(); goalsRender();
      });
    });
  }
  function deliveriesRender(){
    var el = $('deliveriesList'); if(!el) return;
    var mine = orders.filter(function(o){ return o.userId === currentUser.id && (o.status==='pago'||o.status==='andamento'||o.status==='concluido'); });
    if(!mine.length){ el.innerHTML = '<p style="color:var(--text-dim);">Nenhuma entrega em andamento 📦</p>'; return; }
    el.innerHTML = mine.map(function(o){
      var steps = ['aguardando','pago','andamento','concluido'];
      var cur = steps.indexOf(o.status); if(cur<0) cur = 0;
      var bar = steps.map(function(s,i){
        return '<span style="padding:2px 6px; border-radius:8px; font-size:0.7rem; ' + (i<=cur ? 'background:var(--neon-pink); color:#fff;' : 'background:rgba(255,102,178,.12); color:var(--text-dim);') + '">' + s + '</span>';
      }).join(' → ');
      return '<div style="border-bottom:1px dashed var(--border); padding:6px 0; font-size:0.8rem;"><b>' + (o.items&&o.items[0]?o.items[0].name:'Pedido') + '</b><br>' + bar + '</div>';
    }).join('');
  }
  function tasksRender(){
    var el = $('tasksList'); if(!el) return;
    if(!gam.tasks.length){ el.innerHTML = '<p style="color:var(--text-dim);">Nenhuma tarefa ✅</p>'; return; }
    el.innerHTML = gam.tasks.map(function(t,i){
      return '<label style="display:flex; gap:8px; align-items:center; font-size:0.85rem; border-bottom:1px dashed var(--border); padding:4px 0; cursor:pointer;">' +
        '<input type="checkbox" data-task="' + i + '" ' + (t.done?'checked':'') + '> ' + t.title + '</label>';
    }).join('');
    el.querySelectorAll('[data-task]').forEach(function(cb){
      cb.addEventListener('change', function(){
        var i = Number(cb.getAttribute('data-task'));
        gam.tasks[i].done = cb.checked;
        saveGamification(); tasksRender();
      });
    });
  }
  function waitlistRender(){
    var el = $('waitlistList'); if(!el) return;
    var open = gam.waitlist.filter(function(w){ return !w.handled; });
    var myIdx = -1;
    if(currentUser){ for(var k=0;k<open.length;k++){ if(open[k].user_id===currentUser.id || open[k].username===currentUser.name){ myIdx = k; break; } } }
    el.innerHTML = open.map(function(w,i){
      return '<div style="display:flex; justify-content:space-between; align-items:center; font-size:0.85rem; border-bottom:1px dashed var(--border); padding:4px 0;">' +
        '<span>🎀 ' + w.username + (w.game?' — '+w.game:'') + (myIdx===i?' <b style="color:var(--gold);">(você é o #'+(i+1)+')</b>':'') + '</span>' +
        (isAdmin ? '<button data-wl-done="' + i + '" class="btn btn-ghost btn-sm">Atender</button>' : '') +
        '</div>';
    }).join('') || '<p style="color:var(--text-dim);">Fila vazia 🎀</p>';
    if(isAdmin){
      el.querySelectorAll('[data-wl-done]').forEach(function(b){
        b.addEventListener('click', function(){
          var i = Number(b.getAttribute('data-wl-done'));
          gam.waitlist.splice(i,1);
          saveGamification(); waitlistRender();
        });
      });
    }
  }
  function renderGamification(){
    diaryRender(); goalsRender(); deliveriesRender(); tasksRender(); waitlistRender();
  }
```

- [ ] **Step 5: Wiring no `init()` e eventos**

Dentro de `init()`, após `renderReviews()` (ou após `loadAll()`), adicionar:

```js
    await loadGamification();
    renderGamification();
    var shopTasksPanel = $('shopTasksPanel');
    if(shopTasksPanel){ shopTasksPanel.style.display = isAdmin ? '' : 'none'; }
```

E adicionar listeners para os botões de adicionar:

```js
    var gAdd = $('goalAddBtn');
    if(gAdd){ gAdd.addEventListener('click', function(){
      var v = $('goalTitleInput').value.trim();
      if(!v || !currentUser) return;
      gam.goals.push({ title:v, current_value:0, target_value:0, done:false });
      $('goalTitleInput').value = '';
      saveGamification(); goalsRender();
    }); }
    var tAdd = $('taskAddBtn');
    if(tAdd){ tAdd.addEventListener('click', function(){
      var v = $('taskTitleInput').value.trim();
      if(!v) return;
      gam.tasks.push({ title:v, done:false });
      $('taskTitleInput').value = '';
      saveGamification(); tasksRender();
    }); }
    var wAdd = $('waitAddBtn');
    if(wAdd){ wAdd.addEventListener('click', function(){
      if(!currentUser){ alert('Entre para entrar na fila.'); return; }
      var g = $('waitGameInput').value.trim();
      gam.waitlist.push({ user_id: currentUser.id, username: currentUser.name, game: g, handled: false });
      $('waitGameInput').value = '';
      saveGamification(); waitlistRender();
    }); }
```

Adicionar `await loadGamification();` também dentro de `renderAll`/atualização de `currentUser` (após login) — chamar `loadGamification(); renderGamification();` no handler de login (local e Supabase), e no `restoreSession*`.

- [ ] **Step 6: Teste jsdom funcional (modo local, mock crypto)**

```bash
cd /workspace && NODE_PATH=/usr/local/lib/node_modules node -e '
const fs=require("fs"); const crypto=require("crypto");
const {JSDOM}=require("jsdom");
const dom=new JSDOM(fs.readFileSync("index.html","utf8"),{url:"https://kyo.test/",runScripts:"dangerously",pretendToBeVisual:true,beforeParse(w){
  if(w.crypto&&!w.crypto.subtle){Object.defineProperty(w.crypto,"subtle",{value:{digest:async function(a,b){return Buffer.from(crypto.createHash("sha256").update(Buffer.from(b)).digest("hex"),"hex");}}});}
}});
dom.virtualConsole.on("jsdomError",e=>console.log("[err]",String(e.message||e)));
setTimeout(()=>{
  const doc=dom.window.document;
  console.log("gam_section:", !!doc.getElementById("gamification"));
  console.log("diary_list:", !!doc.getElementById("diaryList"));
  console.log("goals_list:", !!doc.getElementById("goalsList"));
  console.log("deliveries:", !!doc.getElementById("deliveriesList"));
  console.log("tasks:", !!doc.getElementById("tasksList"));
  console.log("waitlist:", !!doc.getElementById("waitlistList"));
  process.exit(0);
},5000);
'
```
Expected: todos `true`.

- [ ] **Step 7: Sync e commit**

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html supabase.sql
git commit -m "feat: gamification panels (diary, goals, deliveries, tasks, waitlist) with Supabase tables"
```

---

### Task 6: Mascote GIF + notificação social com GIF + splash

**Files:**
- Create: `assets/mascot-teto.gif`, `assets/mascot-catgirl.gif`, `assets/mascot-momona.gif` (já baixados)
- Modify: `index.html:727-742` (CSS mascote), `index.html:1353-1356` (HTML mascote), `index.html:1338-1348` (social note)
- Test: jsdom smoke + `ls -la assets/*.gif`

**Interfaces:**
- Consumes: nada.
- Produces: mascote com 3 GIFs alternáveis via função `setMascotGif(kind)`; social note com avatar emoji/GIF.

- [ ] **Step 1: Atualizar HTML do mascote para usar GIF + avatares**

Substituir o bloco do mascote (linhas 1353-1356) por:

```html
<div id="mascot" title="LOLI-chan">
  <div id="mascotBubble"></div>
  <img class="mascot-img" id="mascotImg" src="assets/mascot-teto.gif" alt="Mascote LOLI-chan">
  <div id="mascotHearts">💕</div>
</div>
```

Ajustar CSS do `.mascot-img` (linha 728) para arredondado e sem borda quadrada:

```css
  #mascot .mascot-img{width:104px; height:104px; border-radius:50%; object-fit:cover; border:3px solid var(--neon-pink-soft); box-shadow:0 0 20px -4px var(--neon-pink); animation:mascotFloat 3.4s ease-in-out infinite; background:#fff;}
```

- [ ] **Step 2: Adicionar `setMascotGif`**

Adicionar perto das funções do mascote:

```js
  function setMascotGif(kind){
    var img = $('mascotImg');
    if(!img) return;
    var map = { happy:'assets/mascot-catgirl.gif', sad:'assets/mascot-momona.gif', default:'assets/mascot-teto.gif' };
    img.src = map[kind] || map.default;
  }
```

Chamar `setMascotGif('happy')` no caminho de pedido concluído (após checkout/status pago) e `setMascotGif('sad')` em erro (ex: falha de PIX). Manter `setMascotGif('default')` em `mascotReact`/início.

- [ ] **Step 3: Notificação social — avatar com emoji**

No HTML do social note (`#socialNote`), o `#snAvatar` já existe. Trocar o conteúdo default de `?` para emoji:

```html
  <span class="sn-avatar" id="snAvatar">✨</span>
```

Ajustar o CSS de `.sn-avatar` (se existir) para arredondado neon. Em `showSocialNote()`, manter o fallback:

```js
    $('snAvatar').textContent = (item.name || '?').charAt(0).toUpperCase();
```

Se quiser avatar emoji, substituir essa linha por um mapa de emojis por nome (opcional):

```js
    var avatars = { 'Ana L.':'🌸','Pedro M.':'⭐','Julia R.':'💖','Caio S.':'🌈','Bia K.':'🎀','Lucas T.':'✨' };
    $('snAvatar').textContent = avatars[item.name] || (item.name||'?').charAt(0).toUpperCase();
```

- [ ] **Step 4: Splash — emoji kawaii**

Trocar o coração do splash (`#splash .splash-heart`, linha 22) para `✨` e ajustar o logo se quiser. Manter a estrutura.

- [ ] **Step 5: Smoke test + commit**

```bash
cd /workspace && ls -la assets/mascot-teto.gif assets/mascot-catgirl.gif assets/mascot-momona.gif
```
Expected: 3 arquivos existem (>0 bytes).

Rodar smoke jsdom (comando da T1 Step 4). Expected: `erros: nenhum`.

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html assets/mascot-teto.gif assets/mascot-catgirl.gif assets/mascot-momona.gif
git commit -m "feat: kawaii mascot GIFs and social note avatars"
```

---

### Task 7: Admin + validação final + push

**Files:**
- Modify: `index.html` (painel admin — só texto/estilo, sem mudar lógica)
- Test: jsdom funcional + validações completas

**Interfaces:**
- Consumes: tudo das T1-T6.
- Produces: validação final (SYNC, JS_OK, sem IDs órfãos, ES5) e push para `main`.

- [ ] **Step 1: Ajustar painel admin ao tema**

- Trocar títulos "Acesso da Equipe" para manter, mas com emoji kawaii (`🔐 Acesso da Equipe`).
- Verificar que `data-panel` (sub-abas do admin) não conflita com `data-tab`. Eles usam seletores diferentes (`data-panel` vs `data-tab`) — confirmar que o handler de `data-panel` continua intacto.
- Ajustar o botão "Acesso da Equipe" no rodapé (linha 1130) para abrir a aba admin: `onclick` deve chamar `showTab('admin')`.

- [ ] **Step 2: Fixar o botão "Acesso da Equipe"**

Alterar o link do rodapé:

```html
      <button class="admin-link" id="openAdminBtn" onclick="showTab('admin')">🔐 Acesso da Equipe</button>
```

E no JS, substituir o handler existente de `openAdminBtn` (que faz `scrollIntoView`, linha 2713) por `showTab('admin')`:

```js
  $('openAdminBtn').addEventListener('click', function(){ showTab('admin'); });
```

- [ ] **Step 3: Validação ES5 + IDs**

```bash
cd /workspace && node --check index.html 2>&1 | head -5 || echo "JS_OK(node --check nao aplica a html; usar extração)";
```
Extrair o JS do HTML e checar:

```bash
cd /workspace && node -e '
const fs=require("fs");
const html=fs.readFileSync("index.html","utf8");
const m=html.match(/<script>([\s\S]*?)<\/script>/);
const js=m[1];
fs.writeFileSync("/tmp/site.js", js);
'
node --check /tmp/site.js && echo "JS_OK"
rg -n '=>' /tmp/site.js && echo "TEM_ARROW_ES6!" || echo "SEM_ARROW (ES5 OK)"
rg -n '\$\{|\`' /tmp/site.js && echo "TEM_TEMPLATE!" || echo "SEM_TEMPLATE (ES5 OK)"
```

- [ ] **Step 4: Teste funcional jsdom completo (modo local)**

```bash
cd /workspace && NODE_PATH=/usr/local/lib/node_modules node -e '
const fs=require("fs"); const crypto=require("crypto");
const {JSDOM}=require("jsdom");
const dom=new JSDOM(fs.readFileSync("index.html","utf8"),{url:"https://kyo.test/",runScripts:"dangerously",pretendToBeVisual:true,beforeParse(w){
  if(w.crypto&&!w.crypto.subtle){Object.defineProperty(w.crypto,"subtle",{value:{digest:async function(a,b){return Buffer.from(crypto.createHash("sha256").update(Buffer.from(b)).digest("hex"),"hex");}}});}
}});
const errs=[]; dom.virtualConsole.on("jsdomError",e=>errs.push(String(e.message||e)));
setTimeout(()=>{
  const doc=dom.window.document;
  console.log("packGrid:", doc.getElementById("packGrid").children.length);
  console.log("badges:", doc.querySelectorAll(".pack-badge").length);
  console.log("beacon:", doc.getElementById("beaconLabel").innerHTML.slice(0,40));
  console.log("socialNote_show:", doc.getElementById("socialNote").classList.contains("show"));
  console.log("erros:", errs.length?errs.slice(0,4):"nenhum");
  process.exit(0);
},6000);
'
```
Expected: `packGrid: 6`, `badges: 4`, `socialNote_show: true`, `erros: nenhum`.

- [ ] **Step 5: Sync, push e validar GitHub Pages**

```bash
cp index.html porto-das-frutas.html
cmp index.html porto-das-frutas.html && echo SYNC_OK
git add index.html porto-das-frutas.html
git commit -m "feat: kawaii neon redesign with tabs and gamification"
git push origin main
```

Após o push, aguardar ~30s e validar:

```bash
sleep 30
curl -s -m 30 https://kauanfraga12-cyber.github.io/KYO-UPS-STORE/ -o /tmp/gh.html
rg -c 'id="gamification"' /tmp/gh.html && echo "GH_GAM_OK"
rg -c 'id="socialNote"' /tmp/gh.html && echo "GH_SOCIAL_OK"
```

Expected: `GH_GAM_OK: 1`, `GH_SOCIAL_OK: 1`.

---

## Nota Final — Dados do Supabase

Se o banco Supabase já tem `site_config` com `shopName: "Porto das Frutas"`, o site publicado continuará mostrando esse nome até a row ser atualizada. Para forçar "Cantinho Do Loli ✦" sem depender do admin:
- No dashboard Supabase, abrir a tabela `site_config` → editar a row `id=1` → mudar `config.shopName` para `"Cantinho Do Loli ✦"`.
- Ou via SQL Editor: `update public.site_config set data = jsonb_set(data, '{config,shopName}', '"Cantinho Do Loli ✦"') where id = 1;`

O usuário também precisa rodar o bloco SQL da T5 Step 1 no Supabase SQL Editor (novas tabelas de gamificação). Se não rodar, a gamificação funciona em modo local (localStorage) por fallback — mas não persiste entre navegadores.
