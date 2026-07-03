# AI Companion (offline)

A Flutter app scaffold implementing the core architecture from the spec:
character creator → memory manager (SQLite) → on-device GGUF LLM → chat.

## How to get an APK

1. Push this repo to GitHub.
2. Go to the **Actions** tab → the `Build APK` workflow runs automatically on
   push to `main` (or trigger it manually with "Run workflow").
3. When it finishes, download the `ai-companion-apk` artifact from the run
   page — that's your installable `app-release.apk`.

The `android/` and `ios/` platform folders are **not** committed. The
workflow runs `flutter create --platforms=android .` first, which generates
them fresh without touching your `lib/` or `pubspec.yaml`. This keeps the
repo clean and avoids committing generated Gradle files.

## What's actually implemented

- Full dark Material 3 UI (`#090909` background, `#181818` cards, purple/
  crimson accents) matching the spec
- Character creator: name → occupation → personality → interests →
  relationship style, all as tappable catalog cards
- System-prompt builder that regenerates from the selected traits
- SQLite memory manager: companions, chat history, and a memory-facts
  table, with a simple keyword-overlap relevance search that injects only
  the top-N relevant memories into each prompt (not the full history)
- Basic heuristic memory extraction (birthday, "remember", "I love",
  nicknames, etc.) — swap this for a small classifier prompt for better
  recall quality
- RAM detection (`system_info2`) that picks a model tier — TinyLlama 1.1B,
  SmolLM2 1.7B, Qwen2.5 3B, or a ~5B Gemma-class model — and a first-launch
  screen that downloads the chosen GGUF with a progress bar
- Chat screen with streaming responses, typing indicator, and the full
  retrieve → inject → generate → store pipeline from the spec
- Memory timeline, Gallery, and Settings screens with bottom navigation
- Home screen with affection %, greeting, and relationship stage

## What's a placeholder, on purpose

- **Character/occupation art.** I can't generate a production illustration
  set here, so avatars are gradient + emoji placeholders
  (`lib/widgets/companion_avatar.dart`). Drop real art into
  `assets/images/` and swap the widget to use it — the data model
  (`Companion.avatarPath`, `CatalogItem`) is already built to support it.
- **Model download URLs** in `lib/services/ram_service.dart` point at
  example Hugging Face GGUF repos. Confirm licenses/hosting for each model
  you ship, or mirror them somewhere you control — direct HF downloads can
  be slow/rate-limited for end users.
- **Memory retrieval** is keyword overlap, not embeddings. It works but
  isn't as good as a real vector search. `MemoryFact.relevanceTo()` is the
  one function to upgrade if you want that.
- **Voice (TTS/STT), outfits, virtual gifts, multiple companions UI,
  import/export** are not built — the DB schema and screen structure leave
  room for them but they're not in this pass.

## The one real risk: on-device inference

Chat generation goes through `fllama`, a Flutter FFI plugin around
llama.cpp, in `lib/services/llm_service.dart`. It's pulled as a **git
dependency** directly from `github.com/Telosnex/fllama` (its pub.dev
listing isn't reliably versioned, so pinning a pub.dev version number
fails dependency resolution — that's fixed now by using the git source,
which is also the method the maintainers themselves recommend).

This is the correct approach architecturally, but I have no network access
in my sandbox, so **I could not actually run a build here to confirm the
native Android toolchain compiles clean** on GitHub's runners against
`main` of that repo.

If the Actions build fails specifically at the `flutter build apk` step:
- Check the Actions log for the actual native/CMake error
- Pin `ref:` in `pubspec.yaml` to a specific commit SHA instead of `main`
  if upstream changes break the build — find a known-good commit from
  their GitHub Actions/CI history if they have one
- `fllama`'s GitHub repo has an example Android app — diffing its
  `android/build.gradle` NDK/CMake settings against what `flutter create`
  generates is usually the fix if there's a version mismatch

Everything else (UI, DB, memory pipeline, character creator, RAM-based
model selection) is plain Dart/Flutter with no native build step, so it
should compile on the first try.

## Local development

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter run
```
