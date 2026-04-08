Camera3D cam;
CameraSettings camSettings;
Scene scene;
BoidSettings boidSettings;
BoidManager  boidManager;

void setup()
{
  size(800, 800, P3D);
  
  camSettings = new CameraSettings();
  camSettings.fov = 110;
  
  cam = new Camera3D(new PVector(0, 0, 0), camSettings);
  
  scene = new Scene(2000, 2000, 2000);
  
  boidSettings = new BoidSettings();
  
  boidSettings.maxSpeed = 3.0;
  boidSettings.maxForce = 0.08;
  
  boidSettings.perception = 100.0;
  
  boidSettings.sepWeight = 1.6;
  boidSettings.aliWeight = 1.0;
  boidSettings.cohWeight = 1.0;
  
  boidSettings.edgeMargin   = 200.0;
  boidSettings.edgeStrength = 0.2;
  
  boidManager  = new BoidManager(scene, boidSettings, 8000);
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
}

void keyPressed()  { cam.keyPressed(key, keyCode); }
void keyReleased() 
{
  if (key == 'c') boidManager.showChunks = !boidManager.showChunks;
  cam.keyReleased(key, keyCode); 
}
