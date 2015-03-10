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
import 'blob.dart';

import 'camera.dart' as cam;

class core{
  
  Matrix4 projectionMat;
  webgl.RenderingContext gl;
    
  var camera;
  
  //stores all the objects which need to be rendered at any given time
  List<object> containerClass;
  
  core(webgl.RenderingContext givenGL, CanvasElement canvas){
    
    gl = givenGL;
    
    camera = new cam.camera(canvas);
    
    projectionMat = makePerspectiveMatrix(45,(canvas.width/canvas.height), 1, 1000);
    setPerspectiveMatrix(projectionMat, 45,(canvas.width/canvas.height), 1.0, 1000.0);    
   
    gl.clearColor(0.5,0.5,0.5,1.0);
    gl.clearDepth(1.0);
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
    
  }
  
  setup(){
    containerClass = new List<object>();
    containerClass.add(new land(gl));
    containerClass[0].updateMesh(containerClass[0]);
    containerClass.add(new blob(gl));
  }
  
  update(){
    camera.update();
    containerClass[1].update(); 
    List<Gamepad> gamepads = window.navigator.getGamepads();
    for(Gamepad gamepad in gamepads) {
      if(gamepad != null) {
        camera.gamepaddata(gamepad);
      }
    }
  }
  
  draw(){
    Matrix4 viewMat = camera.getViewMat();
    
    //clears data        
    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
    
    for(int i = 0; i < containerClass.length; i++){
      containerClass[i].draw(viewMat, projectionMat);
    }
    
  }
  
}