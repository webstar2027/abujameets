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
This ZIP is a **starter**, not a complete live dating platform. The homepage and account modal are visual/UI features. Real Supabase registration/login, profile editing, media upload, mutual-match logic, private chat, a working admin dashboard, moderation tools, and secure Paystack/Flutterwave checkout plus verified subscription activation still need implementation and testing. The payment endpoint deliberately refuses to pretend checkout is working. Do not collect payments until verification and subscription activation are implemented.

Adult-content functionality must not be enabled until age verification, consent and moderation safeguards are implemented and the hosting/payment providers' rules are checked. No minors, coercion, exploitation, or non-consensual intimate content.

## Deploy later
1. Upload the contents to a new GitHub repository named `abuja-meet`.
2. Create a separate Supabase project.
3. Run `supabase/schema.sql` in the Supabase SQL Editor.
4. Connect the repo to Render and set server environment variables.
5. Complete and test all authentication, access-control, uploads, chat, admin, and payment flows before launch.

Keep `SUPABASE_SERVICE_ROLE_KEY`, `PAYSTACK_SECRET_KEY`, and `FLW_SECRET_KEY` server-side only. Never put secrets in browser files.


Safety scope: the front-end clearly states that explicit/adult 18+ content is prohibited and shows a scam warning. This UI alone does not technically block uploads/messages. Before public launch, implement server-side upload validation, reporting/moderation, and enforce Supabase Row Level Security; do not rely on browser-only checks.
