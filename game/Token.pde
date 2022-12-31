
class Token {

  String id;
  PImage img;
  int tag;
  int x, z;
  color accentColour = color(0, 0, 0);

  float opacity = 1;
  float opacityVel = 0;

  Token(String _id, int _tag, int _x, int _z) {
    id = _id;
    tag = _tag;
    x = _x;
    z = _z;
    img = loadImage("data/imgs/tokens/" + id + ".png");
    switch (id) {
      case "fireplace":
        accentColour = color(255, 220, 110);
        break;
      case "sofa":
        accentColour = color(47, 168, 238);
        break;
      case "teddyBear":
        accentColour = color(163, 114, 80);
        break;
      case "bed":
        accentColour = color(219, 140, 124);
        break;
      case "hotChocolate":
        accentColour = color(245, 72, 66);
        break;
      case "chocolateBar":
        accentColour = color(140, 82, 55);
        break;
    }
  }

  void drawShadow() {
    float w = 0.65;
    float h = img.height * w / img.width;
    float buffer = 0.125;
    float shadowHeight = 0.001;

    hint(DISABLE_DEPTH_MASK);
    updateOpacity();
    
    pushMatrix();
    
    noStroke();
    translate(x - buffer, 0, z - buffer);
    translate(0, -0.075 - shadowHeight, 0);
    rotateY(PI / 4);
    scale(-1, 1, -1);
    rotateX(PI / 2);
    shearX(-PI / 8);
    translate(-w / 2, -h, 0);
    tint(255, 64 * softenAnimation(opacity));

    image(img, 0, 0, w, h); 

    popMatrix();
  }
  
  void drawToken() {
    float w = 0.65;
    float h = img.height * w / img.width;
    float buffer = 0.125;

    hint(DISABLE_DEPTH_MASK);
    updateOpacity();

    pushMatrix();

    translate(x - buffer, 0, z - buffer);
    rotateY(-3 * PI / 4);
    translate(-w / 2, -h - 0.075, 0);
    tint(255, 255 * softenAnimation(opacity));

    image(img, 0, 0, w, h);

    popMatrix();

    tint(255);
    hint(ENABLE_DEPTH_MASK);
  }

  void updateOpacity() {
    opacity += opacityVel;
    if (opacity >= 1) {
      opacity = 1;
      opacityVel = 0;
    }
    if (opacity <= 0) {
      opacity = 0;
      opacityVel = 0;
    }
  }

  void fade() {
    opacityVel = -0.06;
  }
  void unfade() {
    opacityVel = 0.06;
  }
};
