/**
 * The level manager does all the miscelaneous high-level management tasks that don't fit in other classes.
 */
class LevelManager {
  //How many seconds pass between asteroids spawning
  int spawnRate;
  //What is the maximum number of asteroids that can exist before they stop spawning
  int maxAsteroids;
  
  //Score
  int score;
  
  //Fonts for the "Game Over" screen
  PFont courierNew72, courierNew16, courierNew24;
  
  /**
   * Constructor
   */
  LevelManager() {
    //Load two font sizes
    courierNew72 = loadFont("CourierNew72.vlw");
    courierNew16 = loadFont("CourierNew16.vlw");
    courierNew24 = loadFont("CourierNew24.vlw");
    //Clear everything and start a new game
    this.NewGame();
  }
  
  /**
   * The game loop.  This will spawn asteroids periodically, change game constants, and draw the game over screen
   */
  void Update() {
    //Every <spawnRate> seconds, add an asteroid
    if (seconds % spawnRate == 0 && frames == 1) {
      //Make sure that the maximum number of asteroids is not exceeded
      if (asteroids.size() < maxAsteroids) {
        this.AddAsteroid();
      }
    }
    
    //Every ten seconds, add to the max asteroid count
    if (seconds % 10 == 0 && frames == 1) {
      maxAsteroids += 1;
    }
    
    //Every 45 seconds, increase the spawn rate
    if (seconds % 45 == 0 && frames == 1) {
      spawnRate = spawnRate > 2 ? spawnRate - 1 : 2;
    }
    
    //If the player controls have been disabled, the game is over and the ship has 0 lives
    if (ship.playerControls == false) {
      //Draw "Game Over"
      textAlign(CENTER, CENTER);
      stroke(255);
      textSize(72);
      textFont(courierNew72);
      text("GAME OVER", width/2, height/2);
      //Draw "Press 'R' to restart"
      textSize(16);
      textFont(courierNew16);
      text("Press 'R' to restart", width/2, height/2 + 45);
      //Draw the final score
      textSize(24);
      textFont(courierNew24);
      text("Score: " + score, width/2, height/2 + 75);
    //Else, the game isn't over
    } else {
      //Every frame, add the number of elapsed seconds to the score
      this.score += seconds;
      //Draw the score
      textAlign(RIGHT);
      textFont(courierNew24);
      textSize(24);
      stroke(255);
      text(this.score, width - 40, 40);
    }
  }
  
  /**
   * Start a new game.  Clear out old globals
   */
  void NewGame() {
    //Create a new physics handler
    physics = new PhysicsHandler();
    //Create a list of asteroids
    asteroids = new ArrayList<Asteroid>();
    //Create the UI for powerups
    ui = new PowerupUI();
    
    //Start the frame counter at zero and the seconds at 1.
    frames = 0;
    seconds = 1;
    
    //Start the score at zero
    score = 0;
    
    //Spawn a ship at the center of the screen
    ship = new Ship(width/2, height/2);
    //Set the ship's friction (amount that velocity decays)
    ship.friction = 0.975;
    
    //Add the ship to the list of physics objects
    physics.physObjects.add(ship);
    
    //Set the asteroid spawn rate to 1 per 6 seconds
    spawnRate = 6;
    //Set the number of asteroids below which new asteroids will spawn
    maxAsteroids = 16;
    //Start out with 6 asteroids
    for (int i=0; i<6; i++) { this.AddAsteroid(); }
  }
  
  /**
   * Add a new asteroid to the game at the edges of the screen
   */
  void AddAsteroid() {
    //Get a random velocity
    int speed = (int)random(1.5, 3);
    int dir = (int)random(360);
    //Get a random off-screen position
    //Collision detection will push asteroids that spawn overlapped away from each other
    int x=0;
    int y=0;
    //Random screen side to spawn on
    int side = (int)random(4);
    //Depending on the side, spawn randomly along it
    switch (side) {
      //Top
      case 1:
        x = (int)random(width);
        y = (int)random(-70, 0);
        break;
      //Right
      case 2:
        x = (int)random(width, width+70);
        y = (int)random(height);
        break;
      //Bottom
      case 3:
        x = (int)random(width);
        y = (int)random(height, height+70);
        break;
      //Left
      case 4:
        x = (int)random(-70, 0);
        y = (int)random(height);
        break;
    }
    
    //Create an asteroid
    Asteroid newAsteroid = new Asteroid(x, y, speed, dir, 3, 60, 60);
    
    //Add the asteroid to the asteroid list and the physics object list
    asteroids.add(newAsteroid);
    physics.physObjects.add(newAsteroid);
  }
}