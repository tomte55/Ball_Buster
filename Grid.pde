class Grid {
  HashMap<String, Cell> cells = new HashMap<String, Cell>();
  ArrayList<Cell> loadedCells = new ArrayList<Cell>();

  void show() {
    push();
    for (Cell c : cells.values()) {
      for (int i = 0; i < c.balls.size(); i++) {
        Ball ball = c.balls.get(i);
        ball.show();
      }
    }
    pop();
  }

  void update() {
    for (int i = 0; i < loadedCells.size(); i++) {
      Cell c = loadedCells.get(i);
      PVector cPos = c.pos.copy().add(c.size/2, c.size/2);
      float distance = PVector.dist(game.player.pos, cPos);
      if (distance >= game.cellSize*game.renderDistance) {
        c.unload();
      }
    }
  }

  void loadCell(int x, int y) {
    String k = x + ", " + y;
    Cell cell = cells.getOrDefault(k, null);
    if (cell == null) {
      cell = new Cell(x*game.cellSize, y*game.cellSize);
      cell.load();
      cells.put(k, cell);
    } else {
      cell.load();
    }
  }

  void unloadCell(int x, int y) {
    String k = x + ", " + y;
    Cell cell = cells.getOrDefault(k, null);
    if (cell != null) {
      cell.unload();
    }
  }

  Cell getCell(int x, int y) {
    String k = x + ", " + y;
    Cell cell = cells.getOrDefault(k, null);
    return cell;
  }
}

class Cell {
  ArrayList<Ball> balls = new ArrayList<Ball>();
  PVector pos = new PVector();
  int size = game.cellSize;

  int loadedTime = 0;

  boolean loaded = false;

  Cell (float x, float y) {
    pos.set(x, y);
    int amount = round(map(y, 0, -5000, 25, 1));
    ArrayList<Ball> types = generateBalls(amount);
    for (int i = 0; i < types.size(); i++) {
      PVector p = new PVector(x+random(size), y+random(size));
      Ball b = types.get(i);
      b.pos.set(p);
      b.cell = this;
      balls.add(b);
    }
  }

  void load() {
    if (!loaded) {
      for (int i = 0; i < balls.size(); i++) {
        game.balls.add(balls.get(i));
      }
      loaded = true;
      loadedTime = 0;
      game.grid.loadedCells.add(this);
      println("loaded "+pos.x/size+", "+pos.y/size);
    }
  }

  void unload() {
    if (loaded) {
      for (int i = 0; i < balls.size(); i++) {
        game.balls.remove(balls.get(i));
      }
      loaded = false;
      game.grid.loadedCells.remove(this);
      println("unloaded "+pos.x/size+", "+pos.y/size);
    }
  }
}
