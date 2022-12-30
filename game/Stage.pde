
class Stage {

  int size;

  int animStep = 0;
  int animStepCount = 0;
  float animPercent = 0;
  FlipRule currentRule;

  Camera camera;
  ArrayList<ArrayList<Cell>> cells;
  ArrayList<FlipRule> rules;
  ArrayList<Token> tokens;

  Stage(int _size) {
    size = _size;
    camera = new Camera(size);

    cells = new ArrayList<ArrayList<Cell>>();
    for (int x = 0; x < size; x++) {
      ArrayList<Cell> row = new ArrayList<Cell>();
      for (int z = 0; z < size; z++) {
        row.add(new Cell(x, z));
      }
      cells.add(row);
    }

    rules = new ArrayList<FlipRule>();
    rules.add(new FlipRule(X_AXIS, 2.5, 2, 4, 3));
    rules.add(new FlipRule(Z_AXIS, 2.5, 2, 4, 3));

    tokens = new ArrayList<Token>();
    tokens.add(new Token("sofa", 4, 2));
    tokens.add(new Token("fire", 2, 1));
  }

  void drawBoard() {
    for (int x = 0; x < size; x++) {
      for (int z = 0; z < size; z++) {
        if (animStep == 2) {
          cells.get(x).get(z).draw((a, b) -> {
            currentRule.applyCellTransformation(a, b, softenAnimation(animPercent) * PI);
          }); 
        }
        else {
          cells.get(x).get(z).draw();
        }
      }
    }
  }
  
  void draw() {

    handleAnim();

    camera.draw();

    ambientLight(172, 172, 172);
    directionalLight(232, 232, 232, 0.5, 0.5, -1);

    drawBoard();

    directionalLight(255, 255, 255, 1, 0, 1);
    
    for (Token token : tokens) {
      token.draw();
    }
  }

  void handleAnim() {
    if (animStep == 0) {
      return;
    }
    switch (animStep) {
      case 1:
        animPercent += 0.07;
        break;
      case 2:
        animPercent += 0.02;
        break;
      case 3:
        animPercent += 0.07;
    }
    if (animPercent < 1) {
      return;
    }
    animStep += 1;
    animPercent = 0;
    switch (animStep) {
      case 2:
        break;
      case 3:
        for (Token token : tokens) {
          if (currentRule.isInRange(token.x, token.z)) {
            cells.get(token.x).get(token.z).changeColour(true);
            PVector newPos = currentRule.applyRule(token.x, token.z);
            token.x = int(newPos.x);
            token.z = int(newPos.z);
            token.unfade();
            cells.get(token.x).get(token.z).changeColour(token.accentColour, true);
            cells.get(token.x).get(token.z).changeColour();
          }
        }
        break;
      default:
        animStep = 0;
    }
  }

  void applyRule(int index) {
    animStep = 1;
    animStepCount = 3;
    animPercent = 0;
    currentRule = rules.get(index);
    for (Token token : tokens) {
      if (currentRule.isInRange(token.x, token.z)) {
        token.fade();
        cells.get(token.x).get(token.z).changeColour(token.accentColour);
      }
    }
  }
};
