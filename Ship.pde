/**
 * The ship is the player character in this game.
 * The ship class extends the particle class
 */
class Ship extends Particle {
  //Number of lives
  int lives;
  //Invulnerability timer that grants invincibility 
  float invuln;
  //Shoot Timer determines how quickly the player can shoot
  int shootTimer;
  //The ship's shield.  Inactive by default
  Shield shield;
  //The ship's laser.  Inactive by default
  Laser laser;
  //The ship's nuke
  Nuke nuke;
  
  //Ship mass
  float mass;
  
  //Are the controls active?
  boolean playerControls;
  
  /**
   * Constructor
   * @param x  Starting x position for the ship
   * @param y  Starting y position for the ship
   */
  Ship(int x, int y) {
    //Call particle's constructor
    super(x, y, new PVector(0, 0));
    //Set the ship's radius (used by drawing)
    this.radius = 10;
    //Set the bounding box of the ship
    this.r1 = new PVector(this.pos.x - this.radius, this.pos.y - this.radius);
    this.r2 = new PVector(this.pos.x + this.radius, this.pos.y + this.radius);
    
    //Start with 3 lives
    this.lives = 3;
    //Start alive, obviously
    this.playerControls = true;
    //Start with invincibility.
    //This shoiuld be tied directly to frame rate, but when the game starts up the framerate is atrocious.
    this.invuln = 20.0;
    //Create a shield
    this.shield = new Shield();
    //Create a laser
    this.laser = new Laser(this.accel);
    //Create a nuke
    this.nuke = new Nuke();
    
    //Default mass is twice an asteroid
    this.mass = 120;
    
    this.shootTimer = 0;
    
    //Construct a ship shape
    this.shape = new Shape();
    this.shape.Vertex(this.radius, 0);
    this.shape.Vertex(-this.radius, this.radius/1.5);
    this.shape.Vertex(-this.radius, -this.radius/1.5);
  }
  
  /**
   * An extension of particle's Update() method
   */
  void Update() {
    //Call particle's update method
    super.Update();
    //De-increment the shoot timer
    shootTimer = shootTimer > 0 ? shootTimer - 1 : shootTimer;
    //If the player has invincibility
    if (this.invuln > 0) {
      //Reduce it, clamping to zero
      this.invuln -= 1.0/frameRate;
      this.invuln = Utils.Clamp(this.invuln - (1.0/frameRate), 0, 10);
    }
    //Set the shape position to match the ship
    this.shape.Pos(this.pos.x, this.pos.y);
    //Set the shield position to match the ship
    this.shield.pos = this.pos;
    this.laser.Update();
    this.nuke.Update();
    
    //If the invuln timer is at zero
    if (this.invuln == 0) {
      //Check for collisions with asteroids
      for (int i=0; i<asteroids.size(); i++) {
        if (Utils.shapeCollision(asteroids.get(i).shape, this.shape) != null) {
          //If there are no shields
          if (this.shield.level == 0) {
            //Destroy self
            this.Destroy();
          //There are shields.  Perform an elastic collision
          } else {
            //De-increment the shield level
            this.shield.level -= 1;
            Asteroid a2 = asteroids.get(i);
            float massTotal = this.mass+a2.mass;
            float a1NewX = (this.vel.x*(this.mass-a2.mass) + (2 * a2.mass * a2.vel.x)) / massTotal;
            float a1NewY = (this.vel.y*(this.mass-a2.mass) + (2 * a2.mass * a2.vel.y)) / massTotal;
            float a2NewX = (a2.vel.x*(a2.mass-this.mass) + (2 * this.mass * this.vel.x)) / massTotal;
            float a2NewY = (a2.vel.y*(a2.mass-this.mass) + (2 * this.mass * this.vel.y)) / massTotal;
            //Set the asteroid's new velocity
            this.vel = new PVector(a1NewX, a1NewY);
            a2.vel = new PVector(a2NewX, a2NewY);
            this.pos.add(this.vel);
            a2.pos.add(a2.vel);
            //Set a small invuln timer to prevent double crashes
            this.invuln += 3;
          }
        }
      }
    }
    
    //If the player has control
    if (this.playerControls) {
      //Check for key presses
      //If the left key is currently pressed
      if (im.isKeyPressed(LEFT)) {
        if (laser.active == false) {
          //Rotate the acceleration vector to the left
          this.accel.rotate(radians(-5));
          this.laser.beam.Rotate(-5);
          //Rotate the shape to the left
          this.shape.Rotate(-5);
        } else {
          this.accel.rotate(radians(-0.5));
          this.laser.beam.Rotate(-0.5);
          this.shape.Rotate(-0.5);
        }
      }
      //If the right key is currently pressed
      if (im.isKeyPressed(RIGHT)) {
        //If the laser is not active
        if (laser.active == false) {
          //Rotate the acceleration vector to the right
          this.accel.rotate(radians(5));
          this.laser.beam.Rotate(5);
          //Rotate the shape to the right
          this.shape.Rotate(5);
        } else {
          this.accel.rotate(radians(0.5));
          this.laser.beam.Rotate(0.5);
          this.shape.Rotate(0.5);
        }
      }
      //If the up key is currently pressed
      if (im.isKeyPressed(UP)) {
        if (laser.active == false) {
          //Set the acceleration vector's magnitude
          this.accel.setMag(0.2);
        } else {
          this.accel.setMag(0.1);
        }
      //Else, the up key is not pressed
      } else {
        //Set the acceleration vector's magnitude to near-zero
        this.accel.setMag(0.0001);
      }
      //If the spacebar is currently pressed
      if (im.isKeyPressed(' ')) {
        this.Shoot();
      } else {
        this.laser.active = false;
      }
    //Else, player controls are not enabled and the game is over
    } else {
      //Wait for 'R' to be pressed
      if (im.isKeyPressed('R')) {
        //Start a new game
        levelManager.NewGame();
      }
    }
  }
  
