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
