import java.util.concurrent.*;

class BoidManager
{
  ArrayList<Boid>       boids;
  ArrayList<Boid>[][][] chunks;
  Scene                 scene;
  BoidSettings          settings;
  

  int numX, numY, numZ;
  boolean showChunks = false;
  
  ArrayList<ArrayList<Boid>> usedChunks;

  ExecutorService pool;
  int threadCount;

  BoidManager(Scene scene, BoidSettings settings, int count)
  {
    this.threadCount = Runtime.getRuntime().availableProcessors();
    this.pool        = Executors.newFixedThreadPool(threadCount);
    
    this.scene    = scene;
    this.settings = settings;
    
    boids = new ArrayList<Boid>(count);
    usedChunks = new ArrayList<>();

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

    int avg = max(16, boids.size() / max(1, numX * numY * numZ));

    for (int x = 0; x < numX; x++)
      for (int y = 0; y < numY; y++)
        for (int z = 0; z < numZ; z++)
          chunks[x][y][z] = new ArrayList<Boid>(avg);
  }

  int chunkX(float x) { return constrain((int)((x + scene.W) / settings.perception), 0, numX-1); }
  int chunkY(float y) { return constrain((int)((y + scene.H) / settings.perception), 0, numY-1); }
  int chunkZ(float z) { return constrain((int)((z + scene.D) / settings.perception), 0, numZ-1); }

  void rebuildChunks()
  {
    for (ArrayList<Boid> cell : usedChunks)
      cell.clear();
      
    usedChunks.clear();

    for (Boid b : boids)
    {
      int cx = chunkX(b.pos.x);
      int cy = chunkY(b.pos.y);
      int cz = chunkZ(b.pos.z);

      ArrayList<Boid> cell = chunks[cx][cy][cz];

      if (cell.isEmpty()) usedChunks.add(cell);

      cell.add(b);
    }
  }

  void getNeighbors(Boid b, ArrayList<Boid> buffer)
  {
    buffer.clear();
    for (int dx = -1; dx <= 1; dx++)
    {
      int nx = chunkX(b.pos.x) + dx;
      if (nx < 0 || nx >= numX) continue;
      for (int dy = -1; dy <= 1; dy++)
      {
        int ny = chunkY(b.pos.y) + dy;
        if (ny < 0 || ny >= numY) continue;
        for (int dz = -1; dz <= 1; dz++)
        {
          int nz = chunkZ(b.pos.z) + dz;
          if (nz < 0 || nz >= numZ) continue;
          ArrayList<Boid> cell = chunks[nx][ny][nz];
          if (!cell.isEmpty())
            for (int i = 0; i < cell.size(); i++) buffer.add(cell.get(i));
        }
      }
    }
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

    int batchSize = max(1, boids.size() / threadCount);
    ArrayList<Future<?>> futures = new ArrayList<>();

    for (int t = 0; t < threadCount; t++)
    {
      int start = t * batchSize;
      int end   = (t == threadCount - 1) ? boids.size() : start + batchSize;

      futures.add(pool.submit(() ->
      {
        ArrayList<Boid> localBuffer = new ArrayList<>(256);
        for (int i = start; i < end; i++)
        {
          Boid b = boids.get(i);
          b.avoidEdges(scene);
          getNeighbors(b, localBuffer);
          b.flock(localBuffer);
        }
      }));
    }

    for (Future<?> f : futures)
    {
      try { f.get(); }
      catch (Exception e) { e.printStackTrace(); }
    }
    

    for (Boid b : boids) b.update();
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
