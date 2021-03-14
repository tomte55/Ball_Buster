class Particles {
  ArrayList<Particle> particles = new ArrayList<Particle>();

  Particles (PVector p, int amount, color clr, float force, PVector dir) {
    for (int i = 0; i < amount; i++) {
      particles.add(new Particle(p.copy(), clr, force, dir));
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

  Particle (PVector p, color c, float force, PVector dir) {
    pos.set(p.copy().add(PVector.random2D().mult(random(5))));
    vel = PVector.random2D().add(dir.copy().normalize()).mult(random(force));
    push();
    colorMode(HSB, 360, 100, 100);
    clr = color(hue(c)+random(-25, 25), saturation(c)+random(-25, 25), brightness(c)+random(-25, 25));
    pop();
  }

  void update() {
    vel.y += (0.05*size/5)*game.slowmo;
    pos.add(vel.copy().mult(game.slowmo));
    size -= 0.05*game.slowmo;

    lt += 0.05*game.slowmo;

    rotation += sin(lt)/15;
  }

  void show() {
    push();
    noStroke();
    fill(clr);
    translate(pos.x+sin(lt)*25, pos.y);
    rotate(rotation);
    rectMode(CENTER);
    rect(0, 0, size, size);
    pop();
  }
}
