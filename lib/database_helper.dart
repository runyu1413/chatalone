import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'chat.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_messages.db');
    return await openDatabase(
      path,
      version: 2, // Make sure this matches your current schema version
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chatId TEXT,
            messageContent TEXT,
            messageType TEXT,
            messageFormat TEXT,
            isEdited INTEGER,
            reaction TEXT,
            autoDelete INTEGER,
            timeRemaining INTEGER,
            timestamp TEXT,
            replyTo TEXT,
            imageData BLOB
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Upgrade the database to include chatId
          await db.execute('ALTER TABLE messages ADD COLUMN chatId TEXT');
        }
      },
    );
  }

  Future<void> dropDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_messages.db');
    await deleteDatabase(path);
    _database = null; // Reset the database instance to null
  }

  // To drop and recreate the database (for development purposes only)
  Future<void> resetDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'chat_messages.db');
    await deleteDatabase(dbPath);
    _database = null;
    await database;
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatMessage>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages');
    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateMessage(ChatMessage message) async {
    final db = await database;
    await db.update('messages', message.toMap(),
        where: 'id = ?', whereArgs: [message.id]);
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  Future<List<ChatMessage>> getMessagesByChatId(String chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  Future<void> deleteMessagesByChatId(String chatId) async {
    final db = await database;
    await db.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
  }

  Future<List<String>> getAllChatSessionIds() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT DISTINCT chatId FROM messages WHERE chatId IS NOT NULL');
    return result.map((row) => row['chatId'] as String).toList();
  }
}
