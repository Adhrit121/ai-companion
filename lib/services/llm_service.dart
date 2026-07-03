import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ram_service.dart';

// fllama wraps llama.cpp via FFI and runs the GGUF model fully on-device,
// with no network calls at inference time.
import 'package:fllama/fllama.dart';

enum DownloadState { notStarted, downloading, ready, error }

class LlmService {
  LlmService._internal();
  static final LlmService instance = LlmService._internal();

  ModelSpec? _spec;
  DownloadState state = DownloadState.notStarted;
  double progress = 0.0;
  String? _modelPath;
  String? lastError;

  Future<String> get _modelsDir async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  /// Picks a model tier based on device RAM, and returns whether it's
  /// already downloaded.
  Future<ModelSpec> pickModelForDevice() async {
    _spec = await RamService.recommendModel();
    return _spec!;
  }

  Future<bool> isModelDownloaded() async {
    final spec = _spec ?? await pickModelForDevice();
    final path = '${await _modelsDir}/${spec.filename}';
    final file = File(path);
    if (await file.exists()) {
      _modelPath = path;
      state = DownloadState.ready;
      return true;
    }
    return false;
  }

  /// Downloads the chosen GGUF model with progress callbacks.
  /// Call this once after first install; the model then lives on-device
  /// permanently and every future chat runs fully offline.
  Future<void> downloadModel({required void Function(double progress) onProgress}) async {
    final spec = _spec ?? await pickModelForDevice();
    final path = '${await _modelsDir}/${spec.filename}';
    final file = File(path);

    if (await file.exists()) {
      state = DownloadState.ready;
      _modelPath = path;
      onProgress(1.0);
      return;
    }

    state = DownloadState.downloading;
    try {
      final request = http.Request('GET', Uri.parse(spec.downloadUrl));
      final response = await http.Client().send(request);
      final total = response.contentLength ?? (spec.approxSizeMb * 1024 * 1024);

      final sink = file.openWrite();
      int received = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        progress = received / total;
        onProgress(progress);
      }
      await sink.close();

      _modelPath = path;
      state = DownloadState.ready;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_model_id', spec.id);
    } catch (e) {
      state = DownloadState.error;
      lastError = e.toString();
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  /// Runs inference fully on-device via llama.cpp (through fllama).
  /// [systemPrompt] comes from Companion.buildSystemPrompt().
  /// [memoryContext] is the short list of retrieved relevant memories.
  /// [history] is the recent conversation turns.
  Stream<String> generateResponse({
    required String systemPrompt,
    required String memoryContext,
    required List<Map<String, String>> history, // [{role, content}]
    required String userMessage,
  }) async* {
    if (_modelPath == null) {
      throw StateError('Model not downloaded yet. Call downloadModel() first.');
    }

    final fullSystemPrompt = memoryContext.isNotEmpty
        ? '$systemPrompt\n\nImportant memory:\n$memoryContext\n\nRespond naturally, using this context only when relevant.'
        : systemPrompt;

    final request = OpenAiRequest(
      maxTokens: 512,
      messages: [
        Message(Role.system, fullSystemPrompt),
        ...history.map((m) => Message(
              m['role'] == 'user' ? Role.user : Role.assistant,
              m['content'] ?? '',
            )),
        Message(Role.user, userMessage),
      ],
      numGpuLayers: 0, // CPU inference for broad device compatibility
      modelPath: _modelPath!,
      temperature: 0.8,
      topP: 0.95,
    );

    final controller = StreamController<String>();
    fllamaChat(request, (response, responseJson, done) {
      controller.add(response);
      if (done) controller.close();
    });

    yield* controller.stream;
  }
}
