-- VORZIX STUDIO — Supabase setup
-- Execute tudo no SQL Editor do seu projeto Supabase.

create extension if not exists pgcrypto;

create table if not exists public.site_settings (
  id integer primary key check (id = 1),
  title text not null default 'VORZIX STUDIO',
  description text not null default 'Criamos jogos e apps incríveis!' || E'\n' || 'Entre na nossa aventura! 🌟',
  logo_url text,
  updated_at timestamptz not null default now()
);

insert into public.site_settings (id, title, description)
values (1, 'VORZIX STUDIO', 'Criamos jogos e apps incríveis!' || E'\n' || 'Entre na nossa aventura! 🌟')
on conflict (id) do nothing;

create table if not exists public.site_links (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text not null,
  image_url text,
  position integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.site_settings enable row level security;
alter table public.site_links enable row level security;
alter table public.admin_users enable row level security;

-- Qualquer visitante pode ler as configurações e somente os links ativos.
drop policy if exists "Public can read site settings" on public.site_settings;
create policy "Public can read site settings"
on public.site_settings for select to anon, authenticated using (true);

drop policy if exists "Public can read active links" on public.site_links;
create policy "Public can read active links"
on public.site_links for select to anon, authenticated using (active = true);

-- Administradores autenticados podem consultar a própria autorização.
drop policy if exists "Admins can read own admin record" on public.admin_users;
create policy "Admins can read own admin record"
on public.admin_users for select to authenticated
using (user_id = auth.uid());

-- Alterações só podem ser feitas por usuários cadastrados como administradores.
drop policy if exists "Admins manage site settings" on public.site_settings;
create policy "Admins manage site settings"
on public.site_settings for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

drop policy if exists "Admins manage site links" on public.site_links;
create policy "Admins manage site links"
on public.site_links for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Bucket público para logo e imagens dos botões (máximo de 5 MB por arquivo).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('vorzix-assets', 'vorzix-assets', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];

drop policy if exists "Public can view Vorzix images" on storage.objects;
create policy "Public can view Vorzix images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'vorzix-assets');

drop policy if exists "Admins can upload Vorzix images" on storage.objects;
create policy "Admins can upload Vorzix images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'vorzix-assets'
  and exists (select 1 from public.admin_users a where a.user_id = auth.uid())
);

drop policy if exists "Admins can update Vorzix images" on storage.objects;
create policy "Admins can update Vorzix images"
on storage.objects for update to authenticated
using (
  bucket_id = 'vorzix-assets'
  and exists (select 1 from public.admin_users a where a.user_id = auth.uid())
)
with check (
  bucket_id = 'vorzix-assets'
  and exists (select 1 from public.admin_users a where a.user_id = auth.uid())
);

drop policy if exists "Admins can delete Vorzix images" on storage.objects;
create policy "Admins can delete Vorzix images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'vorzix-assets'
  and exists (select 1 from public.admin_users a where a.user_id = auth.uid())
);

-- IMPORTANTE:
-- 1. Crie seu usuário em Authentication > Users (ou faça um cadastro seguro).
-- 2. Copie o UUID desse usuário.
-- 3. Depois de confirmar o UUID, execute:
-- insert into public.admin_users (user_id) values ('COLE_O_UUID_DO_USUARIO_AQUI');
-- Não habilite cadastro público no site. O login é somente por e-mail e senha.
