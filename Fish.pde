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
  private float mass = 1;

  // Speed boost properties
  float boostedSpeed;
  float originalSpeed;
  boolean isBoosted = false;
  int boostDuration = 1000;
  int boostStartTime;
  float currentSpeed;

  // Variables for the smooth death effect
  private float deathTimer = 0;
  private boolean isDead = false;
  private float deathDuration = 1000; // Duration for shrinking/fading

  Fish(float x, float y) {
    location = new PVector(x, y);
    interval = fishHungerSpeed;
    speed = fishSpeed/mass;
    sphere = createShape(SPHERE, size);
    sphere.setTexture(fishImage);
    sphere.setFill(color(255, 150, 150));
    sphere.setStroke(false);
    originalSpeed = fishSpeed/mass;
    boostedSpeed = originalSpeed * 2; // 50% speed boost
    currentSpeed = originalSpeed; // Start at normal speed
  }

  public PVector getLocation() {
    return location;
  }

  public float getSize() {
    return size;
  }

  public void draw() {
    if (isDead) {
      // Apply shrinking and fading
      float elapsedTime = millis() - deathTimer;
      float fadeAmount = map(elapsedTime, 0, deathDuration, 255, 0);
      float shrinkAmount = map(elapsedTime, 0, deathDuration, 1, 0);
      
      // If the fish has finished the death animation, remove it
      if (elapsedTime >= deathDuration) {
        remove = true;
      }

      // Apply fading and shrinking
      pushMatrix();
      translate(location.x, 0, location.y);
      rotateY(angle);
      scale(shrinkAmount); // Shrink the fish
      fill(255, 0, 0, fadeAmount); // Fade out the color
      shape(sphere);
      popMatrix();
      
    } else {
      // Regular drawing behavior
      pushMatrix();
      translate(location.x, 0, location.y);
      rotateY(angle);

      // Calculate flatten factor based on current velocity magnitude
      float currentSpeed = velocity.mag();
      float maxSpeed = boostedSpeed; // Use boostedSpeed as the maximum speed for flattening
      float flattenFactor = map(currentSpeed, originalSpeed, maxSpeed, 1.0, 0.5); // Range from 1.0 to 0.5

      if (scale < 1) {
          scale += 0.05;
          scale(scale);
      }

      // Apply non-uniform scaling with flattenFactor affecting Y-axis
      scale(1, flattenFactor, 1);  // Dynamic Y-scaling for gradual flattening

      PVector pupilLocation = new PVector(5, 2, 2);
      shape(sphere);
      noStroke();
      translate(size / 2, -size / 3, 0);
      translate(0, 0, 10);
      fill(255);
      sphere(10);
      translate(pupilLocation.x, -pupilLocation.y, pupilLocation.z);
      fill(0);
      sphere(5);
      translate(-pupilLocation.x, pupilLocation.y, -pupilLocation.z - 10);
      translate(0, 0, -10);
      fill(255);
      sphere(10);
      translate(pupilLocation.x, -pupilLocation.y, -pupilLocation.z);
      fill(0);
      sphere(5);

      popMatrix();
    }

    displayHealth();
  }

  private Plant getNearest() {
    if (plants.size() < 1) return null;
    float min = Float.MAX_VALUE;
    Plant target = null;
    for (Plant plant : plants) {
      if (!plant.getCanTarget()) continue;
      float distance = location.dist(plant.getLocation());
      if (distance < min) {
        min = distance;
        target = plant;
      }
    }
    return target;
  }

  public void follow() {
    if (target != null) target.setCanTarget(true);
    target = getNearest();
    if (target == null) return;
    target.setCanTarget(false);

    // Handle speed boost timing
    if (isBoosted) {
      int elapsedTime = millis() - boostStartTime;
      if (elapsedTime < boostDuration / 2) {
        // Accelerate up to boostedSpeed
        currentSpeed = map(elapsedTime, 0, boostDuration / 2, originalSpeed, boostedSpeed);
      } else if (elapsedTime < boostDuration) {
        // Decelerate back to originalSpeed
        currentSpeed = map(elapsedTime, boostDuration / 2, boostDuration, boostedSpeed, originalSpeed);
      } else {
        // End the boost
        currentSpeed = originalSpeed;
        isBoosted = false;
      }
    } else {
      currentSpeed = originalSpeed; // Normal speed when not boosted
    }

    PVector direction = PVector.sub(target.getLocation(), location);
    direction.setMag(currentSpeed);
    velocity.lerp(direction, 0.1);
    location.add(velocity);
    angle = atan2(velocity.x, velocity.y) - PI / 2;

    // Check if the fish has reached the target plant
    if (location.dist(target.getLocation()) < size / 2 + target.getSize() / 2) {
      plants.remove(target);
      target = null;
      food++;
      startSpeedBoost(); // Start the speed boost after eating

      // Spawn a new fish if enough food has been collected
      if (food >= fishFoodToMultiply) {
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
      if (food <= fishMinHunger) {
        isDead = true; // Start the death animation
        deathTimer = millis(); // Start the death timer
      }
      previousMillis = currentMillis;
    }
  }

  public void displayHealth() {
    float x = location.x;
    float y = location.y;
    fill(255, 0, 0);
    pushMatrix();
    translate(x, -size * 1.5, y);
    rotateY(PI / 2 - camAngleX);
    rotateX(-camAngleY);
    rect(0, 0, size, 10);
    float fullHealth = abs(fishMinHunger) + fishFoodToMultiply;
    float currHealth = food + abs(fishMinHunger);
    float result = currHealth / fullHealth;
    fill(0, 255, 0);
    translate(-(size * (1 - result)) / 2, 0, 0.01);
    rect(0, 0, size * result, 10);
    popMatrix();
  }

  void startSpeedBoost() {
    isBoosted = true;
    boostStartTime = millis();
  }
}
