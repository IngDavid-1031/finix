-- ============================================================
-- Finix · Esquema de base de datos para Supabase
-- Cómo usarlo: Supabase > SQL Editor > New query > pega todo > Run
-- Se puede ejecutar varias veces sin romper nada.
-- ============================================================

-- ---------- Perfiles (un registro por usuario) ----------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  email       text,
  full_name   text,
  avatar_url  text,
  provider    text,
  created_at  timestamptz not null default now(),
  last_login  timestamptz
);

-- ---------- Movimientos (gastos e ingresos) ----------
create table if not exists public.transactions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title       text not null,
  category    text not null,
  amount      bigint not null,            -- negativo = gasto, positivo = ingreso (en pesos)
  date        timestamptz not null default now(),
  note        text,
  created_at  timestamptz not null default now()
);
create index if not exists transactions_user_date_idx on public.transactions (user_id, date desc);

-- ---------- Metas de ahorro ----------
create table if not exists public.goals (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title       text not null,
  saved       bigint not null default 0,
  target      bigint not null check (target > 0),
  emoji       text not null default '🎯',
  created_at  timestamptz not null default now()
);
create index if not exists goals_user_idx on public.goals (user_id, created_at);

-- ---------- Permisos para usuarios con sesión iniciada (las políticas de abajo filtran por usuario) ----------
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles, public.transactions, public.goals to authenticated;
revoke all on public.profiles, public.transactions, public.goals from anon;

-- ---------- Seguridad: cada usuario solo ve y modifica lo suyo ----------
alter table public.profiles     enable row level security;
alter table public.transactions enable row level security;
alter table public.goals        enable row level security;

drop policy if exists "profiles: own" on public.profiles;
create policy "profiles: own" on public.profiles
  for all to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "transactions: own" on public.transactions;
create policy "transactions: own" on public.transactions
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "goals: own" on public.goals;
create policy "goals: own" on public.goals
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- Crear el perfil automáticamente al registrarse (Google o correo) ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url, provider)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    coalesce(new.raw_user_meta_data ->> 'avatar_url', new.raw_user_meta_data ->> 'picture'),
    new.raw_app_meta_data ->> 'provider'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Tiempo real (la app se actualiza sola al guardar) ----------
do $$
begin
  begin alter publication supabase_realtime add table public.transactions; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.goals;        exception when duplicate_object then null; end;
end $$;
