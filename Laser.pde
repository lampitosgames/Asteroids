/**
 * An object used as the laser powerup.  It is a beam eminating from the head of the ship.
 * The laser will destroy all colliding asteroids
 */
class Laser {
  //A shape that represents the beam of the laser
  Shape beam;
  //Is the laser active?
  boolean active;
  
  /**
   * Constructor
   * @param heading  Direction the laser points in initially
   */
  Laser(PVector heading) {
    //Create a new beam shape.  Shape objects are relatively positioned at creation.  Create a very short and long rectangle.  It will rotate around the origin
    beam = new Shape();
    beam.Vertex(0, -1);
    beam.Vertex(0, 1);
    beam.Vertex(width, 1);
    beam.Vertex(width, -1);
    //Rotate to the heading
    beam.Rotate(heading.heading());
    
    //The laser is inactive by default
    active = false;
  }
  
  /**
   * The update method
   */
  void Update() {
    //Move the beam to the ship's position
    beam.Pos(ship.pos.x, ship.pos.y);
    //If the laser is active
    if (active) {
      //Collision check with asteroids
      //Loop through all asteroids
      for (int i=0; i<asteroids.size(); i++) {
        //Grab the asteroid to check
        Asteroid curAsteroid = asteroids.get(i);
        
        //If there is a collision between the laser and the asteroid-to-check
        if (Utils.shapeCollision(curAsteroid.shape, this.beam) != null) {
          //Destroy that asteroid
          curAsteroid.Destroy();
          break;
        }
      }
    }
  }
  
  /**
   * The draw method
   */
  void Draw() {
    //Only draw the laser if it is active
    if (active) {
      stroke(red);
      fill(red, 127);
      //Loop through all the vertecies
      for (int i=0; i<this.beam.verts.size(); i++) {
        //Grab the current vertex
        PVector p1 = this.beam.verts.get(i);
        //Get the next or first vertex
        PVector p2 = this.beam.verts.get(i+1 == this.beam.verts.size() ? 0 : i+1);
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
}