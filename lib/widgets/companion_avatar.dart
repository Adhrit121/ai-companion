import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/companion.dart';

/// Renders the companion's avatar. Uses an uploaded image if present,
/// otherwise a generated gradient + emoji avatar seeded from the
/// occupation, so every character at least looks visually distinct
/// until real illustration packs are dropped into assets/images/.
class CompanionAvatar extends StatelessWidget {
  final Companion companion;
  final double size;

  const CompanionAvatar({super.key, required this.companion, this.size = 80});

  @override
  Widget build(BuildContext context) {
    if (companion.avatarPath != null && File(companion.avatarPath!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(companion.avatarPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    final colors = _paletteFor(companion.occupationId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: colors.last.withOpacity(0.4), blurRadius: 16, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        companion.occupation.emoji,
        style: TextStyle(fontSize: size * 0.45),
      ),
    );
  }

  List<Color> _paletteFor(String seed) {
    final palettes = [
      [AppColors.purple, AppColors.crimson],
      [AppColors.cyan, AppColors.purple],
      [AppColors.crimson, const Color(0xFFFF8A5B)],
      [const Color(0xFF6C5CE7), AppColors.cyan],
    ];
    final idx = seed.codeUnits.fold<int>(0, (a, b) => a + b) % palettes.length;
    return palettes[idx];
  }
}
