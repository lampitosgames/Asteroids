/**
 * The UI for powerups.  It is drawn last
 */
class PowerupUI {
  //Powers list:
  //  0 = Nuke
  //  1 = Shield
  //  2 = Laser
  //  3 = Default (none)
  int prevActive, curActive;
  
  //Track the totals for all types of resource
  int yellowTotal, blueTotal, redTotal;
  //The cap for different resources
  int yellowMax, blueMax, redMax;
  
  //Boolean to keep track of switching.  Makes sure that only 1 switch will be performed when a key is held
  boolean switchCheckA, switchCheckD;
  
  //So this is a bit of a hack-around.  All the UI elements are absolutely positioned instead of calculated on-the-fly.
  //This is just a personal choice
  //Location of every dot along the curve
  float[][] locations;
  //Color of every dot along the curve
  color[] dotColor;
  //The focus dot is the active dot
  //  o O [0] O o is how this will be drawn
  int focusDot;
  
  /** 
   * Constructor
   */
  PowerupUI() {
    //Initialize animation dot locations
    CalculateDots();
    
    //Start with no power selected by default (the default spacebar action will be to shoot)
    prevActive = 3;
    curActive = 3;
    focusDot = 20;
    
    //Initialize all the resources to their default values
    yellowTotal = 0;
    yellowMax = 1000;
    blueTotal = 0;
    blueMax = 600;
    redTotal = 0;
    redMax = 1000;
    
    //Player can initially switch powers
    switchCheckA = false;
    switchCheckD = false;
  }
  
  /**
   * The update method
   */
  void Update() {
    //If the 'A' key is pressed, cycle the current power to the left
    if (im.isKeyPressed('A') && switchCheckA == false) {
      switchCheckA = true;
      curActive = (int)Utils.Clamp(curActive - 1, 0, 3);
    }
    //If the 'D' key is pressed, cycle the current power to the right
    if (im.isKeyPressed('D') && switchCheckD == false) {
      switchCheckD = true;
      curActive = (int)Utils.Clamp(curActive + 1, 0, 3);
    }
    //On key release, reset the 'one-time-only' key checks
    if (im.isKeyReleased('A')) {
      switchCheckA = false;
    }
    if (im.isKeyReleased('D')) {
      switchCheckD = false;
    }
  }
  
  /**
   * The draw method
   */
  void Draw() {
    //Push the matrix so it can be translated
    pushMatrix();
      //Translate to the bottom-left corner
      translate(0, height);
      ellipseMode(RADIUS);
      
      //Animate the selection indicators
      AnimateToActive();
      
      //Draw the yellow resource monitor
      stroke(yellow);
      noFill();
      //Use a mapped value for the height of the filled meter area
      float yh = Utils.Map(this.yellowTotal, 0, this.yellowMax/2, 0, 25);
      //Calculate the start and end angles for the arc
      float yStartAngle = -1*asin((yh - 25)/25);
      float yEndAngle = asin((yh - 25)/25) + PI;
      //Draw the monitor boundaries
      ellipse(54, -270, 25, 25);
      fill(yellow);
      //Draw a filled arc representing how full the resource is
      arc(54, -270, 25, 25, yStartAngle, yEndAngle, CHORD);
      
      //Same logic for blue meter
      stroke(blue);
      noFill();
      float bh = Utils.Map(this.blueTotal, 0, this.blueMax/2, 0, 25);
      float bStartAngle = -1*asin((bh - 25)/25);
      float bEndAngle = asin((bh - 25)/25) + PI;
      ellipse(153, -229, 25, 25);
      fill(blue);
      arc(153, -229, 25, 25, bStartAngle, bEndAngle, CHORD);
      
      //Same logic for red meter
      stroke(red);
      noFill();
      float rh = Utils.Map(this.redTotal, 0, this.redMax/2, 0, 25);
      float rStartAngle = -1*asin((rh - 25)/25);
      float rEndAngle = asin((rh - 25)/25) + PI;
      ellipse(229, -153, 25, 25);
      fill(red);
      arc(229, -153, 25, 25, rStartAngle, rEndAngle, CHORD);
      
      //Draw white indicator.  it is always filled
      stroke(white);
      fill(white);
      ellipse(270, -54, 25, 25);
    popMatrix();
  }
  
  /**
   * Add points to a given resource.  Clamp the value between 0 and the resource max
   * @param score  Points to add
   * @param type  Type of resource to add to
   */
  void AddPoints(int score, int type) {
    switch (type) {
      case 0:
        this.yellowTotal += score;
        this.yellowTotal = (int)Utils.Clamp(this.yellowTotal, 0, this.yellowMax);
        break;
      case 1:
        this.blueTotal += score;
        this.blueTotal = (int)Utils.Clamp(this.blueTotal, 0, this.blueMax);
        break;
      case 2:
        this.redTotal += score;
        this.redTotal = (int)Utils.Clamp(this.redTotal, 0, this.redMax);
        break;
    }
  }
  
