
class TokenRenderOrderComparator implements Comparator<Token> {  
  public int compare(Token a, Token b) {
    if (a.z > b.z) {
      return -1;
    }
    return a.x > b.x ? -1 : 1;
  }
};


class Stage {

  int level;
  int size;

  PImage wall1Img, wall2Img;
  PGraphics complementaryTokensImg;

  int animStep = 0;
  float animPercent = 0;

  int currentRuleIndex = 0;

  Camera camera;
  ArrayList<ArrayList<Cell>> cells;
  ArrayList<FlipRule> rules;
  ArrayList<Token> tokens;

  Stage(int _level) {
    wall1Img = loadImage("data/imgs/wall1.png");
    wall2Img = loadImage("data/imgs/wall2.png");
    loadLevel(level);
  }

  boolean loadLevel(int _level) {

    JSONArray allLevelsJson = loadJSONArray("data/levels.json");
    if (_level >= allLevelsJson.size()) {
      return false;
    }
    JSONObject levelJson = allLevelsJson.getJSONObject(_level);
    JSONArray tokensJson = levelJson.getJSONArray("tokens");
    JSONArray rulesJson = levelJson.getJSONArray("rules");

    level = _level;
    size = levelJson.getInt("boardSize");

    rules = new ArrayList<FlipRule>();
    for (int i = 0; i < rulesJson.size(); i++) {
      JSONObject rule = rulesJson.getJSONObject(i);
      rules.add(new FlipRule(rule.getString("axis"), rule.getFloat("position"), rule.getInt("end1"), rule.getInt("end2"), rule.getFloat("range")));
    }

    tokens = new ArrayList<Token>();
    for (int i = 0; i < tokensJson.size(); i++) {
      JSONObject token = tokensJson.getJSONObject(i);
      tokens.add(new Token(token.getString("id"), token.getInt("tag"), token.getInt("x"), token.getInt("z")));
    }

    currentRuleIndex = 0;

    // create camera
    camera = new Camera(size);

    // load cells
    cells = new ArrayList<ArrayList<Cell>>();
    for (int x = 0; x < size; x++) {
      ArrayList<Cell> row = new ArrayList<Cell>();
      for (int z = 0; z < size; z++) {
        row.add(new Cell(x, z));
      }
      cells.add(row);
    }

    createComplementaryTokensImg();

    startLevelSe.play();

    return true;
  }

  void createComplementaryTokensImg() {
    float tokenImgSize = 2 * em();
    int gridWidth = ceil(tokenImgSize * 1.25);
    int gridHeight = ceil(tokenImgSize * 1.5);

    HashMap<Integer, ArrayList<Token>> tagMap = new HashMap<Integer, ArrayList<Token>>();
    for (Token token : tokens) {
      if (!tagMap.containsKey(token.tag)) {
        tagMap.put(token.tag, new ArrayList<Token>());
      }
      tagMap.get(token.tag).add(token);
    }

    complementaryTokensImg = createGraphics(gridWidth * 2, gridHeight * tagMap.keySet().size());
    complementaryTokensImg.beginDraw();
    complementaryTokensImg.imageMode(CENTER);
    for (Integer tag : tagMap.keySet()) {
      ArrayList<Token> row = tagMap.get(tag);
      for (int i = 0; i < row.size(); i++) {
        PImage img = row.get(i).img;
        float aspectRatio = img.width * 1.0 / img.height;
        float w, h;
        if (aspectRatio > 1) {
          w = tokenImgSize;
          h = tokenImgSize / aspectRatio;
        }
        else {
          h = tokenImgSize;
          w = tokenImgSize * aspectRatio;
        }
        complementaryTokensImg.image(img, i * gridWidth + gridWidth / 2.0, tag * gridHeight + gridHeight / 2.0, w, h);
      }
    }
    complementaryTokensImg.endDraw();
  }

  boolean isWinningPosition() {
    for (Token a : tokens) {
      boolean foundAdjacent = false;
      for (Token b : tokens) {
        if (a.tag == b.tag && abs(a.x - b.x) + abs(a.z - b.z) == 1) {
          foundAdjacent = true;
          break;
        }
      }
      if (!foundAdjacent) {
        return false;
      }
    }
    return true;
  }

