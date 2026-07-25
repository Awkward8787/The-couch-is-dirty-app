-- The Couch Is Dirty Podcast — Row Level Security Policies
-- Every table has RLS enabled with strict least-privilege access

-- Helper functions (security definer, stable)
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'moderator')
  );
$$;

create or replace function public.is_admin_only()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.is_account_active()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and account_status = 'active'
      and (suspended_until is null or suspended_until < now())
  );
$$;

create or replace function public.is_blocked(blocker uuid, blocked uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.blocked_users
    where (blocker_id = blocker and blocked_id = blocked)
       or (blocker_id = blocked and blocked_id = blocker)
  );
$$;

-- Enable RLS on all tables
alter table public.app_settings enable row level security;
alter table public.profiles enable row level security;
alter table public.rss_sources enable row level security;
alter table public.episodes enable row level security;
alter table public.episode_chapters enable row level security;
alter table public.listening_progress enable row level security;
alter table public.saved_episodes enable row level security;
alter table public.episode_downloads enable row level security;
alter table public.community_posts enable row level security;
alter table public.comments enable row level security;
alter table public.reactions enable row level security;
alter table public.blocked_users enable row level security;
alter table public.reports enable row level security;
alter table public.moderation_actions enable row level security;
alter table public.notifications enable row level security;
alter table public.rss_sync_logs enable row level security;
alter table public.device_push_tokens enable row level security;
alter table public.episode_plays enable row level security;
alter table public.post_rate_limits enable row level security;
alter table public.prohibited_words enable row level security;

-- app_settings: public read for non-sensitive keys; admin write
create policy "app_settings_public_read"
  on public.app_settings for select
  using (key in ('support_email', 'community_guidelines_url', 'terms_url', 'privacy_url', 'minimum_age'));

create policy "app_settings_admin_all"
  on public.app_settings for all
  using (public.is_admin_only())
  with check (public.is_admin_only());

-- profiles
create policy "profiles_public_read"
  on public.profiles for select
  using (
    account_status = 'active'
    or id = auth.uid()
    or public.is_admin()
  );

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (id = auth.uid());

create policy "profiles_update_own"
  on public.profiles for update
  using (id = auth.uid() and public.is_account_active())
  with check (id = auth.uid());

create policy "profiles_admin_update"
  on public.profiles for update
  using (public.is_admin());

-- rss_sources: admin only
create policy "rss_sources_admin_all"
  on public.rss_sources for all
  using (public.is_admin_only())
  with check (public.is_admin_only());

-- episodes: published episodes readable by everyone (including anon/guest)
create policy "episodes_public_read_published"
  on public.episodes for select
  using (status = 'published' or public.is_admin());

create policy "episodes_admin_all"
  on public.episodes for all
  using (public.is_admin_only())
  with check (public.is_admin_only());

-- episode_chapters: follow episode visibility
create policy "episode_chapters_public_read"
  on public.episode_chapters for select
  using (
    exists (
      select 1 from public.episodes e
      where e.id = episode_id and (e.status = 'published' or public.is_admin())
    )
  );

create policy "episode_chapters_admin_all"
  on public.episode_chapters for all
  using (public.is_admin_only())
  with check (public.is_admin_only());

-- listening_progress: own data only
create policy "listening_progress_own"
  on public.listening_progress for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- saved_episodes: own data only
create policy "saved_episodes_own"
  on public.saved_episodes for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- episode_downloads: own data only
create policy "episode_downloads_own"
  on public.episode_downloads for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- community_posts
create policy "community_posts_read"
  on public.community_posts for select
  using (
    is_removed = false
    and not public.is_blocked(auth.uid(), author_id)
    and (
      author_id = auth.uid()
      or public.is_admin()
      or (auth.uid() is not null)
    )
  );

create policy "community_posts_insert"
  on public.community_posts for insert
  with check (
    auth.uid() is not null
    and author_id = auth.uid()
    and public.is_account_active()
  );

create policy "community_posts_update_own"
  on public.community_posts for update
  using (author_id = auth.uid() and public.is_account_active())
  with check (author_id = auth.uid());

create policy "community_posts_admin"
  on public.community_posts for all
  using (public.is_admin());

-- comments
create policy "comments_read"
  on public.comments for select
  using (
    is_removed = false
    and not public.is_blocked(auth.uid(), author_id)
    and (auth.uid() is not null or public.is_admin())
  );

create policy "comments_insert"
  on public.comments for insert
  with check (
    auth.uid() is not null
    and author_id = auth.uid()
    and public.is_account_active()
  );

create policy "comments_update_own"
  on public.comments for update
  using (author_id = auth.uid() and public.is_account_active())
  with check (author_id = auth.uid());

create policy "comments_admin"
  on public.comments for all
  using (public.is_admin());

-- reactions
create policy "reactions_read"
  on public.reactions for select
  using (auth.uid() is not null);

create policy "reactions_own"
  on public.reactions for all
  using (user_id = auth.uid() and public.is_account_active())
  with check (user_id = auth.uid() and public.is_account_active());

-- blocked_users
create policy "blocked_users_own"
  on public.blocked_users for all
  using (blocker_id = auth.uid())
  with check (blocker_id = auth.uid());

-- reports
create policy "reports_insert"
  on public.reports for insert
  with check (
    auth.uid() is not null
    and reporter_id = auth.uid()
    and public.is_account_active()
  );

create policy "reports_read_own"
  on public.reports for select
  using (reporter_id = auth.uid() or public.is_admin());

create policy "reports_admin_update"
  on public.reports for update
  using (public.is_admin());

-- moderation_actions: admin read/write
create policy "moderation_actions_admin"
  on public.moderation_actions for all
  using (public.is_admin())
  with check (public.is_admin());

-- notifications
create policy "notifications_own"
  on public.notifications for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- rss_sync_logs: admin only
create policy "rss_sync_logs_admin"
  on public.rss_sync_logs for select
  using (public.is_admin_only());

-- device_push_tokens
create policy "device_push_tokens_own"
  on public.device_push_tokens for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- episode_plays: insert for authenticated or anon session; read admin
create policy "episode_plays_insert"
  on public.episode_plays for insert
  with check (true);

create policy "episode_plays_admin_read"
  on public.episode_plays for select
  using (public.is_admin_only());

-- post_rate_limits: system managed via service role
create policy "post_rate_limits_own_read"
  on public.post_rate_limits for select
  using (user_id = auth.uid());

-- prohibited_words: readable by authenticated for client-side hint; admin manage
create policy "prohibited_words_read"
  on public.prohibited_words for select
  using (is_active = true and auth.uid() is not null);

create policy "prohibited_words_admin"
  on public.prohibited_words for all
  using (public.is_admin_only())
  with check (public.is_admin_only());

-- Storage buckets (run via Supabase dashboard or separate migration)
-- episode-audio: public read for published, admin write
-- episode-covers: public read, admin write
-- avatars: user write own, public read

-- Seed default app settings
insert into public.app_settings (key, value) values
  ('support_email', '"support@tcidpodcast.com"'::jsonb),
  ('community_guidelines_url', '"https://tcidpodcast.com/community-guidelines"'::jsonb),
  ('terms_url', '"https://tcidpodcast.com/terms"'::jsonb),
  ('privacy_url', '"https://tcidpodcast.com/privacy"'::jsonb),
  ('minimum_age', '13'::jsonb),
  ('post_rate_limit_per_hour', '10'::jsonb),
  ('duplicate_post_window_minutes', '5'::jsonb)
on conflict (key) do nothing;
