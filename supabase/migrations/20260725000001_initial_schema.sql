-- The Couch Is Dirty Podcast — Initial Schema
-- Phase 1: Core tables, indexes, and constraints

-- Extensions
create extension if not exists "pgcrypto";
create extension if not exists "citext";

-- Custom types
create type public.user_role as enum ('user', 'moderator', 'admin');
create type public.account_status as enum ('active', 'warned', 'suspended', 'banned');
create type public.episode_source as enum ('rss', 'manual');
create type public.episode_status as enum ('draft', 'scheduled', 'published', 'archived');
create type public.post_type as enum ('discussion', 'question', 'comment', 'episode_discussion');
create type public.reaction_type as enum ('like', 'love', 'fire');
create type public.report_reason as enum (
  'spam',
  'harassment',
  'hate_speech',
  'profanity',
  'misinformation',
  'off_topic',
  'other'
);
create type public.report_status as enum ('pending', 'reviewed', 'dismissed', 'action_taken');
create type public.report_target_type as enum ('post', 'comment', 'user');
create type public.moderation_action_type as enum (
  'warn',
  'suspend',
  'ban',
  'unban',
  'remove_content',
  'restore_content',
  'dismiss_report'
);
create type public.notification_type as enum (
  'reply',
  'mention',
  'reaction',
  'episode',
  'promotional',
  'moderation'
);
create type public.rss_sync_status as enum ('success', 'partial', 'failed');

-- App settings (singleton-style key/value)
create table public.app_settings (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null
);

-- Profiles (extends auth.users)
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username citext unique,
  display_name text,
  bio text,
  avatar_url text,
  role public.user_role not null default 'user',
  account_status public.account_status not null default 'active',
  birth_year integer,
  age_verified boolean not null default false,
  community_guidelines_accepted_at timestamptz,
  terms_accepted_at timestamptz,
  privacy_accepted_at timestamptz,
  notify_replies boolean not null default true,
  notify_mentions boolean not null default true,
  notify_episodes boolean not null default true,
  notify_promotional boolean not null default false,
  last_active_at timestamptz,
  suspended_until timestamptz,
  suspension_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_length check (char_length(username) between 3 and 30),
  constraint profiles_username_format check (username ~ '^[a-zA-Z0-9_]+$'),
  constraint profiles_bio_length check (bio is null or char_length(bio) <= 500),
  constraint profiles_birth_year_valid check (birth_year is null or birth_year between 1900 and extract(year from now())::integer)
);

create index profiles_username_idx on public.profiles (username);
create index profiles_role_idx on public.profiles (role);
create index profiles_account_status_idx on public.profiles (account_status);

-- RSS sources
create table public.rss_sources (
  id uuid primary key default gen_random_uuid(),
  feed_url text not null unique,
  podcast_title text,
  podcast_artwork_url text,
  is_active boolean not null default true,
  sync_interval_minutes integer not null default 60,
  last_synced_at timestamptz,
  last_sync_status public.rss_sync_status,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rss_sources_https_only check (feed_url ~ '^https://')
);

-- Episodes
create table public.episodes (
  id uuid primary key default gen_random_uuid(),
  rss_guid text unique,
  source public.episode_source not null default 'rss',
  status public.episode_status not null default 'draft',
  title text not null,
  slug text unique,
  description text,
  show_notes text,
  audio_url text,
  audio_storage_path text,
  cover_art_url text,
  cover_storage_path text,
  duration_seconds integer,
  season_number integer,
  episode_number integer,
  is_explicit boolean not null default false,
  published_at timestamptz,
  scheduled_for timestamptz,
  play_count bigint not null default 0,
  rss_preserved_fields jsonb not null default '{}'::jsonb,
  manually_edited_fields text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null,
  constraint episodes_title_length check (char_length(title) between 1 and 300),
  constraint episodes_duration_positive check (duration_seconds is null or duration_seconds > 0)
);

create index episodes_status_published_idx on public.episodes (status, published_at desc nulls last);
create index episodes_source_idx on public.episodes (source);
create index episodes_rss_guid_idx on public.episodes (rss_guid) where rss_guid is not null;
create index episodes_play_count_idx on public.episodes (play_count desc);

