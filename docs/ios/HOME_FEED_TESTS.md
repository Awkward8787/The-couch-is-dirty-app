# Home Tab Manual Test Checklist

Use after rebuilding from branch `cursor/be-a-guest-screen`.

## Layout (no episodes)

- [ ] Open **Feed** (Home) tab
- [ ] **Be a Guest** section is at the top
- [ ] Composer (“What’s on your mind?”) is directly under it
- [ ] Social feed is under the composer
- [ ] No featured / latest / continue-listening / episode cards on Home
- [ ] Episodes still work on the **Episodes** tab

## Posts

- [ ] Signed-out user is prompted to sign in before posting
- [ ] Empty post cannot submit
- [ ] Text post publishes and appears at top with server timestamp
- [ ] Photo attachment can be added and removed before post
- [ ] Link / YouTube link posts show preview / in-app player
- [ ] Pull to refresh updates feed
- [ ] Scroll near bottom loads older posts (pagination)

## Interactions

- [ ] Like toggles and updates count
- [ ] Comments sheet opens; add / delete own comment
- [ ] Owner can Edit (shows Edited) and Delete
- [ ] Non-owner cannot edit another user’s post
- [ ] Mod/Admin can delete others’ posts
- [ ] Starting feed video pauses podcast audio if playing

## Realtime

- [ ] Second signed-in device sees new posts without restart (or after brief delay)
- [ ] Deleted posts disappear without restart
