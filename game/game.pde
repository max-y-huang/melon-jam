
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
}


void keyPressed() {
  if (key == 'z') {
    stage.applyRule(0);
  }
  if (key == 'x') {
    stage.applyRule(1);
  }
}

float softenAnimation(float x) {
  return sin(PI * (x - 0.5)) / 2 + 0.5;
}
