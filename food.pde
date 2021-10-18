class Food {
  public final float INITIAL_MASS = 0.1;
  
  public PVector position;
  public float mass;
   
  public Food() {
    position = new PVector(random(width), random(height));
    mass = INITIAL_MASS;
  }
   
  public Food(float xPos, float yPos) {
    position = new PVector(xPos, yPos);
    mass = INITIAL_MASS;
  }
  
  public void update() {
    render();
  }
   
  private void render() {
     // Prepare renderer
    pushMatrix();
    stroke(255, 255, 255);
    fill(212, 175, 55);
    
    // Move matrix to the position of the blirb and rotate accordingly
    translate(position.x, position.y);
    
    circle(0, 0, mass * 50);
    
    // Pop the matrix
    popMatrix();
   }
}
