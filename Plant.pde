public class Plant {
  private PVector location;
  private float size = 15;
  private boolean canTarget = true;
  private PShape sphere;
  private float scale = 0.1;
  Plant(float x, float y) {
    location = new PVector(x,y);
    sphere = createShape(SPHERE, size);
    sphere.setTexture(plantImage);
    sphere.setFill(color(100, 255, 100));
    sphere.setStroke(false);
  }
  public PVector getLocation() {
    return location;
  }
  public void draw() {
    pushMatrix();
    translate(location.x, 0, location.y);
    if(scale < 1) {
      scale += 0.05;
      scale(scale);
    }
    shape(sphere);
    popMatrix();
  }
  public float getSize() {
    return size;
  }
  public void setCanTarget(boolean canTarget) {
    this.canTarget = canTarget;
  }
  public boolean getCanTarget() {
    return canTarget;
  }
}
