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

//Everthing comes from here, all the land and water, movement etc.


//single tile for starts, work on multi tile setup later on
class core{
  
  Matrix4 projectionMat;
  webgl.RenderingContext gl;
  
  var camera;
  
  //singletile to start with, but design it so easy to add more tiles
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
    
    containerClass = new List<object>();
    
    containerClass.add(new land(gl, 0, 0)); 
    containerClass[0].updateMesh(containerClass[0]);
    containerClass.add(new water(gl));  
    
    
    
  }
  
  logic(){
    camera.update();
  }
  
  draw(){
    Matrix4 viewMat = camera.getViewMat();
    
    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);

    containerClass[0].draw(viewMat, projectionMat);

    
  }
  
  
}