  /**
   * The draw method
   */
  void Draw() {
    //Call the particle draw method
    super.Draw();
    //Draw the shield
    this.shield.Draw();
    //Draw the laser
    this.laser.Draw();
    //Draw the nuke
    this.nuke.Draw();
    //Draw the number of lives left in icon form
    //For every life left
    for (int i=0; i<this.lives; i++) {
      pushMatrix();
        //Buffer space of 10 from screen border and 10 in between ships
        translate(10 + this.radius + i*(this.radius*2 + 10), 10+this.radius);
        //Draw a triangle to represent a ship life
        stroke(255);
        line(0, -this.radius, -this.radius/1.5, this.radius);
        line(-this.radius/1.5, this.radius, this.radius/1.5, this.radius);
        line(this.radius/1.5, this.radius, 0, -this.radius);
      popMatrix();
    }
  }
  
  /**
   * The default particle draw method
   */
  void DrawSelf() {
    //If the invulnerability counter is above zero
    if (this.invuln > 0) {
      //If over 5 left of invulnerability
      if (this.invuln > 5.0) {
        //Blink every 0.33 seconds
        if (frames % 30 > 15) {
          DrawShip(color(255));
        } else {
          DrawShip(color(150));
        }
      //Else, blink every 0.1 seconds
      } else {
        if (frames % 12 > 6) {
          DrawShip(color(255));
        } else {
          DrawShip(color(150));
        }
      }
    //Else, there is no invlunerability.  If the player still has life
    } else if (lives > 0) {
      //Draw the ship a solid white
      DrawShip(color(255));
    //If the game is over
    } else {
      //Draw a discolored ship
      DrawShip(color(100));
    }
  }
  
  /**
   * Allows the ship to be drawn as a different color on specific frames
   */
  void DrawShip(color c) {
    //Draw the shape
    stroke(c);
    noFill();
    //Loop through all the vertecies
    for (int i=0; i<this.shape.verts.size(); i++) {
      //Draw each line between the verts
      //Get the current vertex
      PVector p1 = this.shape.verts.get(i);
      //Get the next vertex or the first
      PVector p2 = this.shape.verts.get(i+1 == this.shape.verts.size() ? 0 : i+1);
      //Draw a line between them
      line(p1.x, p1.y, p2.x, p2.y);
    }
  }
  
  /**
   * The shoot method determines which type of action to perform when the player shoots
   * If resources for the active action are depleted, the default bullet shot will be performed
   */
  void Shoot() {
    //Determine the active shoot action
    switch (ui.curActive) {
      //Nuke
      case 0:
        //If the player has enough yellow resource to launch a nuke
        if (ui.yellowTotal >= ui.yellowMax) {
          //Create a nuke
          ui.yellowTotal = 0;
          nuke.pos = this.pos.copy();
          nuke.active = true;
        //Else, shoot a bullet
        } else {
          this.ShootBullet();
        }
        break;
      //Shield
      case 1:
        if (ui.blueTotal >= 100 && this.shootTimer == 0) {
          if (this.shield.level < 6) {
            ui.blueTotal -= 100;
            this.shield.level += 1;
            this.shootTimer = 45;
          }
        } else {
          this.ShootBullet();
        }
        break;
      //Laser
      case 2:
        if (ui.redTotal >= 2) {
          ui.redTotal -= 2;
          this.laser.active = true;
        } else {
          this.laser.active = false;
          this.ShootBullet();
        }
        break;
      //Bullets
      case 3:
        this.ShootBullet();
        break;
    }
  }
  
  /**
   * This method shoots a bullet at the tip of the ship in the direction the ship is facing
   */
  void ShootBullet() {
    if (this.shootTimer == 0) {
      //Create a new bullet at the ship position in the direction o the acceleration going at 10px/s
      Bullet newBullet = new Bullet((int)this.pos.x, (int)this.pos.y, PVector.mult(this.accel.copy().normalize(), 10));
      //Add the bullet as a physics object
      physics.Add(newBullet);
      //Reset the shoot timer
      this.shootTimer = 15;
    }
  }
  
  /**
   * Takes 1 life from the ship and re-centers it.
   * Also sets invulnerability time positive
   */
  void Destroy() {
    //If the player has more than 1 life left
    if (this.lives > 1) {
      //Decriment the life counter
      this.lives -= 1;
      //Set all movement vectors to their defaults
      this.pos = new PVector(width/2, height/2);
      this.vel = new PVector(0, 0);
      this.accel = new PVector(0.0001, 0);
      //Reset the ship's bounding box
      this.r1 = new PVector(this.pos.x - this.radius, this.pos.y - this.radius);
      this.r2 = new PVector(this.pos.x + this.radius, this.pos.y + this.radius);
      //Grant a few seconds of invincibility
      this.invuln = 10.0;
      
      //Construct a new shape (resets rotation data)
      this.shape = new Shape();
      this.shape.Vertex(this.radius, 0);
      this.shape.Vertex(-this.radius, this.radius/1.5);
      this.shape.Vertex(-this.radius, -this.radius/1.5);
    //Else, the game is over
    } else {
      //Set lives to 0 so that the life counter UI doesn't display anything
      this.lives -= 1;
      //Remove the player's ability to move the ship
      this.playerControls = false;
      //Set the acceleration vector's magnitude to near-zero
      this.accel.setMag(0.00001);
    }
  }
}