
interface TransformationFunc {
  void run(int x, int z);
}


class Cell {

  int x, z;
  color defaultColour = color(48, 48, 48);
  color oldColour;
  color newColour;
  float colourChangePercent = 0;

  Cell(int _x, int _z) {
    x = _x;
    z = _z;
    oldColour = defaultColour;
    newColour = defaultColour;
  }
  
  void draw(TransformationFunc func) {
    updateChangeColour();

    stroke(128);
    strokeWeight(2);
    fill(lerpColor(oldColour, newColour, softenAnimation(colourChangePercent)));

    pushMatrix();
    translate(x * CELL_SIZE, 0, z * CELL_SIZE);

    func.run(x, z);
    box(CELL_SIZE, 0.25 * CELL_SIZE, CELL_SIZE);

    popMatrix();
  }
  void draw() {
    draw((a, b) -> {});
  }

  void updateChangeColour() {
    if (oldColour != newColour) {
      colourChangePercent += 0.07;
      if (colourChangePercent >= 1) {
        oldColour = newColour;
      }
    }
  }

  void changeColour(color c, boolean instantaneous) {
    colourChangePercent = 0;
    newColour = c;
    if (instantaneous) {
      oldColour = newColour;
    }
  }
  void changeColour(boolean instantaneous) {
    changeColour(defaultColour, instantaneous);
  }
  void changeColour(color c) {
    changeColour(c, false);
  }
  void changeColour() {
    changeColour(defaultColour, false);
  }
};
