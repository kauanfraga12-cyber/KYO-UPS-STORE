# Integração da Agente Kimi K3 com o opencode — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preparar a agente IA Kimi K3 (Moonshot AI, via chat/web) para trabalhar em conjunto com o agente opencode, cobrindo contexto, treinamento, divisão de papéis e integrações (GitHub Actions + Supabase).

**Architecture:** Criação de 3 documentos de conhecimento em `docs/` (contexto, treinamento, papéis), uma migração SQL para a tabela `kimi_context` no Supabase, e um workflow GitHub Actions que regera o contexto a cada push em `main` e o versiona no Supabase via service role. Nenhum código da loja é alterado.

**Tech Stack:** Markdown, GitHub Actions (YAML), Supabase (Postgres REST), bash.

## Global Constraints

- JS do site é ES5 puro — nos documentos, exemplos de código devem seguir ES5 (`var`/function, sem arrow functions, sem template literals).
- `index.html` e `porto-das-frutas.html` devem permanecer byte-idênticos (`cp` + `cmp`). Nenhuma edição nesses arquivos.
- Hook `.git/hooks/prepare-commit-msg` auto-adiciona `Co-authored-by: monkeycode-ai` — não adicionar trailer manualmente em commits locais.
- **Nunca** escrever valores reais de credenciais em nenhum arquivo do repo (token MP, service role key, anon key como valor). Referenciar apenas por nome/local.
- Testes jsdom: `NODE_PATH=/usr/local/lib/node_modules`; mockar `crypto.subtle` em `beforeParse`; sem `resources:"usable"`; mockar `fetch`/`matchMedia`.
- Testes Netlify: `NODE_PATH=/usr/local/lib/node_modules node --test tests/netlify/*.test.mjs` (6/6 passando hoje).
- Repo: `kauanfraga12-cyber/KYO-UPS-STORE`, branch `main`, origin GitHub.
- Supabase: URL `https://ukhzidvkiydovbmjxywf.supabase.co`; escrita em `kimi_context` só via service role (GitHub Secret).

---

### Task 1: Criar o pacote de contexto (docs/KIMI-CONTEXT.md)

**Files:**
- Create: `docs/KIMI-CONTEXT.md`

**Interfaces:**
- Consumes: nada.
- Produces: `docs/KIMI-CONTEXT.md` — o arquivo que o usuário cola na Kimi. A Task 2 (treinamento) referencia este arquivo; a Task 5 (workflow) o regenera.

- [ ] **Step 1: Criar o arquivo com o conteúdo completo**

