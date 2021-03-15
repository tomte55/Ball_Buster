void loadConfig() {
  configJSON = loadJSONObject("config.json");
  game.totalBallsHit = configJSON.getInt("ballsHit");
  game.highScore = configJSON.getInt("highScore");
  game.highCombo = configJSON.getInt("highCombo");
  timePlayed = configJSON.getInt("timePlayed");
  saveConfig();
}

void saveConfig() {
  if (game.score > game.highScore) {
    game.highScore = game.score;
    game.newHighscore = true;
  }
  if (game.highRoundCombo > game.highCombo) {
    game.highCombo = game.highRoundCombo;
    game.newHighcombo = true;
  }
  game.totalBallsHit += game.ballsHit;

  configJSON = new JSONObject();
  configJSON.setInt("ballsHit", game.totalBallsHit);
  configJSON.setInt("highScore", game.highScore);
  configJSON.setInt("highCombo", game.highCombo);
  configJSON.setInt("timePlayed", timePlayed);
  saveJSONObject(configJSON, "config.json");
}

PVector getAveragePVector(ArrayList<PVector> arr) {
  PVector total = new PVector();
  for (int i = 0; i < arr.size(); i++) {
    total.add(arr.get(i));
  }
  return total.div(arr.size());
}

ArrayList<Ball> generateBalls(int amount) {
  ArrayList<Ball> arr = new ArrayList<Ball>();
  for (int i = 0; i < amount; i++) {
    float rng = random(1);
    if (rng <= 0.01) {
      arr.add(new HealthBall());
    } else if (rng <= 0.02) {
      arr.add(new KillBall());
      arr.add(new ComboBall());
    } else if (rng <= 0.05) {
      arr.add(new PointBall());
    } else if (rng <= 0.1) {
      arr.add(new RandomBall());
    } else {
      arr.add(new Ball());
    }
  }
  return arr;
}

PVector getRandomPos() {
  return new PVector(random(-width, width*2), random(-height, height));
}

Ball getClosestBall(PVector pos) {
  float closest = 9999999;
  Ball closestBall = null;
  for (int i = 0; i < game.balls.size(); i++) {
    Ball b = game.balls.get(i);
    float d = PVector.dist(b.pos, pos);
    if (d < closest) {
      closest = d;
      closestBall = b;
    }
  }
  if (closestBall == null) {
    return new Ball();
  }
  return closestBall;
}

String getGridPos(PVector p) {
  int x = floor(p.x/game.cellSize);
  int y = floor(p.y/game.cellSize);
  return x + ", " + y;
}

String getGridPos(int _x, int _y) {
  int x = floor(_x/game.cellSize);
  int y = floor(_y/game.cellSize);
  return x + ", " + y;
}
