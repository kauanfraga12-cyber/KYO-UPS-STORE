# Redesign Visual Luxe Sharp + Notificação Social de Avaliações

Data: 2026-08-18

## Resumo

Redesign completo do visual da loja LOLI Ups (arquivo único `index.html`, sincronizado byte-idêntico com `porto-das-frutas.html`) para o estilo **Luxe Sharp**: cantos retos, contornos finos, gradientes suaves e look premium, mantendo a identidade rosa/violeta. Inclui novo sistema de **notificação social** com avaliações reais + simuladas, selos/badges e micro-animações. Tudo em JS ES5, sem dependências novas, preservando IDs, seções (13), funcionalidades (Supabase, PIX, mascote, admin) e o sync byte-idêntico.

## 1. Design Tokens (base visual)

- `--radius`: 20px → **6px** (cards), **4px** (botões/inputs).
- Bordas: contornos finos de 1px mais nítidos (`--border-strong` opaco), hover com brilho dourado.
- Cores (mais profundas e dessaturadas, menos neon):
  - Fundo: `#181022`.
  - Superfícies: `#241732`, `#2e1d3f`, `#382352`.
  - Acentos: rosa `#f77eb4`, violeta `#a78bfa`, dourado `#f5d9a8` (dourado como destaque de selos/premium).
  - Remover variáveis `--neon-*` do hero; usar glow suave dourado/violeta.
- Tipografia: Fredoka (títulos) + Manrope (corpo); títulos com peso maior e tracking ajustado; eyebrow mono uppercase permanece.
- Sombras: mais profundas e precisas, sem blur excessivo.

## 2. Estrutura e Componentes

- **Hero**: gradiente suave rosa→violeta no título; sem neon; partículas discretas (brilho dourado); contador animado no beacon; botões retos com brilho no hover; selos de confiança em pill retangular com ícone SVG e contorno fino.
- **Cards** (pacotes, moedas, Blox Fruits): cantos 6px, borda 1px, hover com realce dourado na borda + elevação leve; badges de preço/selo.
- **Seções**: fundos alternados `--bg`/`--bg-alt` com divisórias retas finas; remover `wave-divider` animado.
- **Formulários**: inputs retos, foco com borda violeta nítida.
- **Header/nav**: fixo, blur suave, borda inferior 1px; links com sublinhado animado fino.
- **Mascote e splash**: mantidos, com cantos retos e contornos finos para combinar.

## 3. Notificação Social de Avaliações

- **Posição**: canto inferior esquerdo.
- **Aparência**: card retangular, fundo escuro translúcido, borda fina dourada, avatar com inicial, 5 estrelas douradas, nome + comentário ou item comprado, botão fechar.
- **Conteúdo**: avaliações reais (DEFAULT_REVIEWS + enviadas por usuários) misturadas com avaliações simuladas de compradores fictícios ligadas a pacotes reais.
- **Comportamento**:
  - Aparece a cada ~12s, exibe ~5s, desliza suavemente.
  - Uma por vez (nunca empilha).
  - Começa após 5s da entrada (após o splash).
  - Não repete a mesma avaliação até reiniciar o ciclo.
  - Pausa com aba oculta.
  - Fechável manualmente; ao fechar, respeita próximo intervalo.
- **Ocultável**: botão discreto na seção de avaliações ("Desativar notificações") grava em localStorage e desliga o sistema; texto alterna para "Ativar notificações".

## 4. Animações e Detalhes Finais

- Hover nos cards: elevação + borda dourada + leve tilt.
- Botões: brilho de varredura no hover.
- Seções: fade-up ao rolar via IntersectionObserver (discreto).
- Beacon: contador animado (serviços entregues).
- Selos: "MAIS VENDIDO", "LANÇAMENTO", "PROMO" nos cards; selo de garantia no checkout; badge de disponibilidade no beacon.
- `prefers-reduced-motion`: desliga todas as animações (já implementado, manter).
- JS ES5 (`var`/function), sem arrow functions/template literals em código novo.

## 5. Não-Alterados (Regressão)

- IDs preservados: `heroTitle`, `heroTagline`, `packGrid`, `beaconCore`, `beaconLabel`, `heroWhatsBtn`, painéis `panelOrders/panelUsers/panelReviews/panelEvents/panelMessages/panelEditor/panelSettings/panelCoins/panelProofs/panelBfPacks/panelBfCoins`, `reviewGrid`, `reviewSubmitBtn`, etc.
- Termos de serviço verbatim.
- Admin `kyoaccount`/`kauannovais@1`.
- Supabase, PIX (Cloudflare/Netlify), mascote, splash.
- Sync byte-idêntico `index.html` ↔ `porto-das-frutas.html` a cada commit.
- Git identidade/co-autoria conforme histórico.

## 6. Validação

- `node --check` no JS embutido extraído (ou validação de sintaxe do arquivo).
- Testes de regressão existentes (se houver) + smoke test no browser (preview).
- Conferir ausência de IDs "missing" e presença dos novos elementos.
