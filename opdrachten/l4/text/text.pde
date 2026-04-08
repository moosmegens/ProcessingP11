class letter
{ 
 private char c;
 private float lifetime;
 private float lifetime_left;
 private boolean dead = false;
 private PVector position;
 private float angle = 0;
 
 public letter(char c, float lifetime, PVector p, float a)
 {
  this.position = p;
  this.c = c;
  this.lifetime = lifetime;
  this.lifetime_left = this.lifetime;
  this.angle = a;
 }
 
 public void tick()
 {
  float deltaTime = 1.0 / frameRate;
  this.lifetime_left -= deltaTime;
  
  if (this.lifetime_left < 0) dead = true;
 }
 
 public void render()
 {
    if (dead) return;

    float alpha = map(lifetime_left, 0, lifetime, 0, 255);

    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);

    fill(255, alpha);
    textAlign(CENTER, CENTER);
    text(c, 0, 0);

    popMatrix();
 }
 
 public boolean is_dead()
 {
  return dead; 
 }
}

PVector mouse_pre;
PVector mouse_now;
PVector mouse_dir;
PVector last_letter = new PVector(-10000, -10000);

ArrayList<letter> letters = new ArrayList<letter>();

int last_spawn_time = 0;
int spawn_interval = 25;

String text = "HELLO WORLD! ";
int offset_text = 0;

int text_size = 40;

void setup()
{
  size(1200, 1200);
  mouse_pre = new PVector(mouseX, mouseY);
  textSize(text_size);
}

void mouse_stuff()
{
  mouse_now = new PVector(mouseX, mouseY);
  mouse_dir = PVector.sub(mouse_now, mouse_pre);
  
  if (mouse_dir.mag() > 0)
  {
    mouse_dir.normalize();
  }
  
  mouse_pre = mouse_now.copy();
}

void draw()
{
  mouse_stuff();
  background(30);

  if (mouse_dir.mag() > 0.01 && millis() - last_spawn_time >= spawn_interval && mousePressed == true && last_letter.dist(mouse_now) > text_size/2)
  {
    letters.add(new letter(text.charAt(offset_text), 4, mouse_now.copy(), mouse_dir.heading()));
    last_letter = mouse_now.copy();
    
    last_spawn_time = millis();
    offset_text++;
    offset_text %= text.length();
  }

  for (int i = letters.size() - 1; i >= 0; i--)
  {
    letter l = letters.get(i);
    l.tick();
    l.render();
  
    if (l.is_dead())
    {
      letters.remove(i);
    }
  }
}

void mousePressed()
{
  offset_text = 0;
}
