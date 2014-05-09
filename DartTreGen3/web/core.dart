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

import 'camera.dart' as cam;


class core{
  
  Matrix4 projectionMat;
  webgl.RenderingContext gl;
  
  var camera;
  
  bool tile = false;
  
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
    for(int i = 0; i < 4; i++){
      for(int j = 0; j < 4; j++){
        containerClass.add(new land(gl, i, j));
        
        containerClass[0].updateMesh(containerClass[j+(i*4)]);
      }
    }
    
    //containerClass.add(new water(gl));
    //containerClass.add(new water(gl));

    
    //adds the mesh we have created to the master list stored in the object class
    //containerClass[0].updateMesh(containerClass[1]);
  }
  
  update(){
    playerPos = camera.getCurrentXY();
    Vector3 temp =  camera.getCurrentXY();
    //print(temp[0]);
    
    
    
    if(temp[0] < -50.0){
      for(int i = 0; i < containerClass.length; i++){
        if(containerClass[i].posx == 5 && containerClass[i].posy == 1){
          //so the tile we want does exist
          //print("need to create");
          tile = true;
          
        }
      }
      if(!tile){
        print("adding tile");
        containerClass.add(new land(gl, 1, 5));
        containerClass[0].updateMesh(containerClass.last);
        print(containerClass[0].meshLength());
        print(containerClass.length);
        print(containerClass.last.posy);
        //tile = false;
      }
      
    }
    
    camera.updateDirection(0.0);
    camera.update();
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


































