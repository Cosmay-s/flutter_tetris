import 'blocks/blocks.dart';

class Board {
  static const int heightBoard = 20;
  static const int widthBoard = 10;

  static const int posFree = 0;
  static const int posFilled = 1;
  static const int posBoarder = 2;

  late List<List<int>> mainBoard;
  late List<List<int>> mainCpy;

  // Функция для создания нового блока
  Block Function() newBlockFunc;

  // Функция обновления счета (без параметров)
  void Function() updateScore;

  // Функция обновления текущего блока
  void Function(Block block) updateBlock;

  // Функция окончания игры
  void Function() gameOver;

  Block currentBlock;

  Board({
    required this.newBlockFunc,
    required this.currentBlock,
    required this.updateScore,
    required this.updateBlock,
    required this.gameOver,
  }) {
    // Инициализация доски и её копии
    mainBoard = List.generate(
      heightBoard,
      (_) => List.filled(widthBoard, posFree),
    );
    mainCpy = List.generate(
      heightBoard,
      (_) => List.filled(widthBoard, posFree),
    );

    initDrawMain();
  }

  /// Обработка нажатий клавиш (WASD)
  void keyboardEventHandler(int key) {
    var x = currentBlock.x;
    var y = currentBlock.y;

    switch (key) {
      case 119: // W - поворот блока
        rotateBlock();
        break;
      case 97: // A - движение влево
        if (!isFilledBlock(x - 1, y)) {
          moveBlock(x - 1, y);
        }
        break;
      case 115: // S - движение вниз
        if (!isFilledBlock(x, y + 1)) {
          moveBlock(x, y + 1);
        }
        break;
      case 100: // D - движение вправо
        if (!isFilledBlock(x + 1, y)) {
          moveBlock(x + 1, y);
        }
        break;
      default:
        // Ничего не делаем для остальных клавиш
        break;
    }
  }

  /// Копирует текущее состояние доски в копию
  void savePresentBoardToCpy() {
    for (int i = 0; i < heightBoard; i++) {
      for (int j = 0; j < widthBoard; j++) {
        mainCpy[i][j] = mainBoard[i][j];
      }
    }
  }

  /// Инициализация доски: рисуем границы и создаём первый блок
  void initDrawMain() {
    for (int i = 0; i < heightBoard; i++) {
      for (int j = 0; j < widthBoard; j++) {
        if (j == 0 || j == widthBoard - 1 || i == heightBoard - 1) {
          mainBoard[i][j] = posBoarder;
          mainCpy[i][j] = posBoarder;
        } else {
          mainBoard[i][j] = posFree;
          mainCpy[i][j] = posFree;
        }
      }
    }

    newBlock();
    drawBoard();
  }

  /// Здесь можно реализовать отрисовку или обновление UI (пусто пока)
  void drawBoard() {
    // В твоём коде UI обычно обновляется через setState, так что тут можно оставить пустым
  }

  /// Создаёт новый блок и ставит его в доску
  void newBlock() {
    currentBlock = newBlockFunc();
    var x = currentBlock.x;
    var y = currentBlock.y;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int boardX = x + j;
        int boardY = y + i;

        if (boardY >= 0 && boardY < heightBoard && boardX >= 0 && boardX < widthBoard) {
          mainBoard[boardY][boardX] = mainCpy[boardY][boardX] + currentBlock[i][j];

          if (mainBoard[boardY][boardX] > 1) {
            // Пересечение с уже занятыми ячейками — игра окончена
            gameOver();
          }
        }
      }
    }
  }

  /// Перемещает текущий блок на новые координаты (x2, y2)
  void moveBlock(int x2, int y2) {
    // Убираем текущий блок с доски
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int oldX = currentBlock.x + j;
        int oldY = currentBlock.y + i;
        if (oldY >= 0 && oldY < heightBoard && oldX >= 0 && oldX < widthBoard) {
          mainBoard[oldY][oldX] -= currentBlock[i][j];
        }
      }
    }

    // Перемещаем блок
    currentBlock.move(x2, y2);

    // Рисуем блок в новой позиции
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int newX = currentBlock.x + j;
        int newY = currentBlock.y + i;
        if (newY >= 0 && newY < heightBoard && newX >= 0 && newX < widthBoard) {
          mainBoard[newY][newX] += currentBlock[i][j];
        }
      }
    }

    drawBoard();
  }

  /// Поворот блока с проверкой столкновений
  void rotateBlock() {
    var tmpBlock = currentBlock.copyWith();
    currentBlock.rotate();

    // Если после поворота блок пересекается с чем-то, откатываем
    if (isFilledBlock(tmpBlock.x, tmpBlock.y)) {
      currentBlock = tmpBlock;
      updateBlock(currentBlock);
      return;
    }

    var x = currentBlock.x;
    var y = currentBlock.y;

    // Убираем старый блок
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int boardY = y + i;
        int boardX = x + j;
        if (boardY >= 0 && boardY < heightBoard && boardX >= 0 && boardX < widthBoard) {
          mainBoard[boardY][boardX] -= tmpBlock[i][j];
        }
      }
    }

    // Рисуем повернутый блок
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int boardY = y + i;
        int boardX = x + j;
        if (boardY >= 0 && boardY < heightBoard && boardX >= 0 && boardX < widthBoard) {
          mainBoard[boardY][boardX] += currentBlock[i][j];
        }
      }
    }

    drawBoard();
  }

  /// Проверяет и очищает заполненные линии, сдвигая доску вниз
  void clearLine() {
    for (int row = 0; row < heightBoard - 1; row++) {
      bool lineFull = true;
      for (int col = 1; col < widthBoard - 1; col++) {
        if (mainBoard[row][col] == posFree) {
          lineFull = false;
          break;
        }
      }

      if (lineFull) {
        // Сдвигаем все строки сверху вниз
        for (int k = row; k > 0; k--) {
          for (int idx = 1; idx < widthBoard - 1; idx++) {
            mainBoard[k][idx] = mainBoard[k - 1][idx];
          }
        }
        // Верхний ряд очищаем
        for (int idx = 1; idx < widthBoard - 1; idx++) {
          mainBoard[0][idx] = posFree;
        }

        updateScore(); // Увеличиваем счет
      }
    }
  }

  /// Проверяет, пересекается ли текущий блок с чем-либо на доске в координатах x2,y2
  bool isFilledBlock(int x2, int y2) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int boardX = x2 + j;
        int boardY = y2 + i;
        if (boardY >= 0 && boardY < heightBoard && boardX >= 0 && boardX < widthBoard) {
          if (currentBlock[i][j] != 0 && mainCpy[boardY][boardX] != 0) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
