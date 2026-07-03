import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/companion.dart';
import '../models/memory.dart';

/// Central local database — all conversation history, companion profiles,
/// and memories live here and never leave the device.
class DbService {
  DbService._internal();
  static final DbService instance = DbService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ai_companion.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE companions (
            id TEXT PRIMARY KEY,
            name TEXT,
            occupationId TEXT,
            personalityIds TEXT,
            interestIds TEXT,
            relationshipStyleIds TEXT,
            avatarPath TEXT,
            affection INTEGER,
            relationshipStage TEXT,
            createdAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            companionId TEXT,
            isUser INTEGER,
            content TEXT,
            timestamp TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE memories (
            id TEXT PRIMARY KEY,
            companionId TEXT,
            category TEXT,
            content TEXT,
            importance INTEGER,
            createdAt TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_messages_companion ON messages(companionId)');
        await db.execute('CREATE INDEX idx_memories_companion ON memories(companionId)');
      },
    );
  }

  // ---------- Companions ----------

  Future<void> saveCompanion(Companion c) async {
    final database = await db;
    await database.insert('companions', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Companion>> getCompanions() async {
    final database = await db;
    final rows = await database.query('companions', orderBy: 'createdAt ASC');
    return rows.map((r) => Companion.fromMap(r)).toList();
  }

  Future<void> deleteCompanion(String id) async {
    final database = await db;
    await database.delete('companions', where: 'id = ?', whereArgs: [id]);
    await database.delete('messages', where: 'companionId = ?', whereArgs: [id]);
    await database.delete('memories', where: 'companionId = ?', whereArgs: [id]);
  }

  // ---------- Messages ----------

  Future<void> addMessage(ChatMessage m) async {
    final database = await db;
    await database.insert('messages', m.toMap());
  }

  Future<List<ChatMessage>> getRecentMessages(String companionId, {int limit = 30}) async {
    final database = await db;
    final rows = await database.query(
      'messages',
      where: 'companionId = ?',
      whereArgs: [companionId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map((r) => ChatMessage.fromMap(r)).toList().reversed.toList();
  }

  // ---------- Memories ----------

  Future<void> addMemory(MemoryFact f) async {
    final database = await db;
    await database.insert('memories', f.toMap());
  }

  Future<void> deleteMemory(String id) async {
    final database = await db;
    await database.delete('memories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MemoryFact>> getAllMemories(String companionId) async {
    final database = await db;
    final rows = await database.query(
      'memories',
      where: 'companionId = ?',
      whereArgs: [companionId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => MemoryFact.fromMap(r)).toList();
  }

  /// Retrieval step of the pipeline: pull the top-N most relevant
  /// memories for the current message instead of the full history.
  Future<List<MemoryFact>> getRelevantMemories(
    String companionId,
    String query, {
    int topN = 5,
  }) async {
    final all = await getAllMemories(companionId);
    all.sort((a, b) => b.relevanceTo(query).compareTo(a.relevanceTo(query)));
    return all.take(topN).where((m) => m.relevanceTo(query) > 0).toList();
  }
}
