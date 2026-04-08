class BoidManager
{
  ArrayList<Boid>       boids;
  ArrayList<Boid>[][][] chunks;
  Scene                 scene;
  BoidSettings          settings;

  int numX, numY, numZ;
  boolean showChunks = false;

  BoidManager(Scene scene, BoidSettings settings, int count)
  {
    this.scene    = scene;
    this.settings = settings;

    boids = new ArrayList<Boid>();
    for (int i = 0; i < count; i++)
      boids.add(new Boid(
        random(-scene.W, scene.W),
        random(-scene.H, scene.H),
        random(-scene.D, scene.D),
        settings
      ));

    fullRebuild();
  }

  public void fullRebuild()
  {
    numX = ceil((scene.W * 2) / settings.perception);
    numY = ceil((scene.H * 2) / settings.perception);
    numZ = ceil((scene.D * 2) / settings.perception);

    chunks = new ArrayList[numX][numY][numZ];
    for (int x = 0; x < numX; x++)
      for (int y = 0; y < numY; y++)
        for (int z = 0; z < numZ; z++)
          chunks[x][y][z] = new ArrayList<Boid>();
  }

  int chunkX(float x) { return constrain((int)((x + scene.W) / settings.perception), 0, numX-1); }
  int chunkY(float y) { return constrain((int)((y + scene.H) / settings.perception), 0, numY-1); }
  int chunkZ(float z) { return constrain((int)((z + scene.D) / settings.perception), 0, numZ-1); }

  void rebuildChunks()
  {
    for (int x = 0; x < numX; x++)
      for (int y = 0; y < numY; y++)
        for (int z = 0; z < numZ; z++)
          chunks[x][y][z].clear();

    for (Boid b : boids)
      chunks[chunkX(b.pos.x)][chunkY(b.pos.y)][chunkZ(b.pos.z)].add(b);
  }

  ArrayList<Boid> getNeighbors(Boid b)
  {
    ArrayList<Boid> result = new ArrayList<Boid>();
    int cx = chunkX(b.pos.x);
    int cy = chunkY(b.pos.y);
    int cz = chunkZ(b.pos.z);

    for (int dx = -1; dx <= 1; dx++)
    {
      int nx = cx + dx; if (nx < 0 || nx >= numX) continue;
      for (int dy = -1; dy <= 1; dy++)
      {
        int ny = cy + dy; if (ny < 0 || ny >= numY) continue;
        for (int dz = -1; dz <= 1; dz++)
        {
          int nz = cz + dz; if (nz < 0 || nz >= numZ) continue;
          result.addAll(chunks[nx][ny][nz]);
        }
      }
    }

    return result;
  }
  
  color chunkColor(int cx, int cy, int cz, int alpha)
  {
    float hue = (cx * 31 + cy * 17 + cz * 7) % 360;
    colorMode(HSB, 360, 100, 100, 100);
    color c = color(hue, 70, 60, alpha);
    colorMode(RGB, 255, 255, 255, 255);
    return c;
  }

  void update()
  {
    rebuildChunks();
    for (Boid b : boids)
    {
      b.avoidEdges(scene);
      b.flock(getNeighbors(b));
      b.update();
    }
  }
  
  void renderChunks()
  {
    float cW = scene.W * 2 / numX;
    float cH = scene.H * 2 / numY;
    float cD = scene.D * 2 / numZ;

    noFill();
    strokeWeight(0.5);

    for (int x = 0; x < numX; x++)
      for (int y = 0; y < numY; y++)
        for (int z = 0; z < numZ; z++)
        {
          if (chunks[x][y][z].isEmpty()) continue;

          float wx = -scene.W + cW * (x + 0.5);
          float wy = -scene.H + cH * (y + 0.5);
          float wz = -scene.D + cD * (z + 0.5);

          stroke(chunkColor(x, y, z, 60));
          pushMatrix();
          translate(wx, wy, wz);
          box(cW, cH, cD);
          popMatrix();
        }
  }

  void render()
  {
    if (showChunks) renderChunks();
    
    fill(180, 210, 255);
    noStroke();
    for (Boid b : boids)
      b.render();
  }

  void run()
  {
    update();
    render();
  }
}
