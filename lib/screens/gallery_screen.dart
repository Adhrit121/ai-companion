import 'package:flutter/material.dart';
import '../theme.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gallery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Illustrations, outfits, and your uploaded images',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined, size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text(
                    'No illustration packs installed yet.\n'
                    'Drop art into assets/images/ and wire it up here,\n'
                    'or add a downloadable pack later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
