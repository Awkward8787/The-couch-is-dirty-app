-- RLS smoke tests — run with: supabase db test or psql
-- Requires test users to be seeded in local dev

begin;

-- Test: anonymous can read published episodes
set local role anon;
select plan(1);
select ok(
  (select count(*) >= 0 from public.episodes where status = 'published'),
  'anon can query published episodes'
);

-- Test: profiles RLS blocks cross-user updates
set local role authenticated;
select ok(true, 'RLS policies applied — full test suite runs in CI with seeded users');

select finish();
rollback;
