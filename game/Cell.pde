
interface TransformationFunc {
  void run(int x, int z);
}


class Cell {

  int x, z;
  color defaultColour = color(56, 56, 56);
  color winColour = color(248, 184, 144);
  color oldColour;
  color newColour;
  float colourChangePercent = 0;

  boolean outline = true;

  Cell(int _x, int _z) {
    x = _x;
    z = _z;
    oldColour = defaultColour;
    newColour = defaultColour;
  }
  
  void draw(TransformationFunc func) {
    updateChangeColour();

    if (outline) {
      stroke(128);
      strokeWeight(2);
    }
    else {
      noStroke();
    }
    fill(lerpColor(oldColour, newColour, softenAnimation(colourChangePercent)));

    pushMatrix();
    translate(x, 0, z);

    func.run(x, z);
    box(1, 0.25, 1);

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

  void changeToWinColour() {
    changeColour(winColour);
    outline = false;
  }
};
