# SD Travel Guide Admin Stack

## What exists now

### 1. App AI backend
- File: `backend/translation_server.py`
- Purpose:
  - `/chat`
  - `/translate`

### 2. Platform backend
- Folder: `backend/platform`
- Purpose:
  - customer data
  - OTP/account flow starter
  - profile and preference storage
  - analytics events
  - places management
  - safety alerts
  - admin dashboard

### 3. Admin dashboard
- URL after startup:
  - `http://127.0.0.1:4100/dashboard`
- Auth:
  - admin key in request header
  - browser prompt/input handled in dashboard UI

## Database shape right now

Local development database file:

- `backend/platform/data/dev-db.json`

Collections stored inside:

- `users`
- `otpChallenges`
- `places`
- `safetyAlerts`
- `analyticsEvents`
- `settings`

## What you can monitor now

- total users
- active users
- premium users
- featured places
- active scam/safety alerts
- event counts
- top place searches
- recent analytics events

## What you can manage now

- add places
- update places
- publish safety alerts
- inspect traveler accounts

## Recommended production upgrade path

### Live app database
- Firestore

### Custom backend logic
- Node.js service layer replacing the local store adapter

### Analytics warehouse
- BigQuery

### Reporting tool
- Metabase or Looker Studio

## Role split

### Firestore
Use for:
- users
- profiles
- preferences
- itineraries
- feed data
- wallet entries
- safety alerts

### BigQuery
Use for:
- product analytics
- retention analysis
- premium conversion analysis
- place popularity trends

### Metabase
Use for:
- charts
- KPI dashboards
- operational reporting

### Custom admin dashboard
Use for:
- editing places
- reviewing users
- changing app data
- updating safety content
- moderation and support actions
