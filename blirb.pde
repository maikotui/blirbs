/*
*  Implementation of the Blirb
*/


/**
  The movement mode for this AI
*/
enum AIMode {
  WANDER // Wanders aimlessly in random directions
  ,FLOCK // Flocks with other nearby Blirbs
}


/**
  A representation of a simple bird-like AI.
*/
class Blirb {
  // General constants
  final float INITIAL_WEIGHT = 1.0;
  final float MAX_SPEED = 2.5;
  final float MAX_FORCE = 100;
  final float NEIGHBOR_DISTANCE = 30;
  final float HUNT_DISTANCE = 15;
  final float EAT_DISTANCE = 1.0;
  
  // Wander constants
  final float WANDER_CIRCLE_DISTANCE = 20.0;
  final float WANDER_CIRCLE_RADIUS = 10.0;
  final float WANDER_CIRCLE_ANGLE = 0.2;
  final float ANGLE_CHANGE = 0.5;
  
  // Flocking constants
  final float ALIGNMENT_AMOUNT = 1.0;
  final float COHESION_AMOUNT = 1.0;
  final float SEPARATION_AMOUNT = 1.0;
  
  // The mode that this blirb's AI is set in 
  public AIMode mode;
  // Basic physics vectors
  public PVector position, velocity, acceleration;
  // The color used to display this blirb
  public color c;
  // The size of this blirb
  public float mass = INITIAL_WEIGHT;
  // A debug mode that displays AI information
  public boolean debugDrawEnabled = false;
  
  // The angle this Blirb is wandering towards
  private float _wanderAngle = random(TWO_PI);
  
  
  /**
    Creates a Blirb with position (x, y), initial rotation of "rotation", AIMode of mode, and color of c.
  */
  public Blirb(float x, float y, float rotation, AIMode mode, color c) {
    // Initial physics values
    acceleration = new PVector(0,0);
    position = new PVector(x,y);
    velocity = new PVector(cos(rotation), sin(rotation));
    
    // Store the mode and color
    this.mode = mode;
    this.c = c;
  }
  
  
  /**
    Needs to be called every update frame (usually in draw).
    This function calculates the movement amount for this blirb and draws it.
  */
  public void update() {
    // Figure out where to move
    chooseMovementDirection();
    
    // Update physics values
    physicsUpdate();
    
    // Draw the blirb
    render();
  }
  
  
  public void consume(float foodWeight) {
    mass += foodWeight;
  }
  
  
  /**
    The physics update frame. Adjusts physics variables.
  */
  void physicsUpdate() {
    // Velocity = acceleration * time (which we expect is constant so we ignore it)
    velocity.add(acceleration);
    velocity.limit(MAX_SPEED);
    
    // Adjust position based on velocity
    position.add(velocity);
    
    // Wrap position inside bounds
    if (position.x < -mass) position.x = width+mass;
    if (position.y < -mass) position.y = height+mass;
    if (position.x > width+mass) position.x = -mass;
    if (position.y > height+mass) position.y = -mass;
  }
  
  
  /**
    Draws the blirb as a triangle with color "c". If the debug drawing mode is enabled,
    it will also draw shapes related to AI calculations.
  */
  void render() {
    // Calculate the amount of rotation needed when drawing this blirb
    float theta = velocity.heading() + radians(90);
    
    // Prepare renderer
    fill(200, 100);
    stroke(c);
    pushMatrix();
    
    // Move matrix to the position of the blirb and rotate accordingly
    translate(position.x, position.y);
    rotate(theta);
    
    // Draw debug shapes
    if(debugDrawEnabled) {
      stroke(255, 255, 255);
      
      // Draw the neighbor radius
      if(mode == AIMode.FLOCK) {
        circle(0, 0, NEIGHBOR_DISTANCE * mass);
      }
      
      // Draw the wander circle
      if(mode == AIMode.WANDER) {
        rotate(-theta);
        PVector circleCenter = velocity.copy().normalize().mult(WANDER_CIRCLE_DISTANCE * mass);
        circle(circleCenter.x, circleCenter.y, WANDER_CIRCLE_RADIUS * mass);
        rotate(theta);
      }
      
      stroke(c);
    }
    
    // Draw the blirb triangle
    beginShape(TRIANGLES);
    vertex(0, -mass*2);
    vertex(-mass, mass*2);
    vertex(mass, mass*2);
    endShape();
    
    // Pop the matrix
    popMatrix();
  }
  
