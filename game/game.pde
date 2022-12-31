import java.util.*;
import javax.swing.*; 
import processing.sound.*;


int TITLE_SCREEN = 0;
int GAME_SCREEN = 1;
int END_SCREEN = 2;


SoundFile bgm;
SoundFile cursorSe;
SoundFile swapSe;
SoundFile startLevelSe;
SoundFile clearLevelSe;

PFont karla;
PFont karlaTitle;

PImage titleScreenImg;


Stage stage;
int screen;
boolean promptingClose = false;


void setup() {
  fullScreen(P3D);
  surface.setTitle("Flipping Houses");
  smooth(4);
  frameRate(60);

  bgm = new SoundFile(this, "data/audio/bgm.wav");
  bgm.amp(0.5);
  bgm.loop();

  cursorSe = new SoundFile(this, "data/audio/cursor.wav");
  cursorSe.amp(0.67);

  swapSe = new SoundFile(this, "data/audio/swap2.wav");
  swapSe.amp(0.67);

  startLevelSe = new SoundFile(this, "data/audio/startLevel.wav");
  startLevelSe.amp(0.67);

  clearLevelSe = new SoundFile(this, "data/audio/clearLevel2.wav");
  clearLevelSe.amp(0.67);

  karla = createFont("fonts/karlaRegular.ttf", em());
  karlaTitle = createFont("fonts/karlaBold.ttf", 2.5 * em());

  titleScreenImg = loadImage("data/imgs/titleScreen.png");

  screen = TITLE_SCREEN;
}


void draw() {
  if (screen != TITLE_SCREEN) {
    stage.draw();
  }

  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  noLights();

  if (screen != TITLE_SCREEN) {
    drawSelectedRule();

    textAlign(LEFT, TOP);
    textFont(karla);
    fill(255);
    text("Level " + (stage.level + 1), em(), em() * 0.9);
  }
  if (screen == TITLE_SCREEN) {
    image(titleScreenImg, 0, 0, width, height);
  }
  if (screen == END_SCREEN && !promptingClose) {
    noStroke();
    fill(32, 32, 32, 128);
    rect(0, 0, width, height);
    textAlign(CENTER, CENTER);
    textFont(karlaTitle);
    fill(255);
    text("You Win", width / 2, height / 2);
  }

  if (promptingClose) {
    noStroke();
    fill(32, 32, 32, 128);
    rect(0, 0, width, height);
    textAlign(CENTER, CENTER);
    textFont(karla);
    fill(255);
    text("Are you sure you want to close the game?\nPress 'Esc' again to confirm, or press any other key to cancel.", width / 2, height / 2);
  }

  hint(ENABLE_DEPTH_TEST);
}

void drawSelectedRule() {
  float size = em() * 2 / 3;
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
  if (promptingClose) {
    if (key == ESC) {
      exit();
    }
    else {
      promptingClose = false;
    }
  }
  else {
    if (key == ESC) {
      promptingClose = true;
      key = 0;
    }
    else if (screen == GAME_SCREEN) {
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
    else if (screen == TITLE_SCREEN) {
      stage = new Stage(0);
      screen = GAME_SCREEN;
    }
    else if (screen == END_SCREEN) {
      screen = TITLE_SCREEN;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (!promptingClose) {
    if (screen == GAME_SCREEN) {
      if (e < 0) {
        stage.selectNextRule();
      }
      else if (e > 0) {
        stage.selectPrevRule();
      }
    }
  }
}

void mouseReleased() {
  if (promptingClose) {
    promptingClose = false;
  }
  else {
    if (screen == GAME_SCREEN) {
      if (mouseButton == LEFT) {
        stage.applyRule();
      }
    }
    else if (screen == TITLE_SCREEN) {
      stage = new Stage(0);
      screen = GAME_SCREEN;
    }
    else if (screen == END_SCREEN) {
      screen = TITLE_SCREEN;
    }
  }
}


float em() {
  return displayHeight / 48.0;
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
