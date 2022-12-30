
class Camera {

  int boardSize;

  Camera(int _boardSize) {
    boardSize = _boardSize;
  }
  
  void draw() {
    float aspectRatio = width * 1.0 / height;
    if (aspectRatio < 1) {
      ortho(-boardSize, boardSize, -boardSize / aspectRatio, boardSize / aspectRatio);
    }
    else {
      ortho(-boardSize * aspectRatio, boardSize * aspectRatio, -boardSize, boardSize);
    }
    camera(-boardSize, -boardSize * 1.2, -boardSize, 0, -boardSize * 0.6, 0, 0, 1, 0);
  }
};
