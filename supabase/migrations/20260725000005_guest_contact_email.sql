-- Update public contact email to official guest/inquiry address
insert into public.app_settings (key, value)
values ('support_email', '"info@tcidpodcast.com"'::jsonb)
on conflict (key) do update set value = excluded.value, updated_at = now();

insert into public.app_settings (key, value)
values ('guest_email', '"info@tcidpodcast.com"'::jsonb)
on conflict (key) do update set value = excluded.value, updated_at = now();
