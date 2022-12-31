import java.util.*;
import processing.sound.*;


SoundFile bgm;
SoundFile cursorSe;
SoundFile swapSe;
SoundFile clearLevelSe;
Stage stage;


void setup() {
  fullScreen(P3D);
  surface.setTitle("Flipping Houses");
  surface.setIcon(loadImage("data/icon.png"));
  smooth(8);
  frameRate(60);

  bgm = new SoundFile(this, "assets/audio/bgm.wav");
  bgm.amp(0.5);
  bgm.loop();

  cursorSe = new SoundFile(this, "assets/audio/cursor.wav");
  cursorSe.amp(0.67);

  swapSe = new SoundFile(this, "assets/audio/swap2.wav");
  swapSe.amp(0.67);

  clearLevelSe = new SoundFile(this, "assets/audio/clearLevel2.wav");
  clearLevelSe.amp(0.67);

  stage = new Stage(0);
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
  float size = 24;
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

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e < 0) {
    stage.selectNextRule();
  }
  else if (e > 0) {
    stage.selectPrevRule();
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
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
