class ScoreText extends GameObject {
  int score = 0;
  float scale = 1;

  ScoreText (PVector p, int s) {
    pos.set(p);
    score = s;
    game.score += s;
  }

  void show() {
    push();
    translate(pos.x, pos.y);
    scale(scale);
    fill(225, 175, 0);
    textSize(35);
    textAlign(CENTER, CENTER);
    text(score, 0, 0);
    pop();

    scale -= 0.01*game.slowmo;
  }
}
