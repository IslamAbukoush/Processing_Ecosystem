import java.util.List;
import java.util.ArrayList;


//==========================================
PImage sharkImage;
PImage fishImage;
PImage plantImage;
//==========================================

List<Shark> sharks;
List<Shark> sharkKids;
List<Fish> fishes;
List<Fish> fishKids;
List<Plant> plants;

// plant settings
int plantNum = 40;
int plantSpawnRate = 50;

// fish settings
int fishNum = 50;
int fishFoodToMultiply = 1;
int fishMinHunger = -5;
int fishHungerSpeed = 2000;
float fishSpeed = 2;

// shark settings
int sharkNum = 10;
int sharkFoodToMultiply = 5;
int sharkMinHunger = -5;
int sharkHungerSpeed = 4000;
float sharkSpeed = 2;



float sphereX = 0, sphereZ = 0; // Sphere position
float platformSize = 2000;       // Size of the platform
float sphereSpeed = 2;          // Speed of the sphere
float angle = 0;                // For sphere movement

// Camera variables
float camRadius = 750;          // Distance of the camera from the platform
float camAngleX = 0;            // Horizontal rotation angle (yaw)
float camAngleY = 0;            // Vertical rotation angle (pitch)
boolean dragging = false;       // Is the mouse being dragged?
float lastMouseX, lastMouseY;   // Last mouse positions

void setup() {
  size(800, 600, P3D);
  rectMode(CENTER);
  sharkImage = loadImage("shark.png");
  fishImage = loadImage("fish.png");
  plantImage = loadImage("plant.png");
  plants = new ArrayList<Plant>();
  for(int i = 0; i < plantNum; i++) {
    spawnPlant();
  }
  fishKids = new ArrayList<Fish>();
  fishes = new ArrayList<Fish>();
  for(int i = 0; i < fishNum; i++) {
    spawnFish();
  }
  sharkKids = new ArrayList<Shark>();
  sharks = new ArrayList<Shark>();
  for(int i = 0; i < sharkNum; i++) {
    spawnShark();
  }
}

void draw() {
  background(200, 200, 255);
  ambientLight(150, 150, 150);                 // Soft ambient light to illuminate objects
  directionalLight(255, 255, 255, 0, 1, 0); // Directional light from above and slightly tilted

  // Calculate camera position based on angles
  float camX = camRadius * cos(camAngleX) * cos(camAngleY);
  float camY = camRadius * sin(camAngleY);
  float camZ = camRadius * sin(camAngleX) * cos(camAngleY);

  camera(camX, camY, camZ, 0, 0, 0, 0, 1, 0);

  // Draw the platform
  fill(255);            // White fill for the platform
  stroke(0);            // Black stroke for the grid
  pushMatrix();
  translate(0, 25, 0);
  box(platformSize+50, 50, platformSize+50);
  
  // Draw grid lines on the platform
  int gridSpacing = 100;
  for (float x = -platformSize/2; x <= platformSize/2; x += gridSpacing) {
    line(x, -25, -platformSize/2, x, -25, platformSize/2);
    line(-platformSize/2, -25, x, platformSize/2, -25, x);
  }
  popMatrix();

  spawnPlants();
  for(Plant plant : plants) {
    plant.draw();
  }
  for(int i = 0; i < fishes.size(); i++) {
    Fish fish = fishes.get(i);
    if(fish.remove) {
      fish.target.setCanTarget(true);
      fishes.remove(fish);
      i--;
      continue;
    }
    fish.follow();
    fish.draw();
  }
  fishes.addAll(fishKids);
  fishKids.clear();
  for(int i = 0; i < sharks.size(); i++) {
    Shark shark = sharks.get(i);
    if(shark.remove) {
      shark.target.setCanTarget(true);
      sharks.remove(shark);
      i--;
      continue;
    }
    shark.follow();
    shark.draw();
  }
  sharks.addAll(sharkKids);
  sharkKids.clear();
}



void spawnShark() {
  sharks.add(new Shark(random(platformSize)-platformSize/2, random(platformSize)-platformSize/2));
}
void spawnShark(PVector location) {
  sharkKids.add(new Shark(location.x, location.y));
}
void spawnFish() {
  fishes.add(new Fish(random(platformSize)-platformSize/2, random(platformSize)-platformSize/2));
}
void spawnFish(PVector location) {
  fishKids.add(new Fish(location.x, location.y));
}
void spawnPlant() {
  plants.add(new Plant(random(platformSize)-platformSize/2, random(platformSize)-platformSize/2));
}

int previousMillis = 0;
void spawnPlants() {
  int currentMillis = millis();
  
  if (currentMillis - previousMillis >= plantSpawnRate) {
    spawnPlant();
    previousMillis = currentMillis;
  }
}

void mousePressed() {
  dragging = true;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseDragged() {
  if (dragging) {
    // Update camera angles based on mouse movement
    camAngleX += (mouseX - lastMouseX) * 0.01; // Adjust for horizontal movement
    camAngleY -= (mouseY - lastMouseY) * 0.01; // Adjust for vertical movement
    camAngleY = constrain(camAngleY, -HALF_PI + 0.1, HALF_PI - 0.1); // Limit vertical movement
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseReleased() {
  dragging = false;
}


void mouseWheel(MouseEvent event) {
  float e = event.getCount(); // Get the scroll amount
  camRadius += e * 50; // Adjust the camera distance (zoom factor)
  camRadius = constrain(camRadius, 100, 3000); // Limit zoom range to avoid getting too close or far
}
