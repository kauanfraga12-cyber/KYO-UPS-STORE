# Design — Loja UPS LOLI (kawaii)

Data: 2026-08-15
Status: Aprovado

## 1. Objetivo

Transformar a loja "Porto das Frutas" em **UPS LOLI ❤** com identidade visual kawaii/rosa,
totalmente funcional no celular, com checkout em etapas, pagamento PIX (Mercado Pago com
fallback manual) e armazenamento persistente (Supabase + fallback localStorage) para que
pedidos e conversas nunca sumam.

## 2. Identidade & Tema

- Nome exibido: **UPS LOLI ❤** (header, hero, rodapé, título da página, painel admin).
- Paleta kawaii:
  - Fundo: degradê rosa-escuro → roxo (`#2a1220`, `#3a1a3a`, `#4a2140` etc).
  - Rosa vibrante: `#ff5f8f`; rosa claro: `#ffc2d4`; roxo: `#b58cff`.
  - Destaque (hover/badges): amarelo-rosa / coral claro.
  - Cantos bem arredondados (`--radius` maior), brilhos suaves, corações decorativos.
- Fontes: título com visual "rounded" (substituir `Rye`/`Righteous` por uma fonte arredondada
  como `Fredoka` ou manter `Manrope` para corpo + `Fredoka` para display).
- Manter: selo de status (🟢/🟠/🔴) e badge de armazenamento (banco online/local).
- Remover todo resquício do tema "pirata/frutas": fontes Rye, marfim `#f4ecd8`, dourado
  como cor dominante, textos de "frutas".

## 3. Navegação (desktop e mobile)

- Menu de abas roláveis no topo: Home, Simulador, Pacotes, Preços, Avaliações, Eventos,
  Ranking, Chat, Termos.
- Carrinho fixo no topo com badge de contador, sempre visível.
- Mobile: abas rolam horizontalmente, alvos de toque grandes (mín 44px), carrinho
  flutuante/fixo acessível, sem overflow horizontal.
- Header colapsa bem em telas pequenas (altura reduzida, sem quebra).

## 4. Fluxo de compra (checkout em etapas)

- Simulador: escolher serviços → carrinho lateral sempre atualizado com total em R$.
- Botão "Finalizar compra" abre checkout em etapas:
  1. Revisar itens + total
  2. Login/conta (ou criar conta)
  3. Pagamento
  4. Confirmação
- Cada etapa validada; navegação entre etapas via botões "Continuar"/"Voltar".
- Ao concluir, cria o pedido no banco (Supabase) e mostra etapa de pagamento.

## 5. Pagamento PIX (Mercado Pago)

- Integração real via **função serverless no Netlify**:
  - `/.netlify/functions/pix-create`: cria cobrança PIX no Mercado Pago (Access Token via
    variável de ambiente `MP_ACCESS_TOKEN`) e retorna QR (base64) + código copia-e-cola.
  - `/.netlify/functions/pix-check`: consulta o status do pagamento por ID.
- Enquanto o Access Token não estiver configurado (variável de ambiente ausente), a função
  retorna um sinal `fallback:true` e o site usa o **modo manual**:
  - Mostra um PIX copia-e-cola simulado + instruções + botão "Já fiz o PIX" que marca o
    pedido como pago/aguardando e oferece botão de confirmação no WhatsApp.
- Painel admin: campos para configurar **chave PIX** e **Access Token do Mercado Pago**
  (armazenados no site_config). O Access Token fica principalmente no Netlify (env var),
  o campo no admin é informativo/auxiliar.

## 6. Armazenamento persistente

- Supabase já conectado (url/anonKey configurados em `supabase-config.js`).
- Tabelas existentes: site_config, profiles, orders, reviews, chat_messages, contacts.
- Fluxos novos (checkout, pagamento) devem gravar pedido em `orders` via Supabase e, no modo
  local, via `store` (localStorage).
- Nada de pedidos/chat deve depender apenas de estado em memória.

## 7. Correções e qualidade

- Revisar layout mobile (overflow, toque, fontes pequenas).
- Corrigir IDs duplicados, botões sem ação, referências a elementos inexistentes.
- Padronizar nomes e limpar código morto do tema antigo.
- Manter acessibilidade básica (labels, contraste) e `prefers-reduced-motion`.

## 8. Painel Admin

- Mantém abas: Pedidos, Usuários, Avaliações, Eventos, Mensagens, Editor de Preços,
  Configurações.
- Novo item de configuração de pagamento (chave PIX + token Mercado Pago).
- Visual acompanha o tema kawaii.

## 9. Arquivos afetados

- `index.html` (principal) e `porto-das-frutas.html` (sincronizado).
- `netlify.toml` (nova pasta de funções `netlify/functions`).
- Novo: `netlify/functions/pix-create.mjs`, `netlify/functions/pix-check.mjs`.
- `supabase.sql` (se necessário ajustar nada — esperado que não; apenas confirmação).

## 10. Fora de escopo

- Gateway Banco Inter (troca de decisão → Mercado Pago).
- Pagamento via cartão/boleto (somente PIX, conforme Termos).
- Deploy final no Netlify (passo do usuário, guiado após a implementação).
