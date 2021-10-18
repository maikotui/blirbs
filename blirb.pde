/* //<>// //<>// //<>//
*  Implementation of the Blirb
 */


/**
 The movement mode for this AI
 */
enum AIMode {
  WANDER // Wanders aimlessly in random directions
    , FLOCK // Flocks with other nearby Blirbs
}

enum HungerState {
  FULL, HUNGRY, STARVING
}

/**
 A representation of a simple bird-like AI.
 */
class Blirb extends Edible {
  // General constants
  final float INIT_SIZE_MIN = 1.0;
  final float INIT_SIZE_MAX = 5.0;
  final float MAX_SPEED = 2.5;
  final float MAX_FORCE = 1.5;

  // Feeding constants
  final float HUNT_DISTANCE = 15;
  final float EAT_DISTANCE = 1.0;
  final int TIME_TILL_HUNGRY = 5; // If the blirb hasn't eaten for longer than this time, it will become hungry
  final int TIME_TILL_STARVING = 10; // If the blirb hasn't eaten for longer than this time, it will become starved
  final int TIME_TILL_DEATH = 15; // If the blirb hasn't eaten for longer than this time, it will die

  // Wander constants
  final float WANDER_CIRCLE_DISTANCE = 20.0;
  final float WANDER_CIRCLE_RADIUS = 10.0;
  final float WANDER_CIRCLE_ANGLE = 0.2;
  final float ANGLE_CHANGE = 0.5;

  // Flocking constants
  final int MIN_NEIGHBORS_TO_FLOCK = 3; // Number of neighbors to start flocking with
  final float NEIGHBOR_DISTANCE = 30;
  final float ALIGNMENT_AMOUNT = 1.0;
  final float COHESION_AMOUNT = 1.0;
  final float SEPARATION_AMOUNT = 1.0;

  // Display constants
  final int NAME_SIZE = 12;
  final float NAME_OFFSET = -3.0;

  // The mode that this blirb's AI is set in
  public AIMode mode = AIMode.WANDER;
  // The name to display above this blirb
  public String name;
  // Basic physics vectors
  public PVector velocity, acceleration;
  // The size of this blirb
  public float mass = random(INIT_SIZE_MIN, INIT_SIZE_MAX);
  // Dictates whether this blirb is hungry
  public HungerState appetite = HungerState.FULL;
  // A debug mode that displays AI information
  public boolean debugDrawEnabled = false;

  // The angle this Blirb is wandering towards
  private float _wanderAngle = random(TWO_PI);
  // The time since this blirb last changed hunger state
  private int _timeLastAte = millis() + int(random(5000));


  /**
   Creates a Blirb with position (x, y), initial rotation of "rotation", AIMode of mode, and color of c.
   */
  public Blirb(String name, float x, float y, float rotation) {
    // Store the name
    this.name = new String(name);

    // Initial physics values
    acceleration = new PVector(0, 0);
    position = new PVector(x, y);
    velocity = new PVector(cos(rotation), sin(rotation));
  }


  /**
   Needs to be called every update frame (usually in draw).
   This function calculates the movement amount for this blirb and draws it.
   */
  public void update() {
    // Update hunger
    updateHungerState();

    // Figure out where to move
    chooseMovementDirection();

    // Update physics values
    physicsUpdate();

    // Draw the blirb
    render();
  }


  public void consume(float foodWeight) {
    appetite = HungerState.FULL;
    _timeLastAte = millis();
    mass += foodWeight;
  }


  public void kill() {
    queueBlirbDeath(this);
  }


