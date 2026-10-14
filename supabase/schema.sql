-- Fortnite Cups — schéma Supabase initial
-- À exécuter dans Supabase > SQL Editor.
-- Ce fichier prépare la base ; il ne crée pas à lui seul un projet Supabase.

create extension if not exists pgcrypto;

create table if not exists public.competitions (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  region text not null default 'EU',
  mode text,
  format text,
  plateformes text[] not null default '{}',
  source text,
  url_source text,
  identifiant_externe text,
  statut text not null default 'a_venir'
    check (statut in ('a_venir', 'terminee', 'annulee')),
  details jsonb not null default '{}'::jsonb,
  cree_le timestamptz not null default now(),
  mis_a_jour_le timestamptz not null default now()
);

create unique index if not exists competitions_source_externe_unique
  on public.competitions (source, region, identifiant_externe)
  where identifiant_externe is not null;

create index if not exists competitions_region_idx
  on public.competitions (region);
create index if not exists competitions_statut_idx
  on public.competitions (statut);

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  competition_id uuid not null
    references public.competitions(id) on delete cascade,
  numero_session integer,
  nom_session text,
  debut timestamptz not null,
  fin timestamptz,
  details jsonb not null default '{}'::jsonb,
  cree_le timestamptz not null default now(),
  constraint sessions_fin_apres_debut
    check (fin is null or fin > debut)
);

create index if not exists sessions_debut_idx
  on public.sessions (debut);
create index if not exists sessions_competition_idx
  on public.sessions (competition_id);

create or replace view public.calendrier as
select
  c.id as competition_id,
  c.nom,
  c.region,
  c.mode,
  c.format,
  c.plateformes,
  c.source,
  c.url_source,
  c.statut,
  c.details as details_competition,
  s.id as session_id,
  s.nom_session,
  s.numero_session,
  s.debut,
  s.fin,
  s.details as details_session
from public.competitions c
left join public.sessions s on s.competition_id = c.id;

-- Le calendrier public est consultable sans connexion.
-- Aucune insertion/modification publique n'est autorisée par ces politiques.
alter table public.competitions enable row level security;
alter table public.sessions enable row level security;

drop policy if exists "Calendrier public en lecture" on public.competitions;
create policy "Calendrier public en lecture"
  on public.competitions for select
  to anon, authenticated
  using (true);

drop policy if exists "Sessions publiques en lecture" on public.sessions;
create policy "Sessions publiques en lecture"
  on public.sessions for select
  to anon, authenticated
  using (true);

grant select on public.competitions to anon, authenticated;
grant select on public.sessions to anon, authenticated;
grant select on public.calendrier to anon, authenticated;
