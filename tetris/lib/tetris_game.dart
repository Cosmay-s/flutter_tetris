import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/src/board.dart';
import '/src/game.dart';

class _GamePainter extends CustomPainter {
  final List<List<int>> board;
  final double blockSize;

  _GamePainter(this.board, this.blockSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        Rect rect = Rect.fromLTWH(
          j * blockSize,
          i * blockSize,  // Исправлено
          blockSize,
          blockSize,
        );
        switch (board[i][j]) {
          case Board.posFree:
            paint.color = Colors.black;
            break;
          case Board.posFilled:
            paint.color = Colors.white;
            break;
          case Board.posBoarder:
            paint.color = Colors.red;
            break;
          default:
            paint.color = Colors.grey;
        }
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  late Game game;

  void _showGameOverDialog(String scores) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: Text('Your score: $scores'),
            actions: const [],
          );
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    game = Game(onGameOver: _showGameOverDialog);
    game.start(
      onUpdate: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          game.board.keyboardEventHandler(event.logicalKey.keyId);
          setState(() {});
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Align(
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final board = game.board.mainBoard;
            double blockSize = min(
              constraints.maxWidth / board[0].length,
              constraints.maxHeight / board.length,
            );
            return CustomPaint(
              painter: _GamePainter(board, blockSize),
              size: Size(board[0].length * blockSize, board.length * blockSize),
            );
          },
        ),
      ),
    );
  }
}
