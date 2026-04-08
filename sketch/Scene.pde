class Scene
{
  float W, H, D;

  Scene(float w, float h, float d)
  {
    W = w; H = h; D = d;
  }

  PVector min() { return new PVector(-W, -H, -D); }
  PVector max() { return new PVector( W,  H,  D); }

  void draw()
  {
    pushStyle();
    noFill();
    stroke(255, 100);
    strokeWeight(1);
    PVector[] c = corners();

    edge(c[0], c[1]); edge(c[1], c[2]); edge(c[2], c[3]); edge(c[3], c[0]);

    edge(c[4], c[5]); edge(c[5], c[6]); edge(c[6], c[7]); edge(c[7], c[4]);

    edge(c[0], c[4]); edge(c[1], c[5]); edge(c[2], c[6]); edge(c[3], c[7]);
    popStyle();
  }

  private PVector[] corners()
  {
    return new PVector[]
    {
      new PVector(-W, -H, -D), new PVector( W, -H, -D),
      new PVector( W,  H, -D), new PVector(-W,  H, -D),
      new PVector(-W, -H,  D), new PVector( W, -H,  D),
      new PVector( W,  H,  D), new PVector(-W,  H,  D)
    };
  }

  private void edge(PVector a, PVector b)
  {
    line(a.x, a.y, a.z, b.x, b.y, b.z);
  }
}
