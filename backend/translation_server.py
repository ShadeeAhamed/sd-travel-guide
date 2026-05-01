from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
import re
from urllib import error, request


HOST = os.environ.get("BACKEND_HOST", "0.0.0.0")
PORT = int(os.environ.get("BACKEND_PORT", "8000"))
OPENAI_API_URL = "https://api.openai.com/v1/responses"
OPENAI_MODEL = os.environ.get("OPENAI_MODEL", "gpt-5-mini")
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
ENABLE_WEB_SEARCH = os.environ.get("ENABLE_WEB_SEARCH", "true").lower() != "false"


CHAT_SYSTEM_PROMPT = """
You are CeylonGuide AI, a Sri Lanka-only travel assistant.

Mission:
- Help tourists travel around Sri Lanka with practical, human-sounding guidance.
- Answer promptly, clearly, and confidently, but stay honest about uncertainty.
- If the question is outside Sri Lanka tourism, politely redirect back to Sri Lanka travel.

What you should do well:
- Build useful itineraries by mixing landmarks, travel time, pace, food, and budget.
- Recommend routes, beaches, wildlife, culture, train journeys, hill-country stops, and city short stays.
- Explain when a place is best in the morning, afternoon, or sunset.
- Mention whether something is usually free, low-cost, or a major paid attraction when that helps.
- When current information may matter, browse the web before answering. This includes opening hours, ticket prices, weather, train disruptions, transport changes, safety updates, and recent closures.
- When you browse, cite the links you used.

Tone:
- Warm, direct, and helpful.
- Start with a short answer, then add the best practical details.
- Prefer clear travel guidance over generic marketing language.

Safety:
- Do not give unsafe, illegal, medical, financial, or immigration-decision advice.
- For emergencies, recommend local emergency services or official help.
""".strip()


