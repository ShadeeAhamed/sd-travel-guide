# SD Travel Guide Platform

This is the new backend foundation for:

- traveler accounts
- OTP login flow
- profile and preference storage
- admin/customer control
- analytics events
- places and safety management
- itinerary and assistant API starter

It is built with **plain Node.js** so you can run it locally without an install-heavy setup.

## What it includes

- `server.js`: HTTP server and route layer
- `src/local-store.js`: local JSON development database
- `src/platform-services.js`: auth, profile, admin, analytics, assistant, itinerary logic
- `dashboard/`: browser-based admin dashboard
- `data/dev-db.json`: starter development data

## Endpoints

- `GET /health`
- `POST /auth/register`
- `POST /auth/login/email`
- `POST /auth/login/phone`
- `POST /auth/verify-otp`
- `GET /profile/me?userId=...`
- `PUT /profile/preferences`
- `POST /events/track`
- `POST /assistant/respond`
- `POST /itinerary/generate`
- `GET /admin/overview`
- `GET /admin/users`
- `GET /admin/places`
- `POST /admin/places`
- `PUT /admin/places/:id`
- `GET /admin/safety-alerts`
- `POST /admin/safety-alerts`
- `GET /admin/analytics`
- `GET /dashboard`

## Run locally

Simplest option on Windows:

```powershell
.\backend\platform\start-platform.ps1
```

For phone testing on the same Wi-Fi:

```powershell
.\backend\platform\start-platform.ps1 -BindHost 0.0.0.0
```

Or:

```powershell
.\backend\platform\start-platform.cmd
```

For phone testing with the `.cmd` version:

```powershell
.\backend\platform\start-platform.cmd 0.0.0.0 4100
```

If you want to run it manually with Node installed:

```powershell
node backend\platform\server.js
```

If you want to use the bundled Node runtime already available on this machine:

```powershell
& 'C:\Users\U S E R\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe' .\backend\platform\server.js
```

Then open:

- API health: `http://127.0.0.1:4100/health`
- Admin dashboard: `http://127.0.0.1:4100/dashboard`
- Admin alias: `http://127.0.0.1:4100/admin`
- Database tab inside the dashboard: `http://127.0.0.1:4100/dashboard#database`

## Developer code + real email together

The app now supports both:

- a visible developer verification code in the OTP screen
- optional real email delivery from the backend

To turn on real email sending, configure Resend before starting the platform:

```powershell
$env:SD_PLATFORM_EMAIL_PROVIDER = 'resend'
$env:SD_PLATFORM_RESEND_API_KEY = 're_xxxxxxxxx'
$env:SD_PLATFORM_EMAIL_FROM = 'SD Travel Guide <noreply@yourdomain.com>'
```

With that enabled, the same OTP will still appear in the app for testing, and it will also be sent to the user email address.

You can also copy [backend/platform/.env.example](</C:/Users/U S E R/tourist_guide/backend/platform/.env.example>) to `backend/platform/.env` and fill in the values there. The platform now auto-loads that file when it starts.

If you want the raw admin database JSON in PowerShell:

```powershell
$headers = @{ 'X-Admin-Key' = 'dev-admin-key' }
Invoke-WebRequest `
  -Uri http://127.0.0.1:4100/admin/database `
  -Headers $headers `
  -UseBasicParsing
```

## Admin dashboard access

Default development admin key:

```text
dev-admin-key
```

The dashboard asks for it on first load and stores it in browser local storage.

## Local development admin user

- Email: `admin@sdtravel.local`
- Password: `Admin123!`

This is for local development only.

## Firestore later

The platform is intentionally shaped so you can replace the local store with Firestore later.

For production, the recommended direction is:

- Firebase Auth for login and OTP
- Firestore for live app data
- BigQuery for analytics
- this admin dashboard upgraded to a richer web control center
