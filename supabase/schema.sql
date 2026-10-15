-- Initial Abuja Meet schema. Run in a new Supabase project's SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,display_name text not null default '',account_type text not null default 'regular' check(account_type in('regular','business')),profession text not null default '',bio text not null default '',gender text not null default 'prefer_not_to_say',interested_in text[] not null default '{}',state text not null default 'FCT' check(state in('FCT','Lagos','Nasarawa','Rivers')),city text not null default '',birth_date date,avatar_url text,interests text[] not null default '{}',whatsapp_number text,whatsapp_visible boolean not null default false,is_admin boolean not null default false,is_banned boolean not null default false,subscription_expires_at timestamptz,created_at timestamptz not null default now());
create table if not exists public.posts(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,media_url text not null,media_type text not null check(media_type in('image','video')),is_adult boolean not null default false,moderation_status text not null default 'pending' check(moderation_status in('pending','approved','rejected')),caption text not null default '',created_at timestamptz not null default now());
create table if not exists public.likes(id uuid primary key default gen_random_uuid(),from_user uuid not null references auth.users(id) on delete cascade,to_user uuid not null references auth.users(id) on delete cascade,created_at timestamptz not null default now(),unique(from_user,to_user),check(from_user<>to_user));
create table if not exists public.matches(id uuid primary key default gen_random_uuid(),user_one uuid not null references auth.users(id) on delete cascade,user_two uuid not null references auth.users(id) on delete cascade,created_at timestamptz not null default now(),check(user_one<user_two),unique(user_one,user_two));
create table if not exists public.messages(id uuid primary key default gen_random_uuid(),match_id uuid not null references public.matches(id) on delete cascade,sender_id uuid not null references auth.users(id) on delete cascade,body text not null check(char_length(body) between 1 and 4000),created_at timestamptz not null default now());
create table if not exists public.reports(id uuid primary key default gen_random_uuid(),reporter_id uuid not null references auth.users(id) on delete cascade,reported_user uuid references auth.users(id) on delete cascade,post_id uuid references public.posts(id) on delete cascade,reason text not null,details text not null default '',status text not null default 'pending' check(status in('pending','reviewing','resolved','dismissed')),created_at timestamptz not null default now());
create table if not exists public.payment_records(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,provider text not null check(provider in('paystack','flutterwave')),provider_reference text unique not null,plan_id text not null check(plan_id in('month','two_months','three_months')),amount_kobo bigint not null check(amount_kobo in(300000,500000,800000)),currency text not null default 'NGN' check(currency='NGN'),status text not null default 'pending' check(status in('pending','success','failed')),created_at timestamptz not null default now(),verified_at timestamptz);
alter table public.profiles enable row level security;alter table public.posts enable row level security;alter table public.likes enable row level security;alter table public.matches enable row level security;alter table public.messages enable row level security;alter table public.reports enable row level security;alter table public.payment_records enable row level security;
create policy "Signed-in users view non-banned profiles" on public.profiles for select to authenticated using(is_banned=false);
create policy "Users insert own non-admin profile" on public.profiles for insert to authenticated with check(auth.uid()=id and is_admin=false and is_banned=false and subscription_expires_at is null);
-- Intentionally no broad client UPDATE policy: add safe column-specific profile editing and server-verified admin/subscription permissions before launch.
create policy "Users manage own likes" on public.likes for all to authenticated using(auth.uid()=from_user) with check(auth.uid()=from_user);
create policy "Participants view matches" on public.matches for select to authenticated using(auth.uid()=user_one or auth.uid()=user_two);
create policy "Users submit reports" on public.reports for insert to authenticated with check(reporter_id=auth.uid());
create policy "Users view own reports" on public.reports for select to authenticated using(reporter_id=auth.uid());
create policy "Users view own payments" on public.payment_records for select to authenticated using(user_id=auth.uid());
-- Before launch: implement safe chat policies, approved-post visibility, private storage, adult checks, verified payment webhooks, and server-side admin checks. Never expose service-role/payment secrets.


-- Abuja Meet auth/profile migration. Run this in Supabase SQL Editor after opening the correct project.
-- Creates a profile automatically for each new Supabase Auth user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  safe_type text;
  safe_state text;
begin
  safe_type := case when new.raw_user_meta_data->>'account_type' = 'business' then 'business' else 'regular' end;
  safe_state := case when new.raw_user_meta_data->>'state' in ('FCT','Lagos','Nasarawa','Rivers') then new.raw_user_meta_data->>'state' else 'FCT' end;
  insert into public.profiles (id, display_name, account_type, profession, state, is_admin, is_banned, subscription_expires_at)
  values (new.id, left(coalesce(new.raw_user_meta_data->>'display_name',''),100), safe_type, left(coalesce(new.raw_user_meta_data->>'profession',''),100), safe_state, false, false, null)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Allow the four listed location values in existing projects.
alter table public.profiles drop constraint if exists profiles_state_check;
alter table public.profiles add constraint profiles_state_check check (state in ('FCT','Lagos','Nasarawa','Rivers'));
