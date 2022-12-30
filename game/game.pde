int CELL_SIZE = 20;


Stage stage;


void setup() {
  size(720, 720, P3D);
  surface.setTitle("Title Here");
  smooth(8);
  frameRate(60);
  stage = new Stage(8);
}

int temp = 0;


void draw() {
  background(32, 32, 32);
  stage.draw();

  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();

  fill(255, 255, 255);

  temp += 1;

  ellipse(width / 2, height / 2 + temp, 10, 10);

  hint(ENABLE_DEPTH_TEST);
}


void keyPressed() {
  // stage.selectPrevRule();
  // stage.selectNextRule();
  if (key == CODED) {
    if (keyCode == LEFT) {
      stage.selectPrevRule();
    }
    else if (keyCode == RIGHT) {
      stage.selectNextRule();
    }
  }
  else if (key == ' ') {
    stage.applyRule();
  }
}

float softenAnimation(float x) {
  return sin(PI * (x - 0.5)) / 2 + 0.5;
}