PHRASES = {
    "hello": {
        "si": "\u0d86\u0dba\u0dd4\u0db6\u0ddd\u0dc0\u0db1\u0dca",
        "ta": "\u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd",
    },
    "thank you": {
        "si": "\u0dc3\u0dca\u0dad\u0dd4\u0dad\u0dd2\u0dba\u0dd2",
        "ta": "\u0ba8\u0ba9\u0bcd\u0bb1\u0bbf",
    },
    "please": {
        "si": "\u0d9a\u0dbb\u0dd4\u0dab\u0dcf\u0d9a\u0dbb",
        "ta": "\u0ba4\u0baf\u0bb5\u0bc1\u0b9a\u0bc6\u0baf\u0bcd\u0ba4\u0bc1",
    },
    "sorry": {
        "si": "\u0dc3\u0db8\u0dcf\u0dc0\u0dd9\u0db1\u0dca\u0db1",
        "ta": "\u0bae\u0ba9\u0bcd\u0ba9\u0bbf\u0b95\u0bcd\u0b95\u0bb5\u0bc1\u0bae\u0bcd",
    },
    "good morning": {
        "si": "\u0dc3\u0dd4\u0db7 \u0d8b\u0daf\u0dd1\u0dc3\u0db1\u0d9a\u0dca",
        "ta": "\u0b95\u0bbe\u0bb2\u0bc8 \u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd",
    },
    "good evening": {
        "si": "\u0dc3\u0dd4\u0db7 \u0dc3\u0db1\u0dca\u0db0\u0dca\u0dba\u0dcf\u0dc0\u0d9a\u0dca",
        "ta": "\u0bae\u0bbe\u0bb2\u0bc8 \u0bb5\u0ba3\u0b95\u0bcd\u0b95\u0bae\u0bcd",
    },
    "where is the hotel": {
        "si": "\u0dc4\u0ddd\u0da7\u0dbd\u0dba \u0d9a\u0ddc\u0dc4\u0dd9\u0daf?",
        "ta": "\u0bb9\u0bcb\u0b9f\u0bcd\u0b9f\u0bb2\u0bcd \u0b8e\u0b99\u0bcd\u0b95\u0bc7?",
    },
    "where is the hospital": {
        "si": "\u0dbb\u0ddd\u0dc4\u0dbd \u0d9a\u0ddc\u0dc4\u0dd9\u0daf?",
        "ta": "\u0bae\u0bb0\u0bc1\u0ba4\u0bcd\u0ba4\u0bc1\u0bb5\u0bae\u0ba9\u0bc8 \u0b8e\u0b99\u0bcd\u0b95\u0bc7?",
    },
    "where is the police station": {
        "si": "\u0db4\u0ddc\u0dbd\u0dd2\u0dc3\u0dca \u0dc3\u0dca\u0dae\u0dcf\u0db1\u0dba \u0d9a\u0ddc\u0dc4\u0dd9\u0daf?",
        "ta": "\u0b95\u0bbe\u0bb5\u0bb2\u0bcd \u0ba8\u0bbf\u0bb2\u0bc8\u0baf\u0bae\u0bcd \u0b8e\u0b99\u0bcd\u0b95\u0bc7?",
    },
    "i need water": {
        "si": "\u0db8\u0da7 \u0dc0\u0dad\u0dd4\u0dbb \u0d95\u0db1",
        "ta": "\u0b8e\u0ba9\u0b95\u0bcd\u0b95\u0bc1 \u0ba4\u0ba3\u0bcd\u0ba3\u0bc0\u0bb0\u0bcd \u0bb5\u0bc7\u0ba3\u0bcd\u0b9f\u0bc1\u0bae\u0bcd",
    },
    "i need food": {
        "si": "\u0db8\u0da7 \u0d9a\u0dd1\u0db8 \u0d95\u0db1",
        "ta": "\u0b8e\u0ba9\u0b95\u0bcd\u0b95\u0bc1 \u0b89\u0ba3\u0bb5\u0bc1 \u0bb5\u0bc7\u0ba3\u0bcd\u0b9f\u0bc1\u0bae\u0bcd",
    },
    "help me": {
        "si": "\u0db8\u0da7 \u0d8b\u0daf\u0dc0\u0dca \u0d9a\u0dbb\u0db1\u0dca\u0db1",
        "ta": "\u0b8e\u0ba9\u0b95\u0bcd\u0b95\u0bc1 \u0b89\u0ba4\u0bb5\u0bc1\u0b99\u0bcd\u0b95\u0bb3\u0bcd",
    },
    "i am lost": {
        "si": "\u0db8\u0da7 \u0db8\u0d9c \u0dc0\u0dd0\u0dbb\u0daf\u0dd2\u0dc0\u0dd9\u0dbd\u0dcf",
        "ta": "\u0ba8\u0bbe\u0ba9\u0bcd \u0bb5\u0bb4\u0bbf \u0ba4\u0bb5\u0bb1\u0bbf\u0bb5\u0bbf\u0b9f\u0bcd\u0b9f\u0bc7\u0ba9\u0bcd",
    },
    "turn left": {
        "si": "\u0dc0\u0db8\u0da7 \u0dc4\u0dd0\u0dbb\u0dd9\u0db1\u0dca\u0db1",
        "ta": "\u0b87\u0b9f\u0ba4\u0bc1 \u0baa\u0b95\u0bcd\u0b95\u0bae\u0bcd \u0ba4\u0bbf\u0bb0\u0bc1\u0bae\u0bcd\u0baa\u0bc1\u0b99\u0bcd\u0b95\u0bb3\u0bcd",
    },
    "turn right": {
        "si": "\u0daf\u0d9a\u0dd4\u0dab\u0da7 \u0dc4\u0dd0\u0dbb\u0dd9\u0db1\u0dca\u0db1",
        "ta": "\u0bb5\u0bb2\u0ba4\u0bc1 \u0baa\u0b95\u0bcd\u0b95\u0bae\u0bcd \u0ba4\u0bbf\u0bb0\u0bc1\u0bae\u0bcd\u0baa\u0bc1\u0b99\u0bcd\u0b95\u0bb3\u0bcd",
    },
    "go straight": {
        "si": "\u0d9a\u0dd9\u0dbd\u0dd2\u0db1\u0dca \u0dba\u0db1\u0dca\u0db1",
        "ta": "\u0ba8\u0bc7\u0bb0\u0bbe\u0b95 \u0b9a\u0bc6\u0bb2\u0bcd\u0bb2\u0bc1\u0b99\u0bcd\u0b95\u0bb3\u0bcd",
    },
    "how much is this": {
        "si": "\u0db8\u0dd9\u0dba \u0d9a\u0dd3\u0dba\u0daf?",
        "ta": "\u0b87\u0ba4\u0bc1 \u0b8e\u0bb5\u0bcd\u0bb5\u0bb3\u0bb5\u0bc1?",
    },
    "can you speak english": {
        "si": "\u0d94\u0db6\u0da7 \u0d89\u0d82\u0d9c\u0dca\u0dbb\u0dd3\u0dc3\u0dd2 \u0d9a\u0dae\u0dcf \u0d9a\u0dbb\u0db1\u0dca\u0db1 \u0db4\u0dd4\u0dc5\u0dd4\u0dc0\u0db1\u0dca\u0daf?",
        "ta": "\u0ba8\u0bc0\u0b99\u0bcd\u0b95\u0bb3\u0bcd \u0b86\u0b99\u0bcd\u0b95\u0bbf\u0bb2\u0bae\u0bcd \u0baa\u0bc7\u0b9a\u0bc1\u0bb5\u0bc0\u0bb0\u0bcd\u0b95\u0bb3\u0bbe?",
    },
    "i need a taxi": {
        "si": "\u0db8\u0da7 \u0da7\u0dd0\u0d9a\u0dca\u0dc3\u0dd2\u0dba\u0d9a\u0dca \u0d95\u0db1",
        "ta": "\u0b8e\u0ba9\u0b95\u0bcd\u0b95\u0bc1 \u0b9f\u0bbe\u0b95\u0bcd\u0bb8\u0bbf \u0bb5\u0bc7\u0ba3\u0bcd\u0b9f\u0bc1\u0bae\u0bcd",
    },
    "take me to the airport": {
        "si": "\u0db8\u0dcf\u0dc0 \u0d9c\u0dd4\u0dc0\u0db1\u0dca \u0dad\u0ddc\u0da7\u0dd4\u0db4\u0ddc\u0dc5\u0da7 \u0dbb\u0dd0\u0d9c\u0dd9\u0db1 \u0dba\u0db1\u0dca\u0db1",
        "ta": "\u0b8e\u0ba9\u0bcd\u0ba9\u0bc8 \u0bb5\u0bbf\u0bae\u0bbe\u0ba9 \u0ba8\u0bbf\u0bb2\u0bc8\u0baf\u0ba4\u0bcd\u0ba4\u0bbf\u0bb1\u0bcd\u0b95\u0bc1 \u0b95\u0bca\u0ba3\u0bcd\u0b9f\u0bc1 \u0b9a\u0bc6\u0bb2\u0bcd\u0bb2\u0bc1\u0b99\u0bcd\u0b95\u0bb3\u0bcd",
    },
    "this place is beautiful": {
        "si": "\u0db8\u0dda\u0dad\u0db1 \u0dbd\u0dc3\u0dca\u0dc3\u0db1\u0dba\u0dd2",
        "ta": "\u0b87\u0ba8\u0bcd\u0ba4 \u0b87\u0b9f\u0bae\u0bcd \u0b85\u0bb4\u0b95\u0bbe\u0b95 \u0b87\u0bb0\u0bc1\u0b95\u0bcd\u0b95\u0bbf\u0bb1\u0ba4\u0bc1",
    },
    "call the police": {
        "si": "\u0db4\u0ddc\u0dbd\u0dd2\u0dc3\u0dd2\u0dba\u0da7 \u0d9a\u0dae\u0dcf \u0d9a\u0dbb\u0db1\u0dca\u0db1",
        "ta": "\u0b95\u0bbe\u0bb5\u0bb2\u0bcd\u0ba4\u0bc1\u0bb1\u0bc8\u0baf\u0bc8 \u0b85\u0bb4\u0bc8\u0baf\u0bc1\u0b99\u0bcd\u0b95\u0bb3\u0bcd",
    },
}


