-- ============================================================
-- KYO UPS STORE — ESQUEMA DO BANCO DE DADOS (SUPABASE)
-- ============================================================
-- Rode este script UMA VEZ no SQL Editor do seu projeto Supabase
-- (Dashboard -> SQL Editor -> New query -> cole -> Run)
-- ============================================================

-- ------------------------------------------------------------
-- TABELAS
-- ------------------------------------------------------------

-- Configurações da loja (uma única linha, id = 1)
create table if not exists public.site_config (
  id integer primary key default 1 check (id = 1),
  data jsonb not null default '{}',
  updated_at timestamptz default now()
);

-- Perfis de usuário (criados automaticamente via trigger do auth)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text unique not null,
  is_admin boolean default false,
  created_at timestamptz default now()
);

-- Pedidos
create table if not exists public.orders (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  username text not null,
  items jsonb not null default '[]',
  total numeric(12,2) not null default 0,
  status text not null default 'aguardando',
  created_at timestamptz default now()
);

-- Avaliações
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  username text not null,
  rating int not null check (rating between 1 and 5),
  text text not null,
  created_at timestamptz default now()
);

-- Chat geral
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  username text not null,
  text text not null,
  kind text default 'user',
  created_at timestamptz default now()
);

-- Mensagens de contato
create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  handle text not null,
  subject text not null,
  message text not null,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- TRIGGER: cria perfil automaticamente quando alguém registra
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- FUNÇÕES
-- ------------------------------------------------------------

-- Promove o usuário logado a admin (chamada quando o PIN está correto)
create or replace function public.promote_admin()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles set is_admin = true where id = auth.uid();
end;
$$;

-- Verifica se o usuário logado é admin.
-- SECURITY DEFINER: executa como o dono (postgres), ignorando RLS,
-- evitando a recursão infinita das políticas que consultam profiles.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_admin = true
  );
$$;

-- Ranking de clientes que mais pagaram (pedidos pago/andamento/concluido)
create or replace function public.get_ranking()
returns table (username text, total numeric, cnt bigint)
language sql
security definer
set search_path = public
as $$
  select o.username, sum(o.total) as total, count(*) as cnt
  from public.orders o
  where o.status in ('pago', 'andamento', 'concluido')
  group by o.username
  order by total desc
  limit 15;
$$;

-- ------------------------------------------------------------
-- PERMISSÕES DE EXECUÇÃO
-- ------------------------------------------------------------
grant execute on function public.handle_new_user() to authenticated, service_role;
grant execute on function public.promote_admin() to anon, authenticated;
grant execute on function public.is_admin() to anon, authenticated;
grant execute on function public.get_ranking() to anon, authenticated;

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY (RLS)
-- ------------------------------------------------------------
alter table public.site_config enable row level security;
alter table public.profiles enable row level security;
alter table public.orders enable row level security;
alter table public.reviews enable row level security;
alter table public.chat_messages enable row level security;
alter table public.contacts enable row level security;

-- site_config: qualquer um lê; qualquer um pode inserir a linha 1; só admin atualiza
drop policy if exists sc_select on public.site_config;
create policy sc_select on public.site_config for select using (true);
drop policy if exists sc_insert on public.site_config;
create policy sc_insert on public.site_config for insert with check (true);
drop policy if exists sc_update on public.site_config;
create policy sc_update on public.site_config for update using (public.is_admin());

-- profiles: dono lê o próprio + admins leem; usuário só atualiza o próprio nome
drop policy if exists pf_select on public.profiles;
create policy pf_select on public.profiles for select using (
  auth.uid() = id
  or public.is_admin()
);
drop policy if exists pf_update on public.profiles;
create policy pf_update on public.profiles for update using (auth.uid() = id);

-- orders: dono lê os próprios + admins leem todos; usuário cria o próprio; admin atualiza/exclui
drop policy if exists od_select on public.orders;
create policy od_select on public.orders for select using (
  auth.uid() = user_id
  or public.is_admin()
);
drop policy if exists od_insert on public.orders;
create policy od_insert on public.orders for insert with check (auth.uid() = user_id);
drop policy if exists od_update on public.orders;
create policy od_update on public.orders for update using (public.is_admin());
drop policy if exists od_delete on public.orders;
create policy od_delete on public.orders for delete using (public.is_admin());

-- reviews: todos leem; usuário cria a própria; admin exclui
drop policy if exists rv_select on public.reviews;
create policy rv_select on public.reviews for select using (true);
drop policy if exists rv_insert on public.reviews;
create policy rv_insert on public.reviews for insert with check (auth.uid() = user_id);
drop policy if exists rv_delete on public.reviews;
create policy rv_delete on public.reviews for delete using (public.is_admin());

-- chat: todos leem; usuário cria; admin exclui
drop policy if exists ch_select on public.chat_messages;
create policy ch_select on public.chat_messages for select using (true);
drop policy if exists ch_insert on public.chat_messages;
create policy ch_insert on public.chat_messages for insert with check (auth.uid() = user_id);
drop policy if exists ch_delete on public.chat_messages;
create policy ch_delete on public.chat_messages for delete using (public.is_admin());

-- contacts: qualquer um envia; só admin lê/exclui
drop policy if exists ct_select on public.contacts;
create policy ct_select on public.contacts for select using (public.is_admin());
drop policy if exists ct_insert on public.contacts;
create policy ct_insert on public.contacts for insert with check (true);
drop policy if exists ct_delete on public.contacts;
create policy ct_delete on public.contacts for delete using (public.is_admin());

-- ------------------------------------------------------------
-- REALTIME: chat ao vivo
-- ------------------------------------------------------------
alter table public.chat_messages replica identity full;
alter publication supabase_realtime add table public.chat_messages;

-- ------------------------------------------------------------
-- DADOS INICIAIS
-- ------------------------------------------------------------
insert into public.site_config (id, data)
values (
  1,
  '{
    "config": {
      "shopName": "Porto das Frutas",
      "tagline": "Upamos sua conta com segurança: maestria, níveis, fragmentos, hakis, leviatã e muito mais — simule o valor final, crie sua conta e pague via PIX.",
      "status": "green",
      "whats": "https://chat.whatsapp.com/CT6bm99cG9HEDHXmhUlUd6"
    },
    "prices": [],
    "packages": [],
    "events": [],
    "admin": {
      "salt": "kyosalt01",
      "hash": "a52a584aab48746ce8cde67c38730c3b718d8fa4146d78d257d3e6344ef51eda"
    }
  }'
)
on conflict (id) do nothing;
