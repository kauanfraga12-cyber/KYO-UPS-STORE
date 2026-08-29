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
