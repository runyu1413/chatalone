import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'chat.dart';
import 'message.dart';

class ConnectFourPage extends StatefulWidget {
  final NearbyService nearbyService;
  final Device connectedDevice;
  final String currentDevicePlayer; // This should be "X" or "O"
  final String myData;
  final List<ChatMessage>? chatState;

  const ConnectFourPage({
    required this.nearbyService,
    required this.connectedDevice,
    required this.currentDevicePlayer,
    required this.myData,
    this.chatState,
  });

  @override
  ConnectFourPageState createState() => ConnectFourPageState();
}

class ConnectFourPageState extends State<ConnectFourPage> {
  ConnectFourGame? connectFourGame;

  @override
  void initState() {
    super.initState();
    connectFourGame = ConnectFourGame();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final splited = data["message"].split('|');
      if (splited[0] == "connectfour") {
        if (splited[1] == "move") {
          int column = int.parse(splited[2]);
          String player = splited[3];

          setState(() {
            if (connectFourGame != null &&
                !connectFourGame!.isColumnFull(column)) {
              connectFourGame!.makeMove(column, player);
              if (!connectFourGame!.isGameOver) {
                // Alternate the player
                connectFourGame!.currentPlayer = player == "R" ? "Y" : "R";
              }
              if (connectFourGame!.isGameOver) {
                showGameOverDialog();
              }
            }
          });
        } else if (splited[1] == "end") {
          // Handle opponent ending the game
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
      }
    });
  }

  void handleConnectFourMove(int column) {
    if (connectFourGame != null &&
        connectFourGame!.currentPlayer == widget.currentDevicePlayer &&
        !connectFourGame!.isColumnFull(column)) {
      String player = connectFourGame!.currentPlayer;
      connectFourGame!.makeMove(column, player);
      setState(() {});
      widget.nearbyService.sendMessage(
        widget.connectedDevice.deviceId,
        "connectfour|move|$column|$player",
      );
      if (!connectFourGame!.isGameOver) {
        connectFourGame!.currentPlayer = player == "R" ? "Y" : "R";
      }
      if (connectFourGame!.isGameOver) {
        showGameOverDialog();
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
      connectFourGame = null;
    });

    // Send end game message to the opponent
    widget.nearbyService
        .sendMessage(widget.connectedDevice.deviceId, "connectfour|end");

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

    if (connectFourGame!.winner == "Draw") {
      message = "It's a Draw!";
    } else if (connectFourGame!.winner == widget.currentDevicePlayer) {
      message = "You win!";
    } else {
      message = "You lose!";
    }

    // Send the game result to the connected device
    widget.nearbyService.sendMessage(
      widget.connectedDevice.deviceId,
      "connectfour_result|$message",
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
        title: Text("Connect Four"),
        automaticallyImplyLeading: false,
      ),
      body: connectFourGame == null
          ? Center(
              child: Text("Game has ended."),
            )
          : Column(
              children: [
                Text(
                  connectFourGame!.currentPlayer == widget.currentDevicePlayer
                      ? "Your turn"
                      : "Opponent's turn",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 42, // 6 rows * 7 columns
                  itemBuilder: (context, index) {
                    int row = index ~/ 7;
                    int column = index % 7;

                    // Determine the border color based on the theme
                    Color borderColor =
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black;

                    // Determine the color of the circle
                    Color circleColor;
                    if (connectFourGame!.board[row][column] == "R") {
                      circleColor = Colors.red;
                    } else if (connectFourGame!.board[row][column] == "Y") {
                      circleColor = Colors.yellow;
                    } else {
                      circleColor =
                          Colors.transparent; // No player, so transparent
                    }

                    return GestureDetector(
                      onTap: () => handleConnectFourMove(column),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: circleColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _confirmEndGame,
                  child: Text("End Game"),
                ),
              ],
            ),
    );
  }
}

class ConnectFourGame {
  List<List<String>> board;
  String currentPlayer;
  bool isGameOver;
  String? winner;

  ConnectFourGame()
      : board = List.generate(6, (_) => List.generate(7, (_) => "")),
        currentPlayer = "R", // Red always starts first
        isGameOver = false,
        winner = null;

  void resetGame() {
    board = List.generate(6, (_) => List.generate(7, (_) => ""));
    currentPlayer = "R"; // Red always starts first
    isGameOver = false;
    winner = null;
  }

  bool isColumnFull(int column) {
    return board[0][column] != "";
  }

  void makeMove(int column, String player) {
    if (!isColumnFull(column) && !isGameOver) {
      for (int row = 5; row >= 0; row--) {
        if (board[row][column] == "") {
          board[row][column] = player;
          break;
        }
      }
      _checkGameStatus();
    }
  }

  void _checkGameStatus() {
    // Check horizontal, vertical, and diagonal wins
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 7; col++) {
        if (board[row][col] != "" &&
            (_checkDirection(row, col, 1, 0) ||
                _checkDirection(row, col, 0, 1) ||
                _checkDirection(row, col, 1, 1) ||
                _checkDirection(row, col, 1, -1))) {
          winner = board[row][col];
          isGameOver = true;
          return;
        }
      }
    }

    // Check for draw
    if (board.every((row) => row.every((cell) => cell != ""))) {
      isGameOver = true;
      winner = "Draw";
    }
  }

  bool _checkDirection(int row, int col, int rowDelta, int colDelta) {
    String player = board[row][col];
    for (int i = 1; i < 4; i++) {
      int newRow = row + i * rowDelta;
      int newCol = col + i * colDelta;
      if (newRow < 0 ||
          newRow >= 6 ||
          newCol < 0 ||
          newCol >= 7 ||
          board[newRow][newCol] != player) {
        return false;
      }
    }
    return true;
  }
}
