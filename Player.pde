class Player extends GameObject {
  boolean dead = false;
  boolean started = false;
  boolean canShoot = true;

  Trail trail = new Trail();
  float trailTimer = 0;

  color clr = color(0, 150, 255);

  float health = 100;
  String deathReason = "";

  int comboShots = 0;

  Player (PVector p) {
    pos.set(p);
    size.set(25, 0);
  }

  void show() {
    if (!dead) {
      trail.show();
      push();
      fill(clr);
      noStroke();
      ellipse(pos.x, pos.y, size.x, size.x);
      pop();
    }
  }

  void update() {
    pos.add(vel.copy().mult(game.slowmo));
    trailTimer += 1*game.slowmo;
    if (trailTimer >= 0.5) {
      trail.points.add(pos.copy());
      trailTimer = 0;
    }
    if (trail.points.size() > 30) {
      trail.points.remove(0);
    }

    if (started && !dead) {
      health -= 0.1;
      if (health <= 0) {
        kill("Low Health");
      }
      vel.y += 0.07*game.slowmo;
    } else {
      vel.set(0, 0);
    }

    Ball b = getClosestBall(pos);
    PVector p = b.pos;
    if (PVector.dist(p, pos) < size.x/2+b.size.x/2) { // Detect collision with ball
      game.textBounce += 15; // Bounce score text
      health += 10;
      health = constrain(health, 0, 100);
      b.action(); // Perform ball action
      if (canShoot) {
        game.combo++;
        if (game.combo >= game.highRoundCombo) {
          game.highRoundCombo = game.combo;
        }
      }
      canShoot = true;
      game.ballsHit++;

      b.blowUp();

      game.camera.shake(5, round(vel.mag()*0.5));

      if (comboShots > 0) { // Auto shoot at closest ball
        Ball cb = getClosestBall(pos);
        if (!(cb instanceof KillBall)) {
          PVector target = cb.pos;
          PVector v = new PVector(target.x-pos.x, target.y-pos.y).setMag(15);
          vel.set(v);
          comboShots--;
        }
      }
    }
  }

  void shoot(PVector target) {
    if (!dead && canShoot) {
      game.aiming = false;
      started = true;
      canShoot = false;
      PVector v = new PVector(target.x-pos.x, target.y-pos.y).normalize();
      vel.set(v.mult(10));
      game.combo = 1;
      game.particles.add(new Particles(pos, 25, color(255)));
      playSound(shoot, -1.5);
    }
  }

  void kill(String d) {
    deathReason = d;
    health = 0;
    started = false;
    dead = true;
    game.aiming = false;
    game.deathTime = frameCount;
    playSound(death, -5);
    game.particles.add(new Particles(pos, 75, clr));
    saveConfig();
  }
}
