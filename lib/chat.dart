import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'home.dart';
import 'tictactoe.dart';

class ChatMessage {
  String messageContent;
  String messageType;
  String messageFormat;
  bool isEdited;
  String? reaction;
  bool autoDelete;
  int? timeRemaining;
  Timer? timer;
  DateTime timestamp;
  ChatMessage? replyTo;
  Uint8List? imageData;

  ChatMessage({
    required this.messageContent,
    required this.messageType,
    required this.messageFormat,
    required this.timestamp,
    this.isEdited = false,
    this.reaction,
    this.autoDelete = false,
    this.timeRemaining,
    this.timer,
    this.replyTo,
    this.imageData,
  });
}

class Chat extends StatefulWidget {
  Device connected_device;
  NearbyService nearbyService;
  List<ChatMessage>? chat_state;
  final String myData;

  Chat({
    required this.connected_device,
    required this.nearbyService,
    required this.myData,
    this.chat_state,
  });

  @override
  State<StatefulWidget> createState() => _Chat();
}

class _Chat extends State<Chat> {
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  final filter = ProfanityFilter();
  List<ChatMessage> messages = [];
  List<ChatMessage> filteredMessages = [];
  List<int> searchResults = [];
  int currentSearchIndex = 0;

  String searchTerm = '';
  bool isSearching = false;

  final myController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? editingIndex;
  ChatMessage? replyToMessage;
  bool isTextSelected = false;
  String? currentDevicePlayer;

  @override
  void initState() {
    super.initState();
    messages = widget.chat_state ?? [];
    filteredMessages = messages;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    init();
    myController.addListener(_handleTextSelection);
  }

  @override
  void dispose() {
    super.dispose();
    receivedDataSubscription.cancel();
    myController.removeListener(_handleTextSelection);
    _scrollController.dispose();
  }

