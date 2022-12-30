
class Camera {

  int boardSize;

  Camera(int _boardSize) {
    boardSize = _boardSize;
  }
  
  void draw() {
    float aspectRatio = width * 1.0 / height;
    if (aspectRatio < 1) {
      ortho(-boardSize * CELL_SIZE, boardSize * CELL_SIZE, -boardSize * CELL_SIZE / aspectRatio, boardSize * CELL_SIZE / aspectRatio);
    }
    else {
      ortho(-boardSize * CELL_SIZE * aspectRatio, boardSize * CELL_SIZE * aspectRatio, -boardSize * CELL_SIZE, boardSize * CELL_SIZE);
    }
    camera(-boardSize * CELL_SIZE, -boardSize * CELL_SIZE * 1.4, -boardSize * CELL_SIZE, 0, -boardSize * CELL_SIZE * 0.8, 0, 0, 1, 0);
  }
};
