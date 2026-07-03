import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/llm_service.dart';
import '../services/ram_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ModelSpec? _spec;

  @override
  void initState() {
    super.initState();
    LlmService.instance.pickModelForDevice().then((s) => setState(() => _spec = s));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Local AI Model',
            children: [
              _row('Active model', _spec?.label ?? 'Detecting...'),
              _row('Size on device', '${_spec?.approxSizeMb ?? '—'} MB'),
              _row('Runs', 'Fully on-device (no cloud calls)'),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Privacy',
            children: const [
              Text(
                'All conversations, memories, and companion profiles are stored '
                'locally in this app\'s SQLite database. Nothing is uploaded.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Data',
            children: [
              _actionRow('Export memories & chat history', Icons.upload_file_rounded, () {}),
              _actionRow('Import backup', Icons.download_rounded, () {}),
              _actionRow('Delete all data', Icons.delete_forever_rounded, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionRow(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.purple),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
