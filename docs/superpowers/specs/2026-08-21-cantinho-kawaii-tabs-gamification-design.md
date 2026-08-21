# Cantinho Do Loli — Redesign Kawaii Neon com Abas e Gamificação

Data: 2026-08-21
Status: Aprovado

## Objetivo

Transformar a loja atual (tema Luxe Sharp, rolagem longa) em um **painel kawaii neon com 5 abas**, mantendo todas as funcionalidades existentes (loja, PIX, admin, Supabase, chat, notificações sociais) e adicionando **gamificação real** (Diário, Metas, Entregas, Tarefas da loja, Lista de espera) salva no Supabase.

## Nome e Marca

- Nome: **"Cantinho Do Loli ✦"** (subtítulo "LOLI UPS")
- Produtos mantidos, renomeados em estilo kawaii
- Mascote: personagem kawaii em GIF (ver Mascote)

## Abordagem Escolhida

**A. Redesign completo com abas** — página de painel com 5 abas, gamificação real, visual kawaii neon. Confirmado pelo usuário.

## Estrutura e Navegação

**Splash (mantém):** tela de entrada estilo kawaii com logo, "Entrar na loja", "Ver preços", "WhatsApp".

**Header:** logo "Cantinho Do Loli ✦" + sub "LOLI UPS"; nav com 5 abas; direita: beacon de status (com contador), carrinho, botão Entrar/perfil.

**5 Abas:**

| Aba | Conteúdo |
|-----|----------|
| Início | Hero compacto, Novidades da loja, Diário do cliente, Metas, Entregas, Tarefas da loja (admin), Lista de espera, Chat |
| Loja | Simulador de preço, Pacotes, Moedas, Tabela de preços, Eventos, Checkout PIX |
| Avaliações | Provas, Avaliações, FAQ |
| Ranking | Ranking de clientes |
| Admin | Painel admin (login + gestão) |

Navegação por `showTab(id)` trocando `<section>` visível. Hash opcional (`#loja`). Notificação social (popup) global sobre qualquer aba.

## Hero

Cabeçalho da aba Início (não é landing page de tela cheia):
- Nome grande com brilho neon
- Tagline atual mantida
- Beacon de status (aberto/fechado) + contador de serviços
- Botões: "Ver Loja" (vai para aba Loja) e "WhatsApp"
- Trust pills mantidas

## Visual — Design Tokens

**Fundo:** roxo escuro `#12041b`.

**Paleta neon (rosa + roxo + ciano):**
| Token | Valor | Uso |
|-------|-------|-----|
| `--neon-pink` | `#ff007f` | bordas, brilhos, botões hover |
| `--neon-pink-soft` | `#ff66b2` | bordas de painel |
| `--neon-violet` | `#b14dff` | acentos secundários, links |
| `--neon-cyan` | `#00e5ff` | acentos terciários, destaques |
| `--bg` | `#12041b` | fundo da página |
| `--panel` | `rgba(255,20,147,0.05)` | fundo dos painéis |
| `--gold` | `#ffd700` | estrelas/avaliações (mantém) |

**Cantos:** painéis 20px, botões 25px (pílula), inputs 12px, avatares redondos.

**Fonte:** Nunito (700/900) do Google Fonts; `--font-display`/`--font-body` apontam para Nunito.

**Sombras neon** (efeito neon-box do exemplo):
```
0 0 10px var(--neon-pink), 0 0 20px var(--neon-pink), inset 0 0 10px var(--neon-pink)
```

**Classe `.neon-box`:** painel com borda rosa + brilho neon, aplicável globalmente.

**Badges kawaii:** selos atuais (Mais Vendido/Lançamento/Promo) com cantos em pílula e fundo neon.

**Ícones:** emojis nos títulos de painel (✦ 🎀 ⭐ 📦 🎯 📖).

## Mascote — GIFs

GIFs baixados do Tenor para `assets/`:

