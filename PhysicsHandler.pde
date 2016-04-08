/**
 * This is a custom physics engine (sort of)
 * It holds and handles all the particles, manages collisions, and manages everything.
 */
class PhysicsHandler {
  //Physics objects are particles that this handler keeps track of
  ArrayList<Particle> physObjects;
  
  /**
   * Constructor
   */
  PhysicsHandler() {
    //Initialize the particle array
    physObjects = new ArrayList<Particle>();
  }
  
  /**
   * The update method calls Update() for all particles in the system
   * It also calculates collisions between asteroids
   */
  void Update() {
    //Loop through physics objects
    for (int i=0; i<this.physObjects.size(); i++) {
       //Update each particle
       physObjects.get(i).Update();
    }
    
    //Detect asteroid collisions
    //Loop through all asteroids
    for (int j=0; j<asteroids.size(); j++) {
      //Get the asteroid to be checked for collisions.  Pass it it's own location in the array to remove
      //double-testing.
      Asteroid a1 = asteroids.get(j);
      //The second asteroid is null by default
      //Each collision detection will assign a new value to a2.  If all are null, no collisions were found
      Asteroid a2 = null;
      
      //Check for collisions as the asteroid wraps around the screen
      //If the right is off the edge
      if (a1.r2.x > width) {
        //Move the bounding box to the left side
        a1.shape.Pos(a1.pos.x - width, a1.pos.y);
        //Collision check at the left side
        a2 = a1.Collide(j);
        //Move the bounding box back
        a1.shape.Pos(a1.pos.x, a1.pos.y);
      }
      //If the left is off the edge.  Use the same method as above
      if (a1.r1.x < 0) {
        a1.shape.Pos(a1.pos.x + width, a1.pos.y);
        a2 = a1.Collide(j);
        a1.shape.Pos(a1.pos.x, a1.pos.y);
      }
      //If the bottom is off the edge
      if (a1.r2.y > height) {
        a1.shape.Pos(a1.pos.x, a1.pos.y - height);
        a2 = a1.Collide(j);
        a1.shape.Pos(a1.pos.x, a1.pos.y);
      }
      if (a1.r1.y < 0) {
        a1.shape.Pos(a1.pos.x, a1.pos.y + height);
        a2 = a1.Collide(j);
        a1.shape.Pos(a1.pos.x, a1.pos.y);
      }
      
      //Collision detect in the current location
      a2 = a1.Collide(j);
      
      //If a collision was detected
      if (a2 != null) {
        //Calculate an elastic collision
        //https://en.wikipedia.org/wiki/Elastic_collision
        float massTotal = a1.mass+a2.mass;
        float a1NewX = (a1.vel.x*(a1.mass-a2.mass) + (2 * a2.mass * a2.vel.x)) / massTotal;
        float a1NewY = (a1.vel.y*(a1.mass-a2.mass) + (2 * a2.mass * a2.vel.y)) / massTotal;
        float a2NewX = (a2.vel.x*(a2.mass-a1.mass) + (2 * a1.mass * a1.vel.x)) / massTotal;
        float a2NewY = (a2.vel.y*(a2.mass-a1.mass) + (2 * a1.mass * a1.vel.y)) / massTotal;
        //Set the asteroid's new velocity
        a1.vel = new PVector(a1NewX, a1NewY);
        a2.vel = new PVector(a2NewX, a2NewY);
        
        /*Add those vectors to the position so that the asteroids don't overlap after colliding.
          This is a messy process because for the sake of efficiency, collisions can only happen
          between 2 asteroids.  If 3+ are clustered close together, lots of jerking around will take
          place until the collision algorithm sorts it all out.*/
        a1.pos.add(a1.vel);
        a2.pos.add(a2.vel);
      }
    }
  }
  
  /**
   * The draw method calls Draw() for all particles in the system
   */
  void Draw() {
    //Loop through physics objects
    for (int i=0; i<this.physObjects.size(); i++) {
       //Draw each particle
       physObjects.get(i).Draw();
    }
  }
  
  /**
   * Add a particle to be tracked by the physics engine
   * @param obj  Particle to add
   */
  void Add(Particle obj) {
    this.physObjects.add(obj); 
  }
}