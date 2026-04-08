class smart_brush 
{
  private PVector position;
  private float noise_offset;
  private float noise_speed = 0.01;
  private float move_speed = 2; 
  private float radius = 15;
  private float radius_random_scale = 5;
 
  public smart_brush(PVector p, float s, float ns, float r, float rs)
  {
    this.position = p.copy();
    this.noise_offset = floor(random(2)) * 1000;
    this.move_speed = s;
    this.noise_speed = ns;
    this.radius = r;
    this.radius_random_scale = rs;
  }
 
  public void tick()
  {
    float nx = noise(noise_offset);
    float ny = noise(noise_offset + 100000);
    
    nx = pow(nx, 0.9);
    ny = pow(ny, 0.9);
    
    nx = map(nx, 0, 1, -1, 1);
    ny = map(ny, 0, 1, -1, 1);
    
    PVector velocity = new PVector(nx, ny);
    velocity.setMag(move_speed);
    
    position.add(velocity);
    noise_offset += noise_speed;
    
    if (position.x < -radius) position.x = width + radius;
    if (position.x > width + radius) position.x = -radius;
  
    if (position.y < -radius) position.y = height + radius;
    if (position.y > height + radius) position.y = -radius; 
  }
 
  public void render()
  {
    noStroke();
    fill(
      map(noise(noise_offset/5), 0.05, 0.80, 0 , 360),
      180,
      255, noise(noise_offset) * 50 + 50);
      
    float r = radius + (noise(noise_offset) * radius_random_scale) - radius_random_scale/2;
    ellipse(position.x, position.y, r, r); 
  }
}


ArrayList<smart_brush> brushes;
int N = 580;

void setup()
{
  size(1200, 1200);
  colorMode(HSB, 360, 100, 100, 100);
  background(0);

  brushes = new ArrayList<smart_brush>();

  for (int i = 0; i < N; i++)
  {
    PVector randomPos = new PVector(
      random(width),
      random(height)
    );
    
    float s = random(.5, 2);
    float ns = 0.01;
    float r = random(10,30);
    float rs = r / random(1.2,2);

    brushes.add(new smart_brush(
      randomPos,
      s,
      ns,
      r,
      rs
    ));
  }
  
  frameRate(240);
}

void draw()
{
  // background(0);
  for (smart_brush b : brushes)
  {
    b.tick();
    b.render();
  }
}
