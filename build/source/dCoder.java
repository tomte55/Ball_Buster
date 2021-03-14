import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 
import ddf.minim.*; 
import mouse.transformed2D.*; 
import tomte.gameManager.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class dCoder extends PApplet {






GameManager gm;
Game game;
Menu menu;

JSONObject configJSON;

int timePlayed;
int lastTime = 0;
// Add statistics
//   -Total balls destroyed
//   -Highest score from one shot
//   -Time played
//   -Highest combo

// Remake screenshake too make it smooth

Minim minim;
AudioPlayer hit;
AudioPlayer death;
float volume = 0.1f;
float pitch = 0;

public void setup() {
  

  minim = new Minim(this);
  hit = minim.loadFile("sounds/hit.wav");
  death = minim.loadFile("sounds/death.wav");

  gm = new GameManager(this);
  gm.enableDebug();
  menu = (Menu)gm.addScene("Menu", new Menu());
  game = (Game)gm.addScene("Game", new Game());

  try {
    loadConfig();
  } 
  catch(Exception e) {
    saveConfig();
  }

  lastTime = millis();
}

public void draw() {
  background(255);

  if (millis()-lastTime >= 1000) {
    timePlayed++;
    lastTime = millis();
  }
}

public void exit() {
  saveConfig();
  super.exit();
}

public void playSound(AudioPlayer sound, int dB) {
  sound.setGain(dB);
  sound.play(0);
}
class Ball extends GameObject {
  int clr = color(255, 0, 0);
  int score = 100;

  Ball () {
  }
  Ball (PVector p) {
    pos.set(p);
    size.set(35, 0);
  }

  public void show() {
    push();
    fill(clr);
    noStroke();
    circle(pos.x, pos.y, size.x);
    pop();
  }

  public void action() {
    Player player = game.player;
    player.pos.sub(player.vel);
    PVector v = new PVector(player.pos.x-pos.x, player.pos.y-pos.y).normalize();
    player.vel.set(v.mult(player.vel.mag()));
    game.balls.remove(this);
  }

  public void blowUp() {
    game.particles.add(new Particles(pos, 50, clr, 2, game.player.vel));
    game.scoreTexts.add(new ScoreText(pos, getScore()));
    playSound(hit, -25);
  }

  public int getScore() {
    return score*game.combo;
  }
}

class RandomBall extends Ball {
  RandomBall () {
  }
  RandomBall (PVector p) {
    super(p);
    clr = color(255, 0, 255);
    score = 200;
  }

  public void action() {
    Player player = game.player;
    player.pos.sub(player.vel);
    PVector v = PVector.random2D();
    player.vel.set(v.mult(15));
    game.balls.remove(this);
  }
}

class PointBall extends Ball {
  PointBall () {
  }
  PointBall (PVector p) {
    super(p);
    size.set(15, 0);
    clr = color(255, 255, 0);
    score = 5000;
  }

  public int getScore() {
    return score;
  }
}

class KillBall extends Ball {
  KillBall () {
  }
  KillBall (PVector p) {
    super(p);
    clr = color(0, 255, 0);
    score = -100;
  }

  public void action() {
    game.player.kill("Green Ball");
    game.balls.remove(this);
  }
}

class HealthBall extends Ball {
  HealthBall () {
  }
  HealthBall (PVector p) {
    super(p);
    clr = color(255, 255, 255);
  }

  public void show() {
    push();
    fill(clr);
    noStroke();
    circle(pos.x, pos.y, size.x);
    pop();

    push();
    strokeWeight(3);
    stroke(255, 0, 0);
    strokeCap(PROJECT);
    line(pos.x-size.x*0.2f, pos.y, pos.x+size.x*0.2f, pos.y); // Horizontal line
    line (pos.x, pos.y-size.x*0.2f, pos.x, pos.y+size.x*0.2f); // Vertical line
    pop();
  }

  public void action() {
    Player player = game.player;
    player.pos.sub(player.vel);
    PVector v = new PVector(player.pos.x-pos.x, player.pos.y-pos.y).normalize();
    player.vel.set(v.mult(player.vel.mag()-0.5f));
    player.health = 100;
    game.balls.remove(this);
  }
}

class ComboBall extends Ball {
  ComboBall () {
  }
  ComboBall (PVector p) {
    super(p);
    clr = color(0, 0, 0);
    score = 0;
  }

  public void action() {
    Player player = game.player;
    player.comboShots += 10;
    game.balls.remove(this);
  }
}
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
  }

  public void show() {
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

  public int checkArg(String arg) {
    if (registry.containsKey(arg)) {
      return PApplet.parseInt(registry.get(arg));
    } else {
      return PApplet.parseInt(arg);
    }
  }

  public void runCode() {
    currentLine = 0;
    for (int i = 0; i < lines.size(); i++) {
      runLine();
    }
  }

  public void runLine() {
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
        registry.put("t", PApplet.parseInt(b instanceof Ball));
        break;
      case "killball":
        registry.put("t", PApplet.parseInt(b instanceof KillBall));
        break;
      case "randomball":
        registry.put("t", PApplet.parseInt(b instanceof RandomBall));
        break;
      case "healthball":
        registry.put("t", PApplet.parseInt(b instanceof HealthBall));
        break;
      case "pointball":
        registry.put("t", PApplet.parseInt(b instanceof PointBall));
        break;
      }
      break;
    case "mark":
      marks.put(tokens[1], currentLine);
      break;
    case "tjmp":
      if (PApplet.parseBoolean(registry.get("t"))) {
        currentLine = marks.get(tokens[1]);
      }
      break;
    case "fjmp":
      if (!PApplet.parseBoolean(registry.get("t"))) {
        currentLine = marks.get(tokens[1]);
      }
      break;
    }

    currentLine++;
    if (currentLine > lines.size()-1) {
      currentLine = 0;
    }
  }
}
public void loadConfig() {
  configJSON = loadJSONObject("config.json");
  game.totalBallsHit = configJSON.getInt("ballsHit");
  game.highScore = configJSON.getInt("highScore");
  game.highCombo = configJSON.getInt("highCombo");
  timePlayed = configJSON.getInt("timePlayed");
  saveConfig();
}

