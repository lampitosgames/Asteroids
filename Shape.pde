/**
 * The shape class is different from the PShape in that it's vertecies are stored as vector positions instead of points.
 * This allows me to use a polygon collision algorithm that would require a lot more work if I was using PShapes
 */
class Shape {
  //List of local-coordinate verts and global-coordinate verts
  ArrayList<PVector> rVerts, verts;
  
  /**
   * Constructor
   */
  Shape() {
    //Keep two lists, one of relatively-positioned verts, and one that updates when Pos() is called
    rVerts = new ArrayList<PVector>();
    verts = new ArrayList<PVector>();
  }
  
  /**
   * Add a vertex to the shape
   * @param x  New vertex x position
   * @param y  New vertex y position
   */
  void Vertex(float x, float y) {
    //Create a new position vector
    PVector newVert = new PVector(x, y);
    //Add it to both vector lists
    this.rVerts.add(newVert);
    this.verts.add(newVert);
  }
  
  /**
   * Set the center position of the shape by adding the provided coordinates to every vertex
   * @param x  New x position
   * @param y  New y position
   */
  void Pos(float x, float y) {
    //Create a new verts list
    verts = new ArrayList<PVector>();
    //Add all vectors, modified to fit the new scaling, to the list
    for (int i=0; i<this.rVerts.size(); i++) {
      float nx = x + rVerts.get(i).x;
      float ny = y + rVerts.get(i).y;
      this.verts.add(new PVector(nx, ny));
    }
  }
  
  /**
   * Rotate the shape around it's origin
   * @param deg  Distance (in degrees) to rotate the shape
   */
  void Rotate(float deg) {
    //Rotate each point by the number of degrees
    for (int i=0; i<rVerts.size(); i++) {
      rVerts.get(i).rotate(radians(deg));
    }
  }
}