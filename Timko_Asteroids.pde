//  Daniel Timko
//  IGME-202-01
//  Homework 2 - Asteroids
//  3/17/16


//Input Manager (From MyCourses)
InputManager im;
//Level Manager
LevelManager levelManager;
//Ultra simple physics engine
PhysicsHandler physics;
//The UI manager.  Just for powerups
PowerupUI ui;

//Time tracking variables
int frames;
int seconds;

//The player ship
Ship ship;
//A list of all asteroids
ArrayList<Asteroid> asteroids;

//Game color scheme.  Keep them all in one place so they can be easily changed
color yellow = color(244, 224, 77);
color blue = color(46, 192, 249);
color red = color(255, 97, 96);
color white = color(255, 255, 255);

/**
 * The setup method
 */
void setup() {
  //Set the window size
  size(1920, 1080);
  //Create the input manager
  im = new InputManager();
  //Create a level manager.  The level manager will create all variables relevant to starting a new game
  levelManager = new LevelManager();
}

/**
 * The draw method
 */
void draw() {
  //Clear the sketch by drawing a black background
  background(0);
  
  //Increment the number of frames since the beginning of the second
  frames = frames >= (int)frameRate ? 0 : frames + 1;
  //If frames is zero, a seecond has passed
  seconds = frames == 0 ? seconds + 1 : seconds;
  
  //Update the level manager
  levelManager.Update();
  //Update and draw physics objects
  physics.Update();
  physics.Draw();
  
  //Update and draw the UI elements.  Do this last to make sure they stay on top
  ui.Update();
  ui.Draw();
}


//InputManager code
void keyPressed() { im.recordKeyPress(keyCode); }
void keyReleased() { im.recordKeyRelease(keyCode); }