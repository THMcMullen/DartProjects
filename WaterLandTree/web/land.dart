library land;

import 'utils.dart' as utils;
import 'dart:math' as math;
import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

import 'object.dart';

class land extends object{
  
  var heightMap;
  var res = 129;
  
  var landIndices;
  
  land(givenGL){
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
      
          gl_FragColor = color*vec4(vLighting,0.5);
          
    
    }""";
    
    //creates the shaders unique for the landscape
    shader = utils.loadShaderSource(gl, vertex, fragment);
    
    attrib = ['aVertexPosition', 'aVertexNormal'];
    unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    attribute = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    var rng = new math.Random();
               
    var hi = 10;
 
    heightMap = new List(res);
    for(int i = 0; i < res; i++){
      heightMap[i] = new List(res);
        for(int j = 0; j < res; j++){
          heightMap[i][j] = 0.1; 
        }      
    }
     
     
   heightMap[0][0] = 0.5;
   heightMap[0][res-1] = 0.5;
   heightMap[res-1][0] = 0.5;
   heightMap[res-1][res-1] = 0.5;
   
   int SideLength2 = res-1;
   int grid_cnt = 0;
   int Erosion_delay = 2;
   
   double r = 10.0;
   double Roughness = 0.55;
   double e = 0.55;
     
   for(int sideLength = res-1; sideLength >= 2; sideLength = sideLength ~/ 2, hi /=2 ){
  
     int halfSide = sideLength~/2;
     int HalfSide2 = SideLength2 ~/ 2;
     int QSide2 = HalfSide2 ~/ 2;
    
     for(int x = 0; x < res-1; x+=sideLength){
       for(int y = 0; y < res-1; y +=sideLength){
        
         double avg = heightMap[x][y]     +
             heightMap[x+sideLength][y]   +
             heightMap[x][y+sideLength]   +
             heightMap[x+sideLength][y+sideLength];
          
          
         avg /= 4.0;
          
         double offset = (-hi) + rng.nextDouble() * (hi- (-hi));
         heightMap[x+halfSide][y+halfSide] = avg + offset;       
       }
     }
    
     for(int x = 0; x < res; x+=halfSide){
       for(int y = (x+halfSide)%sideLength ; y < res; y+= sideLength){
            
         double avg = 
                heightMap[(x-halfSide+res)%res][y] +
                heightMap[(x+halfSide)%res][y]   +
                heightMap[x][(y+halfSide)%res]   +
                heightMap[x][(y-halfSide+res)%res];
              
         avg /= 4;
              
         double offset = (-hi) + rng.nextDouble() * (hi- (-hi));
              
         //if x == 0 and givenX != 0, set to buffered data
   //if y == 0 and givenY != 0, ^
              
       heightMap[x][y] = avg + offset;
              
     }      
   }
 
    //Smothing function goes here
    if(grid_cnt >= Erosion_delay){
    
      for (int x = 0; x < res-1; x += SideLength2){
        for (int y = 0; y < res-1; y += SideLength2){
         
          double avg = heightMap[(x + HalfSide2+res)%res][(y + HalfSide2+res)%res]*(1-e)+
            (heightMap[(x + QSide2+res)%res][(y + QSide2+res)%res] +
            heightMap[(x + SideLength2 - QSide2+res)%res][(y + QSide2+res)%res] +
            heightMap[(x + QSide2+res)%res][(y + SideLength2 - QSide2+res)%res] +
            heightMap[(x + SideLength2 - QSide2+res)%res][(y + SideLength2 - QSide2+res)%res])
            * e / 4;
          
            heightMap[(x + HalfSide2+res)%res][(y + HalfSide2+res)%res] = avg;
     
        }
      }
     
     for (int x = 0; x < res-1; x = x + SideLength2){
       for (int y = 0; y < res-1 ; y = y + SideLength2){
          if (y != 0){
            heightMap[x + HalfSide2][ y] = heightMap[x + HalfSide2][ y]*(1-e)+
            (heightMap[x + QSide2][ y] + heightMap[x + SideLength2 - QSide2][ y] + 
            heightMap[x + HalfSide2][ y  + QSide2] + heightMap[x + HalfSide2][ y - QSide2]) * e / 4; 
          }
          if (x != 0){
            heightMap[x][ y + HalfSide2] = heightMap[x][ y + HalfSide2]*(1-e)+
            (heightMap[x][ y + QSide2] + heightMap[x][ y + SideLength2 - QSide2] + 
            heightMap[x + QSide2][ y + HalfSide2] + heightMap[x - QSide2][ y + HalfSide2]) * e / 4 ;
          }
        }
      } 
      SideLength2 = SideLength2 ~/ 2;  
    }
     
    grid_cnt++;
     
    r = r / Roughness;
    }
    
    
    int posx = 0;
    int posy = 0;
    var vert = new List();
    for(double i = 0.0; i < res; i++){
      for(double j = 0.0; j < res; j++){
    
        vert.add(i);//(((i+posx*res-posx)-res/8)-48);
        vert.add((heightMap[j.toInt()][i.toInt()]));
        vert.add(j);//(((j+posy*res-posy)-res/8)-48);
  
       }
    } 
   
    var pos;
    landIndices = new List();
    vertices = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);
  
    for(int i = 0; i < res-1; i++){
      for(int j = 0; j < res-1; j++){
            
        //the possition of the vertic in the indice array we want to draw.
        pos = (i*res+j);
           
        //top half of square
        landIndices.add(pos);
        landIndices.add(pos+1);
        landIndices.add(pos+res);
         
        //bottem half of square
        landIndices.add(pos+res);
        landIndices.add(pos+res+1);
        landIndices.add(pos+1);
                 
      }
    }
       
    indices = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indices);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(landIndices), webgl.STATIC_DRAW);
    
    
    //print(landIndices);
    
    
    //print(meshLength());
    
    var norm = new List();
    
    for(int x = 0; x < res ; x++){
      for(int y = 0; y < res; y++){
        
        var r = new Vector3.zero();
      
      //r = calcNormal(y, x);
        
        r.normalize();
        
        norm.add(r.x);
        norm.add(r.y);
        norm.add(r.z);
        
        
      }
    }
    
    normals = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, normals);
    gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(norm), webgl.STATIC_DRAW);
  
  }
    
  
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    
    gl.useProgram(shader);
        
    utils.setMatrixUniforms(gl, viewMat, projectMat, uniforms['uPMatrix'], uniforms['uMVMatrix'], uniforms['uNormalMatrix']);
    
    gl.enableVertexAttribArray(attribute['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, vertices);
    gl.vertexAttribPointer(attribute['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(attribute['aVertexNormal']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, normals);
    gl.vertexAttribPointer(attribute['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, indices);
    gl.drawElements(webgl.TRIANGLES, landIndices.length, webgl.UNSIGNED_SHORT, 0);
    
  }
}