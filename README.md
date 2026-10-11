# Abuja Meets website starter

A responsive dating website starter for Abuja (FCT), Lagos State and Nasarawa State. Includes the current logo, responsive homepage, location cards, registration/login modal UI, monthly membership section (₦3,000 for 30 days), Express server and an initial Supabase schema.

## Important: not yet a complete live dating service
Registration/login is currently a UI placeholder. Real Supabase authentication, profiles, mutual-match creation, private chat, an admin dashboard, and secure Paystack/Flutterwave checkout and webhook verification still need to be implemented and tested. The payment endpoint deliberately refuses to fake a successful payment. Do not collect payments until verification is complete.

## Deploy outline
1. Create a new GitHub repository named `abuja-meets` (keep it separate from other projects).
2. Upload all files in this ZIP, preserving the `public` and `supabase` folders.
3. Create a new Supabase project and run `supabase/schema.sql` in its SQL Editor.
4. Create a Render Web Service from the new repository; build command `npm install`, start command `npm start`.
5. Add environment variables in Render: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `SITE_URL`, `PAYSTACK_SECRET_KEY`, `FLW_SECRET_KEY`.
6. Keep service-role and payment secret keys only in Render, never in public/browser files.

## Current contents
- `server.js`: Express server, health and location endpoints
- `public/index.html`, `public/style.css`, `public/app.js`: responsive site UI
- `public/abuja-meets-logo.png`: logo without motto
- `supabase/schema.sql`: initial data schema and basic RLS policies
- `render.yaml`: Render service template

Adult content uploads are not enabled. Confirm applicable law and hosting/payment provider policies before enabling any adult-content feature.
