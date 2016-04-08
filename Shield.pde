/**
 * The shield is a powerup.  It protects the player from asteroid hits, but de-increments itself each time it does so
 */
class Shield {
  //Position of the shield
  PVector pos;
  //Size of the shield
  float radius;
  
  //6 levels.  0 means none
  int level;
  
  //Increment the theta every update.  This is for spinning dot level shields
  float theta;
  
  /**
   * Constructor
   */
  Shield() {
    //The shield has a default radius of 24
    this.radius = 24;
    //Initialize the position vector
    this.pos = new PVector(0, 0);
    //Give the player a small starting shield
    this.level = 1;
    //Start the rotation of odd-level shield elements at 0
    this.theta = 0;
  }
  
  /**
   * The draw method
   */
  void Draw() {
    //Subtract 3 degrees from the outer shield dot rotation value
    this.theta -= 3;
    ellipseMode(RADIUS);
    noFill();
    stroke(blue);
    //If the shield level is greater than zero
    if (level != 0) {
      //Draw a different shield indicator for each level of shielding
      //A solid line circle means 2 levels
      //A rotating circle of points meansn half a level
      if (level == 6) {
        //Three solid circles
        ellipse(this.pos.x, this.pos.y, this.radius, this.radius);
        ellipse(this.pos.x, this.pos.y, this.radius - 3, this.radius - 3);
        ellipse(this.pos.x, this.pos.y, this.radius - 6, this.radius - 6);
      } else if (level == 5) {
        //Draw dotted outline
        for (int i=0; i<20; i++) {
          float x = this.pos.x + cos(radians(theta + i*18))*(this.radius+1);
          float y = this.pos.y + sin(radians(theta + i*18))*(this.radius+1);
          ellipse(x, y, 1, 1);
        }
        ellipse(this.pos.x, this.pos.y, this.radius - 3, this.radius - 3);
        ellipse(this.pos.x, this.pos.y, this.radius - 6, this.radius - 6);
      } else if (level == 4) {
        ellipse(this.pos.x, this.pos.y, this.radius - 3, this.radius - 3);
        ellipse(this.pos.x, this.pos.y, this.radius - 6, this.radius - 6);
      } else if (level == 3) {
        //Draw dotted outline
        for (int i=0; i<20; i++) {
          float x = this.pos.x + cos(radians(theta + i*18))*(this.radius - 2);
          float y = this.pos.y + sin(radians(theta + i*18))*(this.radius - 2);
          ellipse(x, y, 1, 1);
        }
        ellipse(this.pos.x, this.pos.y, this.radius - 6, this.radius - 6);
      } else if (level == 2) {
        ellipse(this.pos.x, this.pos.y, this.radius - 6, this.radius - 6);
      } else if (level == 1) {
        //Draw dotted outline
        for (int i=0; i<20; i++) {
          float x = this.pos.x + cos(radians(theta + i*18))*(this.radius - 5);
          float y = this.pos.y + sin(radians(theta + i*18))*(this.radius - 5);
          ellipse(x, y, 1, 1);
        }
      }
    }
  }
}