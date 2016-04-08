/**
 * The Utils class is filled with static methods that don't fit inside any other class.
 * The sole purpose here is to perform calculations
 */
static class Utils {
  
  //
  //
  //          GENERAL
  //
  //
  
  static float Norm(float val, float min, float max) {
    return (val - min) / (max - min);
  }
  
  static float Lerp(float norm, float min, float max) {
    return (max - min) * norm + min;
  }
  
  static float Map(float val, float sourceMin, float sourceMax, float destMin, float destMax) {
    float n = Utils.Norm(val, sourceMin, sourceMax);
    return Utils.Lerp(n, destMin, destMax);
  }
  /**
   * Calculate the distance between two points
   * @param x1  X of point 1
   * @param y1  Y of point 1
   * @param x2  X of point 2
   * @param y2  Y of point 2
   */
  static float Distance(float x1, float y1, float x2, float y2) {
    return sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1));
  }
  
  /**
   * Detect if two ranges overlap
   * @param min1  Minimum of the first range
   * @param max1  Maximum of the first range
   * @param min2  Minimum of the second range
   * @param max2  Maximum of the second range
   */
 static boolean RangeIntersect(float min1, float max1, float min2, float max2) {
   if (max(min1, max1) >= min(min2, max2) && min(min1, max1) <= max(min2, max2)) {
     return true;
   } else {
     return false;
   }
 }
 
 static float GetRangeIntersect(float min1, float max1, float min2, float max2) {
   return min(max1, max2) - max(min1, min2);
 }
 
 /**
  * Clamp a value to a given range
  * @param val  Value to clamp
  * @param min  Minimum value
  * @param max  Maximum value
  */
 static float Clamp(float val, float min, float max) {
   float rVal = val < min ? min : val;
   rVal = rVal > max ? max : rVal;
   return rVal;
 }
  
  
  //
  //
  //          COLLISION DETECTION
  //
  //
  
  /**
   * Calculate if two CIRCULAR particles are colliding
   * @param p1  The first particle in the detection
   * @param p2  The second particle in the detection
   */
  static boolean ccCollision(Particle p1, Particle p2) {
    //Distance between circle midpoints
    float dist = Utils.Distance(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
    //If the distance is less than the circles' combined radii, they are colliding
    if (dist <= p1.radius + p2.radius) {
      return true;
      
    } else {
      return false;
    }
  }
  
  /**
   * Calculate if two RECTANGULAR particles are colliding
   * @param p1  The first particle
   * @param p2  The second particle
  static boolean rrCollision(Particle p1, Particle p2) {
    //Detect if both ranges intersect
    if (Utils.RangeIntersect(p1.x1, p1.x2, p2.x1, p2.x2) && Utils.RangeIntersect(p1.y1, p1.y2, p2.y1, p2.y2)) {
      return true;
    } else {
      return false;
    }
  }
   */
  
  /**
   * Calculate if a polygon and a circle are colliding
   * @param shape  Polygon in the collision detection
   * @param c  Circle in the collision detection
   */
  static boolean cpCollision(Shape shape, Particle c) {
    //Make sure the circle's center isn't inside the shape
    //CODE MODIFIED FROM: http://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon
    //I borrowed code because the bullet would sometimes move right through a smaller asteroid.  This resulted from it's position vector not
    //updating quicky enough to collide with one of the polygon's sides.  This fixes it by checking if a circle's center is within the polygon.
    int j=shape.verts.size()-1;
    boolean colTest = false;
    for (int i=0; i<shape.verts.size(); j=i++) {
      PVector verti = shape.verts.get(i);
      PVector vertj = shape.verts.get(j);
      if ((verti.y > c.pos.y != vertj.y > c.pos.y) &&
          (c.pos.x < (vertj.x-verti.x) * (c.pos.y-verti.y) / (vertj.y-verti.y) + verti.x) ) {
        colTest = !colTest;
      }
    }
    if (colTest) {
      return true;
    }
    //END OF BORROWED CODE
    
    //Loop through all shape verts
    for (int i=0; i<shape.verts.size(); i++) {
      //Get the current point
      PVector point1 = shape.verts.get(i);
      //Get the next point (or the first point if this is the last point)
      PVector point2 = shape.verts.get(i + 1 == shape.verts.size() ? 0 : i + 1);
      
      //Get circle bounds
      float cx1 = c.pos.x - c.radius;
      float cx2 = c.pos.x + c.radius;
      float cy1 = c.pos.y - c.radius;
      float cy2 = c.pos.y + c.radius;
      
      //Check if the circle might be colliding by running a range test.
      //If the circle's bounds intersect with the rectangle formed by the line, there might be a collision
      boolean intersectX = Utils.RangeIntersect(cx1, cx2, point1.x, point2.x);
      boolean intersectY = Utils.RangeIntersect(cy1, cy2, point1.y, point2.y);
      
      //If both intersect, calculate the distance to the line from the center of the circle
      if (intersectX && intersectY) {
        //First, get the normal to the line
        PVector normal = Utils.Orthog(PVector.sub(point1, point2).normalize());
        
        //Find the distance between the center of the circle and the line
        float constant = -1*normal.x*point1.x - normal.y*point1.y;
        float distance = normal.x*c.pos.x + normal.y*c.pos.y + constant;
        
        //If the distance minus the radius is negative, there is a collision
        if (distance - c.radius <= 0) {
          return true;
        }
      }
    }
    return false;
  }
  
  /**
   * Calculate if two POLYGONS are colliding (Using the Separation Axis Theorem)
   * NOTE: I used multiple tutorials to figure this out.  The code is all mine, but the idea of how it works is not.
   * @param s1  The first shape in the detection
   * @param s2  The second shape in the detection (order doesn't matter)
   */
  static PVector shapeCollision(Shape s1, Shape s2) {
    //Get perpendiculars to all edges on shape 1 to test shape separation
    PVector[] axes1 = new PVector[s1.verts.size()];
    //Get perpendiculars to all edges on shape 2 to test shape separation
    PVector[] axes2 = new PVector[s2.verts.size()];
    //Loop through all shape 1 verts
    for (int i=0; i<s1.verts.size(); i++) {
      //Get the current point
      PVector point1 = s1.verts.get(i);
      //Get the next point (or the first point if this is the last point)
      PVector point2 = s1.verts.get(i + 1 == s1.verts.size() ? 0 : i + 1);
      //Get the normal to the edge, and add it as an axis
      axes1[i] = Utils.Orthog(PVector.sub(point1, point2)).normalize();
    }
    
    //Loop through all shape 2 verts
    for (int i=0; i<s2.verts.size(); i++) {
      //Get the current point
      PVector point1 = s2.verts.get(i);
      //Get the next point (or the first point if this is the last point)
      PVector point2 = s2.verts.get(i + 1 == s2.verts.size() ? 0 : i + 1);
      //Get the normal to the edge, and add it as an axis
      axes2[i] = Utils.Orthog(PVector.sub(point1, point2)).normalize();
    }
    
    PVector smallest = null;
    float overlap = 10000;
    //Loop through all axes, projecting both shapes onto each and checking for overlapping projections.
    //If an axis is found where the projections do not overlap, the shapes do not collide
    for (int a=0; a<axes1.length; a++) {
      //Current axis
      PVector axis = axes1[a];
      //Project s1 and s2 onto the current axis
      float[] range1 = Utils.sProject(s1, axis);
      float[] range2 = Utils.sProject(s2, axis);
      
      //If the ranges don't overlap, we can guarentee that these shapes aren't colliding
      if (Utils.RangeIntersect(range1[0], range1[1], range2[0], range2[1]) == false) {
        return null;
      } else {
        float o = Utils.GetRangeIntersect(range1[0], range1[1], range2[0], range2[1]);
        if (o < overlap) {
          overlap = o;
          smallest = axis;
        }
      }
    }
    for (int a=0; a<axes2.length; a++) {
      //Current axis
      PVector axis = axes2[a];
      //Project s1 and s2 onto the current axis
      float[] range1 = Utils.sProject(s1, axis);
      float[] range2 = Utils.sProject(s2, axis);
      
      //If the ranges don't overlap, we can guarentee that these shapes aren't colliding
      if (Utils.RangeIntersect(range1[0], range1[1], range2[0], range2[1]) == false) {
        return null;
      } else {
        float o = Utils.GetRangeIntersect(range1[0], range1[1], range2[0], range2[1]);
        if (o < overlap) {
          overlap = o;
          smallest = axis;
        }
      }
    }
    if (smallest != null) {
      return smallest.mult(overlap);
    } else {
      return null;
    }
  }
  
  
  //
  //
  //          VECTOR MATH
  //
  //
  
  /**
   * Calculate a dot product of two vectors
   * @param v0  Vector 1
   * @param v1  Vector 2
   */
  static float Dot(PVector v0, PVector v1) {
    return v0.x*v1.x + v0.y*v1.y;
  }
  
  /**
   * Get the perpendicular to a vector
   * @param vector  Vector to use
   */
  static PVector Orthog(PVector vector) {
    return new PVector(-1*vector.y, vector.x);
  }
  
  /**
   * Project a shape onto an axis (vector)
   * This essentially assumes that light is pointing down from above the shape and perpendicular to the axis, returning the size of the shadow.
   * @param s  Shape that will cast it's shadow
   * @param axis  The axis perpendicular to the direction of projection
   */
  static float[] sProject(Shape s, PVector axis) {
    //We are looking for the entire range that is covered by projections of all vertex vectors onto the axis
    float min = Utils.Dot(axis, s.verts.get(0));
    //When starting, the range is zero
    float max = min;
    //For all verticies
    for (int i=1; i<s.verts.size(); i++) {
      //Get the dot product
      float proj = Utils.Dot(axis, s.verts.get(i));
      //If the projection is larger than the maximum
      if (proj > max) {
        max = proj;
      }
      //If the projection is smaller than the minimum
      if (proj < min) {
        min = proj;
      }
    }
    //Return the projected range
    float[] range = {min, max};
    return range;
  }
}