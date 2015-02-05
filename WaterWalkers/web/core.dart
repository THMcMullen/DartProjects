//Creates the various parts which make up the enviroment

library core;

//dart SDK files
import 'dart:html';
import 'dart:web_gl' as webgl;

//dart packages
import 'package:vector_math/vector_math.dart';

//own files
import 'object.dart';
import 'land.dart';
import 'water.dart';

import 'camera.dart' as cam;


class core{
  
  Matrix4 projectionMat;
  webgl.RenderingContext gl;
  
  var camera;
  
  bool tile = false;
  
  Vector3 oldPlayerPos = new Vector3.zero(); 
  
  Vector3 playerPos = new Vector3.zero();
  
  //stores all the objects which need to be rendered at any given time
  List<object> containerClass;
  
  //initialise the programs webgl, and start the core.
  core(webgl.RenderingContext givenGL, CanvasElement canvas){
    print("Core is starting up");
    
    gl = givenGL;
    
    camera = new cam.camera(canvas);
    
    projectionMat = makePerspectiveMatrix(45,(canvas.width/canvas.height), 1, 1000);
    setPerspectiveMatrix(projectionMat, 45,(canvas.width/canvas.height), 1.0, 1000.0);    
   
    gl.clearColor(0.5,0.5,0.5,1.0);
    gl.clearDepth(1.0);
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
    
  }
  
  //create the various parts of our enviroment
  setup(){
    
    containerClass = new List<object>();
    
    //First create the landscape
   /* for(int i = 0; i < 4; i++){
      for(int j = 0; j < 4; j++){
        containerClass.add(new land(gl, i, j));
        
        containerClass[0].updateMesh(containerClass[j+(i*4)]);
      }
    }*/
    
    containerClass.add(new land(gl, 0, 0));        
    containerClass[0].updateMesh(containerClass[0]);
    
    containerClass.add(new water(gl));
    
    //containerClass.add(new water(gl));

    
    //adds the mesh we have created to the master list stored in the object class
    //containerClass[0].updateMesh(containerClass[1]);
  }
  
  //chect our current possition, and see if we need to add another tile to the system
  updateGrid(Vector3 currentPos){
    int tempY = (currentPos[0]~/127);
    int tempX = (currentPos[2]~/127);
    
    tempX = tempX*-1;
    tempY = tempY*-1;
    
    int xp1 = tempX + 1;
    int xm1 = tempX - 1;
    int yp1 = tempY + 1;
    int ym1 = tempY - 1;
    
    bool above = false;
    bool below = false;
    bool left  = false;
    bool right = false;

    for(int i = 0; i < containerClass.length; i ++){

      if(containerClass[i].posx == tempY && containerClass[i].posy == xp1){
        //there is a existing tile above it so no need to create one
        above = true;
      }
      if(containerClass[i].posx == tempY && containerClass[i].posy == xm1){
        //there is a existing tile below it so no need to create one
        below = true;
      }
      if(containerClass[i].posx == yp1 && containerClass[i].posy == tempX){
        right = true;
      }
      if(containerClass[i].posx == ym1 && containerClass[i].posy == tempX){
        left = true;
      }
    }

    
    if(!above){
      containerClass.add(new land(gl, tempY, xp1));
      containerClass[0].updateMesh(containerClass.last);
      
    }
    if(!below){
      containerClass.add(new land(gl, tempY, xm1));
      containerClass[0].updateMesh(containerClass.last);
      
    }
    if(!right){
      containerClass.add(new land(gl, yp1, tempX));
      containerClass[0].updateMesh(containerClass.last);
      
    }
    if(!left){
      containerClass.add(new land(gl, ym1, tempX));
      containerClass[0].updateMesh(containerClass.last);
      
    }
  }
  
  update(){
    playerPos = camera.getCurrentXY();
    Vector3 temp =  camera.getCurrentXY();
    //print(temp[0]);
    //print(playerPos);
    //if we have moved more than 50 places then update the scene
    if(playerPos[0].abs() - oldPlayerPos[0].abs() > 127  ||
       playerPos[0].abs() - oldPlayerPos[0].abs() < -127 ||
       playerPos[2].abs() - oldPlayerPos[2].abs() > 127  ||
       playerPos[2].abs() - oldPlayerPos[2].abs() < -127){
      
      
      oldPlayerPos[0] = playerPos[0];
      oldPlayerPos[2] = playerPos[2];
      
      //based on player possition, create a new gird peace
      //updateGrid(playerPos);
      
    }
    
    camera.updateDirection(0.0);
    camera.update();
    for(int i = 0; i < containerClass.length; i++){
      containerClass[i].update();
    }
  }
  
  draw(locX, locY){
    
    //gets our current view matrix
    
    Matrix4 viewMat = camera.getViewMat();
    
    //add some movement

    //camera.updatePos(locX, locY, 0.0);
    
    
    
    //clears data        
    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
    
    for(int i = 0; i < containerClass.length; i++){
      containerClass[i].draw(viewMat, projectionMat);
    }
  }
  
  
  
}


































