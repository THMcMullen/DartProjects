//handles the creation of the landscape
  // - generates vertices, with a range of z values, to produce a dinamic landscape
  // - create a mesh class which contains several submeshs with join together to create the final landscape

//when the landscape class is first created...
  // - setup the camera class, so we can view the object
  // - set the gl context to a state which we can easily use
  // - begin creating the master mesh class
    // - create submeshs based on various bits of information given from the simulation

//when we go to draw the scene, loop through all the submeshs, and draw them,
  // - no need to update any gl varibles or settings



import 'dart:html';
import 'dart:web_gl' as webgl;
import 'package:vector_math/vector_math.dart';
import 'land_gen.dart' as landGen;
import 'camera.dart' as cam;


class landscape{
  
  Matrix4 projectionMat;
  
  var camera;
  var masterMesh;
  
  landscape(webgl.RenderingContext gl, CanvasElement canvas, String vert, String frag){
    print("new landscape is being generated");
    
    camera = new cam.camera(canvas);
    
    
    
    
    
    
    //set up how we view the scene
    projectionMat = makePerspectiveMatrix(45, (canvas.width/canvas.height), 1, 1000);
    setPerspectiveMatrix(projectionMat, 45 ,(canvas.width/canvas.height),1.0, 1000.0);
    
    //Clear the color to the one we want for the backgraound, as well as the depth buffer
    gl.clearColor(0.62,0.62,0.62,1.0);
    gl.clearDepth(1.0);
    //Enable depth testing to help reduce clipping and stop having one object apper above anohter
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
    
    masterMesh = new landGen.landgen(3, gl, vert, frag);

    
    
  }
  
  void draw(webgl.RenderingContext gl){
    //print("im drawing a loop");
   
    Matrix4 viewMat = camera.getViewMat();
    //print(viewMat);
    
    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
        
    masterMesh.drawMesh(viewMat, projectionMat);
  }
}