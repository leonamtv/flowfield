Boolean draw_field = true;

int scl = 10;
int cols = 0;
int rows = 0;
int num_particles = 1000;
int frame_rate = 30;
int iteration = 0;
int max_iterations = 20000;

float vector_magnitude = 0.3;
float x_offset = 0;
float y_offset = 0;
float z_offset = 0;
float xy_increment = 0.1;
float z_increment = 0.0000;

ArrayList<Particle> particles;
PVector[] flow_field;

PVector vector;

void setup() {
 
  size(1800, 1000);
  frameRate(frame_rate);
  //background(4,41,64);
  //background(255);
  background(0);
  
  cols = width / scl;
  rows = height / scl;
  
  flow_field = new PVector[cols * rows];
  particles = new ArrayList<Particle>();
  
  create_particles();
}

void create_particles () {
  particles = new ArrayList<Particle>();
  
  for (int i = 0; i < num_particles; i++ ) {
    particles.add(new Particle());
  }
}

void draw_vector (PVector vector, int x, int y, int scl) {
  push();
  translate(x * scl, y * scl);
  rotate(vector.heading());
  strokeWeight(1);
  line(0, 0, scl, 0);
  pop();
}

void draw() {
  
  if(!draw_field) 
    background(4,41,64);
  
  stroke(219,242,39,50);
  
  y_offset=0;
  for(int y=0; y < rows; y += 1 ) {
    x_offset=0;
    for(int x=0; x < cols; x += 1 ) {
      
      float angle = noise(x_offset, y_offset, z_offset) * TWO_PI;
      int index = x + y * cols; 
      
      vector = PVector.fromAngle(angle);
      vector.setMag(vector_magnitude);
      
      flow_field[index] = vector;
      
      x_offset += xy_increment;

      if(!draw_field) 
        draw_vector(vector, x, y, scl);
      
    }
    
    y_offset += xy_increment;
    z_offset += z_increment;  
    
    iteration += 1;
    
    if (iteration >= max_iterations) {
      iteration = 0;
      create_particles();
    }
       
  }
  
  
  for (int i = 0; i < particles.size(); i++ ) {
    particles.get(i).follow(flow_field, scl);
    particles.get(i).update();
    particles.get(i).edges();
    particles.get(i).show();
  }
 
}



class Particle {
  
  PVector pos = new PVector(random(width),random(height));
  PVector vel = new PVector(0,0);
  PVector acc = new PVector(0,0);
  PVector prev = this.pos.copy();
  
  float maxSpeed = 4.0;
   
  
  void update () {
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
  
  void applyForce(PVector force) {
    this.acc.add(force);
  }
  
  void updatePrevious () {
     this.prev.x = this.pos.x;
     this.prev.y = this.pos.y;
  }
  
  void show(){
    
    if(draw_field) {
      //stroke(181,34,230,20);
      //stroke(219,242,39,20);
      //stroke(255,0,0,20);
      stroke(255, 208, 138, 20);
      //stroke(255,20);
    } else {
      //stroke(181,34,230);
      stroke(219,242,39);  
    }
    
    strokeWeight(1);
    
    if(draw_field) {
      line(this.pos.x, this.pos.y, this.prev.x, this.prev.y);
    } else {
      point(this.pos.x, this.pos.y);
    }
    
    this.updatePrevious();
  }
  
  void edges(){
    if (this.pos.x > width) {
      this.pos.x = 0;
      this.updatePrevious();
    }
    if (this.pos.y > height) {
      this.pos.y = 0;
      this.updatePrevious();
    }
    if (this.pos.x < 0 ) {
      this.pos.x = width;
      this.updatePrevious();
    }
    if (this.pos.y < 0 ) {
      this.pos.y = height;
      this.updatePrevious();
    }
  }
  
  void follow(PVector[] vectors, int scale) {
      int x = floor(this.pos.x / cols);
      int y = floor(this.pos.y / rows);
      int index = x + y * cols;
      PVector force = vectors[index];
      this.applyForce(force);
  }
  
}
