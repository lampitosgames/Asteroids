/**
 * The bullet class represents the default object that the player can shoot.  Upon collision with asteroids, it destroys them.
 * It has a limited fire-rate (4 per second) and a limited range (the height of the window).
 */
class Bullet extends Particle {
  //A PVector that tracks how far the bullet has traveled
  PVector maxDist;
  //Is the bullet visible? Prevents odd bugs with the garbage collector when the bullet is destroyed
  boolean visible;
  
  /**
   * Constructor
   * @param x  Bullet starting x position
   * @param y  Bullet starting y position
   * @param vel  Bullet initial velocity. Should be the same direction as the ship's acceleration
   */
  Bullet(int x, int y, PVector vel) {
    //Call the default particle constructor
    super(x, y, vel);
    //Give the bullet a radius of 2
    radius = 2;
    //Give the maximum travel distance a starting vector of zero
    maxDist = new PVector(0, 0);
    //The bullet is visible by default
    this.visible = true;
  }
  
  /**
   * Update the bullet's kinematic variables.  Also detect collisions.
   */
  void Update() {
    //Call the particle update
    super.Update();
    //Add the velocity for this frame to the maximum distance
    this.maxDist.add(vel);
    //If the maximum distance of window height has been exceeded
    if (this.maxDist.mag() > height) {
      //Delete the bullet
      this.Destroy();
    }
    
    //Collision check with asteroids
    //Loop through all asteroids
    for (int i=0; i<asteroids.size(); i++) {
      //Grab the asteroid to check
      Asteroid curAsteroid = asteroids.get(i);
      
      //If there is a circle-polygon collision between the bullet and the asteroid-to-check
      //If the bullet is visible
      if (Utils.cpCollision(curAsteroid.shape, this) && this.visible) {
        //Set the asteroid velocity to move in the direction of the bullet.
        //This allows the player to deflect asteroids moving towards the ship by shooting at them
        curAsteroid.vel = PVector.mult(this.vel.normalize(), curAsteroid.vel.mag());
        //Destroy that asteroid
        curAsteroid.Destroy();
        //Destroy self
        this.Destroy();
        break;
      }
    }
  }
  
  /**
   * Draw the bullet.  This overrides the wrapping draw functionality of the particle class
   * because the bullet is too small to make drawing it twice worth it
   */
  void Draw() {
    //If the bullet is visible
    if (this.visible) {
      //Set stroke color to white.  Don't fill
      stroke(255);
      noFill();
      //Draw a circle that represents the bullet
      ellipseMode(RADIUS);
      ellipse(this.pos.x, this.pos.y, this.radius, this.radius);
    }
  }
  
  /**
   * Destroy this bullet
   */
  void Destroy() {
    //Destroy bullet references and make it invisible
    physics.physObjects.remove(physics.physObjects.indexOf(this));
    this.visible = false;
  }
}