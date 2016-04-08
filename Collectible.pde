/**
 * Collectibles are powerup fuel.  They are small particles that gravitate toward the ship.  If the ship collides
 * with a collectible, the player gets points towards powerups
 */
class Collectible extends Particle {
  //Shape representing the collectible
  Shape shape;
  
  //Amount of score the collectible is worth
  int scoreMod;
  //Type (Yellow, Blue, Red)
  int type;
  
  /**
   * Constructor
   * @param x  Starting x location
   * @param y  Starting y location
   */
  Collectible(int x, int y) {
    //Call the particle constructor with a default velocity
    super(x, y, new PVector(0, 0));
    
    //Determine the type randomly.  Equal chance for every particle type
    //Directed random
    int rand = (int)random(100);
    if (rand < 33) {
      type = 0;
    } else if (rand < 66) {
      type = 1;
    } else {
      type = 2;
    }
    
    //Set the friction of the particle so that gravity doesn't send it flying at superspeed
    this.friction = 0.975;
    
    //Set the score modifier to 5
    scoreMod = 5;
    
    //Radius of 5.  Gives a large bounding box to make sure the ship hits the particle
    radius = 5;
    
    //Create a shape to represent this object.  The shape is square.
    shape = new Shape();
    shape.Vertex(-radius, -radius);
    shape.Vertex(radius, -radius);
    shape.Vertex(radius, radius);
    shape.Vertex(-radius, radius);
    //Set the shape position to match the collectible
    this.shape.Pos(this.pos.x, this.pos.y);
  }
  
  /**
   * Update method
   */
  void Update() {
    //Call the particle update method to calculate kinematics variables
    super.Update();
    
    //Set the shape position to match the collectible
    this.shape.Pos(this.pos.x, this.pos.y);
    
    //Gravitate towards the ship
    float dist = Utils.Distance(this.pos.x, this.pos.y, ship.pos.x, ship.pos.y);
    //Calculate the gravitational force 
    float force = (ship.mass / (dist*dist))*4;
    //Add to the velocity based on the gravitational force
    this.vel.x -= force*((this.pos.x-ship.pos.x)/dist);
    this.vel.y -= force*((this.pos.y-ship.pos.y)/dist);
    
    //If the particle is colliding with the ship, destroy it
    if (Utils.shapeCollision(this.shape, ship.shape) != null) {
      this.Destroy();
    }
  }
  
  /**
   * Override the particle draw method
   */
  void Draw() {
    rectMode(CORNERS);
    
    //Create a transparent "Glow" effect for the particle
    //Get a fill color based on type
    switch (type) {
      case 0:
        fill(yellow, 100);
        break;
      case 1:
        fill(blue, 100);
        break;
      case 2:
        fill(red, 100);
        break;
    }
    noStroke();
    rect(this.pos.x - 3, this.pos.y - 3, this.pos.x + 3, this.pos.y + 3);
    
    //Draw the actual particle
    //Get the color based on type
    switch (type) {
      case 0:
        stroke(yellow);
        break;
      case 1:
        stroke(blue);
        break;
      case 2:
        stroke(red);
        break;
    }
    noFill();
    rect(this.pos.x - 1, this.pos.y - 1, this.pos.x + 1, this.pos.y + 1);
    
  }
  
  /**
   * Destroy this particle, adding to the proper point values
   */
  void Destroy() {
    //Add points
    ui.AddPoints(this.scoreMod, this.type);
    //If the game isn't over
    if (ship.playerControls) {
      //Add to the score
      levelManager.score += this.scoreMod*100;
    }
    //Destroy bullet references and make it invisible
    physics.physObjects.remove(physics.physObjects.indexOf(this));
  }
}