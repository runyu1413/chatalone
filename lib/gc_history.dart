import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'message.dart';
import 'database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'generated/l10n.dart';

class GroupChatHistoryPage extends StatefulWidget {
  final String chatId;
  final String groupName;

  const GroupChatHistoryPage(
      {Key? key, required this.chatId, required this.groupName})
      : super(key: key);

  @override
  _GroupChatHistoryPageState createState() => _GroupChatHistoryPageState();
}

class _GroupChatHistoryPageState extends State<GroupChatHistoryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<GroupChatMessage> messages = [];
  List<GroupChatMessage> filteredMessages = [];
  List<int> searchResults = [];
  int currentSearchIndex = 0;
  String searchTerm = '';
  bool isSearching = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    List<GroupChatMessage> dbMessages =
        await _dbHelper.getGroupMessagesByChatId(widget.chatId);
    setState(() {
      messages = dbMessages;
      filteredMessages = messages;
    });
  }

  void _scrollToMessage(int index) {
    const double itemHeight = 100.0;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double offset =
        (index * itemHeight) - (screenHeight / 2) + (itemHeight / 2);

    _scrollController.animateTo(
      offset < 0 ? 0 : offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _searchMessages(String query) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        searchTerm = query;
        if (query.isEmpty) {
          filteredMessages = messages;
          searchResults.clear();
        } else {
          searchResults.clear();
          for (int i = 0; i < messages.length; i++) {
            if (messages[i]
                .messageContent
                .toLowerCase()
                .contains(query.toLowerCase())) {
              searchResults.add(i);
            }
          }
          if (searchResults.isNotEmpty) {
            currentSearchIndex = 0;
            _scrollToMessage(searchResults[currentSearchIndex]);
          }
        }
      });
    });
  }

  void _nextSearchResult() {
    if (searchResults.isNotEmpty) {
      setState(() {
        currentSearchIndex = (currentSearchIndex + 1) % searchResults.length;
        _scrollToMessage(searchResults[currentSearchIndex]);
      });
    }
  }

  void _previousSearchResult() {
    if (searchResults.isNotEmpty) {
      setState(() {
        currentSearchIndex = (currentSearchIndex - 1 + searchResults.length) %
            searchResults.length;
        _scrollToMessage(searchResults[currentSearchIndex]);
      });
    }
  }

  void copyMessage(int index) {
    Clipboard.setData(
        ClipboardData(text: filteredMessages[index].messageContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Message copied to clipboard")),
    );
  }

  TextSpan _buildMessageContent(GroupChatMessage message, String? searchTerm) {
    final String text = message.messageContent;
    final RegExp pattern = RegExp(
      r'\*\*(.*?)\*\*|'
      r'_(.*?)_|'
      r'~(.*?)~|'
      r'\*(.*?)\*|'
      r'~highlight\{(.*?)\}|'
      r"((https?:\/\/)?[a-zA-Z0-9\-\._~:\/\?#\[\]@!\$&\'\(\)\*\+,;=]+\.[a-zA-Z0-9\-\._~:\/\?#\[\]@!\$&\'\(\)\*\+,;=]+)",
      caseSensitive: false,
    );
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    for (final Match match in pattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.white),
        ));
      }
      TextStyle highlightStyle = const TextStyle(color: Colors.white);
      if (searchTerm != null && searchTerm.isNotEmpty) {
        highlightStyle = const TextStyle(
          color: Colors.yellow,
          fontSize: 16,
        );
      }
      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: searchTerm != null &&
                    match
                        .group(1)!
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase())
                ? highlightStyle.color
                : Colors.white,
            fontSize: 16,
          ),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: searchTerm != null &&
                    match
                        .group(2)!
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase())
                ? highlightStyle.color
                : Colors.white,
            fontSize: 16,
          ),
        ));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(
          text: match.group(3),
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: searchTerm != null &&
                    match
                        .group(3)!
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase())
                ? highlightStyle.color
                : Colors.white,
            fontSize: 16,
          ),
        ));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(
          text: match.group(4),
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: searchTerm != null &&
                    match
                        .group(4)!
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase())
                ? highlightStyle.color
                : Colors.white,
            fontSize: 16,
          ),
        ));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(
          text: match.group(5),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.white,
            fontSize: 16,
          ),
        ));
      } else if (match.group(6) != null) {
        final String url = match.group(6)!;
        spans.add(TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 16,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
        ));
      }
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          color: searchTerm != null &&
                  searchTerm.isNotEmpty &&
                  text
                      .substring(lastMatchEnd)
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase())
              ? Colors.yellow
              : Colors.white,
        ),
      ));
    }
    return TextSpan(children: spans);
  }

  String _formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm', 'en_SG');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: isSearching ? null : Text(widget.groupName),
        automaticallyImplyLeading: !isSearching,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: isSearching
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) {
                              _searchMessages(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Search...",
                              border: InputBorder.none,
                            ),
                          ),
                        )
                      : Container(), // Empty container if not searching
                ),
                IconButton(
                  icon: Icon(isSearching ? Icons.clear : Icons.search),
                  onPressed: () {
                    setState(() {
                      if (isSearching) {
                        isSearching = false;
                        searchTerm = '';
                        searchResults.clear();
                        filteredMessages = messages;
                      } else {
                        isSearching = true;
                      }
                    });
                  },
                ),
                if (searchResults.isNotEmpty)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: _previousSearchResult,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: _nextSearchResult,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredMessages.length,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                bool isSender = filteredMessages[index].messageType == 'sender';
                String senderName = filteredMessages[index].personName;
                if (filteredMessages[index].messageType == 'system') {
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
                    child: Text(
                      filteredMessages[index].messageContent,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                } else if (filteredMessages[index].messageFormat == "image" &&
                    filteredMessages[index].imageData != null) {
                  return GestureDetector(
                    child: Container(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green[800],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Image.memory(
                                  filteredMessages[index].imageData!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatTimestamp(
                                      filteredMessages[index].timestamp),
                                  style: textTheme.bodySmall?.copyWith(
                                      fontSize: 6, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(S.of(context).messageOptionsTitle,
                                style: textTheme.titleLarge),
                            content: Text(
                                "What would you like to do to this message?",
                                style: textTheme.bodyMedium),
                            actions: <Widget>[
                              if (filteredMessages[index].messageType ==
                                  "receiver")
                                TextButton(
                                  child: Text(S.of(context).copy,
                                      style: textTheme.labelLarge),
                                  onPressed: () {
                                    copyMessage(index);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              TextButton(
                                child: Text(S.of(context).cancel,
                                    style: textTheme.labelLarge
                                        ?.copyWith(color: Colors.red)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(
                          left: 10, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment: isSender
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.green[800],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      senderName,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    RichText(
                                      text: _buildMessageContent(
                                          filteredMessages[index], searchTerm),
                                    ),
                                    Text(
                                      _formatTimestamp(
                                          filteredMessages[index].timestamp),
                                      style: textTheme.bodySmall?.copyWith(
                                          fontSize: 6, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
