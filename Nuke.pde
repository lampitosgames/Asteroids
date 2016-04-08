/**
 * The nuke is a powerup for the player to use once the yellow energy meter has been filled.  It expands in a circle from the 
 * initial position of the ship, and destroys all active asteroids.  It extends the particle class for the sole purpose of using circle collision
 */
class Nuke extends Particle {
  //Is the nuke active?
  boolean active;
  //The radius at which the nuke will deactivate, allowing more asteroids to spawn
  float maxRadius;
  
  /**
   * Constructor
   */
  Nuke() {
    //Call the particle constructor with default values
    super(0, 0, new PVector(0, 0));
    
    //The initial radius is 15...the radius of the ship
    this.radius = 15;
    //The maximum radius is the width of the screen
    this.maxRadius = width;
    
    //The nuke is inactive by default
    this.active = false;
  }
  
  /**
   * The update method
   */
  void Update() {
    //Only update things if the nuke is active
    if (this.active) {
      //Increment the radius so the nuke expands
      this.radius += 5;
      //Collision check with asteroids
      //Loop through all asteroids
      for (int i=0; i<asteroids.size(); i++) {
        //Grab the asteroid to check
        Asteroid curAsteroid = asteroids.get(i);
        
        //If the asteroid is colliding with the nuke
        if (Utils.cpCollision(curAsteroid.shape, this)) {
          //Destroy that asteroid
          curAsteroid.Destroy();
          break;
        }
      }
    }
    //If the radius is larger than the max radius
    if (this.radius >= this.maxRadius) {
      //Reset the nuke
      this.radius = 15;
      this.active = false;
    }
  }
  
  /**
   * The draw method
   */
  void Draw() {
    //If the nuke is active
    if (this.active) {
      //Draw a series of yellow circles with different stroke weights
      ellipseMode(RADIUS);
      stroke(yellow);
      strokeWeight(5);
      ellipse(this.pos.x, this.pos.y, this.radius + 15, this.radius + 15);
      strokeWeight(2);
      ellipse(this.pos.x, this.pos.y, this.radius, this.radius);
      strokeWeight(1);
      ellipse(this.pos.x, this.pos.y, this.radius - 10, this.radius - 10);
      ellipse(this.pos.x, this.pos.y, this.radius - 25, this.radius - 25);
    }
  }
}