| Arquivo | Uso |
|---------|-----|
| `assets/mascot-teto.gif` (220x236) | Mascote padrão (flutua, balão de fala, animações CSS) |
| `assets/mascot-catgirl.gif` (220x220) | Reação feliz/comemorou (pulo + corações) |
| `assets/mascot-momona.gif` (220x124) | Reação triste/erro |

O mascote alterna o GIF conforme o contexto (padrão → feliz ao completar pedido → triste em erro). Balão de fala e animações CSS mantidos. Componente separado (imagem configurável em `assets/`), fácil de trocar depois. O arquivo antigo `assets/mascot.jpg` pode ser removido ou mantido como fallback.

## Gamificação (aba Início)

Tudo salvo no Supabase (tabelas novas) com fallback local via localStorage. Cliente logado vê os próprios dados; admin vê tudo da loja.

### Diário do cliente
- Lista cronológica dos pedidos do cliente logado (de `orders`, filtro por `user_id`)
- Cada entrada: data, o que comprou, valor, status
- Nota opcional por pedido (tabela `diary_notes`), o cliente escreve/exclui
- Sem login: "Entre para ver seu diário"

### Metas
- Cliente cria metas: título, valor atual, valor alvo (opcional), status
- Ex: "Maestria 600" → 340/600; "Haki V2" → só concluída/não
- Editar progresso, marcar concluída (destaque neon)
- Tabela `goals` (user_id, title, current, target, done, created_at)

### Entregas
- Encomendas do cliente com status em andamento (filtra `orders` pago/andamento)
- Rastreio: aguardando → pago → em andamento → concluído
- Admin atualiza status (já existe no admin; agora visível como "Entregas")

### Tarefas da loja (só admin)
- Checklist: verificar carga, responder dúvidas, etc.
- Admin cria/edita/marca concluída (tabela `shop_tasks`)
- Não-admin não vê o painel

### Lista de espera
- Cliente entra na fila (nome + jogo/pedido)
- Admin marca "atendido" e remove (tabela `waitlist`)
- Mostra posição do cliente ("Você é o #3")

### Chat
- Mantém o atual, na aba Início.

## Estrutura Técnica e Migração

**Arquitetura:** tudo em `index.html` (CSS no `<style>`, JS ES5 no `<script>`, seções trocadas via `showTab(id)`).

**Mapeamento de seções → abas:**
| Aba | Seções atuais |
|-----|---------------|
| Início | `home` (hero), `chat`, + gamificação |
| Loja | `simulador`, `pacotes`, `bloxfruits`, `tabela`, `moedas`, `eventos`, checkout |
| Avaliações | `provas`, `avaliacoes`, `faq` |
| Ranking | `ranking` |
| Admin | painel admin |

**Renomeação kawaii:** "Simulador" → "Simulador Fofinho", "Pacotes" → "Pacotes de Ups", "Moedas" → "Moedinhas", "Provas" → "Provinhas", "Ranking" → "Ranking Fofinho", títulos com emoji.

**Supabase — novas tabelas** (`supabase.sql` estendido): `diary_notes`, `goals`, `shop_tasks`, `waitlist` — todas com RLS (dono lê/edita as próprias; admin lê tudo), usando `public.is_admin()` (função SECURITY DEFINER já criada) para evitar recursão.

**Fallback local:** sem Supabase, dados vão para localStorage (cada navegador vê o próprio).

**Migração por etapas:**
- T1: Design tokens kawaii (paleta, Nunito, cantos, neon-box)
- T2: Estrutura de abas + header/nav + hero compacto
- T3: Aba Loja (mover seções + renomear)
- T4: Aba Avaliações + Ranking
- T5: Gamificação (Diário, Metas, Entregas, Tarefas, Lista de espera) + SQL
- T6: Mascote GIF + notificação social com GIF + splash
- T7: Admin + validação final + push

## Funcionalidades Mantidas (não quebrar)

- Compras, carrinho, checkout PIX (Netlify/Cloudflare Worker)
- Painel admin completo
- Supabase (config, pedidos, reviews, chat, contatos, ranking)
- Chat ao vivo
- Notificação social (agora com avatares GIF)
- Badges de pacotes
- Fade-up / contador de beacon
- Modo local fallback
