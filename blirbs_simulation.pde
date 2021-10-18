/*
*  Main runner for the Blirb simulation
 */


// Number of flockers to spawn
final int DEFAULT_NUM_BLIRBS = 100;


// The font used to display text
PFont arialFont;
// A list of all blirbs in this simulation
ArrayList<Blirb> allBlirbs = new ArrayList();
// A list of all foods in this simulation
ArrayList<Food> allFoods = new ArrayList();

ArrayList<Blirb> blirbsToRemove = new ArrayList();
ArrayList<Food> foodsToRemove = new ArrayList();


/**
 Called on application start
 */
void setup() {
  // Prepare window
  size(1280, 720);
  arialFont = createFont("Arial", 16, true);
  textAlign(CENTER);

  // Spawn all blirbs
  spawnBlirbs();
}


void spawnBlirbs() {

  for (int i = 0; i < DEFAULT_NUM_BLIRBS; i++) {
    Blirb b = new Blirb(str(i), random(width), random(height), random(TWO_PI));
    allBlirbs.add(b);
  }
}


void keyPressed() {
  if (key == ' ') {
    for (int i = 0; i < allBlirbs.size()/2; i++) {
      allFoods.add(new Food());
    }
  }
}

void mousePressed() {
  if(mouseButton == LEFT) {
    allFoods.add(new Food(mouseX, mouseY));
  }
}


/**
 Called once every frame
 */
void draw() {
  if (allBlirbs.size() == 1) {
    Blirb survivor = allBlirbs.get(0);
    endSimulation(survivor);
    survivor.consume(0); // Hacky way to keep the survivor alive
    survivor.update();
    return;
  } else if (allBlirbs.size() == 0) {
    endSimulation(null);
    return;
  }

  // Clear previous frame
  background(50);

  stroke(255, 255, 255, 100);
  fill(255, 255, 255, 100);
  textFont(arialFont, 100);
  text(allBlirbs.size(), width/2, height/2);

  // Update and draw all blirbs
  for (Blirb b : allBlirbs) {
    b.update();
  }

  // Update and draw all foods
  for (Food f : allFoods) {
    f.update();
  }

  for (Blirb b : blirbsToRemove) {
    allBlirbs.remove(b);
  }
  for (Food f : foodsToRemove) {
    allFoods.remove(f);
  }

  blirbsToRemove.clear();
  foodsToRemove.clear();
}


void endSimulation(Blirb winner) {
  background(50);

  stroke(255, 255, 255, 100);
  fill(255, 255, 255, 100);
  textFont(arialFont, 100);
  text("Simulation Over", width/2, height/2 - 50);
  textFont(arialFont, 50);
  if (winner != null) {
    text("Survivor: Blirb #" + winner.name, width/2, height/2 + 25);
    textFont(arialFont, 27);
    text("with a size of " + float(round(winner.mass * 100)) / 100, width/2, height/2 + 85);
  } else {
    text("No Survivors", width/2, height/2 + 50);
  }
}


void queueBlirbDeath(Blirb b) {
  blirbsToRemove.add(b);
}


void queueFoodEat(Food f) {
  foodsToRemove.add(f);
}
