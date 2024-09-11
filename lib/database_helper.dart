import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'message.dart';

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
      version: 5, // Increment version to trigger onUpgrade
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await _createTables(db);
        }
      },
    );
  }

  // Create tables in the database
  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS createdGroupChatMessages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chatId TEXT,
        messageContent TEXT,
        messageType TEXT,
        messageFormat TEXT,
        timestamp TEXT,
        personName TEXT,
        groupName TEXT,
        imageData BLOB
      )
    ''');
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_messages.db');
    await deleteDatabase(path); // Deletes the current database file
    _database = null; // Reset the in-memory database instance
    await database; // Recreate the database with fresh schema
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

  // Insert a new message into the 'messages' table
  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert a new message into the 'createdGroupChatMessages' table
  Future<void> insertGroupMessage(GroupChatMessage message) async {
    final db = await database;
    await db.insert(
      'createdGroupChatMessages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all messages from the 'messages' table
  Future<List<ChatMessage>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages');
    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  // Get all messages from the 'createdGroupChatMessages' table
  Future<List<GroupChatMessage>> getGroupMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('createdGroupChatMessages');
    return List.generate(maps.length, (i) {
      return GroupChatMessage.fromMap(maps[i]);
    });
  }

  // Delete a specific message by id from the 'messages' table
  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  // Delete a specific message by id from the 'createdGroupChatMessages' table
  Future<void> deleteGroupMessage(int id) async {
    final db = await database;
    await db
        .delete('createdGroupChatMessages', where: 'id = ?', whereArgs: [id]);
  }

  // Update an existing message in the 'messages' table
  Future<void> updateMessage(ChatMessage message) async {
    final db = await database;
    await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // Update an existing message in the 'createdGroupChatMessages' table
  Future<void> updateGroupMessage(GroupChatMessage message) async {
    final db = await database;
    await db.update(
      'createdGroupChatMessages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // Delete all messages from the 'messages' table
  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // Delete all messages from the 'createdGroupChatMessages' table
  Future<void> deleteAllGroupMessages() async {
    final db = await database;
    await db.delete('createdGroupChatMessages');
  }

  // Get messages by chatId from the 'messages' table
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

  // Get messages by chatId from the 'createdGroupChatMessages' table
  Future<List<GroupChatMessage>> getGroupMessagesByChatId(String chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'createdGroupChatMessages',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
    return List.generate(maps.length, (i) {
      return GroupChatMessage.fromMap(maps[i]);
    });
  }

  // Delete messages by chatId from the 'messages' table
  Future<void> deleteMessagesByChatId(String chatId) async {
    final db = await database;
    await db.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
  }

  // Delete messages by chatId from the 'createdGroupChatMessages' table
  Future<void> deleteGroupMessagesByChatId(String chatId) async {
    final db = await database;
    await db.delete('createdGroupChatMessages',
        where: 'chatId = ?', whereArgs: [chatId]);
  }

  // Get all distinct chat session IDs from the 'messages' table
  Future<List<String>> getAllChatSessionIds() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT DISTINCT chatId FROM messages WHERE chatId IS NOT NULL');
    return result.map((row) => row['chatId'] as String).toList();
  }

  // Get all distinct chat session IDs from the 'createdGroupChatMessages' table
  Future<List<String>> getAllGroupChatSessionIds() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT DISTINCT chatId FROM createdGroupChatMessages WHERE chatId IS NOT NULL');
    return result.map((row) => row['chatId'] as String).toList();
  }

  // Get the latest message for each chat session in the 'messages' table
  Future<List<Map<String, dynamic>>> getLatestMessagesForEachChat() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT chatId, personName, MAX(timestamp) AS timestamp
      FROM messages
      GROUP BY chatId
    ''');
    return result;
  }

  // Get the latest message for each chat session in the 'createdGroupChatMessages' table
  Future<List<Map<String, dynamic>>> getLatestGroupMessagesForEachChat() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT chatId, groupName, MAX(timestamp) AS timestamp
      FROM createdGroupChatMessages
      GROUP BY chatId
    ''');
    return result;
  }
}
