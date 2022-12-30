
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
      translate(0, 0, -z + position);
      rotateX(-angle);
      translate(0, 0, z - position);
    }
    else {
      translate(-x + position, 0, 0);
      rotateZ(angle);
      translate(x - position, 0, 0);
    }
  }
};
