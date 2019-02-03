class Entity{  
  public PVector Position = new PVector();
  public PVector Velocity = new PVector();
  public PVector Acceleration = new PVector();

  public PVector Target = new PVector(random(0,width-10),random(0,height-10));
  public ArrayList<PVector> obs = new ArrayList<PVector>();
  
  public float MaxSpeed = 5;
  public float SpreadDistance = 10;
  public float MouseDistance = 100;
  
  public boolean Leader = false;
  
  public Entity(PVector pos){
    this.Position = pos; 
  }
  
  public void Draw(){
    ellipse(Position.x,Position.y,20,20);
  }
  
  public void Update(){
    Acceleration = new PVector();
        
    if(!Leader) handleEntity(); else handleLeader();      
    
    handleMovement();
  }
  
  public PVector ToLeader(){
    Target = entities.get(0).Position;
    
    PVector vel = new PVector( Target.x-Position.x, Target.y-Position.y );
    vel.normalize();
    
    return vel;
  }
  
  public PVector AvoidObstacles(){
    PVector vel = new PVector();
    
    for(int i = 0; i < obs.size(); i++){
      float dist = PVector.dist(Position,obs.get(i));  
      
      if(dist <= MouseDistance){
        PVector dir = new PVector( Position.x-obs.get(i).x, Position.y-obs.get(i).y); 
        dir.normalize();
        dir.mult(5);
        
        vel.add(dir);
        
        entities.get(0).Redirect(obs.get(i));
      }
    }
        
    return vel;
  }
  
  public void AddObstacle(PVector pos){
    obs.add(pos);
  }
  
  public PVector Spread(){
    PVector dir = new PVector();
    
    for(int i = 0; i < entities.size(); i++){
      Entity e = entities.get(i);
      float Distance = PVector.dist(Position,e.Position);
      
      if(Distance < SpreadDistance){
        PVector v = new PVector( Position.x-e.Position.x, Position.y-e.Position.y );
        v.normalize();
        
        dir.add(v);
      }
    }    
        
    return dir;
  }
  
  public void Redirect(PVector pos){
    float xx = 0;
    float yy = 0;
    float x0 = 0;
    float y0 = 0;
    
    if(pos.x > Position.x){
      x0 = 0;
      xx = pos.x;
    } else {
      x0 = pos.x;
      xx = 640;
    }
    
    if(pos.y > Position.y){
      y0 = 0;
      yy = pos.y;
    } else {
      y0 = pos.y;
      yy = 480;
    }
    
    Target = new PVector(random(x0,xx),random(y0,yy));
  }
  
  public void handleEntity(){
    PVector fin = new PVector();
    
    fin.add(ToLeader());
    fin.add(Spread());           
    //fin.add(AvoidObstacles());

    fin.normalize();
    
    Acceleration =  PVector.lerp(Acceleration,fin,0.2);
    
    obs.clear();
  }
  
  public void handleLeader(){
    PVector vel = new PVector( Target.x-Position.x, Target.y-Position.y );
    vel.normalize();
    
    Acceleration = vel;
    
    if(PVector.dist(Position,Target) <=40){
      Target = new PVector(random(0,width-10),random(0,height-10));
    }
    
  }
  
  public void handleMovement(){
    Velocity.add(Acceleration);
    
    Velocity.setMag(constrain(Velocity.mag(),0,MaxSpeed));
    
    Position.add(Velocity);
  }
}
