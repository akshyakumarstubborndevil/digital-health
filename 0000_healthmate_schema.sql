create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text not null default '',
  age integer check (age between 20 and 35),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.health_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  category text not null check (category in ('student', 'married', 'job_holder')),
  age integer not null check (age between 20 and 35),
  sleep_hours numeric(3,1) not null check (sleep_hours >= 0 and sleep_hours <= 24),
  water_intake numeric(4,1) not null check (water_intake >= 0 and water_intake <= 20),
  physical_activity text not null default '',
  exercise_frequency text not null default '',
  screen_time numeric(4,1) not null default 0 check (screen_time >= 0),
  sitting_hours numeric(4,1) not null default 0 check (sitting_hours >= 0),
  eating_habits text not null default '',
  stress_level text not null check (stress_level in ('low', 'moderate', 'high')),
  smoking boolean not null default false,
  alcohol text not null default 'never' check (alcohol in ('never', 'occasionally', 'regularly')),
  health_concerns text,
  symptoms text,
  goals text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  resource_id text not null,
  resource_type text not null default 'article',
  created_at timestamptz not null default now(),
  unique (user_id, resource_id)
);

create table public.wellness_completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  item_id text not null,
  completed_on date not null default current_date,
  created_at timestamptz not null default now(),
  unique (user_id, item_id, completed_on)
);

grant select, insert, update on public.profiles to authenticated;
grant all on public.profiles to service_role;
grant select, insert, update, delete on public.health_profiles to authenticated;
grant all on public.health_profiles to service_role;
grant select, insert, delete on public.bookmarks to authenticated;
grant all on public.bookmarks to service_role;
grant select, insert, delete on public.wellness_completions to authenticated;
grant all on public.wellness_completions to service_role;

alter table public.profiles enable row level security;
alter table public.health_profiles enable row level security;
alter table public.bookmarks enable row level security;
alter table public.wellness_completions enable row level security;

create policy "Users can view own profile"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = id);
create policy "Users can insert own profile"
  on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);
create policy "Users can update own profile"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy "Users can view own health profile"
  on public.health_profiles for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users can insert own health profile"
  on public.health_profiles for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Users can update own health profile"
  on public.health_profiles for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "Users can view own bookmarks"
  on public.bookmarks for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users can insert own bookmarks"
  on public.bookmarks for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Users can delete own bookmarks"
  on public.bookmarks for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can view own completions"
  on public.wellness_completions for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users can insert own completions"
  on public.wellness_completions for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Users can delete own completions"
  on public.wellness_completions for delete to authenticated
  using ((select auth.uid()) = user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, age)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.email, ''),
    case
      when new.raw_user_meta_data->>'age' ~ '^[0-9]+$'
        and (new.raw_user_meta_data->>'age')::int between 20 and 35
      then (new.raw_user_meta_data->>'age')::int
      else null
    end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();