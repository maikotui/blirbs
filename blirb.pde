enum AIMode {
  WANDER,
  FLOCK,
  HUNT
}

class Bot {
  // General constants
  final float MAX_SPEED = 2;
  final float MAX_FORCE = 1.0;
  final float NEIGHBOR_DISTANCE = 60;
  
  // Wander constants
  final float WANDER_CIRCLE_DISTANCE = 10.0;
  final float WANDER_CIRCLE_ANGLE = 1.0;
  final float ANGLE_CHANGE = 0.5;
  
  // Flocking constants
  final float ALIGNMENT_AMOUNT = 1.0;
  final float COHESION_AMOUNT = 1.0;
  final float SEPARATION_AMOUNT = 1.0;
  
  public ArrayList<Bot> neighbors;
  
  AIMode mode;
  
  PVector position, velocity, acceleration;
  color c;
  float weight;
  boolean debugDrawEnabled = false;
  
  
  public Bot(float x, float y, float rotation, AIMode mode, color c) {
    acceleration = new PVector(0,0);
    position = new PVector(x,y);
    velocity = new PVector(cos(rotation), sin(rotation));
    
    this.mode = mode;
    this.c = c;
    
    weight = 2.0;
  }
  
  
  public void update() {
    PVector force = new PVector();
    switch(mode) {
     case WANDER:
       force = calculateWander();
       break;
     case FLOCK:
       force = calculateFlock();
       break;
     case HUNT:
       force = calculateHunt();
       break;
    }
    acceleration.add(force.limit(MAX_FORCE));
    physicsUpdate();
    render();
  }
  
  float wanderAngle = random(TWO_PI);
  PVector calculateWander() {
    // Create a circle in front of the bot
    PVector circleCenter = velocity;
    circleCenter.normalize();
    circleCenter.mult(WANDER_CIRCLE_DISTANCE);
    
    // Calculate the displacement from the circle center to the radius
    PVector displacement = new PVector(0, -1);
    displacement.mult(WANDER_CIRCLE_DISTANCE);
    
    float len = displacement.mag();
    displacement.x = cos(wanderAngle) * len;
    displacement.y = sin(wanderAngle) * len;
    
    wanderAngle += Math.random() * ANGLE_CHANGE - ANGLE_CHANGE * .5;
    
    PVector wanderForce = circleCenter.add(displacement);
    return wanderForce;
  }
 
  PVector calculateFlock() {
    PVector flockForce = new PVector();
    flockForce.add(calculateAlignment().mult(ALIGNMENT_AMOUNT));
    flockForce.add(calculateCohesion().mult(COHESION_AMOUNT));
    flockForce.add(calculateSeparation().mult(SEPARATION_AMOUNT));
    return flockForce;
  }
  
  PVector calculateAlignment() {
    PVector force = new PVector();
    int numNeighbors = 0;
    for(Bot bot : neighbors) {
      if(bot != this && position.dist(bot.position) <= NEIGHBOR_DISTANCE) {
        force.add(bot.velocity);
        numNeighbors++;
      }
    }
    
    if(numNeighbors != 0) {
      force.div(numNeighbors);
      force.normalize();
    }
    
    return force;
  }
  
  PVector calculateCohesion() {
    PVector force = new PVector();
    int numNeighbors = 0;
    for(Bot bot : neighbors) {
      if(bot != this && position.dist(bot.position) <= NEIGHBOR_DISTANCE) {
        force.add(bot.position);
        numNeighbors++;
      }
    }
    
    if(numNeighbors != 0) {
      force.div(numNeighbors);
      force.sub(position);
      force.normalize();
    }
    
    return force;
  }
  
  PVector calculateSeparation() {
    PVector force = new PVector();
    int numNeighbors = 0;
    for(Bot bot : neighbors) {
      if(bot != this && position.dist(bot.position) <= NEIGHBOR_DISTANCE) {
        force.add(PVector.sub(bot.position, position));
        numNeighbors++;
      }
    }
    
    if(numNeighbors != 0) {
      force.div(numNeighbors);
      force.mult(-1);
      force.normalize();
    }
    
    return force;
  }
  
  PVector calculateHunt() {
    PVector huntForce = new PVector();
    return huntForce;
  }
  
  void physicsUpdate() {
    velocity.add(acceleration);
    velocity.limit(MAX_SPEED);
    position.add(velocity);
    acceleration.mult(0); 
    
    if (position.x < -weight) position.x = width+weight;
    if (position.y < -weight) position.y = height+weight;
    if (position.x > width+weight) position.x = -weight;
    if (position.y > height+weight) position.y = -weight;
  }
  
  
  void render() {
    float theta = velocity.heading() + radians(90);
    
    fill(200, 100);
    stroke(c);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    
    if(debugDrawEnabled) {
      stroke(255, 255, 255);
      circle(0, 0, NEIGHBOR_DISTANCE);
      stroke(c);
    }
    
    beginShape(TRIANGLES);
    vertex(0, -weight*2);
    vertex(-weight, weight*2);
    vertex(weight, weight*2);
    endShape();
    popMatrix();
  }
}
