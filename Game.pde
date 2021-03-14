class Game extends Scene {
  MouseTransformed mt = new MouseTransformed(gm.sketch);
  Player player;

  ArrayList<Ball> balls;

  ArrayList<Particles> particles;
  ArrayList<ScoreText> scoreTexts;

  int textBounce = 0;

  boolean aiming;
  int aimTime;
  float slowmo;

  // Camera
  ExtendedCamera camera;

  // Gameover screen
  int deathTime = 0;
  float fade;

  // Statistics
  int score;
  int highScore;
  int combo;
  int highRoundCombo;
  int highCombo;
  int totalBallsHit = 0;
  int ballsHit;

  boolean newHighscore;
  boolean newHighcombo;

  PShader edges = loadShader("edges.glsl");

  void setup() {
    particles = new ArrayList<Particles>();
    scoreTexts = new ArrayList<ScoreText>();
    balls = new ArrayList<Ball>();
    generateBalls();
    player = new Player(new PVector(width/2, height/2));
    camera = new ExtendedCamera(gm.sketch, player.pos);

    aiming = false;
    score = 0;
    combo = 1;
    fade = 0;
    slowmo = 1;
    aimTime = 0;
    highRoundCombo = 1;
    ballsHit = 0;
  }

  void draw() {
    background(50);
    slowmo = 1;

    if (aiming && player.started) {
      // Aiming slowmo && screen shake
      slowmo = constrain(map(frameCount-aimTime, 0, 30, 0.5, 0.05), 0.05, 0.5);
      camera.shake(1, map(slowmo, 0.5, 0.05, 0, 2));
    }

    if (player.dead) {
      slowmo = map(fade, 0, 255, 1, 0.1);
    }

    // Slowmotion near killballs
    Ball killBall = getClosestBall(player.pos, new KillBall().getClass());
    if (player.started && killBall != null) {
      float d = PVector.dist(player.pos, killBall.pos);
      float maxDist = constrain(10*player.vel.mag(), player.size.x/2+killBall.size.x/2+1, 300);
      if (d < maxDist) {
        slowmo = constrain(map(d, player.size.x/2+killBall.size.x/2, maxDist, 0.01, 1), 0.01, 1);
      }
    }

    // Kill player on entering lava
    if (player.pos.y >= height && !player.dead) {
      player.kill("Lava");
      particles.add(new Particles(player.pos, round(10*player.vel.mag()), color(255, 100, 0), player.vel.mag()/3, player.vel.copy().mult(-1)));
    }

    // Draw
    push();
    camera.update();
    camera.translateScene();

    for (int i = balls.size()-1; i > -1; i--) {
      Ball b = balls.get(i);
      if (camera.pointInside(b.pos, g)) {
        b.show();
      }
    }

    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).update();
      particles.get(i).show();
      if (particles.get(i).particles.size() == 0) {
        particles.remove(i);
      }
    }

    if (aiming) {
      push();
      stroke(255);
      line(player.pos.x, player.pos.y, getMouse().x, getMouse().y); // Aim line
      pop();
    }

    player.update();
    player.show();

    push();
    noStroke();
    fill(225, 100, 0);
    rect(camera.pos.x-(width/2)/camera.zoom, height, width/camera.zoom, height); // Lava
    pop();

    for (int i = scoreTexts.size()-1; i > -1; i--) {
      scoreTexts.get(i).show();
      if (scoreTexts.get(i).scale <= 0.01) {
        scoreTexts.remove(i);
      }
    }
    pop();

    // HUD
    push();
    fill(255, 255-fade);
    textAlign(CENTER, TOP);
    textSize(75+textBounce);
    if (textBounce > 0) {
      textBounce *= 0.8;
    }
    float textWidth = textWidth("SCORE:"+score);
    text("SCORE:"+score, width/2, 25);
    textSize(25);
    textAlign(CENTER, CENTER);
    translate((width/2)+textWidth/2-15, 15);
    rotate(0.2);
    text("x"+combo, 0, 0);
    pop();

    // Health bar
    drawHealthbar();

    // GameOver
    if (player.dead) {
      fade = constrain(map(frameCount-deathTime, 0, 60, 0, 255), 0, 255);
      // Fade
      push();
      fill(0, fade-30);
      noStroke();
      rect(0, 0, width, height);
      pop();

      // Text
      push();
      textAlign(CENTER, CENTER);
      fill(255, fade);
      translate(width/2, 100);
      rotate(0);
      textSize(125);
      text("Game Over", 0, 0);
      textSize(25);
      text("Killed by "+player.deathReason, 0, 80);
      textSize(50);
      text("Score:"+score, 0, 125);
      text("Balls hit:"+ballsHit, 0, 175);
      text("Highest combo:"+highRoundCombo, 0, 225);
      pop();
    }
  }

  void mousePressed() {
    if (mouseButton == LEFT) {
      if (player.canShoot && !player.dead) {
        aiming = true;
        aimTime = frameCount;
      }

      if (player.dead && frameCount-deathTime >= 60) {
        restartGame();
      }
    }

    if (mouseButton == RIGHT) {
      if (aiming) {
        aiming = false;
      }
    }
  }

  void mouseDragged() {
    if (mouseButton == RIGHT && camera.freeMode) {
      camera.freeModePos.add((pmouseX-mouseX)/camera.zoom, (pmouseY-mouseY)/camera.zoom);
    }
  }

  void mouseReleased() {
    if (mouseButton == LEFT) {
      if (aiming && !player.dead) {
        player.shoot(getMouse());
      }
    }
  }

  void keyPressed() {
    if (gm.input.getKey('f')) {
      camera.toggleFreeCam();
    }

    if (gm.input.getKey(27)) {
      gm.changeScene("Menu");
      saveConfig();
    }

    key = 0;
  }

  void mouseWheel(MouseEvent event) {
    camera.zoom -= event.getCount()*0.1*camera.zoom;
  }

  PVector getMouse() {
    float w = width;
    float h = height;
    PVector mouse;
    mt.pushMatrix();
    mt.translate(w/2, h/2);
    mt.scale(camera.zoom);
    mt.translate(-camera.pos.x, -camera.pos.y);
    mouse = new PVector(mt.mouseX(), mt.mouseY());
    mt.popMatrix();
    return mouse;
  }

  void restartGame() {
    particles = new ArrayList<Particles>();
    scoreTexts = new ArrayList<ScoreText>();
    balls = new ArrayList<Ball>();
    generateBalls();
    player = new Player(new PVector(width/2, height/2));
    aiming = false;
    score = 0;
    combo = 1;
    fade = 0;
    slowmo = 1;
    aimTime = 0;
    highRoundCombo = 1;
    ballsHit = 0;
    newHighscore = false;
    newHighcombo = false;
  }
}
