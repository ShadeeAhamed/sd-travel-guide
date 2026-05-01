# SD Travel Guide API Contracts

## Auth

### `POST /auth/register`
Request:
```json
{
  "fullName": "Ayesha Silva",
  "email": "ayesha@example.com",
  "phone": "+94771234567",
  "password": "secret123"
}
```

Response:
```json
{
  "challengeId": "otp_123",
  "channel": "email",
  "maskedDestination": "ay***@example.com",
  "expiresAt": "2026-05-01T04:30:00.000Z"
}
```

### `POST /auth/login/email`
Request:
```json
{
  "email": "ayesha@example.com",
  "password": "secret123"
}
```

Response:
```json
{
  "challengeId": "otp_456",
  "channel": "email",
  "maskedDestination": "ay***@example.com",
  "expiresAt": "2026-05-01T04:30:00.000Z"
}
```

### `POST /auth/login/phone`
Request:
```json
{
  "phone": "+94771234567"
}
```

Response:
```json
{
  "challengeId": "otp_789",
  "channel": "sms",
  "maskedDestination": "+94*****67",
  "expiresAt": "2026-05-01T04:30:00.000Z"
}
```

### `POST /auth/verify-otp`
Request:
```json
{
  "challengeId": "otp_123",
  "code": "324511",
  "method": "emailPassword"
}
```

Response:
```json
{
  "token": "jwt_or_firebase_token",
  "user": {
    "id": "user_1",
    "fullName": "Ayesha Silva",
    "email": "ayesha@example.com",
    "phone": "+94771234567",
    "isOnboardingComplete": false
  }
}
```

## Profile

### `PUT /profile/preferences`
Request:
```json
{
  "interest": "beach",
  "budget": "medium",
  "style": "relax",
  "food": "both",
  "mood": "chill"
}
```

### `GET /profile/me`
Response:
```json
{
  "id": "user_1",
  "travelPersonality": "Coastal Dreamer",
  "preferences": {
    "interest": "beach",
    "budget": "medium",
    "style": "relax",
    "food": "both",
    "mood": "chill"
  },
  "behavior": {
    "logins": 6,
    "assistantMessages": 11,
    "mapSearches": 4,
    "translatorUses": 8
  }
}
```

## Assistant

### `POST /assistant/respond`
Request:
```json
{
  "message": "What should I do now near Galle?",
  "location": {
    "lat": 6.03,
    "lng": 80.21
  },
  "time": "2026-05-01T17:15:00+05:30",
  "weather": {
    "condition": "clear",
    "temperatureC": 29
  },
  "preferences": {
    "interest": "culture",
    "mood": "chill"
  }
}
```

## Itinerary

### `POST /itinerary/generate`
Request:
```json
{
  "days": 3,
  "preferences": {
    "interest": "hiking",
    "budget": "medium",
    "style": "adventure",
    "food": "local",
    "mood": "adventure"
  }
}
```

## Future Modules
- `GET /transport/estimate`
- `GET /safety/alerts`
- `POST /wallet/expense`
- `POST /feed/posts`
- `POST /companion/share`
