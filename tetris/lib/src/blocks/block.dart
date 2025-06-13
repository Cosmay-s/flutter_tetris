base class Block {
  int _x;
  int _y;


  List<List<int>> _block = List.generate(
    4,
    (_) => List.filled(4, 0),
  );


  Block(this._block, [this._x = 4, this._y = 0]);

  int get x => _x;
  int get y => _y;


  void move(int x, int y) {
    _x = x;
    _y = y;
  }


  Block copyWith({int? xParam, int? yParam}) {
    List<List<int>> tmp = List.generate(4, (_) => List.filled(4, 0));
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        tmp[i][j] = _block[i][j];
      }
    }
    return Block(tmp, xParam ?? _x, yParam ?? _y);
  }

  void rotate() {
    List<List<int>> tmp = List.generate(4, (_) => List.filled(4, 0));
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        tmp[i][j] = _block[j][3 - i];
      }
    }
    _block = tmp;
  }

  List<int> operator [](int index) {
    return _block[index];
  }
}