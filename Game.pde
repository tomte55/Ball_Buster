class Game extends Scene {
  MouseTransformed mt = new MouseTransformed(gm.sketch);
  Player player;

  CodeWindow codeWindow;

  ArrayList<Ball> balls;

  ArrayList<Particles> particles;
  ArrayList<ScoreText> scoreTexts;

  int textBounce = 0;

  boolean aiming;
  int aimTime;
  float slowmo;

  // Camera
  Camera camera;
  int shakeFrames = 0;
  float shakeIntensity = 1;
  ArrayList<Float> speeds;
  ArrayList<PVector> positions;
  boolean screenShake = true;
  boolean freeCam = false;
  PVector freeCamPos = new PVector();

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


  Graph fpsGraph;

  PShader edges = loadShader("edges.glsl");

  void setup() {
    particles = new ArrayList<Particles>();
    scoreTexts = new ArrayList<ScoreText>();
    balls = new ArrayList<Ball>();
    generateBalls();
    player = new Player(new PVector(width/2, height/2));
    camera = new Camera(gm.sketch, player.pos, 0, 0);

    aiming = false;
    score = 0;
    combo = 1;
    fade = 0;
    slowmo = 1;
    aimTime = 0;
    highRoundCombo = 1;
    ballsHit = 0;

    speeds = new ArrayList<Float>();
    positions = new ArrayList<PVector>();

    fpsGraph = new Graph(gm.sketch, width-100, 25, "FPS");
    fpsGraph.toggleMinimal();

    codeWindow = new CodeWindow(0, height-300, 400, 300);
  }

  void draw() {
    background(50);
    fpsGraph.addSample(frameRate);

    // Update
    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).update();
      if (particles.get(i).particles.size() == 0) {
        particles.remove(i);
      }
    }

    player.update();

    slowmo = 1;

    if (aiming && player.started) {
      slowmo = constrain(map(frameCount-aimTime, 0, 30, 0.5, 0.05), 0.05, 0.5);
      shakeScreen(1, map(slowmo, 0.5, 0.05, 0, 2));
    }

    if (player.dead) {
      slowmo = map(fade, 0, 255, 1, 0.1);
    }

    Ball killBall = getClosestBall(player.pos, new KillBall().getClass());
    if (player.started && killBall != null) {
      float d = PVector.dist(player.pos, killBall.pos);
      float maxDist = constrain(10*player.vel.mag(), player.size.x/2+killBall.size.x/2+1, 300);
      if (d < maxDist) {
        slowmo = constrain(map(d, player.size.x/2+killBall.size.x/2, maxDist, 0.01, 1), 0.01, 1);
      }
    }

    if (player.pos.y >= height && !player.dead) {
      player.kill("Lava");
      particles.add(new Particles(player.pos, round(10*player.vel.mag()), color(255, 100, 0), player.vel.mag()/3, player.vel.copy().mult(-1)));
    }

    positions.add(player.pos.copy());
    if (positions.size() > 15) {
      positions.remove(0);
    }

    if (freeCam) {
      camera.target = freeCamPos;
    } else {
      camera.target = getAveragePVector(positions); // Camera target
      speeds.add(player.vel.mag());
      if (speeds.size() > 120) {
        speeds.remove(0);
      }
      float sum = 0;
      for (int i = 0; i < speeds.size(); i++) {
        sum += speeds.get(i);
      }

      float slow = map(slowmo, 0.01, 1, 0.5, 0)/camera.zoom; // Camera zooming
      float speed = map(sum/speeds.size(), 0, 10, 1.5, 1); // Camera zooming
      camera.zoom = speed;

      if (shakeFrames > 0) {
        if (screenShake) {
          camera.offset = PVector.random2D().mult(shakeIntensity); // Camera shake
        }
        shakeFrames--;
      } else {
        camera.offset.set(0, 0);
      }
    }

    // Draw
    push();
    camera.translateScene();

    for (int i = balls.size()-1; i > -1; i--) {
      Ball b = balls.get(i);
      if (camera.pointInside(b.pos, g)) {
        b.show();
      }
    }

    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).show();
    }

    if (aiming) {
      push();
      stroke(255);
      line(player.pos.x, player.pos.y, getMouse().x, getMouse().y);
      pop();
    }

    player.show();

    push();
    noStroke();
    fill(225, 100, 0);
    rect(camera.pos.x-(width/2)/camera.zoom, height, width/camera.zoom, height); // Lava
    pop();

    //filter(edges);

    //drawLava();

    for (int i = scoreTexts.size()-1; i > -1; i--) {
      scoreTexts.get(i).show();
      if (scoreTexts.get(i).scale <= 0.01) {
        scoreTexts.remove(i);
      }
    }
    pop();

    // HUD
    //codeWindow.show();
    //codeWindow.runLine();

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

    fpsGraph.show();

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
    if (mouseButton == RIGHT && freeCam) {
      freeCamPos.add((pmouseX-mouseX)/camera.zoom, (pmouseY-mouseY)/camera.zoom);
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
      freeCam = !freeCam;
      freeCamPos = player.pos.copy();
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
    speeds = new ArrayList<Float>();
    positions = new ArrayList<PVector>();
  }
}
