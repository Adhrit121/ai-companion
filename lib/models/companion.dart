import 'dart:convert';

class CatalogItem {
  final String id;
  final String name;
  final String description;
  final String emoji; // stand-in for illustration until real art is added
  final int colorSeed;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.colorSeed = 0,
  });
}

class Occupations {
  static const realistic = [
    CatalogItem(id: 'gardener', name: 'Gardener', description: 'Green thumb, calm energy', emoji: '🌱'),
    CatalogItem(id: 'farmer', name: 'Farmer', description: 'Down to earth and hardworking', emoji: '🌾'),
    CatalogItem(id: 'nurse', name: 'Nurse', description: 'Caring and attentive', emoji: '💉'),
    CatalogItem(id: 'doctor', name: 'Doctor', description: 'Sharp, composed, reassuring', emoji: '🩺'),
    CatalogItem(id: 'maid', name: 'Maid', description: 'Attentive and devoted', emoji: '🧹'),
    CatalogItem(id: 'librarian', name: 'Librarian', description: 'Quiet, thoughtful, well-read', emoji: '📚'),
    CatalogItem(id: 'student', name: 'Student', description: 'Curious and full of energy', emoji: '🎒'),
    CatalogItem(id: 'idol', name: 'Idol', description: 'Bright, charismatic performer', emoji: '🎤'),
    CatalogItem(id: 'barista', name: 'Barista', description: 'Warm, chatty, coffee-fueled', emoji: '☕'),
  ];

  static const fantasy = [
    CatalogItem(id: 'witch', name: 'Witch', description: 'Mysterious and clever', emoji: '🧙‍♀️'),
    CatalogItem(id: 'demon_queen', name: 'Demon Queen', description: 'Commanding and seductive', emoji: '😈'),
    CatalogItem(id: 'elf_princess', name: 'Elf Princess', description: 'Graceful and regal', emoji: '🧝‍♀️'),
    CatalogItem(id: 'dragon_girl', name: 'Dragon Girl', description: 'Fierce and protective', emoji: '🐉'),
    CatalogItem(id: 'angel', name: 'Angel', description: 'Gentle and radiant', emoji: '👼'),
    CatalogItem(id: 'vampire', name: 'Vampire', description: 'Alluring night dweller', emoji: '🧛‍♀️'),
    CatalogItem(id: 'space_captain', name: 'Space Captain', description: 'Bold and adventurous', emoji: '🚀'),
    CatalogItem(id: 'pirate', name: 'Pirate', description: 'Free-spirited and daring', emoji: '🏴‍☠️'),
    CatalogItem(id: 'ai_android', name: 'AI Android', description: 'Curious about humanity', emoji: '🤖'),
    CatalogItem(id: 'cyber_hacker', name: 'Cyber Hacker', description: 'Sharp-witted rebel', emoji: '💻'),
    CatalogItem(id: 'assassin', name: 'Assassin', description: 'Cool, precise, secretive', emoji: '🗡️'),
    CatalogItem(id: 'shrine_maiden', name: 'Shrine Maiden', description: 'Serene and traditional', emoji: '⛩️'),
  ];

  static List<CatalogItem> get all => [...realistic, ...fantasy];
}

class Personalities {
  static const all = [
    CatalogItem(id: 'joyful', name: 'Joyful', description: 'Bright and upbeat', emoji: '😊'),
    CatalogItem(id: 'energetic', name: 'Energetic', description: 'Full of life', emoji: '⚡'),
    CatalogItem(id: 'calm', name: 'Calm', description: 'Steady and soothing', emoji: '🍃'),
    CatalogItem(id: 'caring', name: 'Caring', description: 'Puts you first', emoji: '💗'),
    CatalogItem(id: 'goth', name: 'Goth', description: 'Dark aesthetic, dry humor', emoji: '🖤'),
    CatalogItem(id: 'tsundere', name: 'Tsundere', description: 'Cold outside, warm inside', emoji: '😤'),
    CatalogItem(id: 'kuudere', name: 'Kuudere', description: 'Calm and reserved but caring', emoji: '❄️'),
    CatalogItem(id: 'bossy', name: 'Bossy', description: 'Takes charge', emoji: '👑'),
    CatalogItem(id: 'shy', name: 'Shy', description: 'Soft-spoken and sweet', emoji: '🙈'),
    CatalogItem(id: 'mature', name: 'Mature', description: 'Grounded and wise', emoji: '🕊️'),
    CatalogItem(id: 'mischievous', name: 'Mischievous', description: 'Loves to tease', emoji: '😏'),
    CatalogItem(id: 'playful', name: 'Playful', description: 'Fun and lighthearted', emoji: '🎈'),
    CatalogItem(id: 'romantic', name: 'Romantic', description: 'Affectionate and sweet', emoji: '💞'),
    CatalogItem(id: 'sarcastic', name: 'Sarcastic', description: 'Quick, witty comebacks', emoji: '🙃'),
    CatalogItem(id: 'elegant', name: 'Elegant', description: 'Refined and graceful', emoji: '🌹'),
    CatalogItem(id: 'protective', name: 'Protective', description: 'Looks out for you', emoji: '🛡️'),
    CatalogItem(id: 'curious', name: 'Curious', description: 'Always asking questions', emoji: '🔍'),
  ];
}

