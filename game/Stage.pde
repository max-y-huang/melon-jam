
class TokenRenderOrderComparator implements Comparator<Token> {  
  public int compare(Token a, Token b) {
    if (a.z > b.z) {
      return -1;
    }
    return a.x > b.x ? -1 : 1;
  }
};


class Stage {

  int size;

  int animStep = 0;
  int animStepCount = 0;
  float animPercent = 0;

  int currentRuleIndex = 0;

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
    rules.add(new FlipRule(X_AXIS, 1, 0, 0, 1.5));
    rules.add(new FlipRule(X_AXIS, 3, 0, 0, 1.5));
    rules.add(new FlipRule(Z_AXIS, 1.5, 2, 4, 2));
    rules.add(new FlipRule(X_AXIS, 3.5, 3, 3, 1));
    rules.add(new FlipRule(X_AXIS, 1.5, 3, 3, 1));
    rules.add(new FlipRule(X_AXIS, 1.5, 4, 4, 2));
    rules.add(new FlipRule(Z_AXIS, 2, 0, 0, 2.5));

    tokens = new ArrayList<Token>();
    tokens.add(new Token("sofa", 0, 0));
    tokens.add(new Token("fireplace", 3, 4));
    tokens.add(new Token("teddyBear", 0, 4));
    tokens.add(new Token("bed", 2, 0));
    // tokens.add(new Token("hotChocolate", 6, 6));
    // tokens.add(new Token("chocolateBar", 7, 5));
  }

  FlipRule currentRule() {
    return rules.get(currentRuleIndex);
  }

  void drawBoard() {
    for (int x = 0; x < size; x++) {
      for (int z = 0; z < size; z++) {
        if (animStep == 2) {
          cells.get(x).get(z).draw((a, b) -> {
            currentRule().applyCellTransformation(a, b, softenAnimation(animPercent) * PI);
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

    if (animStep == 0) {
      currentRule().drawOutline();
    }
    
    ArrayList<Token> sortedTokens = new ArrayList<>(tokens);
    Collections.sort(sortedTokens, new TokenRenderOrderComparator());
    for (Token token : sortedTokens) {
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
          if (currentRule().isInRange(token.x, token.z)) {
            cells.get(token.x).get(token.z).changeColour(true);
            PVector newPos = currentRule().applyRule(token.x, token.z);
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

  void applyRule() {
    if (animStep != 0) {
      return;
    }
    animStep = 1;
    animStepCount = 3;
    animPercent = 0;
    for (Token token : tokens) {
      if (currentRule().isInRange(token.x, token.z)) {
        token.fade();
        cells.get(token.x).get(token.z).changeColour(token.accentColour);
      }
    }
  }

  void selectPrevRule() {
    if (animStep != 0) {
      return;
    }
    currentRuleIndex += rules.size() - 1;
    currentRuleIndex %= rules.size();
  }
  void selectNextRule() {
    if (animStep != 0) {
      return;
    }
    currentRuleIndex += 1;
    currentRuleIndex %= rules.size();
  }
};
