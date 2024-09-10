import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'home.dart';
import 'package:uuid/uuid.dart';
import 'package:ntu_fyp_chatalone/generated/l10n.dart';

class ChatMessage {
  int? id;
  String chatId;
  String messageContent;
  String messageType;
  String messageFormat;
  DateTime timestamp;
  Uint8List? imageData;

  ChatMessage({
    this.id,
    required this.chatId,
    required this.messageContent,
    required this.messageType,
    required this.messageFormat,
    required this.timestamp,
    this.imageData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'messageContent': messageContent,
      'messageType': messageType,
      'messageFormat': messageFormat,
      'timestamp': timestamp.toIso8601String(),
      'imageData': imageData,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      chatId: map['chatId'],
      messageContent: map['messageContent'],
      messageType: map['messageType'],
      messageFormat: map['messageFormat'],
      timestamp: DateTime.parse(map['timestamp']),
      imageData: map['imageData'],
    );
  }
}

class GroupChatCreator extends StatefulWidget {
  List<Device> connectedDevices;
  NearbyService nearbyService;
  String myName;
  var chatState;
  String groupName;
  GroupChatCreator(
      {required this.myName,
      required this.connectedDevices,
      required this.nearbyService,
      required this.groupName});

  @override
  State<StatefulWidget> createState() => _GroupChatCreator();
}

class _GroupChatCreator extends State<GroupChatCreator> {
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
  bool isTextSelected = false;
  String? currentDevicePlayer;
  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = const Uuid().v4();
    if (widget.chatState != null && widget.chatState!.isNotEmpty) {
      chatId = widget.chatState!.first.chatId;
    }
    messages = widget.chatState ?? [];
    filteredMessages = messages;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    init();
    myController.addListener(_handleTextSelection);
  }

  @override
  void dispose() {
    receivedDataSubscription.cancel();
    myController.removeListener(_handleTextSelection);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveChatHistoryAndExit() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(name: widget.myName)),
    );
  }

  Future<void> _saveChatHistoryAfterDisconnect() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Disconnected"),
          content: Text("Your partner has disconnected."),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(name: widget.myName),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void addMessageToList(ChatMessage obj) {
    setState(() {
      messages.add(obj);
      filteredMessages = messages;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void sendMessage(String content, {Uint8List? imageData}) {
    String message = imageData != null ? "image" : "message";
    String finalMessage = "$message|" + content;

    if (imageData != null) {
      String base64Image = base64Encode(imageData);
      finalMessage += "|$base64Image";
    }

    var obj = ChatMessage(
      chatId: chatId,
      messageContent: content,
      messageType: "sender",
      messageFormat: message,
      timestamp: DateTime.now().toUtc().add(const Duration(hours: 8)),
      imageData: imageData,
    );

    addMessageToList(obj);
    for (Device device in this.widget.connectedDevices) {
      widget.nearbyService.sendMessage(device.deviceId, finalMessage);
    }

    myController.clear();
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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

  void init() {
    receivedDataSubscription =
        widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final splited = data["message"].split('|');
      String? senderDeviceId = data["deviceId"];
      if (splited[0] == "message" || splited[0] == "image") {
        Uint8List? imageData;
        if (splited[0] == "image" && splited.length > 2) {
          imageData = base64Decode(splited.last);
        }
        for (Device device in widget.connectedDevices) {
          if (device.deviceId != senderDeviceId) {
            widget.nearbyService.sendMessage(device.deviceId, data["message"]);
          }
        }
        var obj = ChatMessage(
          chatId: chatId,
          messageContent: splited[1],
          messageType: "receiver",
          messageFormat: splited[0],
          timestamp: DateTime.now().toUtc().add(const Duration(hours: 8)),
          imageData: imageData,
        );
        addMessageToList(obj);
      } else if (splited[0] == "disconnect" &&
          splited[1] == "partner_disconnected") {
        _saveChatHistoryAfterDisconnect();
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
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                Expanded(
                  child: isSearching
                      ? TextField(
                          autofocus: true,
                          onChanged: (value) {
                            _searchMessages(value);
                          },
                          decoration: InputDecoration(
                            hintText: S.of(context).searchHint,
                            border: InputBorder.none,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.groupName,
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
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: _previousSearchResult,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: _nextSearchResult,
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(S.of(context).disconnectTitle),
                          content: Text(S.of(context).disconnectMessage),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.of(context).cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(S.of(context).disconnect),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('bold')
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('italic')
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_underline),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('underline')
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_strikethrough),
                    onPressed: isTextSelected
                        ? () => _formatSelectedText('strikethrough')
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.highlight),
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
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
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
                      alignment:
                          filteredMessages[index].messageType == "receiver"
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      padding: const EdgeInsets.only(
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
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                            title: Text(
                              S.of(context).messageOptionsTitle,
                              style: textTheme.titleLarge,
                            ),
                            content: Text(
                              "What would you like to do to this message?",
                              style: textTheme.bodyMedium,
                            ),
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
                                child: Text(
                                  S.of(context).cancel,
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
                      padding: const EdgeInsets.only(
                          left: 10, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment:
                            (filteredMessages[index].messageType == "receiver"
                                ? Alignment.bottomLeft
                                : Alignment.bottomRight),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green[800],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
            color: theme.scaffoldBackgroundColor,
            child: Row(
              children: <Widget>[
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
                      hintText: S.of(context).enterMessage,
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
                  child: FloatingActionButton(
                    onPressed: () {
                      if (myController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(S.of(context).pleaseEnterMessage)));
                      } else if (filter.hasProfanity(myController.text)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S.of(context).profanityDetected),
                              content: Text("Please do not enter profanity"),
                              actions: [
                                TextButton(
                                  child: Text(S.of(context).ok),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        sendMessage(myController.text);
                      }
                    },
                    child: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.green[500],
                    elevation: 0,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    _pickImage();
                  },
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
      chatId: chatId,
      messageContent: content,
      messageType: "system",
      messageFormat: "system",
      timestamp: DateTime.now().toUtc().add(const Duration(hours: 8)),
    );
    addMessageToList(obj);
  }

  void _disconnectAndExit() async {
    for (Device device in widget.connectedDevices) {
      widget.nearbyService.sendMessage(
        device.deviceId,
        "disconnect|partner_disconnected",
      );
    }
    await _saveChatHistoryAndExit();
    receivedDataSubscription.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(name: widget.myName),
      ),
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

  void _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Uint8List imageData = await image.readAsBytes();
        int imageSize = imageData.lengthInBytes;
        if (imageSize >= 20 * 1024) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(S.of(context).imageTooLarge),
                content: Text(S.of(context).imageTooLargeMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text(S.of(context).ok),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          final containsNudity =
              await FlutterNudeDetector.detect(path: image.path);
          if (containsNudity) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Nudity Detected"),
                  content: Text("Please do not send inappropriate images"),
                  actions: <Widget>[
                    TextButton(
                      child: Text(S.of(context).ok),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            final inputImage = InputImage.fromFilePath(image.path);
            final textRecognizer = TextRecognizer();
            try {
              final RecognizedText recognizedText =
                  await textRecognizer.processImage(inputImage);
              final String ocrText = recognizedText.text;

              if (ocrText.isNotEmpty && filter.hasProfanity(ocrText)) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(S.of(context).profanityDetected),
                      content: Text(S.of(context).profanityDetectedMessage),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.of(context).ok),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                sendMessage("Image", imageData: imageData);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Failed to process the image for text")),
              );
            } finally {
              textRecognizer.close();
            }
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
