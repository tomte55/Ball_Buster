void drawHealthbar() {
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
