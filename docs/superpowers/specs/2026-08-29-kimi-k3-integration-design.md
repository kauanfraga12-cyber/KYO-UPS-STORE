# Integração da Agente Kimi K3 com o opencode — Design

Data: 2026-08-29
Status: Em aprovação

## Objetivo

Preparar a agente de IA **Kimi K3** (Moonshot AI, acessada via chat/web em `kimi.ai`) para trabalhar **em conjunto com o agente opencode** (eu, neste ambiente) ajudando o usuário em tudo: entender o código da loja, criar conteúdo, dar consultoria técnica e ajuda de negócio. A Kimi já está integrada com GitHub, Claude, Supabase etc.; falta o contexto e o fluxo de colaboração.

## Contexto — Kimi K3

- Acessada via chat/web (`kimi.ai`), plataforma de agentes (Kimi Work / Kimi Code / Kimi Claw; websites, docs, planilhas, relatórios).
- A Kimi **não executa código** neste repositório; ela conversa. Quem edita/testa/deploya é o opencode.
- O usuário cola contexto para a Kimi, e as sugestões dela voltam para o opencode via o usuário (handoff).

## Abordagem Escolhida

**C — Completo (aprovado pelo usuário):** pacote de contexto + roteiro de treinamento + divisão de papéis + integrações técnicas (GitHub Actions + Supabase).

## Estrutura de Arquivos

Tudo criado em `docs/` (nenhum código da loja é alterado):

```
docs/
├── KIMI-CONTEXT.md      # Pacote de contexto — usuário cola na Kimi ao conversar
├── KIMI-TRAINING.md     # Roteiro de treinamento — fases, quiz, exercícios, critérios
├── KIMI-ROLES.md        # Divisão de papéis: Kimi vs opencode + regras de handoff
└── superpowers/specs/2026-08-29-kimi-k3-integration-design.md   # este documento
```

Arquivos novos no repo (integrações):

```
.github/workflows/update-kimi-context.yml   # gera contexto a cada push em main
supabase-kimi-context.sql                   # DDL da tabela kimi_context (migração)
```

## Seção 2 — Pacote de Contexto (docs/KIMI-CONTEXT.md)

Estrutura planejada:

1. **Identidade e missão** — papel da Kimi como consultora técnica + de negócio da loja "Cantinho Do Loli ✦" (KYO UPS).
2. **Estado atual do projeto** — resumo funcional: loja kawaii neon com 5 abas, gamificação (Diário, Metas, Entregas, Tarefas, Lista de espera), PIX ativo via Mercado Pago, admin com PIN validado no servidor, segurança aplicada (RLS, CSP).
3. **Stack e arquivos-chave** — `index.html` (principal, ES5), `porto-das-frutas.html` (cópia byte-idêntica), `supabase.sql`, `supabase-security-fix.sql`, `supabase-config.js`, funções Netlify (`netlify/functions/pix-create.mjs`, `pix-check.mjs`), `netlify.toml` (CSP), `tests/`.
4. **Regras duras** — JS ES5 puro (sem arrow functions, sem template literals); `index.html` e `porto-das-frutas.html` SEMPRE byte-idênticos (`cp` + `cmp`); não colar credenciais no chat; não adicionar trailer `Co-authored-by` manualmente (hook `prepare-commit-msg` faz isso).
5. **Credenciais por referência** — apenas onde estão (MP token em env var do Netlify; Supabase anon key em `supabase-config.js`; service role key em GitHub Secret), **nunca** os valores.
6. **Comandos úteis** — testes jsdom (`NODE_PATH`, mock `crypto.subtle` em `beforeParse`, sem `resources:"usable"`, mock `fetch`/`matchMedia`); deploy Netlify (CLI/draft+restore); commit.
7. **Changelog rápido** — últimos commits e o que mudou (state de hoje).

## Seção 3 — Roteiro de Treinamento (docs/KIMI-TRAINING.md)

- **Fase 1 — Boot**: colar o `KIMI-CONTEXT.md` e pedir resumo do projeto.
- **Fase 2 — Quiz**: ~15 perguntas-teste com respostas esperadas (ex.: "Qual arquivo é cópia exata do `index.html`?", "Como o PIN do admin é validado hoje?", "Onde está o token do Mercado Pago?").
- **Fase 3 — Exercícios**: análises práticas (ex.: "avalia a segurança do fluxo PIX", "sugere melhorias no checkout").
- **Fase 4 — Evolução**: ao mudar o site, usuário pede ao opencode para atualizar o contexto, depois re-testa.
- **Critérios de aprovação**: lista do que conta como "Kimi treinada".

