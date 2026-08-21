-- ============================================================
-- FIX RLS: "infinite recursion detected in policy for relation profiles"
-- Rode este script UMA VEZ no SQL Editor do Supabase
-- (Dashboard -> SQL Editor -> New query -> cole -> Run)
-- ============================================================

-- 1) Função is_admin() — SECURITY DEFINER ignora RLS, evita recursão
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

grant execute on function public.is_admin() to anon, authenticated;

-- 2) Reescreve as políticas que causavam recursão usando is_admin()
drop policy if exists sc_update on public.site_config;
create policy sc_update on public.site_config for update using (public.is_admin());

drop policy if exists pf_select on public.profiles;
create policy pf_select on public.profiles for select using (
  auth.uid() = id
  or public.is_admin()
);

drop policy if exists od_select on public.orders;
create policy od_select on public.orders for select using (
  auth.uid() = user_id
  or public.is_admin()
);
drop policy if exists od_update on public.orders;
create policy od_update on public.orders for update using (public.is_admin());
drop policy if exists od_delete on public.orders;
create policy od_delete on public.orders for delete using (public.is_admin());

drop policy if exists rv_delete on public.reviews;
create policy rv_delete on public.reviews for delete using (public.is_admin());

drop policy if exists ch_delete on public.chat_messages;
create policy ch_delete on public.chat_messages for delete using (public.is_admin());

drop policy if exists ct_select on public.contacts;
create policy ct_select on public.contacts for select using (public.is_admin());
drop policy if exists ct_delete on public.contacts;
create policy ct_delete on public.contacts for delete using (public.is_admin());
