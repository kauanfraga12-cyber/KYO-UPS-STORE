# Roteiro de Treinamento da Kimi K3

Como treinar a Kimi K3 para dominar o projeto da loja "Cantinho Do Loli ✦" e trabalhar bem com o opencode.

## Fase 1 — Boot

1. Abra um novo chat na Kimi (kimi.ai).
2. Cole o conteúdo de `docs/KIMI-CONTEXT.md`.
3. Envie esta mensagem:
   "Resuma o projeto da loja em 5 bullets e liste as 3 regras mais importantes que você deve respeitar."

**Critério de sucesso:** a Kimi lista regras como: JS ES5, HTMLs byte-idênticos, não colar credenciais.

## Fase 2 — Quiz

Envie as perguntas abaixo UMA POR VEZ. Compare com as respostas esperadas.

1. Qual arquivo é a cópia byte-idêntica do `index.html`? → `porto-das-frutas.html`.
2. Como o PIN do admin é validado hoje? → No servidor (Supabase), via `promote_admin(pin)` com SECURITY DEFINER; não no navegador.
3. Onde está o token do Mercado Pago? → Env var `MP_ACCESS_TOKEN` no Netlify; nunca no repositório.
4. Quais são as 5 abas da loja? → Início, Loja, Avaliações, Ranking, Admin.
5. Que estilo de JS o site usa? → ES5 puro (`var`/function; sem arrow functions/template literals).
6. Qual a regra sobre os dois HTMLs? → Sempre byte-idênticos.
7. O que acontece se eu der uma credencial real no chat? → Ela deve recusar a colar no código e referenciar o local.
8. Quem faz deploy? → O opencode, via Netlify (CLI ou draft+restore).
9. O que a tabela `admin_creds` guarda? → Salt/hash das credenciais admin, protegida por RLS.
10. O que o CSP do netlify.toml protege? → Mitiga XSS (script-src restrito a self/jsdelivr).
11. Como rodar os testes Netlify? → `NODE_PATH=/usr/local/lib/node_modules node --test tests/netlify/*.test.mjs`.
12. O que é o beacon de status? → Indicador aberto/fechado no header.
13. Qual o papel da função `pix-create`? → Gerar QR PIX via Mercado Pago.
14. O que devo fazer quando sugerir algo que precisa de código? → Dizer "ISSO DEVE SER IMPLEMENTADO PELO OPENCODE".
15. A planilha do Google faz parte da loja? → Não, é separada (registro manual de dados).

**Critério de sucesso:** acertar 13+ das 15.

## Fase 3 — Exercícios

Peça análises práticas e avalie a qualidade:

1. "Avalie a segurança do fluxo PIX e aponte riscos."
2. "Sugira 3 melhorias de conversão para a aba Loja."
3. "Escreva uma descrição kawaii de 2 linhas para o pacote 'Kawaii Pack'."
4. "Explique como o RLS protege os dados no Supabase."
5. "Se eu quisesse adicionar uma aba nova, quais arquivos o opencode precisaria tocar?"

**Critério de sucesso:** respostas coerentes com o contexto e sem código ES6 no exemplo.

## Fase 4 — Evolução

1. Quando o site mudar, peça ao opencode: "atualize o KIMI-CONTEXT.md".
2. Abra novo chat na Kimi, cole o contexto atualizado.
3. Refaça o Quiz (Fase 2) rapidamente.

## Critérios de aprovação final (Kimi "treinada")

- Passa no Quiz com 13+ acertos.
- Nos exercícios, nunca sugere ES6 para o site.
- Recusa credenciais reais no chat.
- Usa o aviso "ISSO DEVE SER IMPLEMENTADO PELO OPENCODE" quando a tarefa precisa de código.
