class ExtendedCamera extends Camera {
  ArrayList<Float> speeds = new ArrayList<Float>(); // Average speed used for smooth zooming

  boolean screenShake = true;
  int shakeFrames = 0;
  float shakeIntensity = 1;

  boolean freeMode = false;
  PVector freeModePos = new PVector();

  ExtendedCamera (PApplet sketch, PVector p) {
    super(sketch, p);
    limit.set(1, 1);
    smooth = 0.1;
  }

  void update() {
    if (freeMode) {
      target = freeModePos;
    } else {
      target = game.player.pos;

      speeds.add(game.player.vel.mag());
      if (speeds.size() > 120) {
        speeds.remove(0);
      }
      float sum = 0;
      for (int i = 0; i < speeds.size(); i++) {
        sum += speeds.get(i);
      }
      float speed = map(sum/speeds.size(), 0, 20, 1.5, 0.8);
      zoom = constrain(speed, 0.8, 1.5);
    }

    if (screenShake) {
      if (shakeFrames > 0) {
        offset = PVector.random2D().mult(shakeIntensity);
        shakeFrames--;
      } else {
        offset.set(0, 0);
      }
    }
  }

  void shake(int frames, float intensity) {
    shakeFrames = frames;
    shakeIntensity = intensity;
  }

  void toggleFreeCam() {
    freeMode = !freeMode;
    freeModePos = game.player.pos.copy();
  }
}
