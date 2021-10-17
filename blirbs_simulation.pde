final int NUM_FLOCKERS = 75;
final int NUM_WANDERERS = 25;

ArrayList<Bot> bots;

void setup() {
  size(640, 360);
  stroke(255);
  
  bots = new ArrayList<Bot>();
  for(int i = 0; i < NUM_FLOCKERS; i++) {
    Bot b = new Bot(random(width), random(height), random(TWO_PI), AIMode.FLOCK, color(0,255,0));
    b.neighbors = bots;
    bots.add(b);
  }
  for(int i = 0; i < NUM_WANDERERS; i++) {
    Bot b = new Bot(random(width), random(height), random(TWO_PI), AIMode.WANDER, color(255,0,0));
    b.neighbors = bots;
    bots.add(b);
  }
}

void draw() {
  background(50);
  for(Bot b : bots) {
    b.update();
  }
}
