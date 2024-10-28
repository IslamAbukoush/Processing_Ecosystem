public class Fish {
  private PVector location;
  private float speed;
  private float size = 25;
  private int interval = 2000;
  private int previousMillis = 0;
  private boolean canTarget = true;
  private boolean remove = false;
  private int food = 0;
  private Plant target;
  private PShape sphere;
  private PVector velocity = new PVector(0, 0);
  private float scale = 0.1;
  private float angle = 0;
  Fish(float x, float y) {
    location = new PVector(x, y);
    interval = fishHungerSpeed;
    speed = fishSpeed;
    sphere = createShape(SPHERE, size);
    sphere.setTexture(fishImage);
    sphere.setFill(color(255, 150, 150));
    sphere.setStroke(false);
  }
  public PVector getLocation() {
    return location;
  }
  public float getSize() {
    return size;
  }
  public void draw() {
    pushMatrix();
    translate(location.x, 0, location.y);
    rotateY(angle);
    if(scale < 1) {
      scale += 0.05;
      scale(scale);
    }
    PVector pupilLocation = new PVector(5, 2, 2);
    shape(sphere);
    noStroke();
    translate(size/2,-size/3,0);
    translate(0,0,10);
    fill(255);
    sphere(10);
    translate(pupilLocation.x,-pupilLocation.y,pupilLocation.z);
    fill(0);
    sphere(5);
    translate(-pupilLocation.x,pupilLocation.y,-pupilLocation.z-10);
    translate(0,0,-10);
    fill(255);
    sphere(10);
    translate(pupilLocation.x,-pupilLocation.y,-pupilLocation.z);
    fill(0);
    sphere(5);
    popMatrix();
    displayHealth();
  }
  
  private Plant getNearest() {
    if(plants.size() < 1) return null;
    float min = Float.MAX_VALUE;
    Plant target = null;
    for(Plant plant : plants) {
      if(!plant.getCanTarget()) continue;
      float distance = location.dist(plant.getLocation());
      if(distance < min) {
        min = distance;
        target = plant;
      }
    }
    return target;
  }
  
  public void follow() {
    if(target != null) target.setCanTarget(true);
    target = getNearest();
    if(target == null) return;
    target.setCanTarget(false);
    
    
    PVector direction = PVector.sub(target.getLocation(), location);
    print("\n");
    direction.setMag(speed);
    velocity.lerp(direction, 0.1);
    location.add(velocity);
    angle = atan2(velocity.x, velocity.y)-PI/2;
    if(location.dist(target.getLocation()) < size/2 + target.getSize()/2) {
      plants.remove(target);
      target = null;
      food++;
      if(food >= fishFoodToMultiply) {
        spawnFish(location);
        food = 0;
      }
    }
    checkHunger();
  }
  public void setCanTarget(boolean canTarget) {
    this.canTarget = canTarget;
  }
  public boolean getCanTarget() {
    return canTarget;
  }
  private void checkHunger() {
    int currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      food--;
      if(food <= fishMinHunger) {
        remove = true;
      }
      previousMillis = currentMillis;
    }
  }
  public void displayHealth() {
    float x = location.x;
    float y = location.y;
    fill(255, 0, 0);
    pushMatrix();
    translate(x, -size*1.5, y);
    rotateY(PI/2-camAngleX);
    rotateX(-camAngleY);
    rect(0,0, size, 10);
    float fullHealth = abs(fishMinHunger) + fishFoodToMultiply;
    float currHealth = food + abs(fishMinHunger);
    float result = currHealth/fullHealth;
    fill(0, 255, 0);
    translate(-(size*(1-result))/2,0, 0.01);
    rect(0, 0, size*result, 10);
    popMatrix();
  }
}
