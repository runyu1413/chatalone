import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'chat.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  // Ensure the database is only initialized once
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_messages.db');
    return await openDatabase(
      path,
      version: 4, // Increment version to trigger onUpgrade
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
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
            imageData BLOB,
            personName TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Check if personName column exists, if not, add it
          bool personNameExists =
              await _columnExists(db, 'messages', 'personName');
          if (!personNameExists) {
            await db.execute('ALTER TABLE messages ADD COLUMN personName TEXT');
          }
        }
      },
    );
  }

  // Check if a column exists in a table
  Future<bool> _columnExists(
      Database db, String tableName, String columnName) async {
    List<Map> result = await db.rawQuery('PRAGMA table_info($tableName)');
    for (var row in result) {
      if (row['name'] == columnName) {
        return true;
      }
    }
    return false;
  }

  // Insert a new message
  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Drop the entire database (development use)
  Future<void> dropDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_messages.db');
    await deleteDatabase(path);
    _database = null; // Reset the database instance
  }

  // Reset the database (for development)
  Future<void> resetDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'chat_messages.db');
    await deleteDatabase(dbPath);
    _database = null;
    await database; // Recreate the database
  }

  // Get all messages
  Future<List<ChatMessage>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages');
    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  // Delete a specific message by id
  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  // Update an existing message
  Future<void> updateMessage(ChatMessage message) async {
    final db = await database;
    await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // Delete all messages
  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // Get messages by chatId
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

  // Delete messages by chatId
  Future<void> deleteMessagesByChatId(String chatId) async {
    final db = await database;
    await db.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
  }

  // Get all distinct chat session IDs
  Future<List<String>> getAllChatSessionIds() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT DISTINCT chatId FROM messages WHERE chatId IS NOT NULL');
    return result.map((row) => row['chatId'] as String).toList();
  }

  // Get the latest message for each chat session
  Future<List<Map<String, dynamic>>> getLatestMessagesForEachChat() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT chatId, personName, MAX(timestamp) AS timestamp
      FROM messages
      GROUP BY chatId
    ''');
    return result;
  }
}
