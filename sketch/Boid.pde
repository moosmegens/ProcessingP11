class BoidSettings
{
  float maxSpeed   = 3.0;
  float maxForce   = 0.08;
  float perception = 80.0;

  float sepWeight = 1.6;
  float aliWeight = 1.0;
  float cohWeight = 1.0;

  float edgeMargin   = 100.0;
  float edgeStrength = 0.3;
  
  float startHue = 0;
  float endHue = 360;
  
  final float ROOT3 = sqrt(3);
}

class Boid
{
  PVector pos, vel, acc;
  BoidSettings settings;

  Boid(float x, float y, float z, BoidSettings settings)
  {
    this.settings = settings;
    pos = new PVector(x, y, z);
    vel = PVector.random3D().mult(random(1.5, settings.maxSpeed));
    acc = new PVector();
  }

  void applyForce(PVector f)
  {
    acc.add(f);
  }

  void update()
  {
    vel.add(acc);
    vel.limit(settings.maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void avoidEdges(Scene s)
  {
    float margin   = settings.edgeMargin;
    float strength = settings.edgeStrength;
    PVector steer  = new PVector();

    if (pos.x >  s.W - margin) steer.x -= map(pos.x,  s.W - margin,  s.W, 0, strength);
    if (pos.x < -s.W + margin) steer.x += map(pos.x, -s.W + margin, -s.W, 0, strength);
    if (pos.y >  s.H - margin) steer.y -= map(pos.y,  s.H - margin,  s.H, 0, strength);
    if (pos.y < -s.H + margin) steer.y += map(pos.y, -s.H + margin, -s.H, 0, strength);
    if (pos.z >  s.D - margin) steer.z -= map(pos.z,  s.D - margin,  s.D, 0, strength);
    if (pos.z < -s.D + margin) steer.z += map(pos.z, -s.D + margin, -s.D, 0, strength);

    applyForce(steer);
  }

  PVector separate(ArrayList<Boid> neighbors)
  {
    PVector steer  = new PVector();
    float   desiredSep = settings.perception * 0.5;
    int     count  = 0;

    for (Boid o : neighbors)
    {
      float d = PVector.dist(pos, o.pos);
      if (d > 0 && d < desiredSep)
      {
        steer.add(PVector.sub(pos, o.pos).normalize().div(d));
        count++;
      }
    }

    if (count > 0) steer.div(count);
    if (steer.mag() > 0)
      steer.normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);

    return steer;
  }

  PVector align(ArrayList<Boid> neighbors)
  {
    PVector avg   = new PVector();
    int     count = 0;

    for (Boid o : neighbors)
    {
      if (PVector.dist(pos, o.pos) < settings.perception)
      {
        avg.add(o.vel);
        count++;
      }
    }

    if (count > 0)
      avg.div(count).normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);

    return avg;
  }

  PVector cohere(ArrayList<Boid> neighbors)
  {
    PVector center = new PVector();
    int     count  = 0;

    for (Boid o : neighbors)
    {
      if (PVector.dist(pos, o.pos) < settings.perception)
      {
        center.add(o.pos);
        count++;
      }
    }

    if (count > 0)
    {
      center.div(count);
      return PVector.sub(center, pos).normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);
    }

    return center;
  }

  void flock(ArrayList<Boid> neighbors)
  {
    applyForce(separate(neighbors).mult(settings.sepWeight));
    applyForce(align(neighbors)   .mult(settings.aliWeight));
    applyForce(cohere(neighbors)  .mult(settings.cohWeight));
  }

  void render()
  {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    float yaw   = atan2(vel.x, vel.z);
    float pitch = atan2(-vel.y, sqrt(vel.x * vel.x + vel.z * vel.z));
    
    rotateY(yaw);
    rotateX(pitch);
    
    PVector n = vel.copy().normalize();
    float speed = map(vel.mag(), 0, settings.maxSpeed, 0.5, 1.0);
  
    pushStyle();
    colorMode(HSB, 360, 100, 100);
    
    float hue = map(n.x + n.y + n.z,
          -settings.ROOT3, settings.ROOT3,
          settings.startHue, settings.endHue);
      
    fill(hue, 75, speed * 100);
    colorMode(RGB, 255, 255, 255);

    beginShape(TRIANGLES);
    vertex( 0,  0,  8);
    vertex(-3, -3, -4);
    vertex( 3, -3, -4);
    vertex( 0,  3, -4);
    vertex(-3, -3, -4);
    vertex( 3, -3, -4);
    vertex( 0,  0,  8);
    vertex(-3, -3, -4);
    vertex( 0,  3, -4);
    vertex( 0,  0,  8);
    vertex( 3, -3, -4);
    vertex( 0,  3, -4);
    endShape();

  popMatrix();
    
    popStyle();
  }

  private void v(PVector p) { vertex(p.x, p.y, p.z); }
}
