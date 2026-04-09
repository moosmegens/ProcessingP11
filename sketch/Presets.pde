static class presets 
{
  static void ApplyNormalSpeeds(BoidSettings s)
  {
    s.maxSpeed = 3.0;
    s.maxForce = 0.04;
  }
  
  
  static void ApplyPerfect(BoidSettings s) 
  {
      
    s.perception = 100;
  
    s.sepAngle = s.angleToDot(120);
    s.aliAngle = s.angleToDot(180);
    s.cohAngle = s.angleToDot(120);
    
    s.sepRadius = 0.8;
    
    s.sepWeight = 1.6;
    s.aliWeight = 1.4;
    s.cohWeight = 1.0;
  }
    
  static void ApplyChaos(BoidSettings s) 
  {
      
    s.perception = 40;
  
    s.sepAngle = s.angleToDot(180);
    s.aliAngle = s.angleToDot(140);
    s.cohAngle = s.angleToDot(80);
    
    s.sepRadius = 1;
    
    s.sepWeight = 1.6;
    s.aliWeight = 1.6;
    s.cohWeight = 1.0;
  }
}
