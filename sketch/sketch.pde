Camera3D cam;
CameraSettings camSettings;

void setup()
{
  size(800, 800, P3D);
  camSettings = new CameraSettings();
  cam = new Camera3D(new PVector(0, 0, 0), camSettings);
  camSettings.fov = 110;
}

void draw()
{
  background(0);

  cam.update();

  lights();

  stroke(255);
  noFill();
  box(600);
  
  cam.drawCrosshair();
}

void keyPressed()
{
  cam.keyPressed(key, keyCode);
}

void keyReleased()
{
  cam.keyReleased(key, keyCode);
}
