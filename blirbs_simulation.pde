/*
*  Main runner for the Blirb simulation
*/


// Number of flockers to spawn
final int NUM_FLOCKERS = 75;
// Number of wanderers to spawn
final int NUM_WANDERERS = 25;

// A list of all blirbs in this simulation
ArrayList<Blirb> allBlirbs = new ArrayList();
// A list of all foods in this simulation
ArrayList<Food> allFoods = new ArrayList();

/**
  Called on application start
*/
void setup() {
  // Prepare window
  size(1280, 720);
  stroke(255);
  
 
  // Spawn all blirbs
  spawnBlirbs();
}


void spawnBlirbs() {
  
  for(int i = 0; i < NUM_FLOCKERS; i++) {
    Blirb b = new Blirb(random(width), random(height), random(TWO_PI), AIMode.FLOCK, color(0,255,0));
    b.mass = random(1.0, 10.0);
    allBlirbs.add(b);
  }
  for(int i = 0; i < NUM_WANDERERS; i++) {
    Blirb b = new Blirb(random(width), random(height), random(TWO_PI), AIMode.WANDER, color(128,0,128));
    b.mass = random(1.0, 10.0);
    allBlirbs.add(b);
  }
}



/**
  Called once every frame
*/
void draw() {
  if (mousePressed && (mouseButton == LEFT)) {
    allFoods.add(new Food(mouseX, mouseY));
  }
  
  if(keyPressed && key == ' ') {
     for(int i = 0; i < 30; i++) {
       allFoods.add(new Food()); 
     }
  }
  
  // Clear previous frame
  background(50);
  
  // Update and draw all blirbs
  for(Blirb b : allBlirbs) {
    b.update();
  }
  
  // Update and draw all foods
  for(Food f : allFoods) {
    f.update();
  }
}
