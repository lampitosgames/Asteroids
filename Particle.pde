/**
 * The particle class is the parent class for all moving objects in the game.
 * Physics can be applied in the same way to every particle, and derivative objects
 * can use extra code to modify how the particle functions.
 */
class Particle {
  
  //Kinematics vectors
  PVector pos;
  PVector vel;
  PVector accel;
  
  //Radius of the particle.  Used for drawing and some types of collisions
  int radius;
  //Estimation of a bounding rectangle.  Used for wrapping
  PVector r1, r2;
  //Friction of the particle (speed at which the velocity will decay)
  float friction;
  
  Shape shape;
  
  /**
   * Constructor
   * @param x  Starting x position of this particle
   * @param y  Starting y position of this particle
   * @param speed  Magnitude of the starting velocity vector
   * @param dir  Direction of the starting velocity vector
   */
  Particle(int x, int y, int speed, int dir) {
    //Create a position vector
    this.pos = new PVector(x, y);
    
    //Create a velocity vector with magnitude of <speed> and a heading of <dir>
    this.vel = new PVector(speed, 0);
    this.vel.rotate(radians(dir));
    
    //Create a default acceleration vector.  It has a tiny magnitude so that it's heading can be calculated
    this.accel = new PVector(0.00001, 0);
    
    //Friction will not change the velocity by default.
    friction = 1.0;
        //Nous by default
    radius = 0;
    
    //The bounding box estimation is a poor the default particle
    r1 = new PVector(this.pos.x, this.pos.y);
    r2 = new PVector(this.pos.x, this.pos.y);
  }
  
  /**
   * Constructor Overload
   * @param pos  Starting position vector (from top left of screen)
   * @param vel  Starting velocity vector
   */
  Particle(PVector pos, PVector vel) {
    //Set all movement vectors to their defaults
    this.pos = pos;
    this.vel = vel;
    this.accel = new PVector(0.00001, 0);
    //Friction will not change the velocity by default.
    friction = 1.0;
    //No adius by default
    radius = 0;
    
    //The bounding box estimation is just a point for the default particle
    r1 = new PVector(this.pos.x, this.pos.y);
    r2 = new PVector(this.pos.x, this.pos.y);
  }
  
  /**
   * Constructor Overload
   * @param x  Starting x position of this particle
   * @param y  Starting y position of this particle
   * @param vel  Starting velocity vector
   */
  Particle(int x, int y, PVector vel) {
    //Set all movement vectors to their defaults
    this.pos = new PVector(x, y);
    this.vel = vel;
    this.accel = new PVector(0.00001, 0);
    //Friction will not change the velocity by default.
    friction = 1.0;
    //No adius by default
    radius = 0;
    
    //The bounding box estimation is just a point for the default particle
    r1 = new PVector(this.pos.x, this.pos.y);
    r2 = new PVector(this.pos.x, this.pos.y);
  }
  
  /**
   * Update method that does per-frame calculations about this particle's speed, position, etc.
   * Also runs code for screen-wrapping
   */
  void Update() {
    //Multiply the velocity by the friction value.  Friction is <= 1, with lower values slowing the particle down much faster
    this.vel.mult(this.friction);
    
    //Add the acceleration to the velocity
    this.vel.add(this.accel);
    //Add the velocity to the position
    this.pos.add(this.vel);
    //Add the velocity to the estimated bounding box
    this.r1.add(this.vel);
    this.r2.add(this.vel);
    //Limit the velocity to 20 pixels per frame
    this.vel.limit(20);
    
    //Wrap code
    //If the particle is off the right side
    if (this.pos.x > width) {
      //Wrap it to the left
      this.pos.x = 0;
      this.r1.x = 0 - this.radius;
      this.r2.x = this.radius;
    }
    //If the particle is off the left side
    if (this.pos.x < 0) {
      //Wrap it to the right
      this.pos.x = width;
      this.r1.x = width - this.radius;
      this.r2.x = width + this.radius;
    }
    //If the particle is off the bottom
    if (this.pos.y > height) {
      //Wrap it to the top
      this.pos.y = 0;
      this.r1.y = 0 - this.radius;
      this.r2.y = this.radius;
    }
    //If the particle is off the top
    if (this.pos.y < 0) {
      //Wrap it to the bottom
      this.pos.y = height;
      this.r1.y = height - this.radius;
      this.r2.y = height + this.radius;
    }
  }
  
  /**
   * The draw method calls the DrawSelf() method multiple times depending on wrapping
   */
  void Draw() {
    //If the right is off the edge
    if (this.r2.x > width) {
      //Update the shape position to be wrapped
      this.shape.Pos(this.pos.x - width, this.pos.y);
      //Draw at the new position
      this.DrawSelf();
      //Reset the shape location
      this.shape.Pos(this.pos.x, this.pos.y);
    }
    if (this.r1.x < 0) {
      //Update the shape position to be wrapped
      this.shape.Pos(this.pos.x + width, this.pos.y);
      //Draw at the new position
      this.DrawSelf();
      //Reset the shape location
      this.shape.Pos(this.pos.x, this.pos.y);
    }
    //If the right is off the edge
    if (this.r2.y > height) {
      //Update the shape position to be wrapped
      this.shape.Pos(this.pos.x, this.pos.y - height);
      //Draw at the new position
      this.DrawSelf();
      //Reset the shape location
      this.shape.Pos(this.pos.x, this.pos.y);
    }
    if (this.r1.y < 0) {
      //Update the shape position to be wrapped
      this.shape.Pos(this.pos.x, this.pos.y + height);
      //Draw at the new position
      this.DrawSelf();
      //Reset the shape location
      this.shape.Pos(this.pos.x, this.pos.y);
    }
    //Draw at the current location
    this.DrawSelf();
  }
  
  /**
   * This is where draw code for individual objects will go.  It is a method stub.
   */
  void DrawSelf() {}
}