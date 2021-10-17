/*
*  Main runner for the Blirb simulation
*/


// Number of flockers to spawn
final int NUM_FLOCKERS = 75;

// Number of wanderers to spawn
final int NUM_WANDERERS = 25;

// A list of all blirbs in this simulation
ArrayList<Blirb> blirbs;

void setup() {
  // Prepare window
  size(640, 360);
  stroke(255);
  
  // Spawn all blirbs
  blirbs = new ArrayList<Blirb>();
  for(int i = 0; i < NUM_FLOCKERS; i++) {
    Blirb b = new Blirb(random(width), random(height), random(TWO_PI), AIMode.FLOCK, color(0,255,0));
    b.neighbors = blirbs;
    blirbs.add(b);
  }
  for(int i = 0; i < NUM_WANDERERS; i++) {
    Blirb b = new Blirb(random(width), random(height), random(TWO_PI), AIMode.WANDER, color(255,0,0));
    b.neighbors = blirbs;
    blirbs.add(b);
  }
}

void draw() {
  // Clear previous frame
  background(50);
  
  // Update and draw all blirbs
  for(Blirb b : blirbs) {
    b.update();
  }
}
