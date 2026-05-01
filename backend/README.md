# Tourist Guide Backend

This project now has **two backend layers**:

1. [backend/translation_server.py](</C:/Users/U S E R/tourist_guide/backend/translation_server.py>) for the AI translator and the OpenAI-backed Sri Lanka chat endpoint.
2. [backend/platform/README.md](</C:/Users/U S E R/tourist_guide/backend/platform/README.md>) for the new customer-data platform, admin APIs, analytics model, and browser admin dashboard.

Local development backend for the Flutter AI translator and real AI travel assistant.

The chat endpoint uses the OpenAI Responses API. Keep your API key on this backend; never put it in Flutter/mobile code.

## Endpoints

- `GET /health`
- `POST /translate`
- `POST /chat`

Request:

```json
{
  "text": "where is the hotel",
  "source": "en",
  "target": "si"
}
```

Response:

```json
{
  "translated_text": "හෝටලය කොහෙද?",
  "source": "en",
  "target": "si",
  "found": true
}
```

## Run Locally

```powershell
python backend\translation_server.py
```

For Flutter desktop or web local testing:

```powershell
flutter run --dart-define=TRANSLATION_API_URL=http://127.0.0.1:8000/translate
```

For real AI chat on desktop/web:

```powershell
$env:OPENAI_API_KEY="your_api_key_here"
$env:OPENAI_MODEL="gpt-5-mini"
python backend\translation_server.py
flutter run `
  --dart-define=TRANSLATION_API_URL=http://127.0.0.1:8000/translate `
  --dart-define=AI_CHAT_API_URL=http://127.0.0.1:8000/chat
```

For Android emulator, the Flutter default is already:

```text
http://10.0.2.2:8000/translate
http://10.0.2.2:8000/chat
```

## Chat Behavior

The AI assistant is instructed to answer only Sri Lanka tourism questions. It can use OpenAI web search for current travel information when `ENABLE_WEB_SEARCH` is true.

Environment variables:

- `OPENAI_API_KEY`: required for `/chat`
- `OPENAI_MODEL`: optional, defaults to `gpt-5-mini`
- `ENABLE_WEB_SEARCH`: optional, defaults to `true`

## Platform Backend

The new platform backend adds:

- user/customer data storage
- OTP auth flow starter
- admin dashboard
- places manager
- safety alerts manager
- analytics endpoints

See:

- [backend/platform/README.md](</C:/Users/U S E R/tourist_guide/backend/platform/README.md>)
- [docs/sd_travel_guide_admin_stack.md](</C:/Users/U S E R/tourist_guide/docs/sd_travel_guide_admin_stack.md>)
