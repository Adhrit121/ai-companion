import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:system_info2/system_info2.dart';

class ModelSpec {
  final String id;
  final String label;
  final String filename;
  final String downloadUrl;
  final int approxSizeMb;
  final int minRamMb;

  const ModelSpec({
    required this.id,
    required this.label,
    required this.filename,
    required this.downloadUrl,
    required this.approxSizeMb,
    required this.minRamMb,
  });
}

/// Model tiers, smallest to largest. Swap URLs for whichever GGUF builds
/// you want to host/mirror (e.g. a Hugging Face repo you control).
class ModelCatalog {
  static const tiny = ModelSpec(
    id: 'tinyllama-1.1b',
    label: 'TinyLlama 1.1B (Q4_K_M)',
    filename: 'tinyllama-1.1b-q4_k_m.gguf',
    downloadUrl:
        'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
    approxSizeMb: 670,
    minRamMb: 0,
  );

  static const small = ModelSpec(
    id: 'smollm2-1.7b',
    label: 'SmolLM2 1.7B (Q4_K_M)',
    filename: 'smollm2-1.7b-q4_k_m.gguf',
    downloadUrl:
        'https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF/resolve/main/smollm2-1.7b-instruct-q4_k_m.gguf',
    approxSizeMb: 1050,
    minRamMb: 3500,
  );

  static const medium = ModelSpec(
    id: 'qwen2.5-3b',
    label: 'Qwen2.5 3B Instruct (Q4_K_M)',
    filename: 'qwen2.5-3b-q4_k_m.gguf',
    downloadUrl:
        'https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf',
    approxSizeMb: 1930,
    minRamMb: 6000,
  );

  static const large = ModelSpec(
    id: 'gemma2-5b-ish', // placeholder tier: substitute the 5B GGUF you prefer
    label: 'Gemma-class ~5B (Q4_K_M)',
    filename: 'gemma-5b-q4_k_m.gguf',
    downloadUrl:
        'https://huggingface.co/google/gemma-2-9b-it-GGUF/resolve/main/gemma-2-9b-it-Q4_K_M.gguf',
    approxSizeMb: 3200,
    minRamMb: 8000,
  );

  static const all = [tiny, small, medium, large];
}

class RamService {
  /// Returns total device RAM in MB. Falls back to a conservative
  /// estimate if detection fails on a given device/OS combo.
  static Future<int> getTotalRamMb() async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        // androidInfo doesn't expose RAM directly on all versions;
        // system_info2 is the more reliable cross-check.
        final sysRamBytes = SysInfo.getTotalPhysicalMemory();
        if (sysRamBytes > 0) return (sysRamBytes / (1024 * 1024)).round();
        // If system_info2 fails, assume mid-range as a safe default.
        return 4000;
      }
      final sysRamBytes = SysInfo.getTotalPhysicalMemory();
      return (sysRamBytes / (1024 * 1024)).round();
    } catch (_) {
      return 3000; // conservative default: assume a lower-end device
    }
  }

  /// Chooses the largest model whose minRamMb requirement the device meets,
  /// leaving headroom for the OS and the app itself.
  static Future<ModelSpec> recommendModel() async {
    final ramMb = await getTotalRamMb();
    // Only use RAM above ~1.5GB reserved for OS/app as the "available" pool.
    final usableRam = ramMb - 1500;
    ModelSpec chosen = ModelCatalog.tiny;
    for (final spec in ModelCatalog.all) {
      if (usableRam >= spec.minRamMb) chosen = spec;
    }
    return chosen;
  }
}
