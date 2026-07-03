class MemoryFact {
  final String id;
  final String companionId;
  final String category; // e.g. "birthday", "preference", "event", "nickname"
  final String content; // e.g. "User's birthday is August 3"
  final int importance; // 1-3 (low/medium/high)
  final DateTime createdAt;

  MemoryFact({
    required this.id,
    required this.companionId,
    required this.category,
    required this.content,
    required this.importance,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'companionId': companionId,
        'category': category,
        'content': content,
        'importance': importance,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MemoryFact.fromMap(Map<String, dynamic> map) => MemoryFact(
        id: map['id'],
        companionId: map['companionId'],
        category: map['category'],
        content: map['content'],
        importance: map['importance'],
        createdAt: DateTime.parse(map['createdAt']),
      );

  /// Very simple keyword-overlap relevance score against a query string.
  /// Swap this for embedding-based retrieval later if desired.
  double relevanceTo(String query) {
    final q = query.toLowerCase().split(RegExp(r'\W+')).toSet();
    final c = content.toLowerCase().split(RegExp(r'\W+')).toSet();
    final overlap = q.intersection(c).length;
    return overlap + (importance * 0.5);
  }
}

class ChatMessage {
  final String id;
  final String companionId;
  final bool isUser;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.companionId,
    required this.isUser,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'companionId': companionId,
        'isUser': isUser ? 1 : 0,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'],
        companionId: map['companionId'],
        isUser: map['isUser'] == 1,
        content: map['content'],
        timestamp: DateTime.parse(map['timestamp']),
      );
}
