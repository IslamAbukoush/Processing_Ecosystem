public class Shark {
  private PVector location;
  private float speed;
  private float size = 50;
  private int interval = 2000;
  private int previousMillis = 0;
  private int food = 0;
  private boolean remove = false;
  private Fish target;
  private PShape sphere;
  private PVector velocity = new PVector(0, 0);
  private float scale = 0.1;
  private float angle = 0;
  Shark(float x, float y) {
    location = new PVector(x, y);
    interval = sharkHungerSpeed;
    speed = sharkSpeed;
    sphere = createShape(SPHERE, size);
    sphere.setTexture(sharkImage);
    sphere.setFill(color(150, 150, 255));
    sphere.setStroke(false);
}
  public PVector getLocation() {
    return location;
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
    PVector eyeLocation = new PVector(0,0,30);
    shape(sphere);
    noStroke();
    translate(size/2,-size/3,0);
    translate(eyeLocation.x,eyeLocation.y,eyeLocation.z);
    fill(255);
    sphere(10);
    translate(pupilLocation.x,-pupilLocation.y,pupilLocation.z);
    fill(0);
    sphere(5);
    translate(-pupilLocation.x,pupilLocation.y,-pupilLocation.z-eyeLocation.z);
    translate(eyeLocation.x,eyeLocation.y,-eyeLocation.z);
    fill(255);
    sphere(10);
    translate(pupilLocation.x,-pupilLocation.y,-pupilLocation.z);
    fill(0);
    sphere(5);
    popMatrix();
    displayHealth();
}
  private Fish getNearest() {
    if(fishes.size() < 1) return null;
    float min = Float.MAX_VALUE;
    Fish target = null;
    for(Fish fish : fishes) {
      if(!fish.getCanTarget()) continue;
      float distance = location.dist(fish.getLocation());
      if(distance < min) {
        min = distance;
        target = fish;
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
    direction.setMag(speed);
    velocity.lerp(direction, 0.1);
    location.add(velocity);
    angle = atan2(velocity.x, velocity.y)-PI/2;
    if(location.dist(target.getLocation()) < size/2 + target.getSize()/2) {
      if(target.target != null) target.target.setCanTarget(true);
      fishes.remove(target);
      target = null;
      food++;
      if(food >= sharkFoodToMultiply) {
        spawnShark(location);
        food = 0;
      }
    }
    checkHunger();
  }
  
  private void checkHunger() {
    int currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      food--;
      if(food <= sharkMinHunger) {
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
    float fullHealth = abs(sharkMinHunger) + sharkFoodToMultiply;
    float currHealth = food + abs(sharkMinHunger);
    float result = currHealth/fullHealth;
    fill(0, 255, 0);
    translate(-(size*(1-result))/2,0, 0.01);
    rect(0, 0, size*result, 10);
    popMatrix();
  }
}
