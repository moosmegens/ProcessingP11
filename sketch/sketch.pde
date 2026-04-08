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
  scene = new Scene(500, 500, 500);
  boidSettings = new BoidSettings();
  boidManager  = new BoidManager(scene, boidSettings, 1000);
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
