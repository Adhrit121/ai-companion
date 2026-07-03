import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/companion.dart';
import '../models/memory.dart';
import '../services/db_service.dart';

class MemoryScreen extends StatefulWidget {
  final Companion companion;
  const MemoryScreen({super.key, required this.companion});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  List<MemoryFact> _memories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await DbService.instance.getAllMemories(widget.companion.id);
    setState(() => _memories = m);
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'birthday':
        return Icons.cake_rounded;
      case 'nickname':
        return Icons.badge_rounded;
      case 'preference':
        return Icons.favorite_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Memory Timeline', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Everything ${widget.companion.name} remembers about you',
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(
            child: _memories.isEmpty
                ? const Center(
                    child: Text('No memories yet — they\'ll build up as you chat.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    itemCount: _memories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final m = _memories[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration(),
                        child: Row(
                          children: [
                            Icon(_iconFor(m.category), color: AppColors.purple),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.content),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${m.category} · ${m.createdAt.toLocal().toString().split('.').first}',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              onPressed: () async {
                                await DbService.instance.deleteMemory(m.id);
                                _load();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
