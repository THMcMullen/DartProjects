library water;

import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

import 'utils.dart' as utils;

import 'object.dart';
import 'land.dart';

//created based on the shallow water model
class water extends object{
  
  var waterIndices;
  
  List walkerList = new List<int>();
  
  
  int posX;
  int posY;
  
  
  
  water(webgl.RenderingContext givenGL){
    gl = givenGL;
    
    //shaders to color the landscape based on height
    String vertex = """
      attribute vec3 aVertexPosition;
      attribute vec3 aVertexNormal;
      
      uniform mat3 uNormalMatrix;
      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;
      
      varying vec3 vLighting;
      varying vec3 vColoring;
      
      void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
      
          vec3 ambientLight = vec3(0.6,0.6,0.6);
          vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
          vec3 directionalVector = vec3(0.85, 0.8, 0.75);
      
          vec3 transformedNormal = uNormalMatrix * aVertexNormal;
      
          float directional = max(dot(transformedNormal, directionalVector), 0.0);
          vLighting = ambientLight + (directionalLightColor * directional);
      
          vColoring = vec3(aVertexPosition);
    
    }""";
        
    String fragment = """
      precision mediump float;
      
      varying vec3 vLighting;
      varying vec3 vColoring;
      
      void main(void) {
      
          vec4 color = vec4(vColoring,1);
          float alpha = vColoring.y / 5.0;
      
      
          if(vColoring.y < -0.5)
            color = vec4(0.0, 0.0,1.0, 1.0+alpha );
          else if(vColoring.y < 1.5)
            color = vec4(0.3+alpha, 0.8, 0.3+alpha, 1.0);
          else
            color = vec4(0.8, 0.42, 0.42, (.6 + alpha) );
      
          gl_FragColor = vec4(0.0,0.0,0.0,1.0);
          
    
    }""";
    
    //creates the shaders unique for the landscape
    shader = utils.loadShaderSource(gl, vertex, fragment);

    attrib = ['aVertexPosition', 'aVertexNormal'];
    unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    attribute = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    
    var vert =[  -1.0, -1.0,  1.0,
                  1.0, -1.0,  1.0,
                  1.0,  1.0,  1.0,
                 -1.0,  1.0,  1.0,
  
                 // Back face
                 -1.0, -1.0, -1.0,
                 -1.0,  1.0, -1.0,
                  1.0,  1.0, -1.0,
                  1.0, -1.0, -1.0,
  
                 // Top face
                 -1.0,  1.0, -1.0,
                 -1.0,  1.0,  1.0,
                  1.0,  1.0,  1.0,
                  1.0,  1.0, -1.0,
  
                 // Bottom face
                 -1.0, -1.0, -1.0,
                  1.0, -1.0, -1.0,
                  1.0, -1.0,  1.0,
                 -1.0, -1.0,  1.0,
  
                 // Right face
                  1.0, -1.0, -1.0,
                  1.0,  1.0, -1.0,
                  1.0,  1.0,  1.0,
                  1.0, -1.0,  1.0,
  
                 // Left face
                 -1.0, -1.0, -1.0,
                 -1.0, -1.0,  1.0,
                 -1.0,  1.0,  1.0,
                 -1.0,  1.0, -1.0,
               ];
    
    
    vertices = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);
    
    var norm = [0.0,  0.0,  1.0,
                0.0,  0.0,  1.0,
                0.0,  0.0,  1.0,
                0.0,  0.0,  1.0,

               // Back face
                0.0,  0.0, -1.0,
                0.0,  0.0, -1.0,
                0.0,  0.0, -1.0,
                0.0,  0.0, -1.0,

               // Top face
                0.0,  1.0,  0.0,
                0.0,  1.0,  0.0,
                0.0,  1.0,  0.0,
                0.0,  1.0,  0.0,

               // Bottom face
                0.0, -1.0,  0.0,
                0.0, -1.0,  0.0,
                0.0, -1.0,  0.0,
                0.0, -1.0,  0.0,

               // Right face
                1.0,  0.0,  0.0,
                1.0,  0.0,  0.0,
                1.0,  0.0,  0.0,
                1.0,  0.0,  0.0,

               // Left face
               -1.0,  0.0,  0.0,
               -1.0,  0.0,  0.0,
               -1.0,  0.0,  0.0,
               -1.0,  0.0,  0.0
           ];
    
