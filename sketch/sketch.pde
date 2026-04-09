Camera3D cam;
CameraSettings camSettings;
Scene scene;
BoidSettings boidSettings;
BoidManager  boidManager;

boolean bg = true;
boolean c = true;

void setup()
{ 
  fullScreen(P3D);
  
  camSettings = new CameraSettings();
  
  camSettings.fov = 100;
  camSettings.speed = 5;
  camSettings.maxSpeed = 20;
  camSettings.friction = 0.85;

  boidSettings = new BoidSettings();
  presets.ApplyNormalSpeeds(boidSettings);
  presets.ApplyChaos(boidSettings);
  
  boidSettings.startCohBrightness = 0; boidSettings.endCohBrightness = 100;
  
  boidSettings.edgeMargin   = 100.0; boidSettings.edgeStrength = 0.4;
  
  cam = new Camera3D(new PVector(0, 0, 0), camSettings);
  float s = 500;
  scene = new Scene(s, s, s);
  boidManager  = new BoidManager(scene, boidSettings, 2_000);
}

void draw()
{
  if (bg) background(0);
  cam.update();

  boidManager.update();
  
  if (c) scene.draw();
  boidManager.render();

  cam.drawCrosshair();
  
  println(frameRate);
}

void mouseWheel(MouseEvent event)
{
  camSettings.fov += event.getCount() * 4;
  camSettings.fov = constrain(camSettings.fov, 1.0, 140.0);
}

void keyPressed()  { cam.keyPressed(key, keyCode); }
void keyReleased() 
{
  if (key == 'c') boidManager.showChunks = !boidManager.showChunks;
  
  if (key == 'b') bg = !bg;
  
  if (key == 'C') c = !c;
  
  if (key == 'T')
  {
    boidManager.selectNone();
  }
  else if (key == 't')
  {
    boidManager.selectClosest(cam.pos, 512);
  }
  
  if (key == 'L') boidManager.selectClosest(cam.pos, 1000000);
  
  cam.keyReleased(key, keyCode); 
}
