import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme.dart';
import '../services/llm_service.dart';
import '../services/ram_service.dart';

class ModelSetupScreen extends StatefulWidget {
  final VoidCallback onReady;
  const ModelSetupScreen({super.key, required this.onReady});

  @override
  State<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends State<ModelSetupScreen> {
  bool _checking = true;
  bool _downloading = false;
  double _progress = 0;
  ModelSpec? _spec;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    _spec = await LlmService.instance.pickModelForDevice();
    final ready = await LlmService.instance.isModelDownloaded();
    setState(() => _checking = false);
    if (ready) {
      widget.onReady();
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      await LlmService.instance.downloadModel(
        onProgress: (p) => setState(() => _progress = p),
      );
      widget.onReady();
    } catch (e) {
      setState(() {
        _downloading = false;
        _error = 'Download failed. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.accentGradient(),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.psychology_alt_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Setting up your companion\'s brain',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                'Based on your device\'s memory, we picked ${_spec?.label ?? "a model"} '
                '(~${_spec?.approxSizeMb ?? 0} MB). It downloads once, runs fully offline, '
                'and no conversation ever leaves your device.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              if (_downloading)
                Column(
                  children: [
                    LinearPercentIndicator(
                      lineHeight: 14,
                      percent: _progress.clamp(0, 1),
                      backgroundColor: AppColors.card,
                      progressColor: AppColors.purple,
                      barRadius: const Radius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    Text('${(_progress * 100).toStringAsFixed(0)}%'),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _startDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Download & Continue'),
                ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.crimson)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
