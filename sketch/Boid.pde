class BoidSettings
{
  float maxSpeed   = 3.0;
  float maxForce   = 0.08;
  float perception = 80.0;
  
  float sepRadius = 0.5; // perception * sepRadius

  float sepWeight = 1.6;
  float aliWeight = 1.0;
  float cohWeight = 1.0;

  float edgeMargin   = 100.0;
  float edgeStrength = 0.3;
  
  float sepAngle = -1;
  float aliAngle = -1;
  float cohAngle = -1;
  
  float startHue = 0;
  float endHue = 360;
  
  float startCohBrightness = 1000;
  float endCohBrightness = 100;
  
  int trailLength = 128;
  
  float angleToDot(float degrees)
  {
    return cos(radians(degrees));
  }
  
  final float ROOT3 = sqrt(3);
}

class Boid
{
  PVector pos, vel, acc;
  BoidSettings settings;
  
  PVector[] trail;
  int       trailHead  = 0;
  int       trailCount = 0;

  float cachedHue = 0;
  float cachedBrightness = 100;

  Boid(float x, float y, float z, BoidSettings settings)
  {
    this.settings = settings;
    pos = new PVector(x, y, z);
    vel = PVector.random3D().mult(random(1.5, settings.maxSpeed));
    acc = new PVector();
    cachedBrightness = settings.startCohBrightness;
    resetTrail();
  }
  
  void resetTrail()
  {
    trail      = new PVector[settings.trailLength];
    trailHead  = 0;
    trailCount = 0;
  }

  void applyForce(PVector f)
  {
    acc.add(f);
  }

  void update(boolean recordTrail)
  {
    if (recordTrail)
    {
      trail[trailHead] = pos.copy();
      trailHead        = (trailHead + 1) % settings.trailLength;
      if (trailCount < settings.trailLength) trailCount++;
    }
    
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

  //PVector separate(ArrayList<Boid> neighbors)
  //{
  //  PVector steer  = new PVector();
  //  float   desiredSep = settings.perception * 0.5;
  //  int     count  = 0;

  //  for (Boid o : neighbors)
  //  {
  //    float d = PVector.dist(pos, o.pos);
  //    if (d > 0 && d < desiredSep)
  //    {
  //      steer.add(PVector.sub(pos, o.pos).normalize().div(d));
  //      count++;
  //    }
  //  }

  //  if (count > 0) steer.div(count);
  //  if (steer.mag() > 0)
  //    steer.normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);

  //  return steer;
  //}

  //PVector align(ArrayList<Boid> neighbors)
  //{
  //  PVector avg   = new PVector();
  //  int     count = 0;

  //  for (Boid o : neighbors)
  //  {
  //    if (PVector.dist(pos, o.pos) < settings.perception)
  //    {
  //      avg.add(o.vel);
  //      count++;
  //    }
  //  }

  //  if (count > 0)
  //    avg.div(count).normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);

  //  return avg;
  //}

  //PVector cohere(ArrayList<Boid> neighbors)
  //{
  //  PVector center = new PVector();
  //  int     count  = 0;

  //  for (Boid o : neighbors)
  //  {
  //    if (PVector.dist(pos, o.pos) < settings.perception)
  //    {
  //      center.add(o.pos);
  //      count++;
  //    }
  //  }

  //  if (count > 0)
  //  {
  //    center.div(count);
  //    return PVector.sub(center, pos).normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);
  //  }

  //  return center;
  //}

  void flock(ArrayList<Boid> neighbors)
  {
    PVector sep = new PVector();
    PVector ali = new PVector();
    PVector coh = new PVector();
    int sepCount = 0, aliCount = 0, cohCount = 0;
    float desiredSep = settings.perception * settings.sepRadius;
  
    PVector heading = vel.copy().normalize();
  
    for (int i = 0; i < neighbors.size(); i++)
    {
      Boid o = neighbors.get(i);
      if (o == this) continue;
  
      float d = PVector.dist(pos, o.pos);
      if (d <= 0 || d >= settings.perception) continue;
  
      float invD = 1.0 / d;
      float dx = (o.pos.x - pos.x) * invD;
      float dy = (o.pos.y - pos.y) * invD;
      float dz = (o.pos.z - pos.z) * invD;
      float dp = heading.x*dx + heading.y*dy + heading.z*dz;
  
      boolean inAli = dp >= settings.aliAngle;
      boolean inCoh = dp >= settings.cohAngle;
      boolean inSep = dp >= settings.sepAngle;
      if (!inAli && !inCoh && !inSep) continue;
  
      if (inAli) { ali.add(o.vel); aliCount++; }
      if (inCoh) { coh.add(o.pos); cohCount++; }
      if (inSep && d < desiredSep && settings.sepRadius > 0)
      {
        PVector away = new PVector(pos.x - o.pos.x, pos.y - o.pos.y, pos.z - o.pos.z);
        away.normalize().div(d);
        sep.add(away);
        sepCount++;
      }
    }
  
    if (sepCount > 0)
    {
      sep.div(sepCount);
      sep.normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);
    }
  
    if (aliCount > 0)
      ali.div(aliCount).normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);
  
    if (cohCount > 0)
    {
      coh.div(cohCount);
      PVector desired = PVector.sub(coh, pos);
      coh = desired.copy().normalize().mult(settings.maxSpeed).sub(vel).limit(settings.maxForce);
  
      float distToCenter = desired.mag();
      float maxDist = settings.perception;
      cachedBrightness = map(distToCenter, 0, maxDist, settings.endCohBrightness, settings.startCohBrightness); 
    }
  
    applyForce(sep.mult(settings.sepWeight));
    applyForce(ali.mult(settings.aliWeight));
    applyForce(coh.mult(settings.cohWeight));
  }
  
  void updateCache()
  {
    float nx    = vel.x, ny = vel.y, nz = vel.z;
    float mag   = sqrt(nx*nx + ny*ny + nz*nz);
    if (mag > 0) { nx /= mag; ny /= mag; nz /= mag; }
    cachedHue   = map(nx + ny + nz, -settings.ROOT3, settings.ROOT3, settings.startHue, settings.endHue);
    //cachedSpeed = map(mag, 0, settings.maxSpeed, 0.2, 1.0);
  }

  void render()
  {
    fill(cachedHue, 90, cachedBrightness);

    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateY(atan2(vel.x, vel.z));
    rotateX(atan2(-vel.y, sqrt(vel.x * vel.x + vel.z * vel.z)));

    beginShape(TRIANGLES);
    vertex( 0,  0,  8);
    vertex(-3, -3, -4);
    vertex( 3, -3, -4);

    vertex( 0,  0,  8);
    vertex(-3, -3, -4);
    vertex( 0,  3, -4);

    vertex( 0,  0,  8);
    vertex( 3, -3, -4);
    vertex( 0,  3, -4);

    vertex(-3, -3, -4);
    vertex( 3, -3, -4);
    vertex( 0,  3, -4);
    endShape();

    popMatrix();
  }
  
  void drawTrail()
  {
    if (trailCount < 2) return;

    beginShape();
    for (int i = 0; i < trailCount; i++)
    {
      int   idx = (trailHead - trailCount + i + settings.trailLength) % settings.trailLength;
      float t   = (float)i / trailCount;
      stroke(cachedHue, 75, 100, t*80);
      vertex(trail[idx].x, trail[idx].y, trail[idx].z);
    }
    endShape();
  }

  private void v(PVector p) { vertex(p.x, p.y, p.z); }
}