public void saveConfig() {
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

public PVector getAveragePVector(ArrayList<PVector> arr) {
  PVector total = new PVector();
  for (int i = 0; i < arr.size(); i++) {
    total.add(arr.get(i));
  }
  return total.div(arr.size());
}

public void renderShader() {
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    int c = pixels[i];
    if (red(c) >= 200 && green(c) >= 100) {
      pixels[i] = color(0);
    }
  }
  updatePixels();
}

public void shakeScreen(int frames, float intensity) {
  game.shakeFrames = frames;
  game.shakeIntensity = intensity;
}

public void generateBalls() {
  for (int i = 0; i < 1000; i++) {
    PVector p;
    do {
      p = getRandomPos();
    } while (PVector.dist(p, new PVector(width/2, height/2)) < 100);
    float rng = random(1);
    if (rng <= 0.01f) {
      game.balls.add(new HealthBall(p));
    } else if (rng <= 0.02f) {
      game.balls.add(new KillBall(p));
      game.balls.add(new ComboBall(getRandomPos()));
    } else if (rng <= 0.05f) {
      game.balls.add(new PointBall(p));
    } else if (rng <= 0.1f) {
      game.balls.add(new RandomBall(p));
    } else {
      game.balls.add(new Ball(p));
    }
  }
}

public PVector getRandomPos() {
  return new PVector(random(-width, width*2), random(-height, height));
}

