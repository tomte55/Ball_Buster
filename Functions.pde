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

void generateBalls() {
  for (int i = 0; i < 1000; i++) {
    PVector p;
    do {
      p = getRandomPos();
    } while (PVector.dist(p, new PVector(width/2, height/2)) < 100);
    float rng = random(1);
    if (rng <= 0.01) {
      game.balls.add(new HealthBall(p));
    } else if (rng <= 0.02) {
      game.balls.add(new KillBall(p));
      game.balls.add(new ComboBall(getRandomPos()));
    } else if (rng <= 0.05) {
      game.balls.add(new PointBall(p));
    } else if (rng <= 0.1) {
      game.balls.add(new RandomBall(p));
    } else {
      game.balls.add(new Ball(p));
    }
  }
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
  return closestBall;
}
Ball getClosestBall(PVector pos, Class c) {
  float closest = 9999999;
  Ball closestBall = null;
  for (int i = 0; i < game.balls.size(); i++) {
    Ball b = game.balls.get(i);
    if (b.getClass() == c) {
      float d = PVector.dist(b.pos, pos);
      if (d < closest) {
        closest = d;
        closestBall = b;
      }
    }
  }
  return closestBall;
}
