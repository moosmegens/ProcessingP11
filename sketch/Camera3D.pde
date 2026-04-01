import java.awt.Robot;
import java.awt.MouseInfo;
import com.jogamp.newt.opengl.GLWindow;

class CameraSettings
{
  float fov = 80;
  float speed = 0.6;
  float maxSpeed = 8;
  float friction = 0.85;
  float sensitivity = 0.002;
  float sprintSpeedMult = 10;
  
  char forward = 'w';
  char left = 'a';
  char backwards = 's';
  char right = 'd';
  char up = ' ';
  char down = 'q';
  char sprint = 'x';
  char lock = 'e';
}

class Camera3D
{
  PVector pos, vel;
  float yaw = 0;
  float pitch = 0;
  
  CameraSettings settings = null;
  
  boolean locked = false;
  boolean forward, back, left, right, up, down, sprint;
  Robot robot;
  GLWindow glWindow;

  Camera3D(PVector startPos, CameraSettings settings)
  {
    this.settings = settings;
    pos = startPos.copy();
    vel = new PVector();
    try { robot = new Robot(); }
    catch (Exception e) { println("Robot failed: " + e); }
    glWindow = (GLWindow) surface.getNative();
  }

  int[] screenCenter()
  {
    int wx = glWindow.getX();
    int wy = glWindow.getY();
    return new int[]{ wx + width/2, wy + height/2 };
  }

  void toggleLock()
  {
    locked = !locked;
    if (locked)
    {
      noCursor();
      warpToCenter();
    } else
    {
      cursor();
    }
  }
  
  CameraSettings settings()
  {
    return settings;
  }

  void warpToCenter()
  {
    if (robot == null) return;
    int[] c = screenCenter();
    robot.mouseMove(c[0], c[1]);
  }

  void updateMouse()
  {
    if (!locked || robot == null) return;
    int[] c = screenCenter();
    java.awt.Point p = MouseInfo.getPointerInfo().getLocation();
    float dx = p.x - c[0];
    float dy = p.y - c[1];
    yaw   -= dx * settings.sensitivity;
    pitch += dy * settings.sensitivity;
    pitch = constrain(pitch, -PI/2, PI/2);
    robot.mouseMove(c[0], c[1]);
  }

  void updateMovement()
  {
    float currentSpeed = sprint ? settings.speed * settings.sprintSpeedMult : settings.speed;
    PVector acc = new PVector();
    PVector f = forward();
    PVector r = right();
    if (forward) acc.add(f);
    if (back)    acc.sub(f);
    if (right)   acc.add(r);
    if (left)    acc.sub(r);
    if (up)      acc.y -= 1;
    if (down)    acc.y += 1;
    
    if (acc.mag() > 0)
    {
      acc.normalize().mult(currentSpeed);
      vel.add(acc);
    }
    
    vel.limit(sprint ? settings.maxSpeed * settings.sprintSpeedMult : settings.maxSpeed);
    
    vel.mult(settings.friction);
    pos.add(vel);
  }
  
  PVector forward()
  {
    return new PVector(
      cos(pitch) * sin(yaw),
      sin(pitch),
      cos(pitch) * cos(yaw)
    );
  }

  PVector right()
  {
    return new PVector(
      sin(yaw - HALF_PI),
      0,
      cos(yaw - HALF_PI)
    );
  }

  void apply()
  {
    PVector center = PVector.add(pos, forward());
    float cameraZ = (height/2.0) / tan(radians(settings.fov)/2.0);
    perspective(radians(settings.fov), float(width)/float(height), cameraZ/50.0, cameraZ*10.0);
    camera(pos.x, pos.y, pos.z, center.x, center.y, center.z, 0, 1, 0);
  }

  void update()
  {
    updateMouse();
    updateMovement();
    apply();
  }
  
  void drawCrosshair() { drawCrosshair(true); }
  
  void drawCrosshair(boolean onlyLock)
  {
    if (onlyLock && !locked) return;
    
    pushMatrix();
    pushStyle();
    
    hint(DISABLE_DEPTH_TEST);
    
    camera();
    ortho();
  
    stroke(255);
    strokeWeight(2);
    
    float size = 10;
    line(width/2 - size, height/2, width/2 + size, height/2);
    line(width/2, height/2 - size, width/2, height/2 + size);
  
    popStyle();
    popMatrix();
    
    hint(ENABLE_DEPTH_TEST);
  }

  void keyPressed(char k, int kc)
  {
    if (k == settings.forward) forward = true;
    if (k == settings.backwards) back = true;
    if (k == settings.left) left = true;
    if (k == settings.right) right = true;
    if (k == settings.up) up = true;
    if (k == settings.down) down = true;
    if (k == settings.sprint) sprint = true;
    
    if (k == settings.lock) toggleLock();
  }

  void keyReleased(char k, int kc)
  {
    if (k == settings.forward) forward = false;
    if (k == settings.backwards) back = false;
    if (k == settings.left) left = false;
    if (k == settings.right) right = false;
    if (k == settings.up) up = false;
    if (k == settings.down) down = false;
    if (k == settings.sprint) sprint = false;
  }
}
