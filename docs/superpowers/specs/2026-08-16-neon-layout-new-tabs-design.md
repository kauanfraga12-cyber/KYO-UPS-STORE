# Spec: Layout Game Neon + 3 Novas Abas (Moedas, Provas, FAQ)

## Objetivo

Redesenhar a home e a vitrine de pacotes da loja LOLI Ups com um visual "game neon" (cores vibrantes, gradientes ousados, brilhos) e adicionar três novas abas de navegação: **Loja de Moedas**, **Provas de Entrega** e **Ajuda/FAQ**.

## Contexto

- Site atual: `/workspace/index.html` (e `/workspace/porto-das-frutas.html`, cópia byte-idêntica que deve ser sincronizada ao final).
- Tema atual: rosa kawaii (tokens `--pink`, `--violet`, `--gold` etc.), fonte Fredoka.
- JS em ES5 (`var`, funções declaradas), sem módulos.
- Persistência: Supabase com fallback localStorage (`settings`, `reviews`, `orders`, `chat`).
- Navegação por abas via `[data-nav]` com `scrollIntoView` + classe `.active`.
- Admin já possui abas internas (Pedidos, Clientes, Avaliações, Eventos, Mensagens, Editor, Configurações).

## Escopo

### 1. Home e vitrine em estilo Game Neon

- **Hero** (`#home`): fundo com grid retrô + brilhos animados (pulse), título com glow neon gradiente (rosa → violeta → ciano), mantendo `#heroTitle`, `#heroTagline`, botões (`data-nav`), `#heroWhatsBtn`, `.hero-trust` e o beacon (`#beaconCore`, `#beaconLabel`) intactos.
- **Feature strip**: cards com bordas com brilho neon no hover, ícones com glow.
- **Vitrine de pacotes** (`#packGrid`): cards com moldura neon animada, selo "Popular" mais chamativo, preço com brilho, hover com glow ciano/rosa. Botões `data-pack-add` e demais IDs permanecem iguais.
- **Apenas CSS/HTML visual** — nenhuma mudança de JS funcional na home/vitrine além do que já existe.

### 2. Aba nova — Loja de Moedas

- Nova seção `#moedas` com ofertas de moedas in-game (Robux, fragmentos, Bellys, gemas) em cards estilo neon.
- Dados em `DEFAULT_COINS` (estrutura parecida com `DEFAULT_PACKAGES`): `{ id, icon, name, desc, qty, price }`.
- Itens adicionáveis ao carrinho reutilizando `addToCart`/`renderCart` (adiciona direto como item de tabela se existir preço correspondente, senão adiciona com preço próprio).
- Botão de navegação `data-nav="moedas"` no nav.
- Persistência: `settings.coins` salvo no Supabase/localStorage, com default em `DEFAULT_COINS`.

### 3. Aba nova — Provas de Entrega

- Nova seção `#provas` com galeria de provas (prints) das entregas concluídas.
- Card de prova: imagem (URL), descrição do serviço, data, status.
- Dados em `DEFAULT_PROOFS`: `{ id, img, title, desc, date, status }`.
- Persistência: `settings.proofs` (Supabase/localStorage).
- Admin: novo painel interno `panelProofs` para adicionar/remover provas (campos: URL da imagem, título, descrição, data, status).
- Botão de navegação `data-nav="provas"` no nav.

### 4. Aba nova — Ajuda/FAQ

- Nova seção `#faq` com:
  - Passo-a-passo "Como comprar" em 4 etapas (cards numerados).
  - FAQ em acordeão (detalhe/sumário) com perguntas frequentes: como funciona, quanto demora, segurança, formas de pagamento, o que é upagem.
- Conteúdo estático em HTML (sem banco).
- Botão de navegação `data-nav="faq"` no nav.

### 5. Infraestrutura / regras

- Manter padrão ES5; não quebrar IDs existentes.
- `index.html` e `porto-das-frutas.html` sincronizados ao final.
- Validação: `node --check` do script inline; checagem de IDs referenciados via `$('id')` (nenhum missing); testes Netlify `node --test netlify/functions/*.test.mjs` (6 testes) devem continuar passando.

## Fora de escopo (YAGNI)

- Seletor de tema alternativo por botão (usuário escolheu redesenhar, não trocar por botão).
- Integração real de compra de moedas com gateway (itens de moedas usam o fluxo PIX/checkout existente).
- Upload real de imagens (admin informa URL da imagem).

## Arquitetura / componentes

- **Dados**: novas constantes `DEFAULT_COINS` e `DEFAULT_PROOFS`; `settings` ganha `coins` e `proofs` com defaults e merge no load (local e Supabase), seguindo o padrão existente de `packages`/`events`.
- **Render**: `renderCoins()` e `renderProofs()` seguindo o padrão de `renderPackages()`/`renderReviews()`. Chamadas adicionadas em `init()`.
- **Admin**: novos painéis `panelCoins` e `panelProofs` no HTML do admin, com handlers de adicionar/remover seguindo o padrão de eventos (`panelEvents`).
- **Nav**: três novos botões `data-nav` no `.navlinks`; seções com `id` correspondente.
- **CSS**: variáveis/tokens novos para neon (ex: `--neon-cyan`, `--neon-pink`) e classes de efeito (glow, grid backdrop), com media query mobile mantida.

## Fluxo de dados

1. `loadAll()` carrega `settings.coins` e `settings.proofs` (Supabase ou local), aplicando defaults se vazio.
2. `init()` chama `renderCoins()` e `renderProofs()`.
3. Ao adicionar moeda ao carrinho: `addToCart(...)` com `qty` e preço da moeda → `renderCart()`.
4. Admin salva alterações de moedas/provas → `saveSettingsLocal()` / `saveSettingsSupabase()` e re-render.

## Erros e edge cases

- URLs de imagem inválidas em provas: card mostra placeholder/estilo sem imagem (CSS `background` + `alt`/emojis).
- `settings.coins`/`settings.proofs` ausentes em dados antigos: defaults aplicados no load.
- Nav mobile: novos botões cabem no scroll horizontal já existente.
- Moedas sem preço correspondente na tabela: adicionadas com preço próprio ao carrinho (o cart já suporta items com `price`).

## Testes / validação

1. `node --check` do script inline (extraído via regex) — deve passar.
2. Script de checagem de IDs: todas as referências `$('id')` existem no HTML.
3. `node --test netlify/functions/*.test.mjs` — 6 testes passando.
4. Smoke test manual no preview: navegação nas 3 novas abas funciona, adicionar moeda ao carrinho, admin gerencia provas.
5. `diff index.html porto-das-frutas.html` idêntico após sync.
