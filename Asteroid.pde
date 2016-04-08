/**
 * The asteroid class is a type of particle that moves around the screen.
 * It collides with itself, splits up into smaller asteroids when hit with a bullet,
 * and takes lives from the player when hit.
 */
class Asteroid extends Particle {
  //Asteroid level (when destroyed, this is decrimented for sub asteroids)
  int asteroidLevel;
  //Asteroid mass
  int mass;
  
  /**
   * Constructor
   * @param x  Starting x position of the asteroid
   * @param y  Starting y position of the asteroid
   * @param speed  Starting speed of the asteroid
   * @param dir  Starting velocity direction of the asteroid
   * @param lev  The asteroid's level. Relevant to sub spawning and points
   * @param radius  The size of the asteroid
   * @param mass  The mass of the asteroid used for elastic collision calculations
   */
  Asteroid(int x, int y, int speed, int dir, int lev, int radius, int mass) {
    //Call the particle constructor
    super(x, y, speed, dir);
    //Set given values
    this.asteroidLevel = lev;
    this.radius = radius;
    this.mass = mass;
    //Create an estimated, rectangular bounding box to be used for wrapping
    this.r1 = new PVector(this.pos.x - this.radius, this.pos.y - this.radius);
    this.r2 = new PVector(this.pos.x + this.radius, this.pos.y + this.radius);
    
    /*
      Generate the asteroid shape
      Shapes store vertices in relative coordinates
    */
    this.shape = new Shape();
    //Random number of verts
    int vertNum = (int)random(6, 12);
    //Arc length for possible vertex spawn
    float arcLen = 360/vertNum;
    
    //For every vertex to spawn
    for (int i=0; i<vertNum; i++) {
      //Calculate an angle (anywhere in the arc length, plus the other arc lengths that exist)
      float theta = i * arcLen + random(arcLen);
      //Get the (x, y) components of the vertex using trig
      float vX = cos(radians(theta))*this.radius;
      float vY = sin(radians(theta))*this.radius;
      //Create a vertex
      this.shape.Vertex(vX, vY);
    }
  }
  
  /**
   * Update the asteroid
   */
  void Update() {
    //Call the particle update method
    super.Update();
    //Limit the velocity to 3
    this.vel.limit(3);
    //Set the shape position to match the asteroid position
    this.shape.Pos(this.pos.x, this.pos.y);
  }
  
  /**
   * Draws the asteroid's shape at the current location.  Makes use of the particle class's wrapping functionality in the parent Draw() method
   */
  void DrawSelf() {
    //Draw the shape
    stroke(255);
    noFill();
    //Loop through all the vertecies
    for (int i=0; i<this.shape.verts.size(); i++) {
      //This vertex
      PVector p1 = this.shape.verts.get(i);
      //Next or first vertex
      PVector p2 = this.shape.verts.get(i+1 == this.shape.verts.size() ? 0 : i+1);
      //Draw a line between them
      line(p1.x, p1.y, p2.x, p2.y);
    }
  }
  
  /**
   * Returns the asteroid that is currently colliding with this asteroid (if there is one).
   * Starting at a specific position in the array saves quite a few check cycles when looping through
   * and checking every asteroid for collisions.
   * @param i  Location in the array to start the check. Usually the location of this asteroid
   */
  Asteroid Collide(int i) {
    //Loop through every other asteroid after this one
    for (int k=i+1; k<asteroids.size(); k++) {
      //Save the asteroid-to-check
      Asteroid a2 = asteroids.get(k);
     
      //If these asteroids aren't the same
      if (a2 != this) {
        //Collision check their shapes.  The returned PVector is the MTV (minimum translation vector) that will separate the asteroids
        PVector collision = Utils.shapeCollision(this.shape, a2.shape);
        //If the objects are colliding
        if (collision != null) {
          /*Move the second asteroid to a position where it doesn't clip this asteroid.
            NOTE: This can sometimes cause an odd-looking jerky motion.  But without it, 
            clipping issues run rampant due to low-level asteroids spawning inside of other asteroids*/
          a2.pos.add(collision);
          //Return the collision asteroid so that physics calculations can be done
          return a2;
        }
      }
    }
    //If the code gets this far, no collision was found.  Return null
    return null;
  }
  
  /**
   * Destroy this asteroid.  If it is a high level asteroid, create two in it's place
   */
  void Destroy() {
    //If the asteroid level is > 1, create two more asteroids
    if (this.asteroidLevel > 1) {
      //Get a perpendicular velocity vector with a magnitude of <radius>/2.  This is used to offset the child asteroid spawn locations so they don't overlap initially
      PVector offset = Utils.Orthog(this.vel).normalize().mult(this.radius/2);
      
      //Add the offset to this position to get a location for the first sub-asteroid
      PVector n1Pos = this.pos.copy().add(offset);
      //Create the first asteroid with 2*<vel> offset by 30 degrees. Give it half the radius and half the mass
      Asteroid new1 = new Asteroid((int)n1Pos.x, (int)n1Pos.y, 2*(int)this.vel.mag(), (int)degrees(this.vel.heading()) - 30, this.asteroidLevel - 1, this.radius/2, this.mass/2);
      //Add the new asteroid to relevant lists
      asteroids.add(new1);
      physics.physObjects.add(new1);
      
      //Rotate the offset vector 180 to face the opposite direction
      offset.rotate(radians(180));
      
      //Repeat for the second sub-asteroid
      PVector n2Pos = this.pos.copy().add(offset);
      Asteroid new2 = new Asteroid((int)n2Pos.x, (int)n2Pos.y, 2*(int)this.vel.mag(), (int)degrees(this.vel.heading()) + 30, this.asteroidLevel - 1, this.radius/2, this.mass/2);
      asteroids.add(new2);
      physics.physObjects.add(new2);
    }
    //Regardless of asteroid level, create collectibles.  The max number spawned is equal to 0.1*<mass>
    //Random number based on asteroid size.  Larger asteroids spawn more
    int collectibleCount = (int)random(3, this.mass/10);
    //Loop thorugh and spawn collectibles
    for (int i=0; i<collectibleCount; i++) {
      //Random x and y inside the asteroid
      int x = (int)random(this.pos.x - this.radius, this.pos.x + radius);
      int y = (int)random(this.pos.y - this.radius, this.pos.y + radius);
      //Create a new collectible, passing it's reference to the physics handler
      physics.Add(new Collectible(x, y));
    }
    
    //Remove the current asteroid from all lists
    asteroids.remove(asteroids.indexOf(this));
    physics.physObjects.remove(physics.physObjects.indexOf(this));
  }
}