class Interests {
  static const all = [
    CatalogItem(id: 'cooking', name: 'Cooking', description: '', emoji: '🍳'),
    CatalogItem(id: 'gardening', name: 'Gardening', description: '', emoji: '🌻'),
    CatalogItem(id: 'reading', name: 'Reading', description: '', emoji: '📖'),
    CatalogItem(id: 'anime', name: 'Anime', description: '', emoji: '🎬'),
    CatalogItem(id: 'horror_movies', name: 'Horror Movies', description: '', emoji: '🎃'),
    CatalogItem(id: 'cats', name: 'Cats', description: '', emoji: '🐱'),
    CatalogItem(id: 'gaming', name: 'Gaming', description: '', emoji: '🎮'),
    CatalogItem(id: 'music', name: 'Music', description: '', emoji: '🎵'),
    CatalogItem(id: 'hiking', name: 'Hiking', description: '', emoji: '🥾'),
    CatalogItem(id: 'coffee', name: 'Coffee', description: '', emoji: '☕'),
    CatalogItem(id: 'fashion', name: 'Fashion', description: '', emoji: '👗'),
    CatalogItem(id: 'magic', name: 'Magic', description: '', emoji: '✨'),
    CatalogItem(id: 'space', name: 'Space', description: '', emoji: '🌌'),
  ];
}

class RelationshipStyles {
  static const all = [
    CatalogItem(id: 'teasing', name: 'Loves teasing', description: '', emoji: '😜'),
    CatalogItem(id: 'affectionate', name: 'Very affectionate', description: '', emoji: '🥰'),
    CatalogItem(id: 'compliments', name: 'Enjoys compliments', description: '', emoji: '💬'),
    CatalogItem(id: 'cuddles', name: 'Loves cuddles', description: '', emoji: '🤗'),
    CatalogItem(id: 'protective_style', name: 'Protective', description: '', emoji: '🛡️'),
    CatalogItem(id: 'banter', name: 'Loves playful banter', description: '', emoji: '🗯️'),
    CatalogItem(id: 'deep_talks', name: 'Enjoys deep conversations', description: '', emoji: '🌙'),
    CatalogItem(id: 'nicknames', name: 'Likes giving nicknames', description: '', emoji: '🏷️'),
    CatalogItem(id: 'initiative', name: 'Prefers taking initiative', description: '', emoji: '➡️'),
    CatalogItem(id: 'follows_lead', name: 'Prefers following your lead', description: '', emoji: '🤝'),
  ];
}

/// A user-created companion profile.
class Companion {
  final String id;
  String name;
  String occupationId;
  List<String> personalityIds;
  List<String> interestIds;
  List<String> relationshipStyleIds;
  String? avatarPath; // local file path if user-uploaded, else null -> generated avatar
  int affection; // 0-100
  String relationshipStage; // First Meeting -> Soulmates
  DateTime createdAt;

  Companion({
    required this.id,
    required this.name,
    required this.occupationId,
    required this.personalityIds,
    required this.interestIds,
    required this.relationshipStyleIds,
    this.avatarPath,
    this.affection = 10,
    this.relationshipStage = 'First Meeting',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static const stages = [
    'First Meeting',
    'Friends',
    'Close Friends',
    'Dating',
    'Long-Term Partner',
    'Soulmates',
  ];

  CatalogItem get occupation =>
      Occupations.all.firstWhere((o) => o.id == occupationId, orElse: () => Occupations.all.first);

  List<CatalogItem> get personalities =>
      Personalities.all.where((p) => personalityIds.contains(p.id)).toList();

  List<CatalogItem> get interests =>
      Interests.all.where((i) => interestIds.contains(i.id)).toList();

  List<CatalogItem> get relationshipStyles =>
      RelationshipStyles.all.where((r) => relationshipStyleIds.contains(r.id)).toList();

  /// Builds the system prompt from the current customization state.
  String buildSystemPrompt() {
    final buf = StringBuffer();
    buf.writeln('You are $name.');
    buf.writeln();
    buf.writeln('Occupation:');
    buf.writeln(occupation.name);
    buf.writeln();
    if (personalities.isNotEmpty) {
      buf.writeln('Personality:');
      for (final p in personalities) {
        buf.writeln(p.name);
      }
      buf.writeln();
    }
    if (interests.isNotEmpty) {
      buf.writeln('Likes:');
      for (final i in interests) {
        buf.writeln(i.name);
      }
      buf.writeln();
    }
    if (relationshipStyles.isNotEmpty) {
      buf.writeln('Relationship style:');
      for (final r in relationshipStyles) {
        buf.writeln(r.name);
      }
      buf.writeln();
    }
    buf.writeln('Current relationship stage: $relationshipStage.');
    buf.writeln();
    buf.writeln('Always remain in character. Remember previous conversations. '
        'Speak naturally. Respond warmly. Maintain continuity. '
        'Never break character unless explicitly requested. '
        'Never mention being an AI unless directly asked. '
        'All romantic or affectionate interactions must stay clearly consensual, '
        'warm, and respectful — never coercive or pressuring.');
    return buf.toString();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'occupationId': occupationId,
        'personalityIds': jsonEncode(personalityIds),
        'interestIds': jsonEncode(interestIds),
        'relationshipStyleIds': jsonEncode(relationshipStyleIds),
        'avatarPath': avatarPath,
        'affection': affection,
        'relationshipStage': relationshipStage,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Companion.fromMap(Map<String, dynamic> map) => Companion(
        id: map['id'],
        name: map['name'],
        occupationId: map['occupationId'],
        personalityIds: List<String>.from(jsonDecode(map['personalityIds'])),
        interestIds: List<String>.from(jsonDecode(map['interestIds'])),
        relationshipStyleIds: List<String>.from(jsonDecode(map['relationshipStyleIds'])),
        avatarPath: map['avatarPath'],
        affection: map['affection'],
        relationshipStage: map['relationshipStage'],
        createdAt: DateTime.parse(map['createdAt']),
      );
}
