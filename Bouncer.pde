class Ball extends GameObject {
  Cell cell = null;

  color clr = color(255, 0, 0);
  int score = 100;

  AudioPlayer sound;

  Ball () {
    size.set(35, 35);
    sound = hit;
  }
  Ball (PVector p) {
    pos.set(p);
    size.set(35, 35);
    sound = hit;
  }

  void show() {
    push();
    fill(clr);
    noStroke();
    circle(pos.x, pos.y, size.x);
    pop();
  }

  void action() {
    bounce();
  }

  void blowUp() {
    game.particles.add(new Particles(pos, 50, clr, 1, game.player.vel));
    game.scoreTexts.add(new ScoreText(pos, getScore()));
    playSound(sound, -5);
    game.balls.remove(this);
    cell.balls.remove(this);
  }

  void bounce() {
    Player player = game.player;
    player.pos.sub(player.vel);
    PVector v = new PVector(player.pos.x-pos.x, player.pos.y-pos.y).normalize();
    player.pos.add(player.vel);
    player.vel.set(v.mult(player.vel.mag()));
  }

  int getScore() {
    return score*game.combo;
  }
}

class RandomBall extends Ball {
  RandomBall () {
    super();
    clr = color(255, 0, 255);
    score = 200;
  }
  RandomBall (PVector p) {
    super(p);
    clr = color(255, 0, 255);
    score = 200;
  }

  void action() {
    Player player = game.player;
    player.pos.sub(player.vel);
    PVector v = PVector.random2D();
    player.vel.set(v.mult(15));
    game.balls.remove(this);
    playSound(boost, -5);
  }
}

class PointBall extends Ball {
  PointBall () {
    super();
    size.set(15, 0);
    clr = color(255, 255, 0);
    score = 5000;
  }
  PointBall (PVector p) {
    super();
    size.set(15, 0);
    clr = color(255, 255, 0);
    score = 5000;
  }

  void action() {
    bounce();
    playSound(coin, -5);
  }

  int getScore() {
    return score;
  }
}

class KillBall extends Ball {
  float rotation = radians(random(360));

  KillBall () {
    super();
    clr = color(0, 255, 0);
    score = -100;
  }
  KillBall (PVector p) {
    super(p);
    clr = color(0, 255, 0);
    score = -100;
  }

  void show() {
    push();
    fill(clr);
    noStroke();
    translate(pos.x, pos.y);
    rotate(rotation);
    rectMode(CENTER);
    float s = size.x*0.8;
    rect(0, 0, s, s);
    rotate(radians(45));
    rect(0, 0, s, s);
    pop();
  }

  void action() {
    game.player.kill("Green Ball");
  }
}

class HealthBall extends Ball {
  HealthBall () {
    super();
    clr = color(255, 255, 255);
  }
  HealthBall (PVector p) {
    super(p);
    clr = color(255, 255, 255);
  }

  void show() {
    push();
    fill(clr);
    noStroke();
    circle(pos.x, pos.y, size.x);
    pop();

    push();
    strokeWeight(3);
    stroke(255, 0, 0);
    strokeCap(PROJECT);
    line(pos.x-size.x*0.2, pos.y, pos.x+size.x*0.2, pos.y); // Horizontal line
    line (pos.x, pos.y-size.x*0.2, pos.x, pos.y+size.x*0.2); // Vertical line
    pop();
  }

  void action() {
    Player player = game.player;
    player.pos.sub(player.vel);
    PVector v = new PVector(player.pos.x-pos.x, player.pos.y-pos.y).normalize();
    player.vel.set(v.mult(player.vel.mag()-0.5));
    player.health = 100;
    game.balls.remove(this);
  }
}

class ComboBall extends Ball {
  ComboBall () {
    super();
    clr = color(0, 0, 0);
    score = 0;
  }
  ComboBall (PVector p) {
    super(p);
    clr = color(0, 0, 0);
    score = 0;
  }

  void action() {
    Player player = game.player;
    player.comboShots += 10;
    game.balls.remove(this);
  }
}
