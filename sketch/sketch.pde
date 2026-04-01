Camera3D cam;
CameraSettings camSettings;

void setup()
{
  size(800, 800, P3D);
  camSettings = new CameraSettings();
  cam = new Camera3D(new PVector(0, 0, 0), camSettings);
  camSettings.fov = 110;
}

public int hash(int x, int y, int z) {
    int h = 0x811c9dc5;

    h ^= x;
    h *= 0x01000193;
    h ^= y;
    h *= 0x01000193;
    h ^= z;
    h *= 0x01000193;

    h ^= (h >>> 16);
    h ^= (h << 3);
    h ^= (h >>> 4);
    h ^= (h << 7);
    h ^= (h >>> 12);

    return h;
}

void draw()
{
  background(0);

  cam.update();

  lights();

  stroke(255);
  strokeWeight(2.0);
  noFill();
  
  int boxsize = 1000;
  int numCubesPerSide = 4;
  int smallerboxsize = boxsize / numCubesPerSide;
  
  background(0);
  ambientLight(200,200,200);
  
  translate(width/2, height/2, -500);
  
  pushMatrix();
  noFill();
  box(boxsize);
  popMatrix();

  
  pushMatrix();
  translate(-boxsize/2 + smallerboxsize/2, -boxsize/2 + smallerboxsize/2, -boxsize/2 + smallerboxsize/2);
  
  strokeWeight(1);
  
  for (int x = 0; x < numCubesPerSide; x++) {
    for (int y = 0; y < numCubesPerSide; y++) {
      for (int z = 0; z < numCubesPerSide; z++) {
        pushMatrix();
        translate(x * smallerboxsize, y * smallerboxsize, z * smallerboxsize);
        int c1 = hash(x,y,z) % 128 + 128;
        int c2 = hash(x * 3,y * 4,z * 2) % 128 + 128;
        int c3 = hash(x * 12,y * 8,z * 10) % 128 + 128;
        stroke(40);
        noFill();
        box(smallerboxsize);
        popMatrix();
      }
    }
  }
  
  popMatrix();
  
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
