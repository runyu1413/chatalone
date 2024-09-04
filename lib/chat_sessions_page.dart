import 'package:flutter/material.dart';
import 'database_helper.dart';

class ChatSessionsPage extends StatefulWidget {
  @override
  _ChatSessionsPageState createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> chatSessionIds = [];

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    List<String> sessions = await _dbHelper.getAllChatSessionIds();
    setState(() {
      chatSessionIds = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Sessions'),
      ),
      body: chatSessionIds.isNotEmpty
          ? ListView.builder(
              itemCount: chatSessionIds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Chat Session ${index + 1}'),
                  subtitle: Text('Chat ID: ${chatSessionIds[index]}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'chatHistory',
                      arguments: chatSessionIds[index],
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
}
