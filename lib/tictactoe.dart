import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'chat.dart';

class TicTacToePage extends StatefulWidget {
  final NearbyService nearbyService;
  final Device connectedDevice;
  final String currentDevicePlayer;
  final String myData;
  final List<ChatMessage>? chat_state;

  TicTacToePage({
    required this.nearbyService,
    required this.connectedDevice,
    required this.currentDevicePlayer,
    required this.myData,
    this.chat_state,
  });

  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  TicTacToeGame? ticTacToeGame;

  @override
  void initState() {
    super.initState();
    ticTacToeGame = TicTacToeGame();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    widget.nearbyService.dataReceivedSubscription(callback: (data) {
      final splited = data["message"].split('|');
      if (splited[0] == "tictactoe") {
        if (splited[1] == "move") {
          int index = int.parse(splited[2]);
          String player = splited[3];

          if (ticTacToeGame != null && ticTacToeGame!.board[index] == "") {
            setState(() {
              ticTacToeGame!.board[index] = player;
              ticTacToeGame!._checkGameStatus();

              if (!ticTacToeGame!.isGameOver) {
                ticTacToeGame!.currentPlayer = player == "X" ? "O" : "X";
              }
              if (ticTacToeGame!.isGameOver) {
                showGameOverDialog();
              }
            });
          }
        } else if (splited[1] == "end") {
          // Handle opponent ending the game
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(
                nearbyService: widget.nearbyService,
                connected_device: widget.connectedDevice,
                myData: widget.myData,
                chat_state: widget.chat_state,
              ),
            ),
          ).then((_) {
            // Ensure scroll to bottom after returning to chat
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScrollController _scrollController = ScrollController();
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          });
        }
      }
    });
  }

  void handleTicTacToeMove(int index) {
    if (ticTacToeGame != null &&
        ticTacToeGame!.currentPlayer == widget.currentDevicePlayer) {
      if (ticTacToeGame!.board[index] == "") {
        String player = ticTacToeGame!.currentPlayer;
        if (ticTacToeGame!.makeMove(index)) {
          setState(() {});
          widget.nearbyService.sendMessage(
            widget.connectedDevice.deviceId,
            "tictactoe|move|$index|$player",
          );
          if (!ticTacToeGame!.isGameOver) {
            ticTacToeGame!.currentPlayer = player == "O" ? "X" : "O";
          }
          if (ticTacToeGame!.isGameOver) {
            showGameOverDialog();
          }
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
      ticTacToeGame = null;
    });

    // Send end game message to the opponent
    widget.nearbyService
        .sendMessage(widget.connectedDevice.deviceId, "tictactoe|end");

    // Navigate back to the Chat screen for the current user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          nearbyService: widget.nearbyService,
          connected_device: widget.connectedDevice,
          myData: widget.myData,
          chat_state: widget.chat_state,
        ),
      ),
    ).then((_) {
      // Ensure scroll to bottom after returning to chat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScrollController _scrollController = ScrollController();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void showGameOverDialog() {
    String message;

    if (ticTacToeGame!.winner == "Draw") {
      message = "It's a Draw!";
    } else if (ticTacToeGame!.winner == widget.currentDevicePlayer) {
      message = "You win!";
    } else {
      message = "You lose!";
    }

    // Send the game result to the connected device
    widget.nearbyService.sendMessage(
      widget.connectedDevice.deviceId,
      "tictactoe_result|$message",
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chat(
                      nearbyService: widget.nearbyService,
                      connected_device: widget.connectedDevice,
                      myData: widget.myData,
                      chat_state: widget.chat_state,
                    ),
                  ),
                ).then((_) {
                  // Ensure scroll to bottom after returning to chat
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScrollController _scrollController = ScrollController();
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                });
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
        title: Text("Tic Tac Toe"),
        automaticallyImplyLeading: false,
      ),
      body: ticTacToeGame == null
          ? Center(
              child: Text("Game has ended."),
            )
          : Column(
              children: [
                Text(
                  ticTacToeGame!.currentPlayer == widget.currentDevicePlayer
                      ? "Your turn"
                      : "Opponent's turn",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    // Determine the border color based on the theme
                    Color borderColor =
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black;

                    return GestureDetector(
                      onTap: () => handleTicTacToeMove(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            ticTacToeGame!.board[index],
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _confirmEndGame,
                  child: Text("End Game"),
                ),
              ],
            ),
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