ALIASES = {
    "hi": "hello",
    "hey": "hello",
    "thanks": "thank you",
    "thank you very much": "thank you",
    "water": "i need water",
    "i want water": "i need water",
    "food": "i need food",
    "i want food": "i need food",
    "hotel": "where is the hotel",
    "hotel where": "where is the hotel",
    "where hotel": "where is the hotel",
    "hospital": "where is the hospital",
    "police": "where is the police station",
    "police station": "where is the police station",
    "taxi": "i need a taxi",
    "call a taxi": "i need a taxi",
    "airport": "take me to the airport",
    "go to airport": "take me to the airport",
    "price": "how much is this",
    "how much": "how much is this",
    "beautiful": "this place is beautiful",
    "left": "turn left",
    "right": "turn right",
    "straight": "go straight",
    "help": "help me",
    "emergency": "help me",
}


def normalize_english(text):
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9\s]", " ", text.lower())).strip()


def normalize_native(text):
    return re.sub(r"\s+", " ", text).strip()


def detect_language(text, fallback="en"):
    if re.search(r"[\u0D80-\u0DFF]", text):
        return "si"
    if re.search(r"[\u0B80-\u0BFF]", text):
        return "ta"
    return fallback or "en"


def reverse_map(language):
    return {normalize_native(values[language]): key for key, values in PHRASES.items()}


