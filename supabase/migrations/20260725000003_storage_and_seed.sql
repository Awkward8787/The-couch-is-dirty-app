-- Storage buckets and policies

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('episode-audio', 'episode-audio', true, 524288000, array['audio/mpeg', 'audio/mp4', 'audio/x-m4a', 'audio/wav', 'audio/aac']),
  ('episode-covers', 'episode-covers', true, 10485760, array['image/jpeg', 'image/png', 'image/webp']),
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- Episode audio: public read, admin upload
create policy "episode_audio_public_read"
  on storage.objects for select
  using (bucket_id = 'episode-audio');

create policy "episode_audio_admin_write"
  on storage.objects for insert
  with check (bucket_id = 'episode-audio' and public.is_admin_only());

create policy "episode_audio_admin_update"
  on storage.objects for update
  using (bucket_id = 'episode-audio' and public.is_admin_only());

create policy "episode_audio_admin_delete"
  on storage.objects for delete
  using (bucket_id = 'episode-audio' and public.is_admin_only());

-- Episode covers: public read, admin upload
create policy "episode_covers_public_read"
  on storage.objects for select
  using (bucket_id = 'episode-covers');

create policy "episode_covers_admin_write"
  on storage.objects for insert
  with check (bucket_id = 'episode-covers' and public.is_admin_only());

create policy "episode_covers_admin_update"
  on storage.objects for update
  using (bucket_id = 'episode-covers' and public.is_admin_only());

create policy "episode_covers_admin_delete"
  on storage.objects for delete
  using (bucket_id = 'episode-covers' and public.is_admin_only());

-- Avatars: public read, users upload to own folder
create policy "avatars_public_read"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "avatars_user_upload"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_user_update"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "avatars_user_delete"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Account deletion function (GDPR-style)
create or replace function public.delete_user_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  delete from public.reactions where user_id = v_user_id;
  delete from public.comments where author_id = v_user_id;
  delete from public.community_posts where author_id = v_user_id;
  delete from public.reports where reporter_id = v_user_id;
  delete from public.blocked_users where blocker_id = v_user_id or blocked_id = v_user_id;
  delete from public.notifications where user_id = v_user_id;
  delete from public.device_push_tokens where user_id = v_user_id;
  delete from public.listening_progress where user_id = v_user_id;
  delete from public.saved_episodes where user_id = v_user_id;
  delete from public.episode_downloads where user_id = v_user_id;
  delete from public.post_rate_limits where user_id = v_user_id;

  delete from public.profiles where id = v_user_id;
  delete from auth.users where id = v_user_id;
end;
$$;

grant execute on function public.delete_user_account() to authenticated;
grant execute on function public.increment_episode_play_count(uuid) to anon, authenticated;
