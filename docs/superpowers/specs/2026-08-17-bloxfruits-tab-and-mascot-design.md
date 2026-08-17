# Spec: Aba Blox Fruits, Mascote Animada e Mais Vida no Site

Data: 2026-08-17
Repo: KYO-UPS-STORE (LOLI Ups)
Arquivos: `index.html` + `porto-das-frutas.html` (byte-idênticos), `assets/mascot.jpg`

## Contexto

A loja LOLI Ups vende upagem para Blox Fruits e outros jogos. Hoje só existe a seção
"Pacotes" (geral). O usuário quer:
1. Uma aba dedicada **Blox Fruits** (outros jogos virão depois, cada um com sua aba).
2. Uma **mascote loli kawaii animada** (imagem enviada) fixa no canto, que reage a
   cliques, carrinho, compras e erros.
3. Mais vida no começo do site (hero "seco").
4. Correção do erro de criação de contas (causa: "Confirm email" ativo no Supabase).
5. Conta admin: já existe `kyoaccount` (mantida).

## 1. Aba Blox Fruits (nova seção separada)

- Botão na nav: `data-nav="bloxfruits"` com ícone de jogo, posicionado entre
  "Pacotes" e "Moedas" (linha ~742-743).
- Seção `<section id="bloxfruits" class="section-bg">` após a seção `#pacotes`.
- Conteúdo: título + subtítulo + grid `#bfPackGrid` + grid `#bfCoinGrid`.
- Novos dados:
  - `var DEFAULT_BF_PACKAGES` — pacotes exclusivos de Blox Fruits (inspirados nos
    existentes, com itens do jogo: Maestria, Bounty, Fragmentos, Hakis, Leviatã).
  - `var DEFAULT_BF_COINS` — moedas exclusivas de Blox Fruits (Robux, Fragmentos,
    Bellys, Gemas).
- Persistência: seguem o padrão de `packages`/`coins`:
  - `settings.bfPackages` e `settings.bfCoins` no objeto inicial de `settings`.
  - Adicionados ao return de `sbConfigData()`.
  - Merge em `loadConfigSupabase()` e defaults em `loadAll()`.
- Renderização: `renderBfPacks()` (usa `$('bfPackGrid')`, padrão de `renderPackages`)
  e `renderBfCoins()` (usa `$('bfCoinGrid')`, padrão de `renderCoins`).
  - Botão de compra de pacote BF chama `addToCart(p.id, p.name, p.total, 1)`.
  - Botão de moeda BF chama `addToCart('moedas', c.name, c.price, 1)`.
- Admin: painéis `panelBfPacks` e `panelBfCoins` com `renderAdminBfPacks()` e
  `renderAdminBfCoins()` (padrão de `renderAdminCoins`/`renderAdminProofs`), abas
  "Blox Pacotes" e "Blox Moedas" no admin-tabs, incluídos em `renderAdminAll()`.

## 2. Mascote animada (imagem `assets/mascot.jpg`)

- Imagem enviada salva como `assets/mascot.jpg` (500x281). Referenciada via
  `assets/mascot.jpg` (relativa).
- HTML (antes do `</body>`): `<div id="mascot" title="LOLI-chan">` contendo:
  - `<div id="mascotBubble">` balão de fala (oculto por padrão).
  - `<img src="assets/mascot.jpg" alt="Mascote LOLI">`.
  - `#mascotHearts` para corações voando (animação).
- CSS:
  - Fixa no canto inferior direito: `position:fixed; right:18px; bottom:18px;
    z-index:9999; cursor:pointer;`.
  - Imagem: `border-radius:50%; object-fit:cover; width:110px; height:110px;`
    com borda neon/kawaii e sombra.
  - Animação contínua de flutuação (`@keyframes mascotFloat` — sobe/desce suave).
  - Balão: `position:absolute; bottom:120px; right:0;` estilo kawaii com setinha.
  - Classes de reação: `.mascot-happy` (pula), `.mascot-excited` (treme rápido +
    brilho), `.mascot-sad` (abaixa + balanço), `.mascot-wave` (rotação leve).
  - `@keyframes mascotHearts` (corações que sobem e somem).
- JS (ES5):
  - `var MASCOT_PHRASES` = array de frases de saudação (kawaii).
  - `function mascotSay(text, cls)` — mostra balão com texto, aplica classe de
    animação na imagem, limpa após ~3s (`setTimeout`).
  - `function mascotReact(kind)` — mapeia `kind` para frase + classe:
    - `'welcome'` → saudação de boas-vindas (no load).
    - `'cart'` → "Adicionei ao carrinho! 💕" (chamado em `addToCart`).
    - `'buy'` → "Pedido confirmado! 💖" (chamado ao confirmar pedido/checkout).
    - `'error'` → "Ops! Deu um errozinho 🥺" (chamado nos erros de auth/checkout).
    - `'click'` → frase aleatória de `MASCOT_PHRASES`.
  - Clique na mascote → `mascotReact('click')` + animação de pulo.
  - Atualização: chamadas adicionadas em `addToCart`, confirmação de pedido,
    `setAuthError`, e `init()` (welcome).
- Apenas uma imagem: as "reações" são texto no balão + animações CSS (sem troca
  de sprite).

## 3. Mais vida no site (hero)

- Partículas flutuantes no hero: elementos decorativos animados (corações,
  estrelinhas) via CSS `@keyframes floatUp` dentro de `.hero` (pseudo-elementos
  ou spans fixos). Leve, não interferente.
- Gradiente animado no título: `@keyframes gradShift` no `.grad-text` do hero
  (transição de fundo/tons).
- Cards de destaque (`.feature-card`) com hover animado (elevação + brilho).
- Nenhuma mudança estrutural no hero além de decoração.

## 4. Correção do cadastro

- Causa raiz: **"Confirm email" LIGADO no Supabase** (Authentication → Providers →
  Email). O signup da API retorna usuário mas sem sessão (`confirmation_sent_at`).
- Correção no código: em `registerSupabase`, se `!res.data.session`:
  1. Tentar `loginSupabase(name, pass)` imediatamente (funciona se o toggle foi
     desativado).
  2. Se falhar, lançar mensagem clara: "Sua conta foi criada, mas o Supabase está
     com 'Confirm email' ativo. Desative em Authentication > Providers > Email e
     tente de novo."
- Documentar no site/README que o toggle deve estar desligado.
- (O usuário precisa desativar o toggle no dashboard do Supabase — ação manual,
  fora do código.)

## 5. Conta admin

- Mantida `kyoaccount` / `kauannovais@1` como admin. Nenhuma mudança.

## Critérios de aceite

- `node --check` do JS inline passa.
- Nenhum `$('id')` sem `id` correspondente.
- `diff -q index.html porto-das-frutas.html` → SYNCED.
- 6 testes Netlify (`node --test netlify/functions/*.test.mjs`) passam.
- Nav tem `data-nav="bloxfruits"`; seção `#bloxfruits` com `#bfPackGrid` e
  `#bfCoinGrid`; admin-tabs com `panelBfPacks`/`panelBfCoins`.
- `#mascot` presente; `mascotReact` chamado em cart, buy, error, click, welcome.
- Imagem `assets/mascot.jpg` commitada no repo.
- Deploy Netlify/GitHub Pages atualizado; preview servindo as mudanças.