-- Episode chapters
create table public.episode_chapters (
  id uuid primary key default gen_random_uuid(),
  episode_id uuid not null references public.episodes (id) on delete cascade,
  title text not null,
  start_seconds integer not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint episode_chapters_start_non_negative check (start_seconds >= 0),
  unique (episode_id, start_seconds)
);

create index episode_chapters_episode_idx on public.episode_chapters (episode_id, sort_order);

-- Listening progress
create table public.listening_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  episode_id uuid not null references public.episodes (id) on delete cascade,
  position_seconds integer not null default 0,
  completed boolean not null default false,
  last_listened_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, episode_id),
  constraint listening_progress_position_non_negative check (position_seconds >= 0)
);

create index listening_progress_user_idx on public.listening_progress (user_id, last_listened_at desc);

-- Saved episodes
create table public.saved_episodes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  episode_id uuid not null references public.episodes (id) on delete cascade,
  saved_at timestamptz not null default now(),
  unique (user_id, episode_id)
);

create index saved_episodes_user_idx on public.saved_episodes (user_id, saved_at desc);

-- Episode downloads (authorized offline)
create table public.episode_downloads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  episode_id uuid not null references public.episodes (id) on delete cascade,
  local_file_path text,
  file_size_bytes bigint,
  downloaded_at timestamptz not null default now(),
  expires_at timestamptz,
  unique (user_id, episode_id)
);

create index episode_downloads_user_idx on public.episode_downloads (user_id);

-- Community posts
create table public.community_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users (id) on delete cascade,
  episode_id uuid references public.episodes (id) on delete set null,
  post_type public.post_type not null default 'discussion',
  title text,
  body text not null,
  is_pinned boolean not null default false,
  is_featured boolean not null default false,
  is_removed boolean not null default false,
  removed_at timestamptz,
  removed_by uuid references auth.users (id) on delete set null,
  reply_count integer not null default 0,
  reaction_count integer not null default 0,
  content_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint community_posts_body_length check (char_length(body) between 1 and 10000),
  constraint community_posts_title_length check (title is null or char_length(title) <= 200)
);

create index community_posts_author_idx on public.community_posts (author_id);
create index community_posts_episode_idx on public.community_posts (episode_id) where episode_id is not null;
create index community_posts_created_idx on public.community_posts (created_at desc) where is_removed = false;
create index community_posts_featured_idx on public.community_posts (is_featured, created_at desc) where is_removed = false;
create index community_posts_content_hash_idx on public.community_posts (author_id, content_hash, created_at desc);

-- Comments (threaded via parent_id)
create table public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts (id) on delete cascade,
  author_id uuid not null references auth.users (id) on delete cascade,
  parent_id uuid references public.comments (id) on delete cascade,
  body text not null,
  is_removed boolean not null default false,
  removed_at timestamptz,
  removed_by uuid references auth.users (id) on delete set null,
  reaction_count integer not null default 0,
  content_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint comments_body_length check (char_length(body) between 1 and 5000)
);

create index comments_post_idx on public.comments (post_id, created_at);
create index comments_author_idx on public.comments (author_id);
create index comments_parent_idx on public.comments (parent_id) where parent_id is not null;

-- Reactions
create table public.reactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  post_id uuid references public.community_posts (id) on delete cascade,
  comment_id uuid references public.comments (id) on delete cascade,
  reaction_type public.reaction_type not null default 'like',
  created_at timestamptz not null default now(),
  constraint reactions_target_check check (
    (post_id is not null and comment_id is null) or
    (post_id is null and comment_id is not null)
  ),
  unique (user_id, post_id, reaction_type),
  unique (user_id, comment_id, reaction_type)
);

create index reactions_post_idx on public.reactions (post_id) where post_id is not null;
create index reactions_comment_idx on public.reactions (comment_id) where comment_id is not null;

-- Blocked users
create table public.blocked_users (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid not null references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (blocker_id, blocked_id),
  constraint blocked_users_not_self check (blocker_id <> blocked_id)
);

