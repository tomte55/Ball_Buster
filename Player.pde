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
      translate(pos.x, pos.y);
      rotate(vel.heading());
      ellipse(0, 0, size.x, size.x);
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
    if (game.camera.pointInside(p, g)) {
      if (PVector.dist(p, pos) < size.x/2+b.size.x/2) {
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
        b.blowUp();

        shakeScreen(5, round(vel.mag()*0.5));

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

  void shoot(PVector target) {
    if (!dead && canShoot) {
      game.aiming = false;
      started = true;
      canShoot = false;
      PVector v = new PVector(target.x-pos.x, target.y-pos.y).normalize();
      vel.set(v.mult(10));
      game.combo = 1;
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
    game.particles.add(new Particles(pos, 25, clr, 2, new PVector(0, 0)));
    saveConfig();
  }
}
