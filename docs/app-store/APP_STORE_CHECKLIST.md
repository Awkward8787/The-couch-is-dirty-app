# App Store Submission Checklist

Manual steps for App Store Connect. Update as phases complete.

## App Information

- [ ] App name: **The Couch Is Dirty Podcast**
- [ ] Subtitle: (e.g. "Real talk. No filter.")
- [ ] Bundle ID: `com.tcidpodcast.app`
- [ ] Primary category: News or Entertainment
- [ ] Secondary category: Social Networking (community features)
- [ ] Age rating: **13+** (user-generated content, social capability)
- [ ] Copyright: © 2026 The Couch Is Dirty Podcast

## URLs (must be live at submission)

- [x] Support URL: https://tcidpodcast.com/support
- [x] Privacy Policy: https://tcidpodcast.com/privacy
- [x] Terms of Use: https://tcidpodcast.com/terms
- [x] Community Guidelines: https://tcidpodcast.com/community-guidelines
- [ ] Password recovery redirect: https://tcidpodcast.com/reset-password (configure in Appwrite Auth)

## In-app compliance (iOS)

- [x] Privacy Policy, Terms, Community Guidelines, Support in Profile
- [x] In-app account deletion (Profile → Delete Account)
- [x] Post report → Appwrite `moderation_status: reported`
- [x] Comment report → Appwrite `is_reported: true`
- [x] Block user on feed posts
- [x] Saved Episodes + Listening History
- [x] Forgot password (Appwrite recovery email)
- [x] `PrivacyInfo.xcprivacy` (email, user ID, name, photos, user content)
- [x] `ITSAppUsesNonExemptEncryption` = false in Info.plist
- [x] Launch splash — neutral loading copy
- [x] Administrator login hidden in Release builds (`#if DEBUG` only)

## Assets

- [ ] App icon 1024×1024
- [ ] iPhone 6.7" screenshots (minimum 3)
- [ ] iPhone 6.5" screenshots
- [x] Launch screen configured in Xcode

## Privacy

- [ ] Privacy Nutrition Label completed in App Store Connect (match PrivacyInfo.xcprivacy)
- [x] `PrivacyInfo.xcprivacy` included in app bundle
- [x] No tracking domains declared
- [ ] Data collection in Connect: email, user ID, name, photos, user-generated content

## Capabilities

- [ ] Sign in with Apple — **not required** (email/password only; add if OAuth is added)
- [x] Background audio entitlement
- [ ] Push notifications (optional, with in-app opt-out)

## App Review

- [ ] Demo account credentials in Review Notes
- [ ] Backend (Appwrite) live and populated with episodes
- [ ] No placeholder screens or broken buttons
- [ ] Community moderation accessible to admin (web dashboard)
- [x] Account deletion works in-app

## Export Compliance

- [x] Uses encryption: Yes (HTTPS only) → exempt standard encryption
- [x] `ITSAppUsesNonExemptEncryption` in Info.plist
- [ ] Confirm in App Store Connect questionnaire at upload

## TestFlight

- [ ] Archive build in Xcode (Release configuration)
- [ ] Upload to App Store Connect
- [ ] Internal testing group
- [ ] External beta (optional)

## Post-Launch

- [ ] Monitor crash reports
- [ ] RSS sync cron verified
- [ ] Moderation queue monitored

## Suggested Review Notes

```
Demo listener account:
  Email: [PROVIDE]
  Password: [PROVIDE]

Guest path: Complete onboarding → Episodes tab plays without login.

UGC: Sign in → Home tab → compose post. Report: ⋯ → Report. Block: ⋯ → Block.

Account deletion: Profile → Delete Account (confirmation required).

Backend: https://api.tcidpodcast.com/v1 must stay online during review.

Support: info@tcidpodcast.com
```
