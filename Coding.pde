class CodeWindow extends Window {
  PFont font;

  ArrayList<String> lines = new ArrayList<String>();

  HashMap<String, Integer> marks = new HashMap<String, Integer>();
  HashMap<String, Integer> registry = new HashMap<String, Integer>();

  int currentLine = 0;

  CodeWindow (float x, float y, float sx, float sy) {
    super(gm.sketch, x, y, sx, sy);

    font = createFont("Consolas", 15);

    lines.add("MARK START");
    lines.add("CLOSESTBALL CB");
    lines.add("TYPE CB KILLBALL");
    lines.add("TJMP START");
    lines.add("SHOOT CB");
    lines.add("JUMP START");
  }

  void show() {
    canvas.noSmooth();
    canvas.beginDraw();
    canvas.push();
    canvas.background(0);
    canvas.textFont(font);
    canvas.noStroke();
    canvas.fill(100, 75, 125);
    canvas.rect(0, 0, 40, size.y);
    for (int i = 0; i < lines.size(); i++) {
      if (i == currentLine) {
        canvas.fill(25);
        canvas.rect(40, i*15, size.x, 15);
      }
      canvas.fill(255);
      canvas.textAlign(RIGHT, TOP);
      canvas.text(i+1, 35, i*15);
      canvas.textAlign(LEFT, TOP);
      canvas.text(lines.get(i), 45, i*15);
    }
    canvas.fill(100, 75, 125);
    canvas.rect(size.x-100, 0, 100, size.y);
    canvas.fill(255);
    canvas.textAlign(LEFT, TOP);
    int i = 0;
    for (HashMap.Entry<String, Integer> set : registry.entrySet()) {
      canvas.text(set.getKey() + " = " + set.getValue(), size.x-95, i*15);
      i++;
    }
    canvas.pop();
    canvas.endDraw();
    image(canvas, pos.x, pos.y);
  }

  int checkArg(String arg) {
    if (registry.containsKey(arg)) {
      return int(registry.get(arg));
    } else {
      return int(arg);
    }
  }

  void runCode() {
    currentLine = 0;
    for (int i = 0; i < lines.size(); i++) {
      runLine();
    }
  }

  void runLine() {
    String line = lines.get(currentLine);
    String[] tokens = split(line.toLowerCase(), " ");
    switch(tokens[0]) {
    case "copy":
      registry.put(tokens[2], checkArg(tokens[1]));
      break;
    case "shoot":
      game.player.shoot(game.balls.get(checkArg(tokens[1])).pos);
      break;
    case "print":
      println(checkArg(tokens[1]));
      break;
    case "type":
      Ball b = game.balls.get(checkArg(tokens[1]));
      switch(tokens[2]) {
      case "ball":
        registry.put("t", int(b instanceof Ball));
        break;
      case "killball":
        registry.put("t", int(b instanceof KillBall));
        break;
      case "randomball":
        registry.put("t", int(b instanceof RandomBall));
        break;
      case "healthball":
        registry.put("t", int(b instanceof HealthBall));
        break;
      case "pointball":
        registry.put("t", int(b instanceof PointBall));
        break;
      }
      break;
    case "mark":
      marks.put(tokens[1], currentLine);
      break;
    case "tjmp":
      if (boolean(registry.get("t"))) {
        currentLine = marks.get(tokens[1]);
      }
      break;
    case "fjmp":
      if (!boolean(registry.get("t"))) {
        currentLine = marks.get(tokens[1]);
      }
      break;
    case "jump":
      currentLine = marks.get(tokens[1]);
      break;
    }

    currentLine++;
    if (currentLine > lines.size()-1) {
      currentLine = 0;
    }
  }
}
