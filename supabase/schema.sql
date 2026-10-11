-- Starter schema for Abuja Meets. Run in the Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default '', bio text not null default '',
 gender text not null default 'prefer_not_to_say', interested_in text[] not null default '{}',
 state text not null default 'FCT' check(state in ('FCT','Lagos','Nasarawa')), city text not null default '',
 birth_date date, avatar_url text, interests text[] not null default '{}',
 is_admin boolean not null default false, subscription_expires_at timestamptz,
 created_at timestamptz not null default now()
);
create table if not exists public.likes(id uuid primary key default gen_random_uuid(),from_user uuid not null references auth.users(id) on delete cascade,to_user uuid not null references auth.users(id) on delete cascade,created_at timestamptz not null default now(),unique(from_user,to_user),check(from_user<>to_user));
create table if not exists public.matches(id uuid primary key default gen_random_uuid(),user_one uuid not null references auth.users(id) on delete cascade,user_two uuid not null references auth.users(id) on delete cascade,created_at timestamptz not null default now(),check(user_one<user_two),unique(user_one,user_two));
create table if not exists public.messages(id uuid primary key default gen_random_uuid(),match_id uuid not null references public.matches(id) on delete cascade,sender_id uuid not null references auth.users(id) on delete cascade,body text not null check(char_length(body) between 1 and 4000),created_at timestamptz not null default now());
create table if not exists public.reports(id uuid primary key default gen_random_uuid(),reporter_id uuid not null references auth.users(id) on delete cascade,reported_user uuid references auth.users(id) on delete cascade,reason text not null,details text not null default '',status text not null default 'pending',created_at timestamptz not null default now());
create table if not exists public.payment_records(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,provider text not null check(provider in ('paystack','flutterwave')),provider_reference text unique not null,amount_kobo bigint not null check(amount_kobo=300000),currency text not null default 'NGN' check(currency='NGN'),status text not null default 'pending' check(status in ('pending','success','failed')),created_at timestamptz not null default now(),verified_at timestamptz);
alter table public.profiles enable row level security; alter table public.likes enable row level security; alter table public.matches enable row level security; alter table public.messages enable row level security; alter table public.reports enable row level security; alter table public.payment_records enable row level security;
create policy "Signed in users read profiles" on public.profiles for select to authenticated using(true);
create policy "Users create own profile" on public.profiles for insert to authenticated with check(auth.uid()=id and is_admin=false and subscription_expires_at is null);
create policy "Users manage own likes" on public.likes for all to authenticated using(auth.uid()=from_user) with check(auth.uid()=from_user);
create policy "Participants read matches" on public.matches for select to authenticated using(auth.uid()=user_one or auth.uid()=user_two);
create policy "Participants read messages" on public.messages for select to authenticated using(exists(select 1 from public.matches m where m.id=match_id and (m.user_one=auth.uid() or m.user_two=auth.uid())));
create policy "Subscribed participants send messages" on public.messages for insert to authenticated with check(sender_id=auth.uid() and exists(select 1 from public.matches m join public.profiles p1 on p1.id=m.user_one join public.profiles p2 on p2.id=m.user_two where m.id=match_id and (m.user_one=auth.uid() or m.user_two=auth.uid()) and (p1.subscription_expires_at>now() or p1.is_admin) and (p2.subscription_expires_at>now() or p2.is_admin)));
create policy "Users submit reports" on public.reports for insert to authenticated with check(reporter_id=auth.uid());
create policy "Users read own reports" on public.reports for select to authenticated using(reporter_id=auth.uid());
create policy "Users read own payment records" on public.payment_records for select to authenticated using(user_id=auth.uid());
-- IMPORTANT: Do not create client update policies for is_admin or subscription_expires_at.
-- A secure server-side admin and payment verification flow must be implemented before launch.
