class Menu extends Scene {


  void setup() {
  }

  void draw() {
    background(50);

    push();
    textAlign(CENTER, TOP);
    text("Highscore:"+nfc(game.highScore), width/2, height/2);
    text("Balls Hit:"+game.totalBallsHit, width/2, height/2+15);
    text("Highest combo:"+game.highCombo, width/2, height/2+30);
    text("Time:"+getTimePlayed(timePlayed), width/2, height/2+45);
    pop();
  }

  void mousePressed() {
    gm.changeScene("Game");
  }

  String getTimePlayed(int n) {
    n = n % (24*3600);
    int hours = n/3600;
    n %= 3600;
    int minutes = n/60;
    n %= 60;
    int seconds = n;

    return join(new String[] {nf(hours, 2), nf(minutes, 2), nf(seconds, 2)}, ":");
  }
}