  /**
   * Draws and/or animates the active selection indicators
   */
  void AnimateToActive() {
    //Firstly, draw all the dots.  Colored/different sized dots will be filled over
    for (int i=0; i<locations.length; i++) {
      if (i==2 || i==8 || i==14 || i==20) {
        continue;
      }
      stroke(color(255));
      fill(color(255));
      ellipse(locations[i][0], locations[i][1], 1, 1);
    }
    
    //If the UI is animating between power elements, then update the active dot
    if (prevActive != curActive) {
      //If the previous is less than the current
      if (prevActive < curActive) {
        focusDot += 1;
      } else if (prevActive > curActive) {
        focusDot -= 1;
      }
      
      //Check to see if the active power UI element has been reached by the animation
      if ((focusDot == 2 && curActive == 0) ||
          (focusDot == 8 && curActive == 1) ||
          (focusDot == 14 && curActive == 2) ||
          (focusDot == 20 && curActive == 3)) {
        prevActive = curActive;
      }
    }
    
    //Make sure no OOB exceptions are thrown for odd reasons
    focusDot = (int)Utils.Clamp(focusDot, 2, 20);
    prevActive = (int)Utils.Clamp(prevActive, 0, 3);
    curActive = (int)Utils.Clamp(curActive, 0, 3);
    
    //Draw the active dots
    //center-2
    stroke(dotColor[focusDot - 2]);
    fill(dotColor[focusDot - 2]);
    ellipse(locations[focusDot-2][0], locations[focusDot-2][1], 2, 2);
    
    //center-1
    stroke(dotColor[focusDot - 1]);
    fill(dotColor[focusDot - 1]);
    ellipse(locations[focusDot-1][0], locations[focusDot-1][1], 4, 4);
    
    //center
    stroke(dotColor[focusDot]);
    fill(dotColor[focusDot]);
    ellipse(locations[focusDot][0], locations[focusDot][1], 4, 4);
    
    //center+1
    stroke(dotColor[focusDot + 1]);
    fill(dotColor[focusDot + 1]);
    ellipse(locations[focusDot+1][0], locations[focusDot+1][1], 4, 4);
    
    //center+2
    stroke(dotColor[focusDot + 2]);
    fill(dotColor[focusDot + 2]);
    ellipse(locations[focusDot+2][0], locations[focusDot+2][1], 2, 2);
    
    //Draw the triangular indicator
    //Find the angle
    float ang = atan(locations[focusDot][1] / locations[focusDot][0]);
    //Find the tip of the triangle (7 away from the bottom)
    PVector point1 = new PVector(322*cos(ang), 322*sin(ang));
    
    //Find a vector perpendicular to point1 with a magnitude of 3.5
    PVector offset = PVector.mult(Utils.Orthog(point1).normalize(), 3.5);
    
    //Find a vector that points to the bottom line
    PVector triangleBottom = new PVector(315*cos(ang), 315*sin(ang));
    //Find the last two points of the triangle
    PVector point2 = PVector.add(triangleBottom, offset);
    offset.rotate(radians(180));
    PVector point3 = PVector.add(triangleBottom, offset);
    
    //draw a rectangle
    PShape tri = createShape();
    beginShape();
    tri.vertex(point1.x, point1.y);
    tri.vertex(point2.x, point2.y);
    tri.vertex(point3.x, point3.y);
    endShape();
    shape(tri);
  }
  
