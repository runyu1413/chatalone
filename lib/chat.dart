import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class ChatMessage {
  String messageContent;
  String messageType;
  String messageFormat;
  bool isEdited;
  String? reaction;
  bool autoDelete;
  int? timeRemaining;
  Timer? timer;
  ChatMessage? replyTo;

  ChatMessage({
    required this.messageContent,
    required this.messageType,
    required this.messageFormat,
    this.isEdited = false,
    this.reaction,
    this.autoDelete = false,
    this.timeRemaining,
    this.timer,
    this.replyTo,
  });
}

class Chat extends StatefulWidget {
  Device connected_device;
  NearbyService nearbyService;
  var chat_state;
  Chat({required this.connected_device, required this.nearbyService});

  @override
  State<StatefulWidget> createState() => _Chat();
}

class _Chat extends State<Chat> {
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;
  final filter = ProfanityFilter();
  List<ChatMessage> messages = [];
  final myController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? editingIndex;
  ChatMessage? replyToMessage;
  bool isTextSelected = false;
  TicTacToeGame? ticTacToeGame;
  String? currentDevicePlayer;

  @override
  void initState() {
    super.initState();
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
    });
    this
        .widget
        .nearbyService
        .sendMessage(this.widget.connected_device.deviceId, "delete|$index");
  }

  void deleteMessageForBoth(int index) {
    deleteMessage(index);
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

  void sendMessage(String content, {bool autoDelete = false}) {
    var obj = ChatMessage(
      messageContent: content,
      messageType: "sender",
      messageFormat: "message",
      autoDelete: autoDelete,
      timeRemaining: autoDelete ? 10 : null,
      replyTo: replyToMessage,
    );
    addMessageToList(obj);
    this.widget.nearbyService.sendMessage(
          this.widget.connected_device.deviceId,
          "message|" +
              content +
              (replyToMessage != null
                  ? "|reply|" + replyToMessage!.messageContent
                  : "") +
              (autoDelete ? "|auto" : ""),
        );
    myController.clear();
    setState(() {
      replyToMessage = null;
    });
  }

  void reactToMessage(int index, String reaction) {
    setState(() {
      messages[index].reaction = reaction;
    });
    this.widget.nearbyService.sendMessage(
          this.widget.connected_device.deviceId,
          "react|$index|$reaction",
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

  @override
  void init() {
    receivedDataSubscription =
        this.widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final splited = data["message"].split('|');
      if (splited[0] == "delete") {
        int indexToDelete = int.parse(splited[1]);
        setState(() {
          messages.removeAt(indexToDelete);
        });
      } else if (splited[0] == "edit") {
        int indexToEdit = int.parse(splited[1]);
        setState(() {
          messages[indexToEdit].messageContent = splited[2];
          messages[indexToEdit].isEdited = true;
        });
      } else if (splited[0] == "react") {
        int indexToReact = int.parse(splited[1]);
        String reaction = splited[2];
        setState(() {
          messages[indexToReact].reaction = reaction;
        });
      } else if (splited[0] == "message") {
        var replyMessage;
        if (splited.length > 3 && splited[2] == "reply") {
          replyMessage = ChatMessage(
            messageContent: splited[3],
            messageType: "receiver",
            messageFormat: "message",
          );
        }
        var obj = ChatMessage(
          messageContent: splited[1],
          messageType: "receiver",
          messageFormat: "message",
          autoDelete: splited.contains("auto"),
          timeRemaining: splited.contains("auto") ? 10 : null,
          replyTo: replyMessage,
        );
        addMessageToList(obj);
      } else if (splited[0] == "tictactoe") {
        if (splited[1] == "start") {
          setState(() {
            ticTacToeGame = TicTacToeGame();
            currentDevicePlayer = splited[2]; // Set this device's role ("X")
            ticTacToeGame!.currentPlayer = "O"; // Start with "O"
          });
        } else if (splited[1] == "move") {
          int index = int.parse(splited[2]);
          String player = splited[3];
          if (ticTacToeGame != null && ticTacToeGame!.board[index] == "") {
            setState(() {
              ticTacToeGame!.board[index] =
                  player; // Update the board with the received move
              ticTacToeGame!._checkGameStatus(); // Check if the game has ended
            });
            if (!ticTacToeGame!.isGameOver) {
              // Switch the current player based on the received move
              ticTacToeGame!.currentPlayer = player == "O" ? "X" : "O";
            }
            if (ticTacToeGame!.isGameOver) {
              showGameOverDialog();
            }
          }
        }
      }
    });
  }

  void _handleTextSelection() {
    setState(() {
      isTextSelected =
          myController.selection.start != myController.selection.end;
    });
  }

  TextSpan _buildMessageContent(ChatMessage message) {
    final theme = Theme.of(context); // Access theme data
    final String text = message.messageContent;

    final RegExp pattern = RegExp(
      r'\*\*(.*?)\*\*|' // Bold
      r'_(.*?)_|' // Underline
      r'~(.*?)~|' // Strikethrough
      r'\*(.*?)\*|' // Italic
      r'~highlight\{(.*?)\}|' // Highlight
      r"((https?:\/\/)?[a-zA-Z0-9\-\._~:\/\?#\[\]@!\$&\'\(\)\*\+,;=]+\.[a-zA-Z0-9\-\._~:\/\?#\[\]@!\$&\'\(\)\*\+,;=]+)", // URL
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final Match match in pattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(color: Colors.white), // Set text color to white
        ));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set text color to white
            fontSize: 16,
          ),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.white, // Set text color to white
            fontSize: 16,
          ),
        ));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(
          text: match.group(3),
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.white, // Set text color to white
            fontSize: 16,
          ),
        ));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(
          text: match.group(4),
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white, // Set text color to white
            fontSize: 16,
          ),
        ));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(
          text: match.group(5),
          style: TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.white, // Set text color to white
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
        style: TextStyle(color: Colors.white), // Set text color to white
      ));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.iconTheme.color,
                  ),
                ),
                SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 6,
                      ),
                      Text(this.widget.connected_device.deviceName,
                          style: textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'RobotoMono',
                              color: theme.textTheme.bodyLarge?.color)),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        "connected",
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Toolbar below the AppBar
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.format_bold),
                  onPressed:
                      isTextSelected ? () => _formatSelectedText('bold') : null,
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Edit, Delete, Reply, React, or Copy",
                            style: textTheme.titleLarge,
                          ),
                          content: Text(
                            "Would you like to edit, delete, reply, react to, or copy this message?",
                            style: textTheme.bodyMedium,
                          ),
                          actions: <Widget>[
                            TextButton(
                              child:
                                  Text("Cancel", style: textTheme.labelLarge),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Edit", style: textTheme.labelLarge),
                              onPressed: () {
                                editMessage(index);
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child:
                                  Text("Delete", style: textTheme.labelLarge),
                              onPressed: () {
                                deleteMessageForBoth(index);
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Reply", style: textTheme.labelLarge),
                              onPressed: () {
                                replyTo(index);
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("React", style: textTheme.labelLarge),
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
                              child: Text("Copy", style: textTheme.labelLarge),
                              onPressed: () {
                                copyMessage(index);
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
                      alignment: (messages[index].messageType == "receiver"
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green[800], // Dark green background
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (messages[index].replyTo != null)
                              Container(
                                padding: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: theme.dividerColor),
                                  ),
                                ),
                                child: Text(
                                  "Replying to: " +
                                      messages[index].replyTo!.messageContent,
                                  style: textTheme.bodySmall?.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            RichText(
                              text: _buildMessageContent(messages[index]),
                            ),
                            if (messages[index].isEdited)
                              Text("(edited)",
                                  style: textTheme.bodySmall?.copyWith(
                                      fontSize: 10, color: Colors.white)),
                            if (messages[index].reaction != null)
                              Text(messages[index].reaction!,
                                  style: TextStyle(fontSize: 20)),
                            if (messages[index].autoDelete &&
                                messages[index].timeRemaining != null)
                              Text(
                                "Self-destructs in ${messages[index].timeRemaining} seconds",
                                style: textTheme.bodySmall?.copyWith(
                                    fontSize: 10, color: theme.errorColor),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (ticTacToeGame != null) buildTicTacToeBoard(),
          if (replyToMessage != null)
            Container(
              padding: EdgeInsets.all(10),
              color: theme.cardColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Replying to: " + replyToMessage!.messageContent,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
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
          Container(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            color: theme.scaffoldBackgroundColor,
            child: Row(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                SizedBox(
                  width: 15,
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
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: editingIndex == null
                          ? "Enter your message..."
                          : "Edit your message...",
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        fontFamily: 'RobotoMono',
                      ),
                      hintTextDirection: TextDirection.ltr,
                      border: InputBorder.none,
                    ),
                    controller: myController,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Send self-destructing message?",
                            style: textTheme.titleLarge,
                          ),
                          content: Text(
                            "Do you want this message to auto-delete after 10 seconds?",
                            style: textTheme.bodyMedium,
                          ),
                          actions: <Widget>[
                            TextButton(
                              child:
                                  Text("Cancel", style: textTheme.labelLarge),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Send", style: textTheme.labelLarge),
                              onPressed: () {
                                Navigator.of(context).pop();
                                sendMessage(myController.text,
                                    autoDelete: true);
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
                      textDirection: TextDirection.ltr,
                    ),
                    backgroundColor: Colors.green[500],
                    elevation: 0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.grid_view),
                  onPressed: startTicTacToe,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTicTacToeBoard() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => handleTicTacToeMove(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Center(
              child: Text(
                ticTacToeGame!.board[index],
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
    setState(() {
      ticTacToeGame = TicTacToeGame();
      currentDevicePlayer = "O"; // Set this device as "O"
      ticTacToeGame!.currentPlayer = "O"; // The initiator starts as "O"
    });
    widget.nearbyService.sendMessage(widget.connected_device.deviceId,
        "tictactoe|start|X"); // Tell the other device it is "X"
  }

  void handleTicTacToeMove(int index) {
    if (ticTacToeGame != null &&
        ticTacToeGame!.currentPlayer == currentDevicePlayer) {
      if (ticTacToeGame!.board[index] == "") {
        // Ensure the spot is empty
        String player =
            ticTacToeGame!.currentPlayer; // Capture the current player
        if (ticTacToeGame!.makeMove(index)) {
          setState(() {});
          widget.nearbyService.sendMessage(
            widget.connected_device.deviceId,
            "tictactoe|move|$index|$player", // Send the move to the opponent
          );
          if (!ticTacToeGame!.isGameOver) {
            // Switch the current player locally after the move is made
            ticTacToeGame!.currentPlayer = player == "O" ? "X" : "O";
          }
          if (ticTacToeGame!.isGameOver) {
            showGameOverDialog();
          }
        }
      }
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(ticTacToeGame!.winner == "Draw"
              ? "It's a Draw!"
              : "${ticTacToeGame!.winner} Wins!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  ticTacToeGame = null;
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class TicTacToeGame {
  List<String> board;
  String currentPlayer;
  bool isGameOver;
  String? winner;

  TicTacToeGame()
      : board = List.generate(9, (_) => ""),
        currentPlayer = "X",
        isGameOver = false,
        winner = null;

  void resetGame() {
    board = List.generate(9, (_) => "");
    currentPlayer = "X";
    isGameOver = false;
    winner = null;
  }

  bool makeMove(int index) {
    if (board[index] == "" && !isGameOver) {
      board[index] = currentPlayer;
      _checkGameStatus();
      if (!isGameOver) {
        currentPlayer = currentPlayer == "X" ? "O" : "X";
      }
      return true;
    }
    return false;
  }

  void _checkGameStatus() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] != "" &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winner = board[pattern[0]];
        isGameOver = true;
        return;
      }
    }

    if (!board.contains("")) {
      isGameOver = true;
      winner = "Draw";
    }
  }
}
