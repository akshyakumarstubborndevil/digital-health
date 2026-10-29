# HealthMate build roadmap

- [x] Enable Lovable Cloud (database + auth)
- [x] Enable email/password auth + Google + Lovable sign-in
- [x] DB schema: profiles, health_profiles, bookmarks, wellness_completions, weekly_checkins (RLS, grants, signup trigger)
- [ ] Green design system in src/styles.css
- [ ] Recommendation engine (src/lib) + resources library
- [ ] Auth pages: /auth (sign in, sign up, forgot password), /reset-password
- [ ] Protected layout + pages: categories, assessment, dashboard, profile, reading, exercises, preventive-care, progress
- [ ] Weekly check-ins + progress charts on /progress
- [ ] Public pages: landing, privacy, about
- [ ] README, .env.example, SQL schema doc
- [ ] Tests: recommendation engine rules
- [ ] End-to-end test: register -> confirm -> login -> category -> assessment -> dashboard -> check-in -> logout
