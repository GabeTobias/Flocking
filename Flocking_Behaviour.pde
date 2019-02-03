import SimpleOpenNI.*;

SimpleOpenNI  context;

PShader blur;

PGraphics FlockBuffer;
PGraphics SkeletonBuffer;

PVector pos = new PVector();
PVector pos2D = new PVector();
PVector hand = new PVector();

int ScreenScale = 2;
int[] userList;

ArrayList<Entity> entities = new ArrayList<Entity>();
ArrayList<PVector> limbs = new ArrayList<PVector>();

void setup(){
  size(640*ScreenScale,480*ScreenScale, P2D);
  
  FlockBuffer = createGraphics(640*ScreenScale,480*ScreenScale,P2D);
  SkeletonBuffer = createGraphics(640*ScreenScale,480*ScreenScale,P2D);
  
  InitOpenNI();
  InitBirds();
  
  context.setMirror(false);
  
  userList = context.getUsers();
  
  blur = loadShader("blur_sep.glsl"); 
  blur.set("blurSize", 20);
  blur.set("sigma", 5.0f);  
  
  colorMode(HSB);
  
  noStroke();
}

void InitOpenNI(){
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
}

void InitBirds(){
  for(int i = 0; i < 500; i++){
    entities.add(new Entity(new PVector(random(0,width-10),random(0,height-10))));
  }
  
  entities.get(0).Leader = true;
}

void RenderBirds(){
  for(int i = 0; i < entities.size(); i++){
    AddOps(entities.get(i));
    
    entities.get(i).Update();
    
    fill(70);
    
    if(i != 0) entities.get(i).Draw();
  }
}

void UpdateSkeletons(){
  // update the cam
  context.update();
}

void AddOps(Entity e){
    for(int i = 0; i < limbs.size(); i++){
      e.AddObstacle(limbs.get(i));
    }
}

void RenderOps(){
  limbs.clear();
  
  // draw the skeleton if it's available
  for(int i=0;i<userList.length;i++)
  {
      DrawLimb(userList[i],SimpleOpenNI.SKEL_LEFT_HAND);
      DrawLimb(userList[i],SimpleOpenNI.SKEL_RIGHT_HAND);

      fill(100);

      context.getCoM(userList[i],pos);
      context.convertRealWorldToProjective(pos,pos2D);
      
      pos2D = new PVector(640-pos2D.x,pos2D.y);
      
      ellipse(pos2D.x*ScreenScale,pos2D.y*ScreenScale+100,80,250);
      
      context.getJointPositionSkeleton(userList[i],SimpleOpenNI.SKEL_NECK,pos);
      context.convertRealWorldToProjective(pos,pos2D);
      
      pos2D = new PVector(640-pos2D.x,pos2D.y, pos2D.z);
      
      ellipse(pos2D.x*ScreenScale,pos2D.y*ScreenScale,100,100);
  }
}

void DrawLimb(int user, int limb){
  context.getJointPositionSkeleton(user,limb,pos);
  context.convertRealWorldToProjective(pos,pos2D);
  
  pos2D = new PVector(640-pos2D.x,pos2D.y);
  
  limbs.add(new PVector(pos2D.x*ScreenScale,pos2D.y*ScreenScale));
  
  fill(0);
  ellipse(pos2D.x*ScreenScale,pos2D.y*ScreenScale,40,40);
}

void draw(){
  background(250); 
  
  UpdateSkeletons();  

  fill(255,100);
  rect(0,0,width,height);
  RenderOps();
  color(0);
  text(int(frameRate), 10,20);

  noStroke();
  fill(255,1);
  rect(0,0,width,height);
  RenderBirds();
}

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  userList = context.getUsers();
    
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  userList = context.getUsers();
  
}