    normals = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, normals);
    gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(norm), webgl.STATIC_DRAW);
    
    waterIndices = [
                    0, 1, 2,      0, 2, 3,    // Front face
                    4, 5, 6,      4, 6, 7,    // Back face
                    8, 9, 10,     8, 10, 11,  // Top face
                    12, 13, 14,   12, 14, 15, // Bottom face
                    16, 17, 18,   16, 18, 19, // Right face
                    20, 21, 22,   20, 22, 23  // Left face
                    ];
    
    indices = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indices);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(waterIndices), webgl.STATIC_DRAW);
        
    
    //print(meshHeightMap(0).heightMap);
    
    //within a grid of size 129 * 129, create X walkers at random locations.  
    //each walker needs to move to the lowest spot, and can only move down, 
    //neighbours to search
    //
    // X = center, S = search
    //
    //[S][S][S]
    //[S][X][S]
    //[S][S][S]
    
    
    
    //print(lowest);
    var rng = new math.Random();
    //Random value to spawn walker at

    
    List pos = new List<int>(2);
    
    for(int i = 0; i < 100; i++){//create 5 walkers
      int locX = rng.nextInt(128);
      int locY = rng.nextInt(128);
      pos = walk(locX, locY);
      walkerList.add(pos[0]);
      walkerList.add(pos[1]);
    }
    
    double low = 0.0;
    
    for(int i = 0; i < 128; i++){
      for(int j = 0; j < 128; j++){
        if(meshHeightMap(0).heightMap[i][j] < low){
          low = meshHeightMap(0).heightMap[i][j];
        }
      }
    }
    print(low);
    
    
    
    
    posX = walkerList[0];
    posY = walkerList[1];
    
    
  }
  
  List<int> walk(int tX, int tY){
    List walker = new List<int>(2);
    
    int cX;//current X and Y
    int cY;
    
    int nX;//new X and Y
    int nY;
    
    var rng = new math.Random();
    //Random value to spawn walker at
    int locX = tX;//rng.nextInt(128);
    int locY = tY;//rng.nextInt(128);
    
    double lowest = meshHeightMap(0).heightMap[locX][locY];
    
    bool walking = true;
    
    nX = tX;//locX;
    nY = tY;//locY;
    int temp = 0;
    //while(walking){
      temp ++;
      for(int i = 0; i < 20; i++){
        for(int j = 0; j < 20; j++){
          cX = (nX + i-10) % 128;
          cY = (nX + j-10) % 128;
          
          if(meshHeightMap(0).heightMap[cX][cY] < lowest){
            locX = cX;
            locY = cY;
            lowest = meshHeightMap(0).heightMap[cX][cY]; 
          }
        }
      }
      
      //if the lowest point has not changed
      if(locX == nX && locY == nY){
        //walking = false;
        //print(lowest);
      }
      
      //nX = locX;
      //nY = locY;
      
      
      
    //}
    
    walker[0] = locX;
    walker[1] = locY;
    
    
    
    return walker;
  }
  
  /*List<int> walk(){

    List walker = new List<int>(2);
    
    var rng = new math.Random();
    //int size = 129*129;
    int locX = rng.nextInt(128);
    int locY = rng.nextInt(128);
    
    //locX = 10;
    //locY = 10;
    
    print(meshHeightMap(0).heightMap[locX][locY]);
    
    bool walking = true;
    
    double lowest = 10.0;//meshHeightMap(0).heightMap[locX][locY];
    
    int tempX;
    int tempY;
    
    List lowestValue = new List<double>(9);
    
    var tempCount = 0;
   
    while(walking){
      
      if(locX + 1 < 128){
        lowestValue[0] = meshHeightMap(0).heightMap[locX+1][locY];
      }else{
        lowestValue[0] = 10.0;
      }
      if((locX + 1 < 128) && (locY - 1 > 0)){
        lowestValue[1] = meshHeightMap(0).heightMap[locX+1][locY-1];
      }else{
        lowestValue[1] = 10.0;
      }
      if((locX + 1 < 128) && (locY + 1 < 128)){
        lowestValue[2] = meshHeightMap(0).heightMap[locX+1][locY+1];
      }else{
        lowestValue[2] = 10.0;
      }
      if(locY + 1 < 128){
        lowestValue[3] = meshHeightMap(0).heightMap[locX][locY+1];
      }
      else{
        lowestValue[3] = 10.0;
      }
      
      lowestValue[4] = meshHeightMap(0).heightMap[locX][locY];
      
      if(locY - 1 > 0){
        lowestValue[5] = meshHeightMap(0).heightMap[locX][locY-1];
      }else{
        lowestValue[5] = 10.0;
      }
      if(locX - 1 > 0){
        lowestValue[6] = meshHeightMap(0).heightMap[locX-1][locY];
      }else{
        lowestValue[6] = 10.0;
      }
      if((locX - 1 > 0) && (locY - 1 > 0)){
        lowestValue[7] = meshHeightMap(0).heightMap[locX-1][locY-1];
      }else{
        lowestValue[7] = 10.0;
      }
      if((locX - 1 > 0) && (locY + 1 < 128)){
        lowestValue[8] = meshHeightMap(0).heightMap[locX-1][locY+1];
      }else{
        lowestValue[8] = 10.0;
      }
      
      
      
      
      
      
      
      
      //while we move around to find a lower point we keep our walkers moving
      
      //check the neighbours around us to see if there is a lower value
      //insure we do not check a area that does not exist, eg out of bounds
      /*
      double above = meshHeightMap(0).heightMap[locX+1][locY];
      double aboveM1 = meshHeightMap(0).heightMap[locX+1][locY-1];
      double aboveP1 = meshHeightMap(0).heightMap[locX+1][locY+1];
      
      double plus1 = meshHeightMap(0).heightMap[locX][locY+1];
      double minus1 = meshHeightMap(0).heightMap[locX][locY-1];
      
      double below = meshHeightMap(0).heightMap[locX-1][locY];
      double belowM1 = meshHeightMap(0).heightMap[locX-1][locY-1];
      double belowP1 = meshHeightMap(0).heightMap[locX-1][locY+1];*/
      
      //print(tempCount++);
      
      for(int i = 0; i < 9; i++){
        int change = 0;
        if(lowestValue[i] < lowest){
          lowest = lowestValue[i];
        }
      }
      
      int loc = lowestValue.indexOf(lowest);
      
      if(loc == 0){//above
        locX = locX + 1;
      }else if(loc == 1){//aboveM1
        locX = locX + 1;
        locY = locY - 1;
      }else if(loc == 2){//aboveP1
        locX = locX + 1;
        locY = locY + 1;
      }else if(loc == 3){//plus1
        locY = locY + 1;
      }else if(loc == 4){//center
        walking = false;
      }else if(loc == 5){//minus1
        locY = locY - 1;
      }else if(loc == 6){//below
        locX = locX - 1;        
      }else if(loc == 7){//belowM1
        locX = locX - 1;
        locY = locY - 1;
      }else if(loc == 8){//belowP1
        locX = locX - 1;
        locY = locY + 1;
      }
      
      print(lowest);
      
      
    }

    walker[0] = locX;
    walker[1] = locY;

    return walker;
  }
  * 
  * */
  
  update(){
    //masterMesh[0].heightMap;
    //print("updating water");
  }
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    //print("drawing water");
    
    //need to render 5 walkers
    
    
    
    
    
    
    gl.useProgram(shader);
    
    
    gl.enableVertexAttribArray(attribute['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, vertices);
    gl.vertexAttribPointer(attribute['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(attribute['aVertexNormal']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, normals);
    gl.vertexAttribPointer(attribute['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, indices);
    
    
    for(int i = 0; i < 100; i++){
      
      
      List temp = new List<int>(2);
      
      temp = walk(walkerList[i*2+1], walkerList[i*2]);
      
      walkerList[i*2] = temp[1];
      walkerList[(i*2) + 1] = temp[0];
      
      
      Matrix4 mv = viewMat.clone();
      mv.translate((walkerList[i*2].toDouble())-64,meshHeightMap(0).heightMap[posX][posY]-0.5 ,(walkerList[(i*2)+1].toDouble())-64);
      
      utils.setMatrixUniforms(gl, mv, projectMat, uniforms['uPMatrix'], uniforms['uMVMatrix'], uniforms['uNormalMatrix']);
      
      gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);
      
      mv.setZero();
    }

    //mv.translate((locX.toDouble())+64,meshHeightMap(0).heightMap[locX][locY]-5,(locY.toDouble())+64);
  }
}
  
  