## Seção 4 — Divisão de Papéis (docs/KIMI-ROLES.md)

| Contexto | Kimi K3 | opencode (eu) |
|----------|---------|---------------|
| Consultoria técnica | Sugestões, explicação de arquitetura | Implementa |
| Conteúdo | Textos, descrições, anúncios | Aplica no site |
| Negócio | Preços, planilha, marketing | — |
| Código/deploy | — | Edita, testa, commita, deploya |
| Integrações | Usa GitHub/Supabase para ler | Configura Netlify |

**Regras de handoff**: quando a Kimi sugerir algo que precise de código, o usuário cola a sugestão para o opencode, que implementa e reporta de volta. Formato de handoff: sugestão + arquivo(s) afetados + regra duras afetadas.

## Seção 5 — Integrações Técnicas

### Workflow GitHub Actions — `.github/workflows/update-kimi-context.yml`

- **Trigger**: `push` em `main` (após deploy) + `workflow_dispatch` manual.
- **Passos**:
  1. `actions/checkout@v4`.
  2. Gerar `docs/KIMI-CONTEXT.md` a partir de um script (bash) que monta o arquivo com: cabeçalho fixo, `git log --oneline -10` recente, e bloco "estado atual" via template. (Na v1: template literal no workflow; evolução futura: script `scripts/update-kimi-context.sh` versionado.)
  3. Fazer upload do conteúdo para a tabela `kimi_context` no Supabase via `curl` REST, com `Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY`.
  4. Commit + push do arquivo gerado de volta para `main` (com trailer `Co-authored-by` já adicionado pelo hook local — em Actions o hook não roda, então usar mensagem simples).
- **Segredos (GitHub Secrets, preenchidos pelo usuário)**:
  - `SUPABASE_URL` — `https://ukhzidvkiydovbmjxywf.supabase.co`
  - `SUPABASE_SERVICE_ROLE_KEY` — usuário insere no painel do GitHub (não vai para o repo).
- **Nenhuma credencial da Moonshot necessária** (Kimi é via chat/web). Nenhum valor de credencial é escrito no repositório.

### Tabela Supabase — `supabase-kimi-context.sql`

```sql
create table if not exists public.kimi_context (
  id bigint generated always as identity primary key,
  content text not null,
  created_at timestamptz not null default now()
);
alter table public.kimi_context enable row level security;
create policy "context is public read" on public.kimi_context
  for select using (true);
create policy "context write via service role" on public.kimi_context
  for insert with check (true);
```

- Leitura pública (a Kimi/usuario pode ler sem auth); escrita via service role do workflow.
- SQL é migração separada; usuário aplica no SQL Editor do Supabase (como fez com `supabase-security-fix.sql`).

### Netlify

- Nota no `KIMI-ROLES.md`: como adicionar integração Kimi→Netlify depois (webhook de deploy). Sem código agora.

## Limites e Não-Escopo

- Não alterar `index.html`, `porto-das-frutas.html`, funções Netlify, `netlify.toml`, `supabase-config.js`.
- Não escrever valores reais de credenciais em nenhum arquivo do repo.
- O workflow v1 não chama API da Moonshot (Kimi é chat); só versiona o contexto no Supabase + repositório.
- Google Sheets: continua separado da loja (fora deste escopo).

## Verificação

1. `docs/KIMI-CONTEXT.md`, `docs/KIMI-TRAINING.md`, `docs/KIMI-ROLES.md` existem e estão coerentes.
2. `.github/workflows/update-kimi-context.yml` é válido (lint YAML) e os segredos estão documentados.
3. `supabase-kimi-context.sql` aplicável no SQL Editor do Supabase.
4. Nenhum valor de credencial real nos arquivos novos (`rg` por padrões suspeitos).
5. `index.html` e `porto-das-frutas.html` permanecem byte-idênticos (`cmp`).
6. Testes existentes continuam passando (sem alteração de código, deve ser imediato).
