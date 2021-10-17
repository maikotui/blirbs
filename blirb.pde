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
  final float MAX_SPEED = 2;
  final float MAX_FORCE = 1.0;
  final float NEIGHBOR_DISTANCE = 30;
  
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
  public float weight = INITIAL_WEIGHT;
  // A list of all the other blirbs surrounding this blirb
  public ArrayList<Blirb> neighbors = new ArrayList();
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
    // Calculate the amount of force to apply based on the AIMode
    PVector force = new PVector();
    switch(mode) {
     case WANDER:
       force = calculateWander();
       break;
     case FLOCK:
       force = calculateFlock();
       break;
    }
    
    // Add the applied to the acceleration
    acceleration.add(force.mult(weight).limit(MAX_FORCE));
    
    // Update physics values
    physicsUpdate();
    
    // Draw the blirb
    render();
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
    
    // Reset acceleration
    acceleration.mult(0); 
    
    // Wrap position inside bounds
    if (position.x < -weight) position.x = width+weight;
    if (position.y < -weight) position.y = height+weight;
    if (position.x > width+weight) position.x = -weight;
    if (position.y > height+weight) position.y = -weight;
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
        circle(0, 0, NEIGHBOR_DISTANCE * weight);
      }
      
      // Draw the wander circle
      if(mode == AIMode.WANDER) {
        rotate(-theta);
        PVector circleCenter = velocity.copy().normalize().mult(WANDER_CIRCLE_DISTANCE * weight);
        circle(circleCenter.x, circleCenter.y, WANDER_CIRCLE_RADIUS * weight);
        rotate(theta);
      }
      
      stroke(c);
    }
    
    // Draw the blirb triangle
    beginShape(TRIANGLES);
    vertex(0, -weight*2);
    vertex(-weight, weight*2);
    vertex(weight, weight*2);
    endShape();
    
    // Pop the matrix
    popMatrix();
  }
  

  /**
    Calculates the force for when the blirb is in "wander" mode.
  */
  PVector calculateWander() {
    // Create a circle in front of the blirb
    PVector circleCenter = velocity;
    circleCenter.normalize();
    circleCenter.mult(WANDER_CIRCLE_DISTANCE * weight);
    
    // Calculate the displacement force from the circle center to the radius
    PVector displacement = new PVector(0, -1);
    displacement.mult(WANDER_CIRCLE_RADIUS * weight);
    
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
    for(Blirb blirb : neighbors) {
      if(blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * weight) {
        force.add(PVector.mult(blirb.velocity, blirb.weight)); // Calculate the sum of all neighbors' velocity
        neighborWeights += blirb.weight;
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
    for(Blirb blirb : neighbors) {
      if(blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * weight) {
        force.add(PVector.mult(blirb.position, blirb.weight)); // Calculate the sum of all neighbors' positions
        neighborWeights += blirb.weight;
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
    for(Blirb blirb : neighbors) {
      if(blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * weight) {
        force.add(PVector.sub(blirb.position, position).mult(blirb.weight)); // Calculate the sum directions towards neighbors' positions
        neighborWeights += blirb.weight;
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
