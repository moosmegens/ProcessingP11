Camera3D cam;
CameraSettings camSettings;
Scene scene;
BoidSettings boidSettings;
BoidManager  boidManager;

void setup()
{ 
  size(800, 800, P3D);
  
  camSettings = new CameraSettings();
  camSettings.fov = 100;
  
  cam = new Camera3D(new PVector(0, 0, 0), camSettings);
  
  scene = new Scene(2500, 2500, 2500);
  
  boidSettings = new BoidSettings();
  
  boidSettings.maxSpeed = 3.0;
  boidSettings.maxForce = 0.04;
  
  boidSettings.perception = 128.0;
  
  boidSettings.sepWeight = 1.6;
  boidSettings.aliWeight = 1.6;
  boidSettings.cohWeight = 1.0;
  
  boidSettings.edgeMargin   = 100.0;
  boidSettings.edgeStrength = 0.4;
  
  camSettings.maxSpeed = boidSettings.maxSpeed;
  
  boidManager  = new BoidManager(scene, boidSettings, 20_000);
}

void draw()
{
  background(0);
  cam.update();
  ambientLight(200, 200, 200);

  boidManager.update();
  scene.draw();
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
  cam.keyReleased(key, keyCode); 
}
