-- ============================================================
-- FIX DE SEGURANÇA — kyostoreups
-- Corrige a elevação de privilégio via RPC promote_admin
-- Rode UMA VEZ no SQL Editor do Supabase
-- ============================================================

-- 1) Tabela protegida com as credenciais do admin (não exposta a anon/authenticated)
create table if not exists public.admin_creds (
  id integer primary key,
  salt text not null,
  hash text not null,
  updated_at timestamptz default now()
);

-- Remove a restrição antiga que impedia múltiplas credenciais (check id = 1)
alter table public.admin_creds drop constraint if exists admin_creds_id_check;

alter table public.admin_creds enable row level security;

-- Sem política de SELECT/UPDATE para anon ou authenticated:
-- o acesso só é feito por funções SECURITY DEFINER abaixo.

-- 2) Sincroniza com os hashes atuais
--    hash = sha256(salt || '::' || pin)
insert into public.admin_creds (id, salt, hash)
values
  (1, 'kyosalt01', 'a52a584aab48746ce8cde67c38730c3b718d8fa4146d78d257d3e6344ef51eda'), -- PIN do painel (impala67)
  (2, 'kyoadmin',  '49726c3fd4c55ce59bddeb00588855a660a891f9e45ce4df7b510027b08297fc')  -- login admin kyoaccount
on conflict (id) do update set salt = excluded.salt, hash = excluded.hash;

-- 3) Função de verificação do PIN (segura, roda como dono da tabela)
create or replace function public.check_admin_pin(pin text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
begin
  if pin is null or pin = '' then
    return false;
  end if;
  for r in
    select salt, hash from public.admin_creds order by id
  loop
    if encode(sha256(convert_to(r.salt || '::' || pin, 'UTF8')), 'hex') = r.hash then
      return true;
    end if;
  end loop;
  return false;
end;
$$;

-- 4) promote_admin agora EXIGE o PIN e valida no servidor
drop function if exists public.promote_admin();
create or replace function public.promote_admin(pin text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.check_admin_pin(pin) then
    raise exception 'PIN inválido. Apenas administradores podem executar esta função.';
  end if;
  update public.profiles set is_admin = true where id = auth.uid();
end;
$$;

-- 5) Troca de PIN do painel (o admin já autenticado redefine a credencial id=1)
create or replace function public.set_admin_pin(pin text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Apenas administradores podem alterar a senha.';
  end if;
  if pin is null or length(pin) < 6 then
    raise exception 'A senha deve ter pelo menos 6 caracteres.';
  end if;
  update public.admin_creds
  set salt = 'kyosalt01',
      hash = encode(sha256(convert_to('kyosalt01' || '::' || pin, 'UTF8')), 'hex'),
      updated_at = now()
  where id = 1;
end;
$$;

-- 6) Permissões
revoke execute on function public.promote_admin(text) from public;
revoke execute on function public.promote_admin(text) from anon;
grant execute on function public.promote_admin(text) to authenticated;
grant execute on function public.set_admin_pin(text) to authenticated;

-- 7) Remove o hash/salt admin do site_config público (ficava exposto p/ anonimos)
update public.site_config
set data = data - 'admin'
where id = 1
  and data ? 'admin';

-- 8) Reforça: nenhum UPDATE de is_admin por não-admins
--    (bloqueia sb.from('profiles').update({is_admin:true}) por usuário logado)
drop policy if exists pf_update on public.profiles;
create policy pf_update on public.profiles for update using (public.is_admin());