create index blocked_users_blocker_idx on public.blocked_users (blocker_id);

-- Reports
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users (id) on delete cascade,
  target_type public.report_target_type not null,
  target_post_id uuid references public.community_posts (id) on delete cascade,
  target_comment_id uuid references public.comments (id) on delete cascade,
  target_user_id uuid references auth.users (id) on delete cascade,
  reason public.report_reason not null,
  details text,
  status public.report_status not null default 'pending',
  reviewed_by uuid references auth.users (id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint reports_target_check check (
    (target_type = 'post' and target_post_id is not null) or
    (target_type = 'comment' and target_comment_id is not null) or
    (target_type = 'user' and target_user_id is not null)
  ),
  constraint reports_details_length check (details is null or char_length(details) <= 1000)
);

create index reports_status_idx on public.reports (status, created_at desc);
create index reports_reporter_idx on public.reports (reporter_id);

-- Moderation actions (audit log)
create table public.moderation_actions (
  id uuid primary key default gen_random_uuid(),
  moderator_id uuid not null references auth.users (id) on delete set null,
  action_type public.moderation_action_type not null,
  target_user_id uuid references auth.users (id) on delete set null,
  target_post_id uuid references public.community_posts (id) on delete set null,
  target_comment_id uuid references public.comments (id) on delete set null,
  report_id uuid references public.reports (id) on delete set null,
  reason text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index moderation_actions_created_idx on public.moderation_actions (created_at desc);
create index moderation_actions_target_user_idx on public.moderation_actions (target_user_id);

-- Notifications
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  notification_type public.notification_type not null,
  title text not null,
  body text,
  data jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index notifications_user_unread_idx on public.notifications (user_id, is_read, created_at desc);

-- RSS sync logs
create table public.rss_sync_logs (
  id uuid primary key default gen_random_uuid(),
  rss_source_id uuid not null references public.rss_sources (id) on delete cascade,
  status public.rss_sync_status not null,
  episodes_imported integer not null default 0,
  episodes_updated integer not null default 0,
  episodes_skipped integer not null default 0,
  error_message text,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);

create index rss_sync_logs_source_idx on public.rss_sync_logs (rss_source_id, started_at desc);

-- Device push tokens
create table public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token text not null,
  platform text not null default 'ios',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);

create index device_push_tokens_user_idx on public.device_push_tokens (user_id) where is_active = true;

-- Episode play events (privacy-friendly analytics)
create table public.episode_plays (
  id uuid primary key default gen_random_uuid(),
  episode_id uuid not null references public.episodes (id) on delete cascade,
  user_id uuid references auth.users (id) on delete set null,
  session_id text,
  played_at timestamptz not null default now(),
  duration_listened_seconds integer,
  source text default 'ios'
);

create index episode_plays_episode_idx on public.episode_plays (episode_id, played_at desc);

-- Rate limiting for community posts
create table public.post_rate_limits (
  user_id uuid not null references auth.users (id) on delete cascade,
  window_start timestamptz not null,
  post_count integer not null default 0,
  primary key (user_id, window_start)
);

-- Prohibited words (admin-managed)
create table public.prohibited_words (
  id uuid primary key default gen_random_uuid(),
  word text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Updated_at trigger function
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger episodes_updated_at before update on public.episodes
  for each row execute function public.set_updated_at();
create trigger listening_progress_updated_at before update on public.listening_progress
  for each row execute function public.set_updated_at();
create trigger community_posts_updated_at before update on public.community_posts
  for each row execute function public.set_updated_at();
create trigger comments_updated_at before update on public.comments
  for each row execute function public.set_updated_at();
create trigger rss_sources_updated_at before update on public.rss_sources
  for each row execute function public.set_updated_at();
create trigger device_push_tokens_updated_at before update on public.device_push_tokens
  for each row execute function public.set_updated_at();

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name'),
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Increment play count
create or replace function public.increment_episode_play_count(p_episode_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.episodes
  set play_count = play_count + 1
  where id = p_episode_id and status = 'published';
end;
$$;
