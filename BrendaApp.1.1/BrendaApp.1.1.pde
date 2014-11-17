import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import java.awt.AWTException;
import java.awt.Robot;
 import toxi.geom.*;
import toxi.geom.mesh2d.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.util.datatypes.*;
import toxi.processing.*;
 
 boolean showBackground=true;
 float facePosX=0.0f;
 float facePosY=0.0f;
ArrayList <BreakCircle> circles = new ArrayList <BreakCircle> ();

VerletPhysics2D physics;
ToxiclibsSupport gfx;
FloatRange radius;
Vec2D mouse;
 
int maxCircles = 3; // maximum amount of circles on the screen
int numPoints = 50;  // number of voronoi points / segments
int minSpeed = 2;    // minimum speed of a voronoi segment
int maxSpeed = 14;   // maximum speed of a voronoi segment
 
Capture video;
OpenCV opencv;
 
 float SCALE = 4.0;
 
 int score=0;
 PFont font;
 
 float facePosScaleX = 0.0f;
 float facePosScaleY = 0.0f;
void setup() {
  size(800, 600);
  
  video = new Capture(this, 640/(int)SCALE, 480/(int)SCALE);         // open video stream
  opencv = new OpenCV(this, 640/(int)SCALE, 480/(int)SCALE);
  
  facePosScaleX = (float)width / 640.0f;
  facePosScaleY = (float)height / 480.0f;
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  // load detection 
 font = createFont("Helvetica",24);
  video.start();
          
frameRate(50);  
 smooth();
  frameRate(30); //////
  noStroke();
  gfx = new ToxiclibsSupport(this);
  physics = new VerletPhysics2D();
  physics.setDrag(0.05f);
  physics.setWorldBounds(new Rect(0,0,width,height));
  radius = new BiasedFloatRange(30, 100, 30, 0.6f);
  
  reset();
  textFont(font,20);
}
 
void draw() 
{
  background(0);
  frame.setTitle("framerate: " + frameRate);
  //scale(2);
  opencv.loadImage(video);
  pushMatrix();
scale(-1,1);
  if(showBackground)
   image(video,-width,0,width,height);
   popMatrix();
  removeAddCircles();

  physics.update();
 
 noStroke();
 fill(255);
  mouse = new Vec2D(facePosX,facePosY);
  for (BreakCircle bc : circles) {
    bc.run();
  }
 
  noFill();
  stroke(0, 255, 0);
  strokeWeight(1);
  Rectangle[] faces = opencv.detect();
 
 rectMode(CENTER);
  for (int i = 0; i < faces.length; i++) {
    facePosX = (320+(320-faces[i].x * SCALE + faces[i].width * SCALE*0.0)) * facePosScaleX;
    facePosY = (faces[i].y * SCALE + faces[i].height * SCALE*0.5 )* facePosScaleY;
    
    
  }
  rect(facePosX, facePosY,25,25); 
  
  fill(255);
  text("Score: " + score, 20,30);
}
 
void captureEvent(Capture c) {
  c.read();
}


void removeAddCircles() {
  for (int i=circles.size()-1; i>=0; i--) {
    // if a circle is invisible, remove it...
    if (circles.get(i).transparency < 0) {
      circles.remove(i);
      // and add two new circles (if there are less than maxCircles)
      if (circles.size() < maxCircles) {
        circles.add(new BreakCircle(new Vec2D(width/2 +random(-100,100),height/2 +random(-100,100)),radius.pickRandom()));
        circles.add(new BreakCircle(new Vec2D(width/2 +random(-100,100),height/2+random(-100,100)) ,radius.pickRandom()));
      }
    }
  }
}
 
void keyPressed() {
  if (key == ' ') 
      reset(); 
  if(key=='b')
    showBackground=!showBackground;
}
 
void reset() {
  score=0;
  // remove all physics elements
  for (BreakCircle bc : circles) {
    physics.removeParticle(bc.vp);
    physics.removeBehavior(bc.abh);
  }
  // remove all circles
  circles.clear();
  // add one circle of radius 50 at the origin
  circles.add(new BreakCircle(new Vec2D(width/2 +random(-100,100),height/2 +random(-100,100)),50));
}
