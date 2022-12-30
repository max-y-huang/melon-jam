
int X_AXIS = 0;
int Z_AXIS = 1;


class FlipRule {

  int axis, end1, end2, range;
  float position;
  
  FlipRule(int _axis, float _position, int _end1, int _end2, int _range) {
    axis = _axis;
    position = _position;
    end1 = min(_end1, _end2);
    end2 = max(_end1, _end2);
    range = _range;
  }

  boolean isInRange(int x, int z) {
    if (axis == Z_AXIS) {
      return abs(z - position) < range && x >= end1 && x <= end2;
    }
    return abs(x - position) < range && z >= end1 && z <= end2;
  }

  PVector applyRule(int x, int z) {
    if (!isInRange(x, z)) {
      return new PVector(x, 0, z);
    }
    if (axis == Z_AXIS) {
      return new PVector(x, 0, z + 2 * (position - z));
    }
    return new PVector(x + 2 * (position - x), 0, z);
  }

  void applyCellTransformation(int x, int z, float angle) {
    if (!isInRange(x, z)) {
      return;
    }
    if (axis == Z_AXIS) {
      translate(0, 0, (-z + position) * CELL_SIZE);
      rotateX(-angle);
      translate(0, 0, (z - position) * CELL_SIZE);
    }
    else {
      translate((-x + position) * CELL_SIZE, 0, 0);
      rotateZ(angle);
      translate((x - position) * CELL_SIZE, 0, 0);
    }
  }

  void drawOutline() {

    float y = -0.25;

    noFill();
    stroke(0, 255, 255);
    strokeWeight(3);
    
    pushMatrix();

    float x, z, w, d;
    if (axis == Z_AXIS) {
      x = (end1 + end2) / 2.0;
      z = position;
      w = end2 - end1 + 1;
      d = range * 2;
      line((end1 - 0.5) * CELL_SIZE, y * CELL_SIZE, position * CELL_SIZE, (end2 + 0.5) * CELL_SIZE, y * CELL_SIZE, position * CELL_SIZE);
    }
    else {
      x = position;
      z = (end1 + end2) / 2.0;
      w = range * 2;
      d = end2 - end1 + 1;
      line(position * CELL_SIZE, y * CELL_SIZE, (end1 - 0.5) * CELL_SIZE, position * CELL_SIZE, y * CELL_SIZE, (end2 + 0.5) * CELL_SIZE);
    }
    translate(x * CELL_SIZE, y * CELL_SIZE, z * CELL_SIZE);
    box(w * CELL_SIZE, 0, d * CELL_SIZE);
    
    popMatrix();
  }
};
