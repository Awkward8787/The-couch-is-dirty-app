-- Allow anonymous read access to guest_email app setting
drop policy if exists "app_settings_public_read" on public.app_settings;

create policy "app_settings_public_read"
  on public.app_settings for select
  using (key in (
    'support_email',
    'guest_email',
    'community_guidelines_url',
    'terms_url',
    'privacy_url',
    'minimum_age'
  ));
