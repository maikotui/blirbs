final int NUM_FLOCKERS = 75;
final int NUM_WANDERERS = 25;

ArrayList<Blirb> blirbs;

void setup() {
  size(640, 360);
  stroke(255);
  
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
  background(50);
  for(Blirb b : blirbs) {
    b.update();
  }
}
