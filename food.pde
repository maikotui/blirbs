/*
 *  Maiko Tuitupou Jr
 *  -----------------
 *  Defines basic foods for the Blirbs to hunt
 */


/**
 A basic parent class for all things that can be eaten
 */
class Edible {
  public float mass;
  public PVector position;
}


/**
 An edible dot that is displayed on the main window
 */
class Food extends Edible {
  public final float INITIAL_MASS = 0.75;


  /**
  Places a food at a random location
  */
  public Food() {
    position = new PVector(random(width), random(height));
    mass = INITIAL_MASS;
  }


  /**
  Places a food at the given location
  */
  public Food(float xPos, float yPos) {
    position = new PVector(xPos, yPos);
    mass = INITIAL_MASS;
  }


  /**
  Should be called once every frame; handles rendering the food
  */
  public void update() {
    render();
  }

  
  /**
  Draws the food. Note: the size of the food will be depenedent on it's mass
  */
  private void render() {
    // Prepare renderer
    pushMatrix();
    stroke(255, 255, 255);
    fill(212, 175, 55);

    // Move matrix to the position of the blirb and rotate accordingly
    translate(position.x, position.y);

    circle(0, 0, mass * 3);

    // Pop the matrix
    popMatrix();
  }
}
