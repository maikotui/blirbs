/*
 *  Maiko Tuitupou Jr
 *  -----------------
 *  Main runner for the Blirb simulation
 */


// Number of blirbs to spawn by default
final int DEFAULT_NUM_BLIRBS = 100;


// The font used to display text
PFont arialFont;

// A list of all blirbs in this simulation
ArrayList<Blirb> allBlirbs = new ArrayList();
// A list of all foods in this simulation
ArrayList<Food> allFoods = new ArrayList();

// Internal list of blirbs to remove
private ArrayList<Blirb> _blirbsToRemove = new ArrayList();
private ArrayList<Food> _foodsToRemove = new ArrayList();


/**
 Called on application start
 */
void setup() {
  // Prepare window
  size(1280, 720);
  arialFont = createFont("Arial", 16, true);
  textAlign(CENTER);

  // The default list of blirbs to spawn
  IntDict defaultBlirbs = new IntDict();
  defaultBlirbs.set("", DEFAULT_NUM_BLIRBS);

  if (args != null) {
    InputStream is = createInput(args[0]); // Expect first argument to be a filepath
    if (is != null) {
      try {
        String text = new String(is.readAllBytes());
        IntDict blirbsFromFile = new IntDict();
        // Regex has two groups - Group 1 is the name, Group 2 is the number of blirbs to spawn
        String[][] matches = matchAll(text, "^([A-Za-z]+)\\s*(\\d+)?$");
        if (matches.length < 1) { // File had no correctly formatted blirbs to spawn
          println("File formatted incorrectly, could not find any blirbs to spawn.");
          println("Running simulation with default of " + DEFAULT_NUM_BLIRBS + " blirbs.");
          spawnBlirbs(defaultBlirbs);
        } else {
          for (String[] match : matches) {
            if (match[2] == null) { // No count given, so just create a single blirb
              blirbsFromFile.set(match[1], 1);
            } else {
              blirbsFromFile.set(match[1], int(match[2]));
            }
          }

          // We've gone over all the matches, now spawn the blirbs and start the simulation
          spawnBlirbs(blirbsFromFile);
        }
      }
      catch(IOException e) { // Error while reading file
        println("Could not read file: " + e.toString());
        println("Running simulation with default of " + DEFAULT_NUM_BLIRBS + " blirbs.");
        spawnBlirbs(defaultBlirbs);
      }
    } else { // Could not open file
      println("Could not open file '" + args[0] + "'.");
      println("Running simulation with default of " + DEFAULT_NUM_BLIRBS + " blirbs.");
      spawnBlirbs(defaultBlirbs);
    }
  } else { // File was not given
    // Spawn all blirbs
    println("No file given, running simulation with default of " + DEFAULT_NUM_BLIRBS + " blirbs");
    spawnBlirbs(defaultBlirbs);
  }
}


/**
 Spawns blirbs using the given IntDict. The dictionary should have entries as the bird's name for the key,
 then how many with that name to spawn as the value.
 */
private void spawnBlirbs(IntDict blirbsToSpawn) {
  for (String blirbName : blirbsToSpawn.keys()) {
    for (int i = 0; i < blirbsToSpawn.get(blirbName); i++) {
      String printedName = blirbName;
      if (printedName != "") { // Prettier formatting
        printedName += " ";
      }
      Blirb b = new Blirb(printedName + (i + 1), random(width), random(height), random(TWO_PI));
      allBlirbs.add(b);
    }
  }
}


/**
 Called every time a key is pressed. Only tracks spacebar presses.
 Spacebar will spawn enough food for half the population.
 */
void keyPressed() {
  if (key == ' ') {
    for (int i = 0; i < allBlirbs.size()/2; i++) {
      allFoods.add(new Food());
    }
  }
}


/**
 Called every time the mouse is pressed. Only tracks the left mouse button.
 When the mouse button is pressed, spawns a food at the mouse location.
 */
void mousePressed() {
  if (mouseButton == LEFT) {
    allFoods.add(new Food(mouseX, mouseY));
  }
}


/**
 Called once every frame and does the following:
 1. Checks if we can end the simulation
 2. Clears the previously drawn frame
 3. Displays the current number of Blirbs
 4. Updates all Blirbs and Foods
 5. Removes all Blirbs and Foods that are queued to be removed
 */
void draw() {
  // If we have 1 or less blirbs, end the simulation
  if (allBlirbs.size() == 1) {
    Blirb survivor = allBlirbs.get(0);
    displaySimulationEnd(survivor);
    survivor.consume(0); // Hacky way to keep the survivor alive so it can be displayed at end
    survivor.update();
    return;
  } else if (allBlirbs.size() == 0) {
    displaySimulationEnd(null);
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

  // Remove queue
  for (Blirb b : _blirbsToRemove) {
    allBlirbs.remove(b);
  }
  for (Food f : _foodsToRemove) {
    allFoods.remove(f);
  }
  _blirbsToRemove.clear();
  _foodsToRemove.clear();
}


/**
 Displays text showing who the survivor was (if one exists)
 */
private void displaySimulationEnd(Blirb winner) {
  background(50);

  stroke(255, 255, 255, 100);
  fill(255, 255, 255, 100);
  textFont(arialFont, 100);
  text("Simulation Over", width/2, height/2 - 50);
  textFont(arialFont, 50);
  if (winner != null) {
    text("Survivor: Blirb '" + winner.name + "'", width/2, height/2 + 25);
    textFont(arialFont, 27);
    text("with a size of " + float(round(winner.mass * 100)) / 100, width/2, height/2 + 65);
  } else {
    text("No Survivors", width/2, height/2 + 50);
  }
}


/**
 Queues a blirb to be removed at the end of this frame
 */
public void queueBlirbDeath(Blirb b) {
  _blirbsToRemove.add(b);
}


/**
 Queues a blirb to be removed at the end of this frame
 */
public void queueFoodEat(Food f) {
  _foodsToRemove.add(f);
}