  void chooseMovementDirection() {
    PVector force = new PVector();
    
    // Find the closest food within hunting distance
    Food closestFood = null;
    ArrayList<Food> foodsToEat = new ArrayList();
    for(Food f : allFoods) {
      // Calculate how far away the food is
      float distF = PVector.dist(position, f.position);
      
      // If the food is within eating distance, add it to the list of foods to eat
      if(distF <= EAT_DISTANCE * mass) {
        foodsToEat.add(f);
      } 
      else if(distF <= HUNT_DISTANCE * mass) { // If the food is within hunting distance, consider moving towards it
        if(closestFood == null) { // We have not found a food in hunting distance yet
           closestFood = f;
        } 
        else if(distF < PVector.dist(position, closestFood.position)) { // This is closer than our closest found food
          closestFood = f;
        }
      }
    }
    
    // Eat the foods that are nearby
    for(Food f : foodsToEat) {
       consume(f.mass);
       allFoods.remove(f);
    }
    
    // If there is a food closeby, move towards it
    if(closestFood != null) {
      force = PVector.sub(closestFood.position, position);
    }
    else { // No food nearby, so we can move according to the AI mode
      switch(mode) {
       case WANDER:
         force = calculateWander();
         break;
       case FLOCK:
         force = calculateFlock();
         break;
      }    
    }
    
    
    // Add the applied to the acceleration
    acceleration.add(force.div(mass)).limit(MAX_FORCE);
  }
  

  /**
    Calculates the force for when the blirb is in "wander" mode.
  */
  PVector calculateWander() {
    // Create a circle in front of the blirb
    PVector circleCenter = velocity;
    circleCenter.normalize();
    circleCenter.mult(WANDER_CIRCLE_DISTANCE * mass);
    
    // Calculate the displacement force from the circle center to the radius
    PVector displacement = new PVector(0, -1);
    displacement.mult(WANDER_CIRCLE_RADIUS * mass);
    
    // Randomly change the displacement
    float len = displacement.mag();
    displacement.x = cos(_wanderAngle) * len;
    displacement.y = sin(_wanderAngle) * len;
    
    // Offset wander angle slightly so it will be different next frame
    _wanderAngle += Math.random() * ANGLE_CHANGE - ANGLE_CHANGE * .5;
    
    // Calculate and return the wander force
    PVector wanderForce = circleCenter.add(displacement);
    return wanderForce;
  }
 
 
  /**
    Calculates the force for when the blirb is in "flock" mode.
    Flocking force is the sum of alignment, cohesion, and separation.
  */
  PVector calculateFlock() {
    // flocking = alignment + cohesion + separation
    PVector flockForce = new PVector();
    flockForce.add(calculateAlignment().mult(ALIGNMENT_AMOUNT));
    flockForce.add(calculateCohesion().mult(COHESION_AMOUNT));
    flockForce.add(calculateSeparation().mult(SEPARATION_AMOUNT));
    return flockForce;
  }
  
  
  /**
    Calculates the amount the alignment with respect to the blirb's neighbors.
    Alignment is the average of the neighbor blirb's velocity.
  */
  PVector calculateAlignment() {
    PVector force = new PVector();
    int neighborWeights = 0;
    
    // For each neighbor within the neighbor distance
    for(Blirb blirb : allBlirbs) {
      if(blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * mass) {
        force.add(PVector.mult(blirb.velocity, blirb.mass)); // Calculate the sum of all neighbors' velocity
        neighborWeights += blirb.mass;
      }
    }
    
    // Avoid divide by zero error
    if(neighborWeights != 0) {
      force.div(neighborWeights); // Calculate average of all neighbors' velocities
      force.normalize();
    }
    
    return force;
  }
  
  
  /**
    Calculates the amount of cohesion with respect to the blirb's neighbors.
    Cohesion is the direction towards the center of mass.
  */
  PVector calculateCohesion() {
    PVector force = new PVector();
    int neighborWeights = 0;
    
    // For each neighbor within the neighbor distance
    for(Blirb blirb : allBlirbs) {
      if(blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * mass) {
        force.add(PVector.mult(blirb.position, blirb.mass)); // Calculate the sum of all neighbors' positions
        neighborWeights += blirb.mass;
      }
    }
    
    // Avoid divide by zero error
    if(neighborWeights != 0) {
      force.div(neighborWeights); // Calculate the position of the center of mass
      force.sub(position); // Calculate the vector from this blirb's position to the center of mass
      force.normalize();
    }
    
    return force;
  }
  
  
  /**
    Calculates the amount of separation with respect to the blirb's neighbors.
    Separation is the behaviour that steers blirbs away from each other.
  */
  PVector calculateSeparation() {
    PVector force = new PVector();
    int neighborWeights = 0;
    // For each neighbor within the neighbor distance
    for(Blirb blirb : allBlirbs) {
      if(blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * mass) {
        force.add(PVector.sub(blirb.position, position).mult(blirb.mass)); // Calculate the sum directions towards neighbors' positions
        neighborWeights += blirb.mass;
      }
    }
    
    // Avoid divide by zero error
    if(neighborWeights != 0) {
      force.div(neighborWeights); // Calculate the average direction towards neighbors' positions
      force.mult(-1); // Invert it so we move away from it
      force.normalize();
    }
    
    return force;
  }
}
