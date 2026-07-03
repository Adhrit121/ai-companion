import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/companion.dart';
import '../widgets/companion_avatar.dart';

class HomeScreen extends StatelessWidget {
  final Companion companion;
  const HomeScreen({super.key, required this.companion});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(companion.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('${companion.affection}%',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          Text(_greeting(), style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Center(child: CompanionAvatar(companion: companion, size: 200)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"Welcome home."',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text(companion.relationshipStage,
                    style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
