create table public.weekly_checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  week_start date not null,
  sleep_hours numeric(3,1) not null check (sleep_hours between 0 and 24),
  water_intake numeric(4,1) not null check (water_intake between 0 and 20),
  exercise_sessions integer not null default 0 check (exercise_sessions >= 0),
  stress_level text not null check (stress_level in ('low', 'moderate', 'high')),
  weight_kg numeric(5,1),
  energy_level integer not null default 3 check (energy_level between 1 and 5),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, week_start)
);

grant select, insert, update, delete on public.weekly_checkins to authenticated;
grant all on public.weekly_checkins to service_role;

alter table public.weekly_checkins enable row level security;

create policy "Users can view own check-ins"
  on public.weekly_checkins for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users can insert own check-ins"
  on public.weekly_checkins for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Users can update own check-ins"
  on public.weekly_checkins for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users can delete own check-ins"
  on public.weekly_checkins for delete to authenticated
  using ((select auth.uid()) = user_id);