```markdown
# Contexto da Loja — Cantinho Do Loli ✦ (para a agente Kimi K3)

Você é a Kimi K3, consultora técnica e de negócio da loja virtual "Cantinho Do Loli ✦" (KYO UPS). Sua missão: ajudar o usuário a entender o código, criar conteúdo, dar consultoria técnica e sugestões de negócio. Você NÃO executa código — quem edita, testa e faz deploy é o agente opencode. Quando sugerir algo que precise de código, diga "ISSO DEVE SER IMPLEMENTADO PELO OPENCODE" para o usuário colar a sugestão lá.

## Estado atual do projeto

- Loja kawaii neon com 5 abas: Início, Loja, Avaliações, Ranking, Admin.
- Gamificação real salva no Supabase: Diário, Metas, Entregas, Tarefas da loja, Lista de espera, Ranking.
- Pagamento PIX ativo via Mercado Pago (token em env var do Netlify; QR gerado pela função Netlify `pix-create`).
- Admin com login e PIN validado no servidor (Supabase), não no navegador.
- Segurança aplicada: RLS no Supabase, CSP no Netlify, credenciais admin em tabela protegida.

## Stack e arquivos-chave

- `index.html` — página principal (JS ES5 puro, `var`/function, sem arrow functions/template literals).
- `porto-das-frutas.html` — cópia byte-idêntica de `index.html` (NUNCA divergir).
- `supabase.sql` — schema do banco (tabelas, RLS, funções).
- `supabase-security-fix.sql` — correções de segurança aplicadas (admin_creds, promote_admin com PIN server-side).
- `supabase-config.js` — URL do Supabase e chave anon (pública, segura para front-end).
- `netlify/functions/pix-create.mjs` e `pix-check.mjs` — funções Netlify do PIX.
- `netlify.toml` — headers de segurança incluindo CSP.
- `tests/netlify/*.test.mjs` — testes das funções Netlify (6/6 passando).

## Regras duras

1. Código JS é ES5 puro: use `var`, `function`, concatenação com `+`. PROIBIDO arrow functions, template literals, `let`/`const` em código de exemplo que o opencode vá aplicar.
2. `index.html` e `porto-das-frutas.html` devem SEMPRE ser byte-idênticos.
3. NUNCA colar valores reais de credenciais no chat (token MP, chaves, senhas). Referencie por nome/local.
4. Não adicionar trailer `Co-authored-by:` em mensagens de commit — o hook do git faz isso automaticamente.

## Credenciais — onde estão (referência, não valores)

- Token Mercado Pago: env var `MP_ACCESS_TOKEN` no Netlify (rotacionar se vazar).
- Supabase URL + anon key: em `supabase-config.js` (públicas, uso front-end).
- Service role key do Supabase: GitHub Secret `SUPABASE_SERVICE_ROLE_KEY` (só usada pelo GitHub Actions).
- PIN do painel admin e credenciais admin: banco Supabase, tabela `admin_creds` (protegida por RLS).

## Comandos úteis (rodados pelo opencode, não pela Kimi)

- Testes Netlify: `NODE_PATH=/usr/local/lib/node_modules node --test tests/netlify/*.test.mjs`
- Testes jsdom do index.html: node com jsdom, mockando `crypto.subtle` em `beforeParse`, sem `resources:"usable"`, mockando `fetch` e `matchMedia`.
- Garantir HTMLs idênticos: `cp index.html porto-das-frutas.html && cmp index.html porto-das-frutas.html`
- Deploy Netlify: CLI com token de deploy (env var) ou draft deploy + restore via API.
- Commit: `git add ... && git commit -m "tipo: mensagem"` (hook adiciona Co-authored-by).

## Changelog rápido

- bb625b0 security: CSP header no Netlify.
- 6ea64fd security: PIN validado server-side no promote_admin; admin hash removido do site_config.
- 5399c2f fix: botões data-jump ativam a aba antes do scroll.
- e0aa996 style: layout compacto.
- c43f08d fix: testes movidos para tests/netlify + otimização mobile.
```

- [ ] **Step 2: Validar o arquivo**

Run: `test -f docs/KIMI-CONTEXT.md && wc -l docs/KIMI-CONTEXT.md && rg -n "sb_publishable_|nfp_|kauannovais|impala67|glpat-" docs/KIMI-CONTEXT.md`
Expected: arquivo existe; o comando `rg` NÃO retorna valores reais de credenciais (a string `sb_publishable_` deve aparecer zero vezes; se aparecer é porque vazou valor).

- [ ] **Step 3: Commit**

```bash
git add docs/KIMI-CONTEXT.md
git commit -m "docs: kimi context pack for the K3 agent"
```

---

### Task 2: Criar o roteiro de treinamento (docs/KIMI-TRAINING.md)

**Files:**
- Create: `docs/KIMI-TRAINING.md`

**Interfaces:**
- Consumes: `docs/KIMI-CONTEXT.md` (Task 1) — o roteiro cola esse arquivo na Fase 1.
- Produces: `docs/KIMI-TRAINING.md` — guia do usuário para treinar e validar a Kimi.

- [ ] **Step 1: Criar o arquivo com o conteúdo completo**

```markdown
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
```

- [ ] **Step 2: Validar o arquivo**

Run: `test -f docs/KIMI-TRAINING.md && rg -c "ISSO DEVE SER IMPLEMENTADO PELO OPENCODE" docs/KIMI-TRAINING.md`
Expected: contagem >= 2 (regra mencionada no quiz e no fluxo).

- [ ] **Step 3: Commit**

```bash
git add docs/KIMI-TRAINING.md
git commit -m "docs: kimi training roadmap with quiz and exercises"
```

---

### Task 3: Criar a divisão de papéis (docs/KIMI-ROLES.md)

**Files:**
- Create: `docs/KIMI-ROLES.md`

**Interfaces:**
- Consumes: nada (tabela de papéis autossuficiente).
- Produces: `docs/KIMI-ROLES.md` — referência de colaboração entre Kimi e opencode.

- [ ] **Step 1: Criar o arquivo com o conteúdo completo**

```markdown
# Divisão de Papéis — Kimi K3 + opencode

Como a Kimi K3 e o agente opencode trabalham juntos na loja "Cantinho Do Loli ✦".

## Tabela de papéis

| Contexto | Kimi K3 | opencode (eu) |
|----------|---------|---------------|
| Consultoria técnica | Sugestões, explicação de arquitetura | Implementa |
| Conteúdo | Textos, descrições, anúncios | Aplica no site |
| Negócio | Preços, planilha, marketing | — |
| Código/deploy | — | Edita, testa, commita, deploya |
| Integrações | Usa GitHub/Supabase para ler | Configura Netlify |

## Regras de handoff

1. **Kimi → usuário → opencode**: a Kimi sugere algo que precisa de código. Ela deve marcar com "ISSO DEVE SER IMPLEMENTADO PELO OPENCODE". O usuário cola a sugestão no opencode.
2. **opencode → usuário → Kimi**: o opencode implementa, testa e reporta. O usuário leva o resultado para a Kimi se precisar de revisão/opinião.
3. **Formato de handoff** (o usuário cola no opencode):
   - Sugestão (o que a Kimi quer fazer)
   - Arquivo(s) afetados
   - Regras duras afetadas (ex.: ES5, HTMLs idênticos)
4. **Quando a Kimi não tem contexto**: pedir ao usuário o `docs/KIMI-CONTEXT.md` atualizado (o opencode mantém esse arquivo).

## Fluxo de trabalho diário

1. Usuário conversa com a Kimi (chat) para ideias/consultoria.
2. Sugestões que precisam de código vão para o opencode (com o formato de handoff).
3. opencode implementa, testa e faz commit/deploy.
4. Se necessário, usuário leva o resultado de volta à Kimi para avaliação.

## Netlify (futuro)

A Kimi ainda não integra com o Netlify. Para adicionar depois: criar um webhook de deploy no Netlify que dispare uma automação na Kimi, ou alimentar a Kimi com o status dos deploys via um resumo gerado pelo workflow do GitHub Actions.

## Limites

- A Kimi NÃO edita código neste repositório (é chat/web).
- O opencode NÃO é consultor criativo — foco em implementação de código, testes e deploy.
- Google Sheets é separado da loja: só registro manual de dados enviados pelo usuário no chat.
```

- [ ] **Step 2: Validar o arquivo**

Run: `test -f docs/KIMI-ROLES.md && rg -n "handoff|openocode|ISSO DEVE" docs/KIMI-ROLES.md`
Expected: linhas de handoff presentes. (Observação: o texto usa "opencode", o `rg` por "openocode" não deve retornar nada.)

- [ ] **Step 3: Commit**

```bash
git add docs/KIMI-ROLES.md
git commit -m "docs: kimi-opencode role split and handoff rules"
```

---

### Task 4: Criar a migração SQL da tabela kimi_context

**Files:**
- Create: `supabase-kimi-context.sql`

**Interfaces:**
- Consumes: nada.
- Produces: `supabase-kimi-context.sql` — DDL aplicável pelo usuário no SQL Editor do Supabase. A Task 5 (workflow) insere linhas nessa tabela via REST.

- [ ] **Step 1: Criar o arquivo com o DDL completo**

```sql
-- ============================================================
-- KYO UPS STORE — TABELA kimi_context (contexto da Kimi K3)
-- Aplicar no SQL Editor do Supabase (como supabase-security-fix.sql)
-- ============================================================

create table if not exists public.kimi_context (
  id bigint generated always as identity primary key,
  content text not null,
  created_at timestamptz not null default now()
);

alter table public.kimi_context enable row level security;

-- Leitura pública: qualquer pessoa pode ler o contexto (inclusive a Kimi via Supabase).
create policy "context is public read" on public.kimi_context
  for select using (true);

-- Escrita: permitida apenas via service role (o GitHub Actions usa a service key).
-- Sem política de INSERT para anon/authenticated, então só a service role insere.
```

- [ ] **Step 2: Validar SQL e ausência de credenciais**

Run: `test -f supabase-kimi-context.sql && rg -n "sb_publishable_|service_role|Bearer" supabase-kimi-context.sql`
Expected: NÃO deve haver valor `sb_publishable_`; a menção a `service role` apenas em comentário (linha "apenas via service role").

- [ ] **Step 3: Commit**

```bash
git add supabase-kimi-context.sql
git commit -m "feat: add kimi_context table migration for Supabase"
```

---

### Task 5: Criar o workflow GitHub Actions que regera o contexto

**Files:**
- Create: `.github/workflows/update-kimi-context.yml`

**Interfaces:**
- Consumes: `supabase-kimi-context.sql` (Task 4, tabela `kimi_context`), `docs/KIMI-CONTEXT.md` (Task 1).
- Produces: workflow que, a cada push em `main`, gera `docs/KIMI-CONTEXT.md`, faz upsert na tabela `kimi_context` via REST e commita de volta.

- [ ] **Step 1: Criar o workflow**

```yaml
name: Update Kimi Context

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update-context:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Generate context from template + recent log
        run: |
          {
            echo "# Contexto da Loja — Cantinho Do Loli ✦ (para a agente Kimi K3)"
            echo ""
            echo "Gerado automaticamente pelo GitHub Actions em $(date -u +'%Y-%m-%dT%H:%M:%SZ')."
            echo ""
            echo "## Estado atual (últimos commits na main)"
            git log --oneline -10
            echo ""
            echo "> Cole o conteúdo completo de docs/KIMI-CONTEXT.md (mantido manualmente) junto deste resumo."
            echo "> O arquivo docs/KIMI-CONTEXT.md é a fonte da verdade para o contexto completo."
          } > kimi-context-generated.md

      - name: Upsert context into Supabase
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
        run: |
          CONTENT=$(cat kimi-context-generated.md)
          python3 - <<'EOF'
          import json, os, urllib.request

          content = open("kimi-context-generated.md", encoding="utf-8").read()
          url = os.environ["SUPABASE_URL"].rstrip("/") + "/rest/v1/kimi_context"
          key = os.environ["SUPABASE_SERVICE_ROLE_KEY"]

          # Inserir sempre uma nova versão (versionamento por created_at)
          data = json.dumps({"content": content}).encode()
          req = urllib.request.Request(
              url,
              data=data,
              method="POST",
              headers={
                  "apikey": key,
                  "Authorization": "Bearer " + key,
                  "Content-Type": "application/json",
                  "Prefer": "return=minimal",
              },
          )
          try:
              with urllib.request.urlopen(req, timeout=30) as resp:
                  print("INSERT kimi_context ->", resp.status)
          except urllib.error.HTTPError as e:
              print("ERRO", e.code, e.read().decode())
              raise SystemExit(1)
          EOF

      - name: Commit generated context back
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add kimi-context-generated.md
          if git diff --cached --quiet; then
            echo "sem alterações no resumo; nada a commitar"
          else
            git commit -m "chore: regenerate kimi context summary"
            git push
          fi
```

- [ ] **Step 2: Validar YAML e ausência de segredos em claro**

Run: `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/update-kimi-context.yml'))" && echo YAML-OK`
Expected: `YAML-OK` (sem erro de parse). Nota: se o pyyaml não estiver instalado, rode antes `pip3 install --break-system-packages pyyaml`. Também conferir que o arquivo NÃO contém o valor do service role (somente `${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}`).

- [ ] **Step 3: Documentar os segredos necessários no repositório**

O usuário deve configurar no GitHub (Settings → Secrets and variables → Actions → New repository secret):
- `SUPABASE_URL` = `https://ukhzidvkiydovbmjxywf.supabase.co`
- `SUPABASE_SERVICE_ROLE_KEY` = valor da service role (Settings → API no Supabase)

Registrar isso no corpo do commit e confirmar com o usuário que ele criou os secrets.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/update-kimi-context.yml
git commit -m "ci: add workflow to regenerate and version kimi context"
```

---

### Task 6: Verificação final e fechamento

**Files:**
- Nenhum (verificação somente).

**Interfaces:**
- Consumes: todos os artefatos das Tasks 1-5.

- [ ] **Step 1: Rodar os testes existentes (nada deve ter quebrado)**

Run: `NODE_PATH=/usr/local/lib/node_modules node --test tests/netlify/*.test.mjs`
Expected: 6 pass, 0 fail.

- [ ] **Step 2: Conferir HTMLs byte-idênticos**

Run: `cmp index.html porto-das-frutas.html && echo IDENTICOS`
Expected: `IDENTICOS`.

- [ ] **Step 3: Scan de credenciais reais nos arquivos novos**

Run: `rg -n "sb_publishable_|nfp_|impala67|kauannovais|glpat-" docs/KIMI-CONTEXT.md docs/KIMI-TRAINING.md docs/KIMI-ROLES.md supabase-kimi-context.sql .github/workflows/update-kimi-context.yml`
Expected: nenhuma linha retornada.

- [ ] **Step 4: Listar arquivos criados**

Run: `git status --short`
Expected: os 5 arquivos novos rastreados e commitados; sem alterações em `index.html`/`porto-das-frutas.html`/`netlify.toml`.

- [ ] **Step 5: Push (se o usuário pedir)**

```bash
git push origin main
```

Após o push, o workflow `update-kimi-context.yml` roda sozinho. O usuário precisa ter criado os secrets `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` antes do primeiro push para o passo de upsert funcionar.
