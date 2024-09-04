import 'database_helper.dart';
import 'chat.dart';
import 'package:uuid/uuid.dart';

class ChatHistoryManager {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String? chatId;
  List<ChatMessage> messages = [];

  ChatHistoryManager() {
    // Generate a unique chat ID when the manager is initialized
    chatId = Uuid().v4();
  }

  // Add a message to the temporary in-memory list
  void addMessage(ChatMessage message) {
    messages.add(message);
  }

  // Save the chat history to the database when the session ends
  Future<void> saveChatHistory() async {
    if (chatId != null && messages.isNotEmpty) {
      for (var message in messages) {
        message.chatId = chatId;
        await _dbHelper.insertMessage(message);
      }
      clearChatHistory(); // Clear in-memory messages after saving
    }
  }

  // Load chat history from the database by chat ID
  Future<void> loadChatHistory(String chatId) async {
    List<ChatMessage> dbMessages = await _dbHelper.getMessagesByChatId(chatId);
    messages = dbMessages;
  }

  // Clear the in-memory chat history (useful for starting a new session)
  void clearChatHistory() {
    messages.clear();
    chatId = Uuid().v4(); // Generate a new chat ID for the next session
  }
}
