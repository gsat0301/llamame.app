-- Migration 002: Provider Gallery & Ratings
-- Run this in the Supabase SQL editor after 001_init.sql

begin;

-- -----------------------------------------------------------------------
-- provider_gallery: up to 4 work images per provider
-- -----------------------------------------------------------------------
create table if not exists public.provider_gallery (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.profiles(id) on delete cascade,
  image_url text not null,
  position smallint not null check (position between 0 and 3),
  created_at timestamptz not null default now(),
  unique (provider_id, position)
);

create index if not exists idx_provider_gallery_provider on public.provider_gallery(provider_id);

-- -----------------------------------------------------------------------
-- provider_ratings: star rating (1-5) + optional comment
-- -----------------------------------------------------------------------
create table if not exists public.provider_ratings (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.profiles(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  stars smallint not null check (stars between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  -- one rating per customer per provider
  unique (provider_id, customer_id)
);

create index if not exists idx_provider_ratings_provider on public.provider_ratings(provider_id);
create index if not exists idx_provider_ratings_customer on public.provider_ratings(customer_id);

-- -----------------------------------------------------------------------
-- Trigger: keep provider_details.average_rating in sync
-- -----------------------------------------------------------------------
create or replace function public.update_provider_avg_rating()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
  v_avg numeric(3,2);
  v_count int;
begin
  -- Determine which provider was affected
  if TG_OP = 'DELETE' then
    v_provider_id := OLD.provider_id;
  else
    v_provider_id := NEW.provider_id;
  end if;

  select coalesce(avg(stars), 0), count(*)
  into v_avg, v_count
  from public.provider_ratings
  where provider_id = v_provider_id;

  -- Upsert provider_details to ensure the row exists
  insert into public.provider_details(profile_id, average_rating, jobs_completed)
  values (v_provider_id, v_avg, 0)
  on conflict (profile_id) do update
    set average_rating = excluded.average_rating,
        updated_at = now();

  return null;
end;
$$;

drop trigger if exists trg_update_provider_avg_rating on public.provider_ratings;
create trigger trg_update_provider_avg_rating
after insert or update or delete on public.provider_ratings
for each row execute procedure public.update_provider_avg_rating();

-- -----------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------
alter table public.provider_gallery enable row level security;
alter table public.provider_ratings enable row level security;

-- Gallery: anyone can view; only the provider (owner) can insert/delete
drop policy if exists "gallery_select_all" on public.provider_gallery;
create policy "gallery_select_all"
on public.provider_gallery for select
using (true);

drop policy if exists "gallery_insert_own" on public.provider_gallery;
create policy "gallery_insert_own"
on public.provider_gallery for insert
with check (auth.uid() = provider_id);

drop policy if exists "gallery_delete_own" on public.provider_gallery;
create policy "gallery_delete_own"
on public.provider_gallery for delete
using (auth.uid() = provider_id);

-- Ratings: anyone can view stars; only admin can view comments (enforced in app query)
-- Any authenticated user (except the provider themselves) can insert a rating
drop policy if exists "ratings_select_all" on public.provider_ratings;
create policy "ratings_select_all"
on public.provider_ratings for select
using (true);

drop policy if exists "ratings_insert_authenticated" on public.provider_ratings;
create policy "ratings_insert_authenticated"
on public.provider_ratings for insert
with check (
  auth.uid() is not null
  and auth.uid() != provider_id
);

-- Allow customer to update their own rating
drop policy if exists "ratings_update_own" on public.provider_ratings;
create policy "ratings_update_own"
on public.provider_ratings for update
using (auth.uid() = customer_id)
with check (auth.uid() = customer_id);

-- Allow customer to delete their own rating
drop policy if exists "ratings_delete_own" on public.provider_ratings;
create policy "ratings_delete_own"
on public.provider_ratings for delete
using (auth.uid() = customer_id);

commit;
