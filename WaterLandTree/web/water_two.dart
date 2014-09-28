library waterTwo;

import 'dart:web_gl' as webgl;

import 'blob.dart';
import 'utils.dart' as utils;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

class water_two{
  
  int sizeX = 0;
  int sizeY = 0;
  int startX = 0;
  int startY = 0;
  
  webgl.RenderingContext gl;
    
  Map<String, int> attributes;
  Map<String, int> uniforms;
  
  Map<String, int> waterAttributes;
  Map<String, int> waterUniforms;
  
  var waterShader;
  var shader;
  var boxVert;
  var ind;
  var norm;
  
  List waterIndices;
  var wVert;
  var waterVert;
  var waterInd;
  var waterNorm;
  var wNorm = new List();
  
  var g;
  var h, h1;
  var vx, vx1;
  var vy, vy1;
  
  var X;
  var Y;
  var X1;
  var Y1; 
  

  
  var bigArray;
  
  var blobMap;
  
  
  water_two(givenGL, passMap){
    
    gl = givenGL;
    
    X = 128;
    Y = 128;
    
    String verts = """
      attribute vec3 aVertexPosition;
      attribute vec3 aVertexNormal;
  
      uniform mat3 uNormalMatrix;
      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      varying vec3 vLighting;

      void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

          vec3 ambientLight = vec3(0.6,0.6,1.0);
          vec3 directionalLightColor = vec3(0.8, 0.8, 0.8);
          vec3 directionalVector = vec3(1.0, 1.0, 1.0);

          vec3 transformedNormal = uNormalMatrix * aVertexNormal;

          float directional = max(dot(transformedNormal, directionalVector), 0.0);
          vLighting = ambientLight + (directionalLightColor * directional);
      }""";

       String frag = """
      precision mediump float;

      varying vec3 vLighting;
  
      void main(void) {

          gl_FragColor = vec4(0.0,0.0,0.0, 1.0);

      }""";
       
       waterShader = utils.loadShaderSource(gl, verts, frag);
       
       var attrib = ['aVertexPosition', 'aVertexNormal'];
       var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
       
       waterAttributes = utils.linkAttributes(gl, waterShader, attrib);
       waterUniforms = utils.linkUniforms(gl, waterShader, unif);
       
       blobMap = passMap;
       
       wVert = new List();
       waterIndices = new List();
       
       waterVert = gl.createBuffer();
       waterInd = gl.createBuffer();
      
       //add Buffer to the data
       for(int i = 1; i < blobMap.length-1; i++){
         for(int j = 1; j < blobMap[i].length-1; j++){
           //not empty data, so add buffer/false data
           //set value to 200 for false data, as data will not reach that value otherwise
           if(blobMap[i][j] != 0 && blobMap[i][j] != 200){
             if(blobMap[i+1][j+1] == 0){
               blobMap[i+1][j+1] = 200;
             }
             if(blobMap[i+1][j] == 0){
               blobMap[i+1][j] = 200;
             }
             if(blobMap[i+1][j-1] == 0){
               blobMap[i+1][j-1] = 200;
             }
             if(blobMap[i][j+1] == 0){
               blobMap[i][j+1] = 200;
             }
             if(blobMap[i][j-1] == 0){
               blobMap[i][j-1] = 200;
             }
             if(blobMap[i-1][j+1] == 0){
               blobMap[i-1][j+1] = 200;
             }
             if(blobMap[i-1][j] == 0){
               blobMap[i-1][j] = 200;
             }
             if(blobMap[i-1][j-1] == 0){
               blobMap[i-1][j-1] = 200;
             }
           }
         }
       }
       


       
       //start at one to skip the buffer
       for(int x = 0; x < blobMap.length-1; x++){
         for(int y = 0; y < blobMap[x].length-1; y++){
           if(blobMap[x][y] != 0){ 
             wVert.add(y.toDouble());
             wVert.add(-0.5);
             wVert.add(x.toDouble());
           }
         }
       }
       

       
       
       for(int i = 0; i < blobMap.length-3; i++){
         for(int j = 0; j < blobMap[i].length-3; j++){
           if(blobMap[i][j] != 0){
             if(blobMap[i+1][j] != 0){
               int current = null;
               int cm1 = null;
               int cp1 = null;
               int currentp1 = null;
               for(int k = 0; k < wVert.length; k+=3){
                  if(wVert[k] == j && wVert[k+2] == i){
                    current = k~/3;
                  }else if(wVert[k] == j+1 && wVert[k+2] == i){
                    currentp1 = k~/3;
                  }else if(wVert[k] == j && wVert[k+2] == i+1){
                    cm1 = k~/3;
                  }else if(wVert[k] == j+1 && wVert[k+2] == i+1){
                    cp1 = k~/3;
                  }
               }
               if(cp1 == null || cm1 == null || current == null || currentp1 == null){
                  //print("$i:, \n $j:");
               }else{               
                 waterIndices.add(currentp1);
                 waterIndices.add(cm1);
                 waterIndices.add(cp1);
                 waterIndices.add(current);
                 waterIndices.add(currentp1);
                 waterIndices.add(cm1);
               }
             }
           }
         }
       }
       
       // add the spped up to the map, by adding the values to skip, remembering to ignore points of 0, or 200, only working on "real" data.
       
       var waterMap = new List(blobMap.length);
       
       for(int i = 0; i < blobMap.length; i++){
         var c = 0;
         waterMap[i] = new List();
         waterMap[i].add(0);
         for(int j = 1; j < blobMap[i].length+1; j++){
           if(blobMap[i][j-1] != 0 && blobMap[i][j-1] != 200){
             c++;
             waterMap[i].add(j-1);
           }else{
             waterMap[i].add(0);
           }
         }
         waterMap[i][0] = c;
       }
       
       for(int i = 0; i < waterMap.length; i++){
         print(waterMap[i]); 
       }
       
       
       
       
       
       
       
       
       
       gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, waterInd);
       gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(waterIndices), webgl.STATIC_DRAW);
       
       gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);    
       gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(wVert), webgl.DYNAMIC_DRAW);
           
           
       //print(blobInd);
          
    
    
  }
  
  void waterUpdate(){
    
  }
  
 
    
    
  void drawWater(Matrix4 viewMat, Matrix4 projectMat){
     
    gl.useProgram(waterShader);
    
    utils.setMatrixUniforms(gl, viewMat, projectMat, waterUniforms['uPMatrix'], waterUniforms['uMVMatrix'], waterUniforms['uNormalMatrix']);
    
    gl.enableVertexAttribArray(waterAttributes['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, waterVert);
    gl.vertexAttribPointer(waterAttributes['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(waterAttributes['aVertexNormal']);
    //gl.bindBuffer(webgl.ARRAY_BUFFER, waterNorm);
    //gl.vertexAttribPointer(waterAttributes['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
        
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, waterInd);
    
    gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);
    //print(waterIndices.length);
    //print("h");
    
    
  }
    
    
    
    
  
}
