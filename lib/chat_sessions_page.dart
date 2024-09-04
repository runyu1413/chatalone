import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart'; // For formatting timestamp

class ChatSessionsPage extends StatefulWidget {
  @override
  _ChatSessionsPageState createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> chatSessions = [];

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  // Load the latest message for each chat session
  Future<void> _loadChatSessions() async {
    List<Map<String, dynamic>> sessions =
        await _dbHelper.getLatestMessagesForEachChat();

    // Make a mutable copy of the list before sorting
    List<Map<String, dynamic>> mutableSessions =
        List<Map<String, dynamic>>.from(sessions);

    // Sort the mutable list by the parsed timestamp in descending order
    mutableSessions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['timestamp']);
      DateTime dateB = DateTime.parse(b['timestamp']);
      return dateB.compareTo(dateA); // For latest timestamps on top
    });

    setState(() {
      chatSessions = mutableSessions; // Update the state with the sorted list
    });
  }

  // Method to delete a chat session from the database and update the UI
  Future<void> _deleteChatSession(String chatId) async {
    await _dbHelper.deleteMessagesByChatId(chatId); // Delete from database
    _loadChatSessions(); // Reload the sessions to update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Sessions'),
      ),
      body: chatSessions.isNotEmpty
          ? ListView.builder(
              itemCount: chatSessions.length,
              itemBuilder: (context, index) {
                String personName =
                    chatSessions[index]['personName'] ?? 'Unknown';
                String timestamp = chatSessions[index]['timestamp'];
                String formattedTimestamp = _formatTimestamp(timestamp);

                return ListTile(
                  title: Text(personName),
                  subtitle: Text('Last message at: $formattedTimestamp'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(
                          chatSessions[index]['chatId']);
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'chatHistory',
                      arguments: chatSessions[index]['chatId'],
                    );
                  },
                );
              },
            )
          : Center(
              child: Text('No chat sessions found'),
            ),
    );
  }

  // Show a confirmation dialog before deleting a chat session
  void _showDeleteConfirmationDialog(String chatId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Chat Session'),
          content: Text('Are you sure you want to delete this chat session?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteChatSession(chatId); // Call the delete method
              },
            ),
          ],
        );
      },
    );
  }

  // Format the timestamp
  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