public Ball getClosestBall(PVector pos) {
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
public Ball getClosestBall(PVector pos, Class c) {
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

  public void setup() {
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

  public void draw() {
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
      slowmo = constrain(map(frameCount-aimTime, 0, 30, 0.5f, 0.05f), 0.05f, 0.5f);
      shakeScreen(1, map(slowmo, 0.5f, 0.05f, 0, 2));
    }

    if (player.dead) {
      slowmo = map(fade, 0, 255, 1, 0.1f);
    }

    Ball killBall = getClosestBall(player.pos, new KillBall().getClass());
    if (player.started && killBall != null) {
      float d = PVector.dist(player.pos, killBall.pos);
      float maxDist = constrain(10*player.vel.mag(), player.size.x/2+killBall.size.x/2+1, 300);
      if (d < maxDist) {
        slowmo = constrain(map(d, player.size.x/2+killBall.size.x/2, maxDist, 0.01f, 1), 0.01f, 1);
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

      float slow = map(slowmo, 0.01f, 1, 0.5f, 0)/camera.zoom; // Camera zooming
      float speed = map(sum/speeds.size(), 0, 10, 1.5f, 1); // Camera zooming
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

    //drawLava();

    for (int i = scoreTexts.size()-1; i > -1; i--) {
      scoreTexts.get(i).show();
      if (scoreTexts.get(i).scale <= 0.01f) {
        scoreTexts.remove(i);
      }
    }
    pop();

    // HUD
    //codeWindow.show();

    push();
    fill(255, 255-fade);
    textAlign(CENTER, TOP);
    textSize(75+textBounce);
    if (textBounce > 0) {
      textBounce *= 0.8f;
    }
    float textWidth = textWidth("SCORE:"+score);
    text("SCORE:"+score, width/2, 25);
    textSize(25);
    textAlign(CENTER, CENTER);
    translate((width/2)+textWidth/2-15, 15);
    rotate(0.2f);
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

  public void mousePressed() {
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

  public void mouseDragged() {
    if (mouseButton == RIGHT && freeCam) {
      freeCamPos.add((pmouseX-mouseX)/camera.zoom, (pmouseY-mouseY)/camera.zoom);
    }
  }

  public void mouseReleased() {
    if (mouseButton == LEFT) {
      if (aiming && !player.dead) {
        player.shoot(getMouse());
      }
    }
  }

  public void keyPressed() {
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

  public void mouseWheel(MouseEvent event) {
    camera.zoom -= event.getCount()*0.1f*camera.zoom;
  }

  public PVector getMouse() {
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

  public void restartGame() {
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
public void drawHealthbar() {
  int w = width;

  push();
  rectMode(CENTER);
  noStroke();
  fill(0, 255-game.fade);
  rect(w/2, 125, 304, 24);
  fill(225, 0, 0, 255-game.fade);
  rect(w/2, 125, 300, 20);

  float healthWidth = map(game.player.health, 0, 100, 0, 300);
  fill(0, 225, 0, 255-game.fade);
  rect((w/2)-150+healthWidth/2, 125, healthWidth, 20);
  pop();
}
class Menu extends Scene {


  public void setup() {
  }

  public void draw() {
    background(50);

    push();
    textAlign(CENTER, TOP);
    text("Highscore:"+nfc(game.highScore), width/2, height/2);
    text("Balls Hit:"+game.totalBallsHit, width/2, height/2+15);
    text("Highest combo:"+game.highCombo, width/2, height/2+30);
    text("Time:"+getTimePlayed(timePlayed), width/2, height/2+45);
    pop();
  }

  public void mousePressed() {
    gm.changeScene("Game");
  }

  public String getTimePlayed(int n) {
    n = n % (24*3600);
    int hours = n/3600;
    n %= 3600;
    int minutes = n/60;
    n %= 60;
    int seconds = n;

    return join(new String[] {nf(hours, 2), nf(minutes, 2), nf(seconds, 2)}, ":");
  }
}
class Particles {
  ArrayList<Particle> particles = new ArrayList<Particle>();

  Particles (PVector p, int amount, int clr, float force, PVector dir) {
    for (int i = 0; i < amount; i++) {
      particles.add(new Particle(p.copy(), clr, force, dir));
    }
  }

  public void update() {
    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).update();
    }
  }

  public void show() {
    for (int i = particles.size()-1; i > -1; i--) {
      Particle p = particles.get(i);
      p.show();
      if (p.size <= 0) {
        particles.remove(p);
      }
    }
  }
}

class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  int clr;
  float rotation = random(-1, 1);
  float size = random(5, 10);

  Particle (PVector p, int c, float force, PVector dir) {
    pos.set(p.copy().add(PVector.random2D().mult(random(5))));
    vel = PVector.random2D().add(dir.copy().normalize()).mult(random(force));
    push();
    colorMode(HSB, 360, 100, 100);
    clr = color(hue(c)+random(-25, 25), saturation(c)+random(-25, 25), brightness(c)+random(-25, 25));
    pop();
  }

  public void update() {
    vel.y += 0.05f*game.slowmo;
    pos.add(vel.copy().mult(game.slowmo));
    size -= 0.05f*game.slowmo;
  }

  public void show() {
    push();
    noStroke();
    fill(clr);
    translate(pos.x, pos.y);
    rotate(rotation);
    rectMode(CENTER);
    rect(0, 0, size, size);
    pop();
  }
}
class Player extends GameObject {
  boolean dead = false;
  boolean started = false;
  boolean canShoot = true;

  Trail trail = new Trail();
  float trailTimer = 0;

  int clr = color(0, 150, 255);

  float health = 100;
  String deathReason = "";

  int comboShots = 0;

  Player (PVector p) {
    pos.set(p);
    size.set(25, 0);
  }

  public void show() {
    if (!dead) {
      trail.show();
      push();
      fill(clr);
      noStroke();
      translate(pos.x, pos.y);
      rotate(vel.heading());
      ellipse(0, 0, size.x, size.x);
      pop();
    }
  }

  public void update() {
    pos.add(vel.copy().mult(game.slowmo));
    trailTimer += 1*game.slowmo;
    if (trailTimer >= 0.5f) {
      trail.points.add(pos.copy());
      trailTimer = 0;
    }
    if (trail.points.size() > 30) {
      trail.points.remove(0);
    }

    if (started && !dead) {
      health -= 0.1f;
      if (health <= 0) {
        kill("Low Health");
      }
      vel.y += 0.07f*game.slowmo;
    } else {
      vel.set(0, 0);
    }

    Ball b = getClosestBall(pos);
    PVector p = b.pos;
    if (game.camera.pointInside(p, g)) {
      if (PVector.dist(p, pos) < size.x/2+b.size.x/2) {
        b.blowUp();
        game.textBounce += 15;
        health += 10;
        health = constrain(health, 0, 100);
        b.action();
        if (canShoot) {
          game.combo++;
          if (game.combo >= game.highRoundCombo) {
            game.highRoundCombo = game.combo;
          }
        }
        canShoot = true;
        game.ballsHit++;

        if (comboShots > 0) {
          Ball cb = getClosestBall(pos);
          if (!(cb instanceof KillBall)) {
            PVector target = cb.pos;
            PVector v = new PVector(target.x-pos.x, target.y-pos.y).setMag(vel.mag());
            vel.set(v);
            comboShots--;
          }
        }
      }
    }
  }

  public void shoot(PVector target) {
    if (!dead && canShoot) {
      game.aiming = false;
      started = true;
      canShoot = false;
      PVector v = new PVector(target.x-pos.x, target.y-pos.y).normalize();
      vel.set(v.mult(10));
      game.combo = 1;
    }
  }

  public void kill(String d) {
    deathReason = d;
    health = 0;
    started = false;
    dead = true;
    game.aiming = false;
    game.deathTime = frameCount;
    playSound(death, -25);
    game.particles.add(new Particles(pos, 25, clr, 2, new PVector(0, 0)));
    saveConfig();
  }
}
class ScoreText extends GameObject {
  int score = 0;
  float scale = 1;

  ScoreText (PVector p, int s) {
    pos.set(p);
    score = s;
    game.score += s;
  }

  public void show() {
    push();
    translate(pos.x, pos.y);
    scale(scale);
    fill(225, 175, 0);
    textSize(35);
    textAlign(CENTER, CENTER);
    text(score, 0, 0);
    pop();

    scale -= 0.01f*game.slowmo;
  }
}
class Trail {
  ArrayList<PVector> points = new ArrayList<PVector>();

  public void show() {
    push();
    if (points.size() > 1) {
      for (int i = 0; i < points.size(); i++) {
        PVector p1 = points.get(i);
        //PVector p2 = points.get(i+1);
        strokeWeight(constrain(map(i, 0, points.size(), 1, 10), 1, 10));
        stroke(200);
        //line(p1.x, p1.y, p2.x, p2.y);
        point(p1.x, p1.y);
      }
    }
    pop();
  }
}
  public void settings() {  fullScreen(FX2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "dCoder" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
