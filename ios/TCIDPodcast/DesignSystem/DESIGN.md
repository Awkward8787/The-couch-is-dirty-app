# TCID Podcast — Studio Dark Design System

## 1. Visual Theme & Atmosphere

Warm charcoal studio — dim, focused, editorial. Like a podcast booth at night: near-black with subtle warmth, not OLED flat black. Red accent only for **play**, **live**, and **primary actions** (max two hits per screen).

## 2. Color Palette & Roles

| Token | Role |
|-------|------|
| `background` | App canvas — warm charcoal |
| `surface` | Cards, rows, inputs |
| `surfaceElevated` | Mini player, modals, hover states |
| `surfaceOverlay` | Sheets, grouped profile blocks |
| `textPrimary` | Headlines, body |
| `textSecondary` | Metadata, captions |
| `textTertiary` | Hints, loading copy |
| `accent` | Play, live dot, primary CTA |
| `accentMuted` | Badge backgrounds |
| `border` / `separator` | 8–10% white hairlines |

## 3. Typography Rules

- **Display** — screen titles (`largeTitle`, semibold)
- **Title** — episode names, section headers (`title2`, bold)
- **Headline** — card titles (`headline`, semibold)
- **Body** — post copy, descriptions
- **Caption** — timestamps, metadata
- **Micro** — launch status, badges (11pt)

## 4. Component Stylings

- **Primary CTA** — accent fill, white label, 12pt radius
- **Secondary** — surface fill + border
- **Filter chip selected** — accent border + accent text (not solid fill)
- **Play button** — white circle, accent icon
- **Cards** — surface bg, 16pt radius, no shadow (depth via surface tiers)
- **Feed short video** — 9:16 frame, max 60s, MP4/MOV ≤30 MB, play overlay on `surfaceOverlay`

## 5. Layout Principles

- Screen gutter: 16pt
- Section gap: 24pt
- Card padding: 16pt
- Touch target: 44pt minimum

## 6. Depth & Elevation

Three tiers only: background → surface → surfaceElevated. No drop shadows; use borders and elevation color steps.

## 7. Do's and Don'ts

**Do:** Restrain accent; use wordmark on launch/onboarding; group profile rows; vertical 9:16 for feed clips.  
**Don't:** Pure `#000` full screens; solid red filter chips; fake notification badges; dev copy in UI; landscape-only feed videos.

## 8. Responsive Behavior

Single-column iPhone-first. Safe areas respected. Reduce motion: skip scale/fade animations.

## 9. Agent Prompt Guide

When adding UI: import `TCIDTheme`, use `TCIDColors.background`, prefer `TCIDPrimaryButton` for one main action, `TCIDSecondaryButton` for alternates, `TCIDStudioBackground` for splash screens.
