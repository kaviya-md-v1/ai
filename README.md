# CIPHER.AI — Kaviya's Hacker Terminal Assistant

A Matrix/Cyberpunk-themed Flutter AI assistant with STT, TTS, and Sinhala street-slang persona.

---

## 📁 Project Structure

```
lib/
├── main.dart                        # Entry point, app loader, routing
├── theme/
│   └── app_theme.dart               # All colors, fonts, ThemeData
├── models/
│   └── chat_message.dart            # Message data model
├── services/
│   ├── ai_service.dart              # OpenAI + Gemini API (switchable)
│   ├── speech_service.dart          # Speech-to-Text (STT)
│   └── tts_service.dart             # Text-to-Speech (TTS)
├── screens/
│   ├── chat_screen.dart             # Main terminal chat UI
│   └── settings_screen.dart         # API key + provider config
└── widgets/
    ├── chat_bubble.dart             # Message bubble (user + AI)
    ├── typing_text_widget.dart      # Typewriter animation
    └── scanline_overlay.dart        # CRT scanline effect
```

---

## 🚀 Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure API key

**Option A — .env file (recommended for dev):**
Edit the `.env` file in the project root:
```
AI_PROVIDER=gemini          # or "openai"
GEMINI_API_KEY=AIza...      # from aistudio.google.com (free tier available)
OPENAI_API_KEY=sk-...       # from platform.openai.com
```

**Option B — In-app settings:**
Launch the app → tap the ⚙️ gear icon → enter your key → Save.
Keys are stored securely in SharedPreferences on-device.

### 3. Android permissions
Replace your `android/app/src/main/AndroidManifest.xml` with the contents
of `android_manifest_instructions.xml` (or manually add the permissions listed there).

### 4. iOS permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>CIPHER needs the mic for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>CIPHER uses speech recognition for Sinhala STT</string>
```

### 5. Fonts
Download `VT323-Regular.ttf` from Google Fonts and place it at:
```
assets/fonts/VT323-Regular.ttf
```
(Share Tech Mono loads via `google_fonts` package — no download needed.)

### 6. Run
```bash
flutter run
```

---

## 🎙️ Features

| Feature | Details |
|---|---|
| **AI Chat** | OpenAI GPT-4o-mini or Google Gemini 1.5 Flash |
| **Persona** | Street Sinhala slang, loyal to "Kaviya" |
| **STT** | Mic button → speaks in Sinhala (si-LK locale) |
| **TTS** | AI replies spoken aloud (Sinhala voice if available) |
| **Typewriter FX** | AI text animates character-by-character |
| **Boot animation** | Terminal boot sequence on launch |
| **Scanlines** | Subtle CRT scanline overlay |
| **Settings** | Switch provider + enter key at runtime |

---

## 🔑 Getting API Keys (Free Options)

- **Gemini** (recommended — has a free tier):  
  https://aistudio.google.com → Get API Key

- **OpenAI**:  
  https://platform.openai.com → API Keys

---

## 🛠️ Customization

### Change AI persona
Edit `_kSystemPrompt` in `lib/services/ai_service.dart`

### Change colors
Edit hex values in `lib/theme/app_theme.dart`

### Change typing speed
In `chat_screen.dart`, find `charDelayMs: 14` and adjust (lower = faster)

### Change TTS voice speed
In `tts_service.dart`, adjust `setSpeechRate(0.45)` (0.0–1.0)
