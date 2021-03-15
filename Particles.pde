class Particles {
  ArrayList<Particle> particles = new ArrayList<Particle>();

  Particles (PVector pos, int amount, color clr) {
    for (int i = 0; i < amount; i++) {
      PVector p = pos.copy().add(PVector.random2D().mult(35/2));
      particles.add(new Particle(p, clr));
    }
  }

  void update() {
    for (int i = particles.size()-1; i > -1; i--) {
      particles.get(i).update();
    }
  }

  void show() {
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
  color clr;
  float rotation = random(-1, 1);
  float size = random(5, 10);

  float lt = random(10);
  float ltC = random(0.01, 0.07);

  Particle (PVector p, color c) {
    pos.set(p.copy().add(PVector.random2D().mult(random(5))));
    vel = PVector.random2D();
    push();
    colorMode(HSB, 360, 100, 100);
    clr = color(hue(c)+random(-25, 25), saturation(c)+random(-25, 25), brightness(c)+random(-25, 25));
    pop();
  }

  void update() {
    size -= 0.05*game.slowmo;

    lt += ltC*game.slowmo;

    vel.x = sin(lt);
    rotation += sin(lt)/15;

    Ball b = getClosestBall(pos);
    if (PVector.dist(b.pos, pos) < b.size.x/2 && pos.y < b.pos.y) {
      vel.set(0, 0);
      rotation = 0;
    } else {
      vel.y += (0.03*size/5)*game.slowmo;
      pos.add(vel.copy().mult(game.slowmo));
      pos.x += sin(lt)*game.slowmo;
      pos.y += cos(lt)*game.slowmo;

      Player player = game.player;
      float d = PVector.dist(player.pos, pos);
      if (d < 100) {
        pos.add(player.vel.copy().mult(map(d, 0, 100, 0.6, 0.1)).mult(game.slowmo));
      }
    }
  }

  void show() {
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
