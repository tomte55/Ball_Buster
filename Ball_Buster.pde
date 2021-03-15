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

Minim minim;
AudioPlayer hit;
AudioPlayer death;
AudioPlayer boost;
AudioPlayer coin;
AudioPlayer shoot;
float volume = 0.25;
float pitch = 0;

void setup() {
  fullScreen(FX2D);

  minim = new Minim(this);
  hit = minim.loadFile("sounds/hit.wav");
  death = minim.loadFile("sounds/death.wav");
  boost = minim.loadFile("sounds/boost.wav");
  coin = minim.loadFile("sounds/coin.wav");
  shoot = minim.loadFile("sounds/shoot.wav");

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

void playSound(AudioPlayer sound, float dB) {
  sound.setGain(dB/volume);
  sound.play(0);
}
