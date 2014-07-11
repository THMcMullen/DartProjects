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
  
  var blobInd;
  
  var len = 3;
  
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
      
          gl_FragColor = color;//vec4(0.0,0.0,0.0,1.0);
          
    
    }""";
    
    //creates the shaders unique for the landscape
    shader = utils.loadShaderSource(gl, vertex, fragment);

    attrib = ['aVertexPosition', 'aVertexNormal'];
    unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    attribute = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    var d = 129;
    var posx = 0;
    var posy = 0;
    
    var vert = new List();
       for(double i = 0.0; i < d; i++){
         for(double j = 0.0; j < d; j++){
       
           vert.add(((i+posx*d-posx)-d/8)-48);
           vert.add(-0.5);
           vert.add(((j+posy*d-posy)-d/8)-48);
     
          }
       } 
      
    //print(vert);
   vertices = gl.createBuffer();
   gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);
   gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);
    
    
    waterIndices = new List<int>();
    
    var pos;

   vertices = gl.createBuffer();
   gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);
   gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);
 
     for(int i = 0; i < d-1; i++){
       for(int j = 0; j < d-1; j++){
             
       //the possition of the vertic in the indice array we want to draw.
       pos = (i*d+j);
          
       //top half of square
       waterIndices.add(pos);
       waterIndices.add(pos+1);
       waterIndices.add(pos+d);
          
       //bottem half of square
       waterIndices.add(pos+d);
       waterIndices.add(pos+d+1);
       waterIndices.add(pos+1);
            
     }
   }
      
   indices = gl.createBuffer();
   gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indices);
   gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(waterIndices), webgl.STATIC_DRAW);
   
   var norm = new List();

       for(int x = 0; x < d ; x++){
         for(int y = 0; y < d; y++){
           
           var r = new Vector3.zero();

           
           norm.add(0.0);
           norm.add(0.0);
           norm.add(0.0);
           
           
       }
     }
     
     normals = gl.createBuffer();
     gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, normals);
     gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(norm), webgl.STATIC_DRAW);
       
   
   
   //print(waterIndices);
    
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

   /* 
    List pos = new List<int>(2);
    
    for(int i = 0; i < 1000; i++){//create 5 walkers
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
    * 
    * */
    
    var nw, nn, ne, ww;
    var minIndex;
    var label = 1;
    
    List labelTable = new List();
    labelTable.add(0);
    
    //walkers not the best idea, so set group level to 0, then do connected-component labeling
    List blobMap = new List(d+2);
    for(int i = 0; i < d+2; i++){
     blobMap[i] = new List(d+2);
      for(int j = 0; j < d+2; j++){
        blobMap[i][j] = 0;
      }
    }
    for(int k = 0; k < 2; k++){
      for(int i = 1; i < d; i++){
        for(int j = 1; j < d; j++){
          //check if the hight at the given location is under a given height
          if(meshHeightMap(0).heightMap[i][j] <= -0.5){
            nw = blobMap[i-1][j-1];
            nn = blobMap[i-1][ j ];
            ne = blobMap[i-1][j+1];
            ww = blobMap[ i ][j-1];
            minIndex = ww;
            if( 0 < nw && nw < minIndex){minIndex = nw;}
            if( 0 < nn && nn < minIndex){minIndex = nn;}
            if( 0 < ne && ne < minIndex){minIndex = ne;}
            if( 0 < ww && ww < minIndex){minIndex = ww;}
            
            //not part of a group so join a new one
            if(minIndex == 0){
              blobMap[i][j] = label;
              labelTable.add(label);
              label++;
            }else{//we are part of a group so set our value to that
              if( minIndex < labelTable[nw] ){ labelTable[nw] = minIndex; }
              if( minIndex < labelTable[nn] ){ labelTable[nn] = minIndex; }
              if( minIndex < labelTable[ne] ){ labelTable[ne] = minIndex; }
              if( minIndex < labelTable[ww] ){ labelTable[ww] = minIndex; }
              
              blobMap[i][j] = minIndex;
            }
            
          }else{
            blobMap[i][j] = 0;
          }
        }
      }
      
      var i = labelTable.length;
      while( i != 0 ){
        i--;
        label = labelTable[i];
        while( label != labelTable[label] ){
          label = labelTable[label];
        }
        labelTable[i] = label;
      }
       
      for(int y=0; y<d+2; y++){
        for(int x=0; x<d+2; x++){
          label = blobMap[y][x];
          if( label == 0 ){ continue; }
          while( label != labelTable[label] ){
            label = labelTable[label];
          }
          blobMap[y][x] = label;
        }
      }
     
      

      
    }
    
    Set uniqueLabels = new Set();
    
    for(int i = 0; i < labelTable.length; i++){
      uniqueLabels.add(labelTable[i]);
    }
    
    
    List uniqueTable = new List.from(uniqueLabels);
    print(uniqueTable);
    //print(labelTable);
    
    int z = 0;
    for(int i = 0; i < uniqueTable.length; i++){
      for(int j = 0; j < labelTable.length; j++){
        if(labelTable[j] == uniqueTable[i]){
          labelTable[j] = i;
        }
      }
      

    }

    //full with all blob info, for blob 1
    var blobVert = new List();
    for(int x = 1; x < d+2; x++){
      for(int y = 1; y < d+2; y++){
        if(blobMap[x][y] == 1){ 
          blobVert.add(y.toDouble());
          blobVert.add(64.5);
          blobVert.add(x.toDouble());
        }
      }
    }
    
    
    
    blobInd = new List();
    //Try create test blob class
    for(int x = 1; x < d+2; x++){
      for(int y = 1; y < d+2; y++){
        //we are part of blob 1
        if(blobMap[y][x] == 1){
          //test to see if below us is also blob 1
          if(blobMap[y+1][x] == 1){
            int current = null;
            int cm1 = null;
            int cp1 = null;
            int currentp1 = null;
            for(int i = 0; i < blobVert.length; i+=3){
              //check to find out indice
              if(blobVert[i] == x && blobVert[i+2] == y){
                current = i~/3;
              }else if(blobVert[i] == x+1 && blobVert[i+2] == y){
                currentp1 = i~/3;
              }else if(blobVert[i] == x && blobVert[i+2] == y+1){
                cm1 = i~/3;
              }else if(blobVert[i] == x+1 && blobVert[i+2] == y+1){
                cp1 = i~/3;
              }
            }
            if(cp1 == null || cm1 == null || current == null || currentp1 == null){
             // print("$x:, \n $y:");
            }else{
              
              blobInd.add(currentp1);
              blobInd.add(cm1);
              blobInd.add(cp1);
              blobInd.add(current);
              blobInd.add(currentp1);
              blobInd.add(cm1);
              

            }
          }
        }
      }
    }
    
    len = blobInd.length;
    
    print(blobInd.length);
    
    
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indices);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(blobInd), webgl.STATIC_DRAW);
    
    
    
    
    print(labelTable);
     
    var value;
    
    for(int i = 0; i < blobVert.length; i++){
      blobVert[i] -= 65;
    }

    for(var a = 0; a < d; a++){
      for(var b = 0; b < d; b++){
          //value =(a*d)+(b); 
                              
          //vert[(value*3)+1] = blobMap[b][a] > 0? 10.0: 0.0;
          
      }
    }  
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);  
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(blobVert), webgl.STATIC_DRAW);
    //gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(vert));

    
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
    
  
  update(){
    //masterMesh[0].heightMap;
    //print("updating water");
    /*for(int i = 0; i < 1000; i++){
         
         
         List temp = new List<int>(2);
         
         temp = walk(walkerList[i*2+1], walkerList[i*2]);
         
         walkerList[i*2] = temp[1];
         walkerList[(i*2) + 1] = temp[0];
         
    }*/
         
    
    
  }
  
  
  
  
  
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    //print("drawing water");
    
    //need to render 5 walkers
    
    gl.useProgram(shader);

    Matrix4 mv = new Matrix4.zero();
    
    mv = viewMat;

    
    
    gl.enableVertexAttribArray(attribute['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, vertices);
    gl.vertexAttribPointer(attribute['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(attribute['aVertexNormal']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, normals);
    gl.vertexAttribPointer(attribute['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, indices);

      
    utils.setMatrixUniforms(gl, mv, projectMat, uniforms['uPMatrix'], uniforms['uMVMatrix'], uniforms['uNormalMatrix']);
      
    gl.drawElements(webgl.TRIANGLES, len, webgl.UNSIGNED_SHORT, 0);


  }
}
  
  


