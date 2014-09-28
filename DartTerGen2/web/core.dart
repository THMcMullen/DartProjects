//acts as the core of the program where evertyhing meets,
//everything begins here and is passed through here.

//nexus

library core;

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'camera.dart' as cam;
import 'utils.dart' as utils;
import 'waterGen.dart' as water;
import 'package:vector_math/vector_math.dart';

class core{ 
  
  Matrix4 projectionMat;
  
  webgl.RenderingContext gl;
  
  var camera;
  
  var worldWater;
  
  //initialise the programs webgl, and start the core.
  core(webgl.RenderingContext givenGL, CanvasElement canvas){
    
    print("Core Has Started");
    
    gl = givenGL;
    
    camera = new cam.camera(canvas);
    
    projectionMat = makePerspectiveMatrix(45,(canvas.width/canvas.height), 1, 1000);
    setPerspectiveMatrix(projectionMat, 45,(canvas.width/canvas.height), 1.0, 1000.0);    
    
    gl.clearColor(0.5,0.5,0.5,1.0);
    gl.clearDepth(1.0);
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
    
    createWorld();

    
  }
  
  //create the landscape
  createWorld(){
    

    
    worldWater = new water.water(gl);
    

  }
  
  //drawing a scene
  draw(){

    Matrix4 viewMat = camera.getViewMat();
    
    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
    
    //var date = new DateTime.now().millisecondsSinceEpoch;
    
    worldWater.draw(viewMat, projectionMat);
    
    //var finaldate = new DateTime.now().millisecondsSinceEpoch;
    
    //print(finaldate - date);
    
  }
  
  //updating a scene or part of the world
  update(){
    //print("h");
    
    worldWater.waterUpdate();
  }
  
}
