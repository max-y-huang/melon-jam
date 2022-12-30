
Stage stage;


void setup() {
  size(720, 720, P3D);
  surface.setTitle("Title Here");
  smooth(8);
  frameRate(60);
  stage = new Stage(8);
}


void draw() {
  background(32, 32, 32);
  stage.draw();

  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  noLights();

  drawSelectedRule();

  hint(ENABLE_DEPTH_TEST);
}

void drawSelectedRule() {
  float size = min(height / 32.0, 32);
  noStroke();

  pushMatrix();

  translate(width / 2 - size * (stage.rules.size() - 1), height - 2 * size);

  for (int i = 0; i < stage.rules.size(); i++) {
    if (i == stage.currentRuleIndex) {
      fill(0, 255, 255);
    }
    else {
      fill(128, 128, 128);
    }
    ellipse(0 + size * 2 * i, 0, size, size);
  }

  popMatrix();
}


void keyPressed() {
  if ((key == CODED && keyCode == LEFT) || key == 'a' || key == 'A') {
    stage.selectPrevRule();
  }
  if ((key == CODED && keyCode == RIGHT) || key == 'd' || key == 'D') {
    stage.selectNextRule();
  }
  else if (key == ' ') {
    stage.applyRule();
  }
}

float softenAnimation(float x) {
  return sin(PI * (x - 0.5)) / 2 + 0.5;
}


void dashline(float x0, float y0, float z0, float x1, float y1, float z1, float[] spacing) {
  float distance = dist(x0, y0, z0, x1, y1, z1);
  float [] xSpacing = new float[spacing.length];
  float [] ySpacing = new float[spacing.length];
  float [] zSpacing = new float[spacing.length];
  float drawn = 0.0;

  if (distance > 0) {
    int i;
    boolean drawLine = true;
    for (i = 0; i < spacing.length; i++) {
      xSpacing[i] = lerp(0, (x1 - x0), spacing[i] / distance);
      ySpacing[i] = lerp(0, (y1 - y0), spacing[i] / distance);
      zSpacing[i] = lerp(0, (z1 - z0), spacing[i] / distance);
    }
    i = 0;
    while (drawn < distance) {
      if (drawLine) {
        line(x0, y0, z0, x0 + xSpacing[i], y0 + ySpacing[i], z0 + zSpacing[i]);
      }
      x0 += xSpacing[i];
      y0 += ySpacing[i];
      z0 += zSpacing[i];
      drawn = drawn + mag(xSpacing[i], ySpacing[i], zSpacing[i]);
      i = (i + 1) % spacing.length;
      drawLine = !drawLine;
    }
  }
}

void dashline(float x0, float y0, float z0, float x1, float y1, float z1, float dash, float gap) {
  float [] spacing = { dash, gap };
  dashline(x0, y0, z0, x1, y1, z1, spacing);
}
