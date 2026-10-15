# ABUJA MEET — redesigned website starter

Includes a redesigned responsive homepage, account UI preview (regular/business, with profession selection), show/hide password, launch locations (Abuja/FCT, Lagos, Nasarawa, Port Harcourt), the three subscription plans, feature descriptions, and an initial Supabase schema for profiles, posts, matches, messages, reports and payment records.

## Account types and professions
- Regular account
- Business account
- Profession choices include lawyer, law firm, web/IT professional, business owner, entrepreneur, healthcare professional, engineer, teacher, accountant, artist, real estate professional, student, and other.

## Subscription pricing
- ₦3,000 for 30 days
- ₦5,000 for 60 days
- ₦8,000 for 90 days

## Important: what is and is not live
This ZIP is a starter, not a complete live dating platform. The registration and login form now connects to Supabase Auth when Render environment variables are configured. The migration creates a basic profile on registration. Profile editing, media upload, mutual-match logic, private chat, a working admin dashboard, moderation tools, and secure Paystack/Flutterwave checkout plus verified subscription activation still need implementation and testing. The payment endpoint deliberately refuses to pretend checkout is working. Do not collect payments until verification and subscription activation are implemented.

Adult-content functionality must not be enabled until age verification, consent and moderation safeguards are implemented and the hosting/payment providers' rules are checked. No minors, coercion, exploitation, or non-consensual intimate content.

## Deploy later
1. Upload the contents to a new GitHub repository named `abuja-meet`.
2. Create a separate Supabase project.
3. Run `supabase/schema.sql` in the Supabase SQL Editor.
4. Connect the repo to Render and set `SUPABASE_URL` and `SUPABASE_ANON_KEY` as environment variables. The service role key is not needed for browser sign-up/login.
5. In Supabase SQL Editor, run `supabase/auth-profile-migration.sql` on an existing database (or use the complete `schema.sql` for a fresh database).
6. In Supabase Authentication settings, check that Email sign-ups are enabled. If email confirmation is enabled, users must click the confirmation link before password login. Add your deployed Render URL to Authentication URL Configuration / Redirect URLs.
7. Test sign-up and login. The form now uses Supabase Auth, and the migration creates a basic profile on registration.
8. Complete and test all profile editing, access-control, uploads, chat, admin, and payment flows before launch.

Keep `SUPABASE_SERVICE_ROLE_KEY`, `PAYSTACK_SECRET_KEY`, and `FLW_SECRET_KEY` server-side only. Never put secrets in browser files.


Safety scope: the front-end clearly states that explicit/adult 18+ content is prohibited and shows a scam warning. This UI alone does not technically block uploads/messages. Before public launch, implement server-side upload validation, reporting/moderation, and enforce Supabase Row Level Security; do not rely on browser-only checks.
