# SD Travel Guide Foundation

## Architecture

### Client
- Flutter mobile app
- Local-first auth/session storage with `sqflite`
- Local traveler preference engine for personalization
- Existing map, places, assistant, and translator modules plugged into a premium shell

### Planned Production Backend
- Node.js + Express API gateway
- Firebase Auth or custom OTP provider
- Firestore for traveler profiles, feed, and recommendations
- Postgres for transport pricing, safety, and analytics if relational reporting is needed
- OpenAI Responses API for assistant, itinerary, and grounded travel help

## Current Implemented Modules

1. Authentication
   - Email + password login
   - Phone + OTP login
   - Signup with 2-step verification
   - Local session persistence

2. Traveler Personality System
   - Onboarding MCQ flow
   - Stored interest, budget, style, food preference, and mood
   - Generated traveler personality label

3. Premium App Shell
   - Branded welcome flow
   - Discover tab
   - Map tab
   - AI tab
   - Dynamic itinerary tab
   - Profile tab

4. Preference Engine
   - Personalized place ranking
   - Time-aware greeting
   - Personalized daily itinerary generation

## Code Structure

### Models
- `lib/models/user_profile_model.dart`
- `lib/models/auth_models.dart`
- `lib/models/place_model.dart`

### Storage
- `lib/database/auth_db.dart`
- `lib/database/places_db.dart`
- `lib/database/routes_db.dart`

### Services
- `lib/services/auth_service.dart`
- `lib/services/user_preference_engine.dart`
- `lib/services/ai_chat_service.dart`
- `lib/services/ai_translation_service.dart`
- `lib/services/map_service.dart`

### Screens
- `lib/screens/app_bootstrap_screen.dart`
- `lib/screens/auth_welcome_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/signup_screen.dart`
- `lib/screens/otp_verification_screen.dart`
- `lib/screens/onboarding_screen.dart`
- `lib/screens/travel_shell_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/itinerary_builder_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/wallet_screen.dart`
- `lib/screens/ar_explorer_screen.dart`

### Branding
- `lib/theme/app_theme.dart`
- `assets/branding/sd_travel_guide_logo.png`

## UI Components

### Dark Premium Direction
- Deep navy background
- Gold accent
- Large rounded cards
- High-contrast hero blocks
- One-tap primary actions

### Key Experience Rules
- Login friction stays low
- OTP is always required
- Personalization starts before the user reaches the home tab
- Important actions stay visible on the first screen

## ML Logic

### Current
- Rule-based recommendation engine
- Place scoring by interest, budget, and travel style
- Mood-driven UI accents and itinerary framing

### Next Upgrade
- Track:
  - assistant usage
  - map searches
  - saved places
  - itinerary edits
  - dwell time by place screen
- Move from rule-based ranking to hybrid ranking:
  - rules
  - recent behavior weighting
  - collaborative hints from similar traveler clusters

## Delivery Roadmap

1. Replace demo OTP with real email/SMS provider
2. Connect auth and profile storage to Firebase/Auth backend
3. Add weather + location grounding to the assistant
4. Add transport intelligence and scam protection dataset
5. Add companion sync and social feed
6. Add camera-based AR landmark recognition
7. Add subscription and premium feature gates