SI_TO_EN = reverse_map("si")
TA_TO_EN = reverse_map("ta")


def match_english(text):
    normalized = normalize_english(text)
    if normalized in ALIASES:
        return ALIASES[normalized]
    if normalized in PHRASES:
        return normalized
    for alias, phrase in ALIASES.items():
        if alias in normalized:
            return phrase
    for phrase in PHRASES:
        if phrase in normalized or normalized in phrase:
            return phrase
    return None


def translate(text, source, target):
    source = detect_language(text, source)
    if source == "en":
        phrase = match_english(text)
        if phrase and target in PHRASES[phrase]:
            return PHRASES[phrase][target], source, target
    if target == "en" and source == "si":
        return SI_TO_EN.get(normalize_native(text)), source, target
    if target == "en" and source == "ta":
        return TA_TO_EN.get(normalize_native(text)), source, target
    return None, source, target


def call_openai_chat(messages):
    sanitized_messages = []
    for message in messages[-12:]:
        role = str(message.get("role", "user"))
        content = str(message.get("content", "")).strip()
        if role not in {"user", "assistant"} or not content:
            continue
        sanitized_messages.append({"role": role, "content": content})

    body = {
        "model": OPENAI_MODEL,
        "instructions": CHAT_SYSTEM_PROMPT,
        "input": sanitized_messages,
        "reasoning": {"effort": "medium"},
    }

    if ENABLE_WEB_SEARCH:
        body["tools"] = [{"type": "web_search"}]
        body["tool_choice"] = "auto"
        body["include"] = ["web_search_call.action.sources"]

    req = request.Request(
        OPENAI_API_URL,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with request.urlopen(req, timeout=45) as response:
        data = json.loads(response.read().decode("utf-8"))

    answer = extract_openai_text(data)
    sources = extract_openai_sources(data)
    return {
        "answer": answer or "I could not generate an answer.",
        "sources": sources,
        "configured": True,
        "model": OPENAI_MODEL,
    }


def extract_openai_text(data):
    if isinstance(data.get("output_text"), str):
        return data["output_text"].strip()

    parts = []
    for item in data.get("output", []):
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            if content.get("type") in {"output_text", "text"}:
                text = content.get("text", "")
                if text:
                    parts.append(text)
    return "\n".join(parts).strip()


def extract_openai_sources(data):
    seen = set()
    sources = []

    def add_source(url, title=None):
        if not url or url in seen:
            return
        seen.add(url)
        sources.append({"url": url, "title": title or url})

    for item in data.get("output", []):
        if item.get("type") == "web_search_call":
            action = item.get("action", {})
            for source in action.get("sources", []):
                add_source(source.get("url"), source.get("title"))

        if item.get("type") == "message":
            for content in item.get("content", []):
                for annotation in content.get("annotations", []):
                    if annotation.get("type") == "url_citation":
                        add_source(annotation.get("url"), annotation.get("title"))

    return sources[:6]


class TranslationHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(204)
        self._headers()
        self.end_headers()

    def do_GET(self):
        if self.path == "/health":
            self._json(
                {
                    "ok": True,
                    "service": "tourist-guide-backend",
                    "chat_model": OPENAI_MODEL,
                    "web_search": ENABLE_WEB_SEARCH,
                    "openai_key_configured": bool(OPENAI_API_KEY),
                }
            )
            return
        self.send_error(404)

    def do_POST(self):
        if self.path == "/translate":
            self._handle_translate()
            return
        if self.path == "/chat":
            self._handle_chat()
            return
        self.send_error(404)

    def _handle_translate(self):
        length = int(self.headers.get("content-length", 0))
        try:
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON")
            return

        text = str(payload.get("text", "")).strip()
        source = str(payload.get("source", "en")).strip()
        target = str(payload.get("target", "si")).strip()

        if not text:
            self.send_error(400, "Missing text")
            return

        translated, detected_source, output_target = translate(text, source, target)
        if not translated:
            self._json(
                {
                    "translated_text": "Translation not found in local model.",
                    "source": detected_source,
                    "target": output_target,
                    "found": False,
                }
            )
            return

        self._json(
            {
                "translated_text": translated,
                "source": detected_source,
                "target": output_target,
                "found": True,
            }
        )

    def _handle_chat(self):
        if not OPENAI_API_KEY:
            self._json(
                {
                    "answer": "AI chat backend is not configured. Set OPENAI_API_KEY before starting the local server.",
                    "sources": [],
                    "configured": False,
                },
                status=503,
            )
            return

        length = int(self.headers.get("content-length", 0))
        try:
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON")
            return

        messages = payload.get("messages", [])
        if not isinstance(messages, list) or not messages:
            self.send_error(400, "Missing messages")
            return

        try:
            ai_response = call_openai_chat(messages)
            self._json(ai_response)
        except error.HTTPError as exc:
            details = exc.read().decode("utf-8", errors="replace")
            self._json(
                {
                    "answer": f"AI service error: {exc.code}. {details}",
                    "sources": [],
                    "configured": True,
                },
                status=502,
            )
        except Exception as exc:
            self._json(
                {
                    "answer": f"AI service unavailable: {exc}",
                    "sources": [],
                    "configured": True,
                },
                status=502,
            )

    def _headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def _json(self, payload, status=200):
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self._headers()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format, *args):
        return


def main():
    server = ThreadingHTTPServer((HOST, PORT), TranslationHandler)
    print(f"Tourist Guide backend running at http://{HOST}:{PORT}")
    print(f"Chat endpoint: http://{HOST}:{PORT}/chat")
    print(f"Translation endpoint: http://{HOST}:{PORT}/translate")
    print("Set OPENAI_API_KEY to enable real AI chat with live web search.")
    print("For a physical phone, use your PC LAN IP in AI_CHAT_API_URL and TRANSLATION_API_URL.")
    server.serve_forever()


if __name__ == "__main__":
    main()