  void addMessageToList(ChatMessage obj) {
    setState(() {
      messages.add(obj);
      filteredMessages = messages;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    if (obj.autoDelete) {
      obj.timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          obj.timeRemaining = (obj.timeRemaining ?? 10) - 1;
        });

        if (obj.timeRemaining! <= 0) {
          timer.cancel();
          setState(() {
            messages.remove(obj);
            filteredMessages = messages;
          });
          this.widget.nearbyService.sendMessage(
              this.widget.connected_device.deviceId, "delete|auto");
        }
      });
    }
  }

  void deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
      filteredMessages = messages;
    });
    this
        .widget
        .nearbyService
        .sendMessage(this.widget.connected_device.deviceId, "delete|$index");
  }

  void deleteMessageForBoth(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Message"),
          content: Text(
              "Are you sure you want to delete this message? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                deleteMessage(index);
              },
            ),
          ],
        );
      },
    );
  }

  void editMessage(int index) {
    setState(() {
      editingIndex = index;
      myController.text = messages[index].messageContent;
    });
  }

  void saveEditedMessage(String newText) {
    if (editingIndex != null) {
      setState(() {
        messages[editingIndex!].messageContent = newText;
        messages[editingIndex!].isEdited = true;
        filteredMessages = messages;
      });
      this.widget.nearbyService.sendMessage(
          this.widget.connected_device.deviceId, "edit|$editingIndex|$newText");
      editingIndex = null;
      myController.clear();
    }
  }

  void replyTo(int index) {
    setState(() {
      replyToMessage = messages[index];
    });
  }

  void sendMessage(String content,
      {Uint8List? imageData, bool autoDelete = false, int? timeInSeconds}) {
    String message = imageData != null ? "image" : "message";
    String finalMessage = "$message|" +
        content +
        (replyToMessage != null
            ? "|reply|" + replyToMessage!.messageContent
            : "") +
        (autoDelete ? "|auto|$timeInSeconds" : "");

    if (imageData != null) {
      String base64Image =
          base64Encode(imageData); // Convert image data to base64
      finalMessage +=
          "|$base64Image"; // Append the encoded image to the message
      print("Sending Image: $finalMessage"); // Debug print
    } else {
      print("Sending Message: $finalMessage"); // Debug print
    }

    var obj = ChatMessage(
      messageContent: content,
      messageType: "sender",
      messageFormat: message,
      autoDelete: autoDelete,
      timeRemaining: autoDelete ? timeInSeconds ?? 10 : null,
      timestamp: DateTime.now().toUtc().add(Duration(hours: 8)),
      replyTo: replyToMessage,
      imageData: imageData,
    );

    addMessageToList(obj);
    this
        .widget
        .nearbyService
        .sendMessage(this.widget.connected_device.deviceId, finalMessage);

    myController.clear();
    setState(() {
      replyToMessage = null;
    });
  }

  void reactToMessage(int index, String reaction) {
    setState(() {
      if (messages[index].reaction == reaction) {
        messages[index].reaction = null;
      } else {
        messages[index].reaction = reaction;
      }
      filteredMessages = messages;
    });
    this.widget.nearbyService.sendMessage(
          this.widget.connected_device.deviceId,
          "react|$index|${messages[index].reaction ?? ''}",
        );
  }

  void copyMessage(int index) {
    Clipboard.setData(ClipboardData(text: messages[index].messageContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Message copied to clipboard")),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToMessage(int index) {
    final double itemHeight = 100.0;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double offset =
        (index * itemHeight) - (screenHeight / 2) + (itemHeight / 2);

    _scrollController.animateTo(
      offset < 0 ? 0 : offset,
      duration: Duration(milliseconds: 300),
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

  @override
  void init() {
    receivedDataSubscription =
        this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final splited = data["message"].split('|');
      if (splited[0] == "delete") {
        int indexToDelete = int.parse(splited[1]);
        setState(() {
          messages.removeAt(indexToDelete);
          filteredMessages = messages;
        });
      } else if (splited[0] == "edit") {
        int indexToEdit = int.parse(splited[1]);
        setState(() {
          messages[indexToEdit].messageContent = splited[2];
          messages[indexToEdit].isEdited = true;
          filteredMessages = messages;
        });
      } else if (splited[0] == "react") {
        int indexToReact = int.parse(splited[1]);
        String reaction = splited[2];
        setState(() {
          messages[indexToReact].reaction = reaction;
          filteredMessages = messages;
        });
      } else if (splited[0] == "message" || splited[0] == "image") {
        var replyMessage;
        int? autoDeleteTime;
        Uint8List? imageData;

        if (splited.length > 3 && splited[2] == "reply") {
          replyMessage = ChatMessage(
            messageContent: splited[3],
            messageType: "receiver",
            messageFormat: "message",
            timestamp: DateTime.now().toUtc().add(Duration(hours: 8)),
          );
          autoDeleteTime = int.tryParse(splited[4]);
        } else if (splited.contains("auto")) {
          autoDeleteTime = int.tryParse(splited.last);
        }

        if (splited[0] == "image" && splited.length > 2) {
          imageData = base64Decode(
              splited.last); // Decode the base64 string back to Uint8List
        }

        var obj = ChatMessage(
          messageContent: splited[1],
          messageType: "receiver",
          messageFormat: splited[0],
          autoDelete: autoDeleteTime != null,
          timeRemaining: autoDeleteTime ?? 10,
          replyTo: replyMessage,
          timestamp: DateTime.now().toUtc().add(Duration(hours: 8)),
          imageData: imageData,
        );

        addMessageToList(obj);
      } else if (splited[0] == "tictactoe" && splited[1] == "start") {
        sendSystemMessage("Played Tic Tac Toe");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicTacToePage(
              nearbyService: widget.nearbyService,
              connectedDevice: widget.connected_device,
              currentDevicePlayer: "O",
              chat_state: messages,
              myData: widget.myData,
            ),
          ),
        );
      } else if (splited[0] == "disconnect" &&
          splited[1] == "partner_disconnected") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Disconnected"),
              content: Text(
                  "Your partner has disconnected. You will be returned to the home screen."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(name: widget.myData),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _handleTextSelection() {
    setState(() {
      isTextSelected =
          myController.selection.start != myController.selection.end;
    });
  }

  TextSpan _buildMessageContent(ChatMessage message, String? searchTerm) {
    final theme = Theme.of(context);
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
          style: TextStyle(color: Colors.white),
        ));
      }

      TextStyle highlightStyle = TextStyle(color: Colors.white);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        highlightStyle = TextStyle(
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
          style: TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.white,
            fontSize: 16,
          ),
        ));
      } else if (match.group(6) != null) {
        final String url = match.group(6)!;
        spans.add(TextSpan(
          text: url,
          style: TextStyle(
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
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 10),
            child: Row(
              children: <Widget>[
                SizedBox(width: 20),
                Expanded(
                  child: isSearching
                      ? TextField(
                          autofocus: true,
                          onChanged: (value) {
                            _searchMessages(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search...",
                            border: InputBorder.none,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              this.widget.connected_device.deviceName,
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'RobotoMono',
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
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
                        icon: Icon(Icons.arrow_upward),
                        onPressed: _previousSearchResult,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward),
                        onPressed: _nextSearchResult,
                      ),
                    ],
                  ),
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Disconnect"),
                          content: Text("Are you sure you want to disconnect?"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Disconnect"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _disconnectAndExit();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Visibility(
            visible: isTextSelected,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.format_bold),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('bold')
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_italic),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('italic')
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_underline),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('underline')
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_strikethrough),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('strikethrough')
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.highlight),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('highlight')
                        : null,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredMessages.length,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                if (filteredMessages[index].messageType == 'system') {
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
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
                    onLongPress: () {
                      if (filteredMessages[index].messageType == "sender") {
                        deleteMessageForBoth(index);
                      } else if (filteredMessages[index].messageType ==
                          "receiver") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Select a Reaction"),
                              content: Wrap(
                                spacing: 10,
                                children: [
                                  IconButton(
                                    icon: Text("👍"),
                                    onPressed: () {
                                      reactToMessage(index, "👍");
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  IconButton(
                                    icon: Text("❤️"),
                                    onPressed: () {
                                      reactToMessage(index, "❤️");
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  IconButton(
                                    icon: Text("😂"),
                                    onPressed: () {
                                      reactToMessage(index, "😂");
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      alignment:
                          filteredMessages[index].messageType == "receiver"
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      padding: EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment:
                            filteredMessages[index].messageType == "receiver"
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green[800],
                            ),
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .end, // Align timestamp to bottom-right
                              children: [
                                Image.memory(
                                  filteredMessages[index].imageData!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                if (filteredMessages[index].reaction != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      filteredMessages[index].reaction!,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                SizedBox(height: 5),
                                Text(
                                  _formatTimestamp(
                                      filteredMessages[index].timestamp),
                                  style: textTheme.bodySmall?.copyWith(
                                      fontSize: 10, color: Colors.white),
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
                            title: Text(
                              "Message Options",
                              style: textTheme.titleLarge,
                            ),
                            content: Text(
                              "What would you like to do to this message?",
                              style: textTheme.bodyMedium,
                            ),
                            actions: <Widget>[
                              if (filteredMessages[index].messageType ==
                                  "sender") ...[
                                TextButton(
                                  child:
                                      Text("Edit", style: textTheme.labelLarge),
                                  onPressed: () {
                                    editMessage(index);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Delete",
                                      style: textTheme.labelLarge),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    deleteMessageForBoth(index);
                                  },
                                ),
                              ],
                              if (filteredMessages[index].messageType ==
                                  "receiver")
                                TextButton(
                                  child: Text("React",
                                      style: textTheme.labelLarge),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Select a Reaction",
                                            style: textTheme.titleLarge,
                                          ),
                                          content: Wrap(
                                            spacing: 10,
                                            children: [
                                              IconButton(
                                                icon: Text("👍"),
                                                onPressed: () {
                                                  reactToMessage(index, "👍");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              IconButton(
                                                icon: Text("❤️"),
                                                onPressed: () {
                                                  reactToMessage(index, "❤️");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              IconButton(
                                                icon: Text("😂"),
                                                onPressed: () {
                                                  reactToMessage(index, "😂");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              TextButton(
                                child:
                                    Text("Copy", style: textTheme.labelLarge),
                                onPressed: () {
                                  copyMessage(index);
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child:
                                    Text("Reply", style: textTheme.labelLarge),
                                onPressed: () {
                                  replyTo(index);
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Cancel",
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: Colors.red),
                                ),
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
                      padding: EdgeInsets.only(
                          left: 10, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment:
                            (filteredMessages[index].messageType == "receiver"
                                ? Alignment.bottomLeft
                                : Alignment.bottomRight),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width *
                                0.75, // Set max width to 75% of screen width
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green[800],
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (filteredMessages[index].replyTo != null)
                                  Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: theme.dividerColor),
                                      ),
                                    ),
                                    child: Text(
                                      "Reply to: " +
                                          filteredMessages[index]
                                              .replyTo!
                                              .messageContent,
                                      style: textTheme.bodySmall?.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                RichText(
                                  text: _buildMessageContent(
                                      filteredMessages[index], searchTerm),
                                ),
                                if (filteredMessages[index].isEdited)
                                  Text(
                                    "(edited)",
                                    style: textTheme.bodySmall?.copyWith(
                                        fontSize: 6, color: Colors.white),
                                  ),
                                if (filteredMessages[index].reaction != null)
                                  Text(
                                    filteredMessages[index].reaction!,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                if (filteredMessages[index].autoDelete &&
                                    filteredMessages[index].timeRemaining !=
                                        null)
                                  Text(
                                    "Self-destructs in ${filteredMessages[index].timeRemaining} seconds",
                                    style: textTheme.bodySmall?.copyWith(
                                        fontSize: 10, color: theme.errorColor),
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
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (replyToMessage != null)
            Container(
              padding: EdgeInsets.all(10),
              color: theme.cardColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Reply to: " + replyToMessage!.messageContent,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: () {
                      setState(() {
                        replyToMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (editingIndex != null)
            Container(
              color: theme.cardColor,
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Editing: ${messages[editingIndex!].messageContent}",
                      style: textTheme.bodyMedium
                          ?.copyWith(color: theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: () {
                      setState(() {
                        editingIndex = null;
                        myController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            color: theme.scaffoldBackgroundColor,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a message";
                      } else if (filter.hasProfanity(value)) {
                        return 'Message contains profanity';
                      }
                      return null;
                    },
                    style: textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                        fontFamily: 'RobotoMono'),
                    decoration: InputDecoration(
                      hintText: editingIndex == null
                          ? "Enter your message..."
                          : "Edit your message...",
                      hintStyle: textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                          fontFamily: 'RobotoMono'),
                      border: InputBorder.none,
                    ),
                    controller: myController,
                    minLines: 1,
                    maxLines: 10,
                  ),
                ),
                GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        int? timeInSeconds;
                        return AlertDialog(
                          title: Text("Send self-destructing message?"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Enter time in seconds (Minimum 1 second)"),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        timeInSeconds = int.tryParse(value);
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Default: 10 seconds",
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("seconds"),
                                ],
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Send"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                sendMessage(myController.text,
                                    autoDelete: true,
                                    timeInSeconds: timeInSeconds);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: FloatingActionButton(
                    onPressed: () {
                      if (editingIndex == null) {
                        if (myController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter a message")));
                        } else if (filter.hasProfanity(myController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Please do not enter profanity")));
                        } else {
                          sendMessage(myController.text);
                        }
                      } else {
                        saveEditedMessage(myController.text);
                      }
                    },
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.green[500],
                    elevation: 0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.games),
                  onPressed: _showGameMenu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendSystemMessage(String content) {
    var obj = ChatMessage(
      messageContent: content,
      messageType: "system",
      messageFormat: "system",
      timestamp: DateTime.now().toUtc().add(Duration(hours: 8)),
    );
    addMessageToList(obj);
  }

  void _disconnectAndExit() {
    widget.nearbyService.sendMessage(
      widget.connected_device.deviceId,
      "disconnect|partner_disconnected",
    );

    receivedDataSubscription.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(name: widget.myData),
      ),
    );
  }

  void _showGameMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Game"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text("Tic Tac Toe"),
                  onTap: () {
                    Navigator.of(context).pop();
                    startTicTacToe();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _formatSelectedText(String format) {
    final selectedText = myController.text
        .substring(myController.selection.start, myController.selection.end);

    String formattedText = selectedText;

    switch (format) {
      case 'bold':
        formattedText = '**$selectedText**';
        break;
      case 'italic':
        formattedText = '*$selectedText*';
        break;
      case 'underline':
        formattedText = '_$selectedText _';
        break;
      case 'strikethrough':
        formattedText = '~$selectedText~';
        break;
      case 'highlight':
        formattedText = '~highlight{$selectedText}';
        break;
    }

    final newText = myController.text.replaceRange(myController.selection.start,
        myController.selection.end, formattedText);

    setState(() {
      myController.text = newText;
      myController.selection = TextSelection.collapsed(
          offset: myController.selection.start + formattedText.length);
    });
  }

  void startTicTacToe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Start Tic Tac Toe"),
          content: Text("Are you sure you want to start a Tic Tac Toe game?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Start"),
              onPressed: () {
                sendSystemMessage("Played Tic Tac Toe");
                Navigator.of(context).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicTacToePage(
                      nearbyService: widget.nearbyService,
                      connectedDevice: widget.connected_device,
                      currentDevicePlayer: "X",
                      myData: widget.myData,
                      chat_state: messages.isNotEmpty ? messages : null,
                    ),
                  ),
                );

                widget.nearbyService.sendMessage(
                    widget.connected_device.deviceId, "tictactoe|start|O");
              },
            ),
          ],
        );
      },
    );
  }

  void _pickImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        Uint8List imageData = await image.readAsBytes();
        int imageSize = imageData.lengthInBytes;

        if (imageSize >= 20 * 1024) {
          // Show dialog if the image is 20KB or larger
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Image Too Large"),
                content: Text(
                    "Your selected image is too large to send. Please choose an image smaller than 20KB."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Extract text from the image using OCR
          final String ocrText;
          try {
            ocrText = await FlutterTesseractOcr.extractText(
              image.path,
              language:
                  'eng', // Ensure you have the eng.traineddata in your assets
            );
            print("OCR Text Detected: $ocrText");
          } catch (e) {
            print("Error during OCR: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Failed to process the image for text")),
            );
            return;
          }

          // Check if recognized text contains profanity
          if (ocrText.isNotEmpty && filter.hasProfanity(ocrText)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text("The image contains profanity and cannot be sent")),
            );
          } else {
            // Send the image if no profanity is found
            sendMessage("Image", imageData: imageData);
          }
        }
      } else {
        print("No image was selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while picking the image")),
      );
    }
  }
}
