-- Seed official podcast RSS source for The Couch Is Dirty Podcast
-- Public feed URL — safe to commit

insert into public.rss_sources (
  feed_url,
  podcast_title,
  podcast_artwork_url,
  is_active,
  sync_interval_minutes
)
values (
  'https://media.rss.com/the-couch-is-dirty-podcast/feed.xml',
  'The Couch is Dirty Podcast',
  'https://media.rss.com/the-couch-is-dirty-podcast/20260203_060212_32f38b82552f042abcdb98d0b9254e8b.png',
  true,
  60
)
on conflict (feed_url) do update set
  podcast_title = excluded.podcast_title,
  podcast_artwork_url = excluded.podcast_artwork_url,
  is_active = true,
  updated_at = now();

insert into public.app_settings (key, value)
values ('rss_feed_url', '"https://media.rss.com/the-couch-is-dirty-podcast/feed.xml"'::jsonb)
on conflict (key) do update set value = excluded.value, updated_at = now();
