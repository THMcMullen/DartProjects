library dart_matter;

//dart SDK files
import 'dart:html';
import 'dart:web_gl' as webgl;

//dart packages
import 'package:vector_math/vector_math.dart';

import 'camera.dart' as cam;

import 'land.dart';



class dart_matter{
  
  Matrix4 projectionMat;
  webgl.RenderingContext gl;   
  var camera;
  
  int gridSize = 10;
  int baseRes = 129;
  
  List landCon;
  
  dart_matter(webgl.RenderingContext givenGL, CanvasElement canvas){
    
    gl = givenGL;
            
    camera = new cam.camera(canvas);
      
    projectionMat = makePerspectiveMatrix(45,(canvas.width/canvas.height), 1, 1000);
    setPerspectiveMatrix(projectionMat, 45,(canvas.width/canvas.height), 1.0, 1000.0);    
     
    gl.clearColor(0.5,0.5,0.5,1.0);
    gl.clearDepth(1.0);
    gl.enable(webgl.RenderingContext.DEPTH_TEST);
    
    //create a 10x10 2d array for containing the grids
    //work on smaller maps to start, 
    landCon = new List(gridSize);
    
    for(int i = 0; i < landCon.length; i++){
      landCon[i] = new List<land>(10);
      for(int j = 0; j < landCon[i].length; j++){
        landCon[i][j] = null;
 
      }
    }
    
    landCon[5][5] = new land(gl, 5, 5, baseRes);
    landCon[5][6] = new land(gl, 5, 6, baseRes);
    landCon[5][4] = new land(gl, 5, 4, baseRes);
    landCon[6][5] = new land(gl, 6, 5, baseRes);
    landCon[4][5] = new land(gl, 4, 5, baseRes);
    landCon[4][4] = new land(gl, 4, 4, (baseRes+1)~/2);
    landCon[6][4] = new land(gl, 6, 4, (baseRes+1)~/2);
    landCon[6][6] = new land(gl, 6, 6, (baseRes+1)~/2);
    landCon[4][6] = new land(gl, 4, 6, (baseRes+1)~/2);
    landCon[3][5] = new land(gl, 3, 5, (baseRes+1)~/2);
    landCon[7][5] = new land(gl, 7, 5, (baseRes+1)~/2);
    landCon[5][7] = new land(gl, 5, 7, (baseRes+1)~/2);
    landCon[5][3] = new land(gl, 5, 3, (baseRes+1)~/2);

  }
  
  
  //initialises the word by creating the first series of land, and from that create water and trees
  //test layout
  //
  // 000/000/032/000/000
  // 000/032/064/032/000
  // 032/064/128/064/032
  // 000/032/064/032/000
  // 000/000/032/000/000
  setup(){
    
    //create hight res last, start with the outside first
    
    //med res
    
    landCon[3][5].CreateHeightMap(landCon);
    landCon[7][5].CreateHeightMap(landCon);
    landCon[5][7].CreateHeightMap(landCon);
    landCon[5][3].CreateHeightMap(landCon);
    
    landCon[4][4].CreateHeightMap(landCon);
    landCon[6][4].CreateHeightMap(landCon);
    landCon[6][6].CreateHeightMap(landCon);
    landCon[4][6].CreateHeightMap(landCon);

    
    
    //high res
    landCon[5][4].CreateHeightMap(landCon);
    landCon[5][6].CreateHeightMap(landCon);
    landCon[6][5].CreateHeightMap(landCon);
    landCon[4][5].CreateHeightMap(landCon);
    landCon[5][5].CreateHeightMap(landCon);


   
    //med res
    landCon[4][4].CreateObject(landCon);
    landCon[6][4].CreateObject(landCon);
    landCon[6][6].CreateObject(landCon);
    landCon[4][6].CreateObject(landCon);
    
    landCon[3][5].CreateObject(landCon);
    landCon[7][5].CreateObject(landCon);
    landCon[5][7].CreateObject(landCon);
    landCon[5][3].CreateObject(landCon);
    

    //high res
    landCon[6][5].CreateObject(landCon);
    landCon[5][4].CreateObject(landCon);
    landCon[5][6].CreateObject(landCon);
    landCon[4][5].CreateObject(landCon);
    landCon[5][5].CreateObject(landCon);
    
    
    
  }

  
  //check the user data, and see what needs to be done,
  //if the user has moved to much, create a new tile, update older ones, remove those that are to far away
  update(){
    camera.update();
  }

  
  //go through a list of enviroment details and render them.
  draw(){
    
    Matrix4 viewMat = camera.getViewMat();
    
    gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
    
    
    landCon[5][5].draw(viewMat, projectionMat);
    landCon[6][5].draw(viewMat, projectionMat);
    landCon[4][5].draw(viewMat, projectionMat);
    landCon[5][4].draw(viewMat, projectionMat);
    landCon[5][6].draw(viewMat, projectionMat);
    
    landCon[4][4].draw(viewMat, projectionMat);
    landCon[6][4].draw(viewMat, projectionMat);
    landCon[6][6].draw(viewMat, projectionMat);
    landCon[4][6].draw(viewMat, projectionMat);
    
    landCon[3][5].draw(viewMat, projectionMat);
    landCon[7][5].draw(viewMat, projectionMat);
    landCon[5][7].draw(viewMat, projectionMat);
    landCon[5][3].draw(viewMat, projectionMat);

   
  }
  
  keyDown(KeyboardEvent e){
    //hit space to update the water sim one time step
    if(e.keyCode == 32){
      landCon[5][5].downGrade(landCon);
    }
    //hit "A" to make the simulation run automatically, or off
    if(e.keyCode == 16){
      landCon[5][5].upGrade(landCon);
      
    }
    
  }
  
  
  
}