  void handleWin() {
    if (!loadLevel(level + 1)) {
      screen = END_SCREEN;
    }
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

  void drawWalls() {

    if (animStep != 4 && screen == GAME_SCREEN) {
      return;
    }
    
    if (screen == GAME_SCREEN) {
      tint(255, 255 * 10 * softenAnimation(animPercent));
    }

    // x-axis wall
    pushMatrix();
    translate(size / 2.0 - 0.5, 0, size - 0.5);
    rotateY(PI);
    translate(-size / 2.0, -size / 2.0 - 0.075, 0);
    image(wall1Img, 0, 0, size, size / 2.0);
    popMatrix();

    // z-axis wall
    pushMatrix();
    translate(size - 0.5, 0, size / 2.0 - 0.5);
    rotateY(-PI / 2);
    translate(-size / 2.0, -size / 2.0 - 0.075, 0);
    image(wall2Img, 0, 0, size, size / 2.0);
    popMatrix();

    tint(255);
  }
  
  void drawLevel() {

    handleAnim();

    background(32, 32, 32);

    camera.draw();

    noLights();
    directionalLight(255, 255, 255, 1, 0, 0);
    directionalLight(184, 184, 184, 0, 0, 1);

    drawWalls();

    noLights();
    directionalLight(255, 255, 255, 0, 1, 0);
    directionalLight(184, 184, 184, 1, 0, 0);
    directionalLight(128, 128, 128, 0, 0, 1);

    drawBoard();

    noLights();
    directionalLight(255, 255, 255, 1, 0, 1);

    if (animStep == 0 && screen == GAME_SCREEN) {
      currentRule().drawOutline();
    }
    
    ArrayList<Token> sortedTokens = new ArrayList<>(tokens);
    Collections.sort(sortedTokens, new TokenRenderOrderComparator());
    for (Token token : sortedTokens) {
      token.draw();
    }
  }

  void drawHUD() {

    float carouselSize = em() * 2 / 3;
    noStroke();
    pushMatrix();
    translate(width / 2 - carouselSize * (rules.size() - 1), height - 2 * carouselSize);
    for (int i = 0; i < rules.size(); i++) {
      if (i == currentRuleIndex) {
        fill(0, 255, 255);
      }
      else {
        fill(128, 128, 128);
      }
      ellipse(0 + carouselSize * 2 * i, 0, carouselSize, carouselSize);
    }
    popMatrix();

    textAlign(LEFT, TOP);
    textFont(karla);
    fill(255);
    text("Level " + (level + 1), 2 * em(), 2 * em() * 0.9);

    image(complementaryTokensImg, width - complementaryTokensImg.width - 2 * em(), 2 * em() * 0.9);
  }

  void handleAnim() {
    if (animStep == 0) {
      return;
    }
    // update animation
    switch (animStep) {
      case 1:
        animPercent += 0.06;
        break;
      case 2:
        animPercent += 0.02;
        break;
      case 3:
        animPercent += 0.045;
      case 4:
        animPercent += 0.006;
    }
    // move to next animation step
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
      case 4:
        if (isWinningPosition()) {
          clearLevelSe.play();
          for (ArrayList<Cell> row : cells) {
            for (Cell cell : row) {
              cell.changeToWinColour();
            }
          }
        }
        else {
          animStep = 0;
        }
        break;
      default:
        handleWin();
        animStep = 0;
    }
  }

  void applyRule() {
    if (animStep != 0) {
      return;
    }
    animStep = 1;
    animPercent = 0;
    swapSe.play();
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
    cursorSe.play();
    currentRuleIndex += rules.size() - 1;
    currentRuleIndex %= rules.size();
  }
  void selectNextRule() {
    if (animStep != 0) {
      return;
    }
    cursorSe.play();
    currentRuleIndex += 1;
    currentRuleIndex %= rules.size();
  }
};
