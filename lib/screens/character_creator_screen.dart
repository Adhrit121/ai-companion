import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../models/companion.dart';

class CharacterCreatorScreen extends StatefulWidget {
  final void Function(Companion) onDone;
  const CharacterCreatorScreen({super.key, required this.onDone});

  @override
  State<CharacterCreatorScreen> createState() => _CharacterCreatorScreenState();
}

class _CharacterCreatorScreenState extends State<CharacterCreatorScreen> {
  final _nameController = TextEditingController();
  String? _occupationId;
  final Set<String> _personalityIds = {};
  final Set<String> _interestIds = {};
  final Set<String> _relationshipStyleIds = {};
  int _step = 0;

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _occupationId != null;
      case 2:
        return _personalityIds.isNotEmpty;
      default:
        return true;
    }
  }

  void _finish() {
    final companion = Companion(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      occupationId: _occupationId!,
      personalityIds: _personalityIds.toList(),
      interestIds: _interestIds.toList(),
      relationshipStyleIds: _relationshipStyleIds.toList(),
    );
    widget.onDone(companion);
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _nameStep(),
      _catalogGridStep(
        title: 'Choose an occupation',
        items: Occupations.all,
        selected: {if (_occupationId != null) _occupationId!},
        multi: false,
        onToggle: (id) => setState(() => _occupationId = id),
      ),
      _catalogGridStep(
        title: 'Pick personality traits',
        items: Personalities.all,
        selected: _personalityIds,
        multi: true,
        onToggle: (id) => setState(() =>
            _personalityIds.contains(id) ? _personalityIds.remove(id) : _personalityIds.add(id)),
      ),
      _catalogGridStep(
        title: 'Interests (optional)',
        items: Interests.all,
        selected: _interestIds,
        multi: true,
        onToggle: (id) => setState(
            () => _interestIds.contains(id) ? _interestIds.remove(id) : _interestIds.add(id)),
      ),
      _catalogGridStep(
        title: 'Relationship style (optional)',
        items: RelationshipStyles.all,
        selected: _relationshipStyleIds,
        multi: true,
        onToggle: (id) => setState(() => _relationshipStyleIds.contains(id)
            ? _relationshipStyleIds.remove(id)
            : _relationshipStyleIds.add(id)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Create your companion')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / steps.length,
              backgroundColor: AppColors.card,
              color: AppColors.purple,
            ),
            const SizedBox(height: 20),
            Expanded(child: steps[_step]),
            Row(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _canContinue
                      ? () {
                          if (_step == steps.length - 1) {
                            _finish();
                          } else {
                            setState(() => _step++);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_step == steps.length - 1 ? 'Meet ${_nameController.text}' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What\'s their name?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'e.g. Luna, Alice, Scarlett...',
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _catalogGridStep({
    required String title,
    required List<CatalogItem> items,
    required Set<String> selected,
    required bool multi,
    required void Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final isSelected = selected.contains(item.id);
              return GestureDetector(
                onTap: () => onToggle(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.purple : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 12)]
                        : [],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 30)),
                      const Spacer(),
                      Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      if (item.description.isNotEmpty)
                        Text(item.description,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
