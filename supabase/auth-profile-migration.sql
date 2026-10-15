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
