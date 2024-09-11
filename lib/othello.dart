import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'chat.dart';
import 'message.dart';

class OthelloPage extends StatefulWidget {
  final NearbyService nearbyService;
  final Device connectedDevice;
  final String currentDevicePlayer;
  final String myData;
  final List<ChatMessage>? chatState;

  const OthelloPage({
    required this.nearbyService,
    required this.connectedDevice,
    required this.currentDevicePlayer,
    required this.myData,
    this.chatState,
  });

  @override
  OthelloPageState createState() => OthelloPageState();
}

class OthelloPageState extends State<OthelloPage> {
  OthelloGame? othelloGame;

  @override
  void initState() {
    super.initState();
    othelloGame = OthelloGame();
    othelloGame!.resetGame(); // Initialize the board with starting positions
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final message = data["message"];
      final splited = message.split('|');
      if (splited[0] == "othello") {
        if (splited[1] == "move") {
          int index = int.parse(splited[2]);
          String player = splited[3];

          if (othelloGame != null &&
              othelloGame!.board[index] == "" &&
              othelloGame!.isValidMove(index, player)) {
            setState(() {
              othelloGame!.makeMove(index, player);
              if (othelloGame!.isGameOver) {
                showGameOverDialog();
              }
            });
          }
        } else if (splited[1] == "end") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(
                nearbyService: widget.nearbyService,
                connectedDevice: widget.connectedDevice,
                myData: widget.myData,
                chatState: widget.chatState,
              ),
            ),
          ).then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScrollController scrollController = ScrollController();
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          });
        }
      }
    });
  }

  void handleOthelloMove(int index) {
    if (othelloGame != null &&
        othelloGame!.currentPlayer == widget.currentDevicePlayer &&
        othelloGame!.isValidMove(index, widget.currentDevicePlayer)) {
      String player = othelloGame!.currentPlayer;
      if (othelloGame!.makeMove(index, player)) {
        setState(() {});
        widget.nearbyService.sendMessage(
          widget.connectedDevice.deviceId,
          "othello|move|$index|$player",
        );
        if (othelloGame!.isGameOver) {
          showGameOverDialog();
        }
      }
    }
  }

  void _confirmEndGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Game"),
          content: Text("Are you sure you want to end this game?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without ending the game
              },
            ),
            TextButton(
              child: Text("End Game"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _endGame(); // End the game and navigate to chat
              },
            ),
          ],
        );
      },
    );
  }

  void _endGame() {
    setState(() {
      othelloGame = null;
    });

    // Send end game message to the opponent
    widget.nearbyService
        .sendMessage(widget.connectedDevice.deviceId, "othello|end");

    // Navigate back to the Chat screen for the current user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          nearbyService: widget.nearbyService,
          connectedDevice: widget.connectedDevice,
          myData: widget.myData,
          chatState: widget.chatState,
        ),
      ),
    ).then((_) {
      // Ensure scroll to bottom after returning to chat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScrollController scrollController = ScrollController();
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void showGameOverDialog() {
    String message;

    if (othelloGame!.winner == "Draw") {
      message = "It's a Draw!";
    } else if (othelloGame!.winner == widget.currentDevicePlayer) {
      message = "You win!";
    } else {
      message = "You lose!";
    }

    // Send the game result to the connected device
    widget.nearbyService.sendMessage(
      widget.connectedDevice.deviceId,
      "othello_result|$message",
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Othello"),
        automaticallyImplyLeading: false,
      ),
      body: othelloGame == null
          ? Center(
              child: Text("Game has ended."),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    othelloGame!.currentPlayer == widget.currentDevicePlayer
                        ? "Your turn (${othelloGame!.currentPlayer})"
                        : "Opponent's turn (${othelloGame!.currentPlayer})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      // Determine the border color based on the theme
                      Color borderColor =
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black;

                      String disc = othelloGame!.board[index];
                      Color discColor;
                      if (disc == "B") {
                        discColor = Colors.black;
                      } else if (disc == "W") {
                        discColor = Colors.white;
                      } else {
                        discColor = Colors.transparent;
                      }

                      return GestureDetector(
                        onTap: () => handleOthelloMove(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            color: disc == "B" || disc == "W"
                                ? (disc == "B"
                                    ? Colors.green[800]
                                    : Colors.green[400])
                                : Colors.green[600],
                          ),
                          child: Center(
                            child: disc != ""
                                ? Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: discColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _confirmEndGame,
                  child: Text("End Game"),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}

class OthelloGame {
  List<String> board; // "B", "W", or ""
  String currentPlayer; // "B" or "W"
  bool isGameOver;
  String? winner;

  OthelloGame()
      : board = List.generate(64, (_) => ""),
        currentPlayer = "B", // Black starts
        isGameOver = false,
        winner = null;

  void resetGame() {
    board = List.generate(64, (_) => "");
    // Set up the initial four discs
    board[27] = "W";
    board[28] = "B";
    board[35] = "B";
    board[36] = "W";
    currentPlayer = "B";
    isGameOver = false;
    winner = null;
  }

  bool isValidMove(int index, String player) {
    if (board[index] != "") return false;

    List<int> directions = [
      -9, // NW
      -8, // N
      -7, // NE
      -1, // W
      1, // E
      7, // SW
      8, // S
      9, // SE
    ];

    String opponent = player == "B" ? "W" : "B";
    for (int direction in directions) {
      int currentIndex = index + direction;
      bool hasOpponentBetween = false;

      // Check boundaries
      while (_isInBounds(currentIndex, index, direction) &&
          board[currentIndex] == opponent) {
        hasOpponentBetween = true;
        currentIndex += direction;
      }

      if (hasOpponentBetween &&
          _isInBounds(currentIndex, index, direction) &&
          board[currentIndex] == player) {
        return true;
      }
    }

    return false;
  }

  bool makeMove(int index, String player) {
    if (!isValidMove(index, player)) return false;

    board[index] = player;
    _flipDiscs(index, player);
    _checkGameStatus();

    if (!isGameOver) {
      currentPlayer = player == "B" ? "W" : "B";
    }

    return true;
  }

  void _flipDiscs(int index, String player) {
    List<int> directions = [
      -9, // NW
      -8, // N
      -7, // NE
      -1, // W
      1, // E
      7, // SW
      8, // S
      9, // SE
    ];

    String opponent = player == "B" ? "W" : "B";

    for (int direction in directions) {
      int currentIndex = index + direction;
      List<int> discsToFlip = [];

      while (_isInBounds(currentIndex, index, direction) &&
          board[currentIndex] == opponent) {
        discsToFlip.add(currentIndex);
        currentIndex += direction;
      }

      if (_isInBounds(currentIndex, index, direction) &&
          board[currentIndex] == player) {
        for (int flipIndex in discsToFlip) {
          board[flipIndex] = player;
        }
      }
    }
  }

  void _checkGameStatus() {
    if (!board.contains("")) {
      // Board is full, game over
      isGameOver = true;
      _determineWinner();
    } else if (!_hasAnyValidMoves("B") && !_hasAnyValidMoves("W")) {
      // No valid moves for either player, game over
      isGameOver = true;
      _determineWinner();
    }
  }

  void _determineWinner() {
    int blackCount = board.where((disc) => disc == "B").length;
    int whiteCount = board.where((disc) => disc == "W").length;

    if (blackCount > whiteCount) {
      winner = "B";
    } else if (whiteCount > blackCount) {
      winner = "W";
    } else {
      winner = "Draw";
    }
  }

  bool _hasAnyValidMoves(String player) {
    for (int i = 0; i < 64; i++) {
      if (isValidMove(i, player)) return true;
    }
    return false;
  }

  bool _isInBounds(int currentIndex, int originalIndex, int direction) {
    int originalRow = originalIndex ~/ 8;
    int currentRow = currentIndex ~/ 8;
    int currentCol = currentIndex % 8;

    // Ensure the index is within the board boundaries
    if (currentIndex < 0 || currentIndex >= 64) return false;

    // Diagonal moves cross rows, so row check is different
    if (direction == -9 ||
        direction == -7 ||
        direction == 7 ||
        direction == 9) {
      return true;
    }

    // For other directions, ensure the move stays within the same row
    return originalRow == currentRow || currentCol >= 0 && currentCol < 8;
  }
}
