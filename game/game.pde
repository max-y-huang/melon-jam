import java.util.*;
import processing.sound.*;

boolean TESTING = false;


int TITLE_SCREEN = 0;
int GAME_SCREEN = 1;
int END_SCREEN = 2;

int oldWidth = 0, oldHeight = 0;

float volume = 0.7;


SoundFile bgm;
SoundFile cursorSe;
SoundFile swapSe;
SoundFile startLevelSe;
SoundFile clearLevelSe;
SoundFile winGameSe;

PFont karla;
PFont karlaTitle;

PImage titleScreenImg;


Stage stage;
int screen;
boolean promptingClose = false;


void settings() {
  size(displayWidth * 3 / 4, displayHeight * 3 / 4, P3D);
  PJOGL.setIcon("data/imgs/icon.png");
  smooth(4);
}


void setup() {
  surface.setTitle("Flipping Houses");
  surface.setLocation(displayWidth * 1 / 8, displayHeight * 1 / 8);
  frameRate(60);

  bgm = new SoundFile(this, "data/audio/bgm.wav");
  bgm.amp(0.5 * volume);

  cursorSe = new SoundFile(this, "data/audio/cursor.wav");
  cursorSe.amp(0.67 * volume);

  swapSe = new SoundFile(this, "data/audio/swap.wav");
  swapSe.amp(0.67 * volume);

  startLevelSe = new SoundFile(this, "data/audio/startLevel.wav");
  startLevelSe.amp(0.67 * volume);

  clearLevelSe = new SoundFile(this, "data/audio/clearLevel.wav");
  clearLevelSe.amp(0.67 * volume);

  winGameSe = new SoundFile(this, "data/audio/winGame.wav");
  winGameSe.amp(0.67 * volume);

  titleScreenImg = loadImage("data/imgs/titlePage.jpg");

  resizeAssets();

  screen = TITLE_SCREEN;
  bgm.loop();
}


void resizeAssets() {
  karla = createFont("fonts/karlaRegular.ttf", em());
  karlaTitle = createFont("fonts/karlaBold.ttf", 2.5 * em());
  if (stage != null) {
    stage.createComplementaryTokensImg();
  }
}


void draw() {

  if (oldWidth != width || oldHeight != height) {
    resizeAssets();
    oldWidth = width;
    oldHeight = height;
  }

  if (screen != TITLE_SCREEN) {
    stage.drawLevel();
  }

  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  noLights();

  if (screen != TITLE_SCREEN) {
    stage.drawHUD();
  }
  if (screen == TITLE_SCREEN) {
    noStroke();
    imageMode(CENTER);
    float imageAspectRatio = titleScreenImg.width * 1.0 / titleScreenImg.height;
    float screenAspectRatio = width * 1.0 / height;
    if (imageAspectRatio > screenAspectRatio) {
      image(titleScreenImg, width / 2, height / 2, height * imageAspectRatio, height);
    }
    else {
      image(titleScreenImg, width / 2, height / 2, width, width / imageAspectRatio);
    }
    imageMode(CORNER);
    if (!promptingClose) {
      textAlign(CENTER, BOTTOM);
      textFont(karlaTitle);
      fill(255);
      text("Flipping Houses", width / 2, height / 3);
      textFont(karla);
      textAlign(CENTER, TOP);
      text("\nPress any key to play.\n\n" +
        "Cozify the rooms by moving complementary items beside each other.\n\n" +
        "Left/A/Scroll: Select previous move\n" +
        "Right/D/Scroll: Select next move\n" +
        "Space/LMB: Flip\n" + 
        "Escape: Exit game", width / 2, height / 3);
    }

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
      startLevelSe.play();
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
      bgm.loop();
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
      bgm.loop();
    }
  }
}


float em() {
  return height / 32.0;
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