  /**
   The physics update frame. Adjusts physics variables.
   */
  void physicsUpdate() {
    // Velocity = acceleration * time (which we expect is constant so we ignore it)
    velocity.add(acceleration);
    if (appetite == HungerState.STARVING) {
      velocity.limit(MAX_SPEED * 2);
    } else {
      velocity.limit(MAX_SPEED);
    }


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
    pushMatrix();

    // Move matrix to the position of the blirb and rotate accordingly
    translate(position.x, position.y);

    // Draw the name
    stroke(255, 255, 255, 100);
    fill(255, 255, 255, 100);
    textFont(arialFont, NAME_SIZE);
    text(name, 0, NAME_OFFSET * mass);

    // Rotate for drawing the triangle and other debug shapes
    rotate(theta);

    // Draw debug shapes
    if (debugDrawEnabled) {
      fill(200, 100);
      stroke(255, 255, 255);

      // Draw the neighbor radius
      if (mode == AIMode.FLOCK) {
        circle(0, 0, NEIGHBOR_DISTANCE * mass);
      }

      // Draw the wander circle
      if (mode == AIMode.WANDER) {
        rotate(-theta);
        PVector circleCenter = velocity.copy().normalize().mult(WANDER_CIRCLE_DISTANCE * mass);
        circle(circleCenter.x, circleCenter.y, WANDER_CIRCLE_RADIUS * mass);
        rotate(theta);
      }
    }

    // Set the color based on it's hunger level
    fill(255, 255, 255, 100);
    switch(appetite) {
    case STARVING:
      stroke(255, 0, 0);
      fill(255, 0, 0);
      break;
    case HUNGRY:
      stroke(255, 250, 205);
      break;
    case FULL:
      stroke(0, 255, 0);
      break;
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


  void updateHungerState() {
    int timeSinceLastAte = millis() - _timeLastAte;
    if (timeSinceLastAte > TIME_TILL_DEATH * 1_000) {
      kill();
    } else if (timeSinceLastAte > TIME_TILL_STARVING * 1_000) {
      appetite = HungerState.STARVING;
    } else if (timeSinceLastAte > TIME_TILL_HUNGRY * 1_000) {
      appetite = HungerState.HUNGRY;
    }
  }


  void chooseMovementDirection() {
    PVector force = new PVector();

    // If the blirb is hungry, find the closest food within hunting distance
    if (appetite != HungerState.FULL) {
      Edible closestFood = null;
      ArrayList<Edible> foodsToEat = new ArrayList();
      for (Food f : allFoods) {
        // Calculate how far away the food is
        float distF = PVector.dist(position, f.position);

        // If the food is within eating distance, add it to the list of foods to eat
        if (distF <= EAT_DISTANCE * mass) {
          foodsToEat.add(f);
        } else if (distF <= HUNT_DISTANCE * mass) { // If the food is within hunting distance, consider moving towards it
          if (closestFood == null) { // We have not found a food in hunting distance yet
            closestFood = f;
          } else if (distF < PVector.dist(position, closestFood.position)) { // This is closer than our closest found food
            closestFood = f;
          }
        }
      }

      // If the blirb is starving, look at nearby blirbs to eat
      if (appetite == HungerState.STARVING) {
        for (Blirb b : allBlirbs) {
          if (b != this && b.mass <= mass) {
            // Calculate how far away the food is
            float distB = PVector.dist(position, b.position);

            // If the food is within eating distance, add it to the list of foods to eat
            if (distB <= EAT_DISTANCE * mass) {
              foodsToEat.add(b);
            } else if (distB <= HUNT_DISTANCE * mass) { // If the food is within hunting distance, consider moving towards it
              if (closestFood == null) { // We have not found a food in hunting distance yet
                closestFood = b;
              } else if (distB < PVector.dist(position, closestFood.position)) { // This is closer than our closest found food
                closestFood = b;
              }
            }
          }
        }
      }

      // Eat the foods that are nearby
      for (Edible e : foodsToEat) {
        consume(e.mass);
        if (e instanceof Food) {
          Food f = (Food)e;
          queueFoodEat(f);
        } else if (e instanceof Blirb) {
          Blirb b = (Blirb)e;
          b.kill();
        }
      }

      // If there is a food closeby, move towards it
      if (closestFood != null) {
        force = PVector.sub(closestFood.position, position);
        acceleration.add(force.div(mass)).limit(MAX_FORCE);
        return;
      }
    }

    // The blirb either is not hungry or could not find nearby food, so we go to default behavior
    ArrayList<Blirb> neighbors = new ArrayList();
    for (Blirb blirb : allBlirbs) {
      if (blirb != this && position.dist(blirb.position) <= NEIGHBOR_DISTANCE * mass) {
        neighbors.add(blirb);
      }
    }

    if (neighbors.size() > MIN_NEIGHBORS_TO_FLOCK) {
      mode = AIMode.FLOCK;
    } else {
      mode = AIMode.WANDER;
    }
    switch(mode) {
    case WANDER:
      force = calculateWander();
      break;
    case FLOCK:
      force = calculateFlock(neighbors);
      break;
    }



    // Add the applied to the acceleration
    acceleration.add(force.div(mass));
    if(appetite == HungerState.STARVING) {
     acceleration.limit(MAX_FORCE * 2); 
    }
    else {
      acceleration.limit(MAX_FORCE);
    }
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
  PVector calculateFlock(ArrayList<Blirb> neighbors) {
    // flocking = alignment + cohesion + separation
    PVector flockForce = new PVector();
    flockForce.add(calculateAlignment(neighbors).mult(ALIGNMENT_AMOUNT));
    flockForce.add(calculateCohesion(neighbors).mult(COHESION_AMOUNT));
    flockForce.add(calculateSeparation(neighbors).mult(SEPARATION_AMOUNT));
    return flockForce;
  }


  /**
   Calculates the amount the alignment with respect to the blirb's neighbors.
   Alignment is the average of the neighbor blirb's velocity.
   */
  PVector calculateAlignment(ArrayList<Blirb> neighbors) {
    PVector force = new PVector();
    int neighborWeights = 0;

    // For each neighbor within the neighbor distance
    for (Blirb blirb : neighbors) {
      force.add(PVector.mult(blirb.velocity, blirb.mass)); // Calculate the sum of all neighbors' velocity
      neighborWeights += blirb.mass;
    }

    // Avoid divide by zero error
    if (neighborWeights != 0) {
      force.div(neighborWeights); // Calculate average of all neighbors' velocities
      force.normalize();
    }

    return force;
  }


  /**
   Calculates the amount of cohesion with respect to the blirb's neighbors.
   Cohesion is the direction towards the center of mass.
   */
  PVector calculateCohesion(ArrayList<Blirb> neighbors) {
    PVector force = new PVector();
    int neighborWeights = 0;

    // For each neighbor within the neighbor distance
    for (Blirb blirb : neighbors) {
      force.add(PVector.mult(blirb.position, blirb.mass)); // Calculate the sum of all neighbors' positions
      neighborWeights += blirb.mass;
    }

    // Avoid divide by zero error
    if (neighborWeights != 0) {
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
  PVector calculateSeparation(ArrayList<Blirb> neighbors) {
    PVector force = new PVector();
    int neighborWeights = 0;
    // For each neighbor within the neighbor distance
    for (Blirb blirb : neighbors) {
      force.add(PVector.sub(blirb.position, position).mult(blirb.mass)); // Calculate the sum directions towards neighbors' positions
      neighborWeights += blirb.mass;
    }

    // Avoid divide by zero error
    if (neighborWeights != 0) {
      force.div(neighborWeights); // Calculate the average direction towards neighbors' positions
      force.mult(-1); // Invert it so we move away from it
      force.normalize();
    }

    return force;
  }
}