  /**
   * Calculate the absolute positions for each dot.  This is sloppy, but it works.
   */
  void CalculateDots() {
    //These have to be pretty exact calculations.  Finding an algorithm to do this with less code would take longer
    //than just typing in exact values.  Luckily, these only need to be calculated once
    
    //Dot locations
    locations = new float[23][];
    //Dot colors
    dotColor = new color[23];
    
    //Yellow dot arc
    //Yellow dot 1
    locations[0] = new float[2];
    locations[0][0] = 275*cos(radians(-2.25*39));
    locations[0][1] = 275*sin(radians(-2.25*39));
    dotColor[0] = yellow;
    //Yellow dot 2
    locations[1] = new float[2];
    locations[1][0] = 275*cos(radians(-2.25*38));
    locations[1][1] = 275*sin(radians(-2.25*38));
    dotColor[1] = yellow;
    //Yellow dot 3
    locations[2] = new float[2];
    locations[2][0] = 275*cos(radians(-2.25*35));
    locations[2][1] = 275*sin(radians(-2.25*35));
    dotColor[2] = color(255, 255, 255, 0);
    //Yellow dot 4
    locations[3] = new float[2];
    locations[3][0] = 275*cos(radians(-2.25*32));
    locations[3][1] = 275*sin(radians(-2.25*32));
    dotColor[3] = yellow;
    //Yellow dot 5
    locations[4] = new float[2];
    locations[4][0] = 275*cos(radians(-2.25*31));
    locations[4][1] = 275*sin(radians(-2.25*31));
    dotColor[4] = yellow;
    
    //White separation dot
    locations[5] = new float[2];
    locations[5][0] = 275*cos(radians(-2.25*30));
    locations[5][1] = 275*sin(radians(-2.25*30));
    dotColor[5] = white;
    
    //Blue dot arc
    //Blue dot 1
    locations[6] = new float[2];
    locations[6][0] = 275*cos(radians(-2.25*29));
    locations[6][1] = 275*sin(radians(-2.25*29));
    dotColor[6] = blue;
    //Blue dot 2
    locations[7] = new float[2];
    locations[7][0] = 275*cos(radians(-2.25*28));
    locations[7][1] = 275*sin(radians(-2.25*28));
    dotColor[7] = blue;
    //Blue dot 3
    locations[8] = new float[2];
    locations[8][0] = 275*cos(radians(-2.25*25));
    locations[8][1] = 275*sin(radians(-2.25*25));
    dotColor[8] = color(255, 255, 255, 0);
    //Blue dot 4
    locations[9] = new float[2];
    locations[9][0] = 275*cos(radians(-2.25*22));
    locations[9][1] = 275*sin(radians(-2.25*22));
    dotColor[9] = blue;
    //Blue dot 5
    locations[10] = new float[2];
    locations[10][0] = 275*cos(radians(-2.25*21));
    locations[10][1] = 275*sin(radians(-2.25*21));
    dotColor[10] = blue;
    
    //White separation dot
    locations[11] = new float[2];
    locations[11][0] = 275*cos(radians(-2.25*20));
    locations[11][1] = 275*sin(radians(-2.25*20));
    dotColor[11] = white;
    
    //Red dot arc
    //Red dot 1
    locations[12] = new float[2];
    locations[12][0] = 275*cos(radians(-2.25*19));
    locations[12][1] = 275*sin(radians(-2.25*19));
    dotColor[12] = red;
    //Red dot 2
    locations[13] = new float[2];
    locations[13][0] = 275*cos(radians(-2.25*18));
    locations[13][1] = 275*sin(radians(-2.25*18));
    dotColor[13] = red;
    //Red dot 3
    locations[14] = new float[2];
    locations[14][0] = 275*cos(radians(-2.25*15));
    locations[14][1] = 275*sin(radians(-2.25*15));
    dotColor[14] = color(255, 255, 255, 0);
    //Red dot 4
    locations[15] = new float[2];
    locations[15][0] = 275*cos(radians(-2.25*12));
    locations[15][1] = 275*sin(radians(-2.25*12));
    dotColor[15] = red;
    //Red dot 5
    locations[16] = new float[2];
    locations[16][0] = 275*cos(radians(-2.25*11));
    locations[16][1] = 275*sin(radians(-2.25*11));
    dotColor[16] = red;
    
    //White separation dot
    locations[17] = new float[2];
    locations[17][0] = 275*cos(radians(-2.25*10));
    locations[17][1] = 275*sin(radians(-2.25*10));
    dotColor[17] = white;
    
    //White dot 1
    locations[18] = new float[2];
    locations[18][0] = 275*cos(radians(-2.25*9));
    locations[18][1] = 275*sin(radians(-2.25*9));
    dotColor[18] = white;
    //White dot 2
    locations[19] = new float[2];
    locations[19][0] = 275*cos(radians(-2.25*8));
    locations[19][1] = 275*sin(radians(-2.25*8));
    dotColor[19] = white;
    //White dot 3
    locations[20] = new float[2];
    locations[20][0] = 275*cos(radians(-2.25*5));
    locations[20][1] = 275*sin(radians(-2.25*5));
    dotColor[20] = color(255, 255, 255, 0);
    //White dot 4
    locations[21] = new float[2];
    locations[21][0] = 275*cos(radians(-2.25*2));
    locations[21][1] = 275*sin(radians(-2.25*2));
    dotColor[21] = white;
    //White dot 5
    locations[22] = new float[2];
    locations[22][0] = 275*cos(radians(-2.25*1));
    locations[22][1] = 275*sin(radians(-2.25*1));
    dotColor[22] = white;
  }
}