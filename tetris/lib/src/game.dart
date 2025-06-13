import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'blocks/blocks.dart';
import 'board.dart';

final class Game {
  late Board _board;
  late Block currentBlock;
  late Block nextBlock;
  bool _isGameOver = false;
  int score = 0;

  final Function(String scores) onGameOver;

  Game({required this.onGameOver}) {
    currentBlock = getNewRandomBlock();
    nextBlock = getNewRandomBlock();
  }

  /// Публичный геттер для доступа к приватному полю _board
  Board get board => _board;

  Future<void> start({required VoidCallback onUpdate}) async {
    _board = Board(
      currentBlock: currentBlock,
      newBlockFunc: newBlock,
      updateScore: updateScore,
      updateBlock: updateBlock,
      gameOver: gameOver,
    );

    while (!_isGameOver) {
      nextStep();
      await Future.delayed(const Duration(milliseconds: 500));
      onUpdate();
    }

    onGameOver(score.toString());
  }

  void updateBlock(Block block) {
    currentBlock = block;
  }

  /// Функция обновления счета без параметров (увеличивает на 1)
  void updateScore() {
    score += 1;
  }

  Block newBlock() {
    currentBlock = nextBlock;
    nextBlock = getNewRandomBlock();
    return currentBlock;
  }

  bool get isGameOver => _isGameOver;

  void gameOver() {
    _isGameOver = true;
  }

  void nextStep() {
    var x = currentBlock.x;
    var y = currentBlock.y;

    if (!_board.isFilledBlock(x, y + 1)) {
      _board.moveBlock(x, y + 1);
    } else {
      _board.clearLine();
      _board.savePresentBoardToCpy();
      _board.newBlock();
      _board.drawBoard();
    }
  }
}
