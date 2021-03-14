import processing.sound.*;
import ddf.minim.*;
import mouse.transformed2D.*;
import tomte.gameManager.*;

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
AudioPlayer boost;
AudioPlayer coin;
float volume = 0.25;
float pitch = 0;

void setup() {
  fullScreen(P2D);

  minim = new Minim(this);
  hit = minim.loadFile("sounds/hit.wav");
  death = minim.loadFile("sounds/death.wav");
  boost = minim.loadFile("sounds/boost.wav");
  coin = minim.loadFile("sounds/coin.wav");

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

void draw() {
  background(255);

  if (millis()-lastTime >= 1000) {
    timePlayed++;
    lastTime = millis();
  }
}

void exit() {
  saveConfig();
  super.exit();
}

void playSound(AudioPlayer sound, int dB) {
  sound.setGain(dB/volume);
  sound.play(0);
}
