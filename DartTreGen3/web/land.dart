library land;

import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

import 'utils.dart' as utils;

import 'object.dart';


//created using diamond-square height maps
class land extends object{
    
  var heightMap;
  var d = 129;
  
  var landIndices;
  var gridPos;
  
  int posx;
  int posy;
  
  int width = 2;
  
  
  land(givenGL, location, y){
    gl = givenGL;
    gridPos = location;
    
    //print(y);
    
    
    posy = location; //(meshLength()/width).floor();
    posx = y; //meshLength()%width;
    
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
      
      
          if(vColoring.y < 0.0)
            color = vec4(0.0, 0.0,1.0, 1.0+alpha );
          else if(vColoring.y < 1.5)
            color = vec4(0.3+alpha, 0.8, 0.3+alpha, 1.0);
          else
            color = vec4(0.8, 0.42, 0.42, (.6 + alpha) );
      
          gl_FragColor = vec4(vLighting.x*color.x, vLighting.y * color.y, vLighting.z*color.z,1.0);
          
    
    }""";
    
    //creates the shaders unique for the landscape
    shader = utils.loadShaderSource(gl, vertex, fragment);

    attrib = ['aVertexPosition', 'aVertexNormal'];
    unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    attribute = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    var rng = new math.Random();
           
    var hi = 10;
 
    heightMap = new List(d);
    for(int i = 0; i < d; i++){
      heightMap[i] = new List(d);
        for(int j = 0; j < d; j++){
          heightMap[i][j] = 0.1; 
        }      
    }
     
     
   heightMap[0][0] = 0.0;
   heightMap[0][d-1] = 0.0;
   heightMap[d-1][0] = 0.0;
   heightMap[d-1][d-1] = 0.0;
   
  int below = 0;
  int beside = 0;
  
  for(int i = 0; i < meshLength(); i++){
    if((meshHeightMap(i).posx == posx-1) && (meshHeightMap(i).posy == posy)){
      //print("below me is $i");   
      below = i;
    }
    if((meshHeightMap(i).posx == posx) && (meshHeightMap(i).posy == (posy-1))){
      //print("beside me is $i");   
      beside = i;
    }
    
  }
   

   
      
   for(int sideLength = d-1; sideLength >= 2; sideLength = sideLength ~/ 2, hi /=2 ){
   
    int halfSide = sideLength~/2;
   
    for(int x = 0; x < d-1; x+=sideLength){
      for(int y = 0; y < d-1; y +=sideLength){
       
        double avg = heightMap[x][y]     +
            heightMap[x+sideLength][y]   +
            heightMap[x][y+sideLength]   +
            heightMap[x+sideLength][y+sideLength];
         
         
        avg /= 4.0;
         
        double offset = (-hi) + rng.nextDouble() * (hi- (-hi));
        heightMap[x+halfSide][y+halfSide] = avg + offset;       
      }
    }
     
      for(int x = 0; x < d; x+=halfSide){
        for(int y = (x+halfSide)%sideLength ; y < d; y+= sideLength){
             
          double avg = 
                 heightMap[(x-halfSide+d)%d][y] +
                 heightMap[(x+halfSide)%d][y]   +
                 heightMap[x][(y+halfSide)%d]   +
                 heightMap[x][(y-halfSide+d)%d];
               
          avg /= 4;
               
          double offset = (-hi) + rng.nextDouble() * (hi- (-hi));
               
          //if x == 0 and givenX != 0, set to buffered data
          //if y == 0 and givenY != 0, ^
                 
          heightMap[x][y] = avg + offset;
          
          if(posx != 0){
            if(y == 0){
              heightMap[x][y] = meshHeightMap(below).heightMap[x][d-1];
            }
          }
          //data from grid below
          if(posy != 0){
            if(x == 0){
              heightMap[x][y] = meshHeightMap(beside).heightMap[d-1][y];
            }
          }
          
          
        }
      }
    }
   
   
   List smooth = new List(d);
   
   /*for(int i= 2; i < d-3; i++){
    smooth[i] = (heightMap[0][i] + heightMap[0][i-1] + heightMap[0][i-2] + heightMap[0][i+1] + heightMap[0][i+2])/5.0;
    heightMap[0][i] = smooth[i];
   }*/
   for(int i= 2; i < d-3; i++){
    smooth[i] = (heightMap[d-1][i] + heightMap[d-1][i-1] + heightMap[d-1][i-2] + heightMap[d-1][i+1] + heightMap[d-1][i+2])/5.0;
    heightMap[d-1][i] = smooth[i];
   }
   for(int i= 2; i < d-3; i++){
    smooth[i] = (heightMap[i][d-1] + heightMap[i-1][d-1] + heightMap[i-2][d-1] + heightMap[i+1][d-1] + heightMap[i+2][d-1])/5.0;
    heightMap[i][d-1] = smooth[i];
   }
   /*for(int i= 2; i < d-3; i++){
    smooth[i] = (heightMap[i][0] + heightMap[i-1][0] + heightMap[i-2][0] + heightMap[i+1][0] + heightMap[i+2][0])/5.0;
    heightMap[i][0] = smooth[i];
   }*/
   //heightMap[0] = smooth;
   
   
   
 
   
    var vert = new List();
    for(double i = 0.0; i < d; i++){
      for(double j = 0.0; j < d; j++){
    
        vert.add(((i+posx*d-posx)-d/8)-48);
        vert.add((heightMap[j.toInt()][i.toInt()]));
        vert.add(((j+posy*d-posy)-d/8)-48);
  
       }
    } 
   
    var pos;
    landIndices = new List();
    vertices = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);
  
      for(int i = 0; i < d-1; i++){
        for(int j = 0; j < d-1; j++){
              
        //the possition of the vertic in the indice array we want to draw.
        pos = (i*d+j);
           
        //top half of square
        landIndices.add(pos);
        landIndices.add(pos+1);
        landIndices.add(pos+d);
           
        //bottem half of square
        landIndices.add(pos+d);
        landIndices.add(pos+d+1);
        landIndices.add(pos+1);
             
      }
    }
       
    indices = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indices);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(landIndices), webgl.STATIC_DRAW);
    
    //print(meshLength());
    
    var norm = new List();

    for(int x = 0; x < d ; x++){
      for(int y = 0; y < d; y++){
        
        var r = new Vector3.zero();
        
        r = calcNormal(y, x);
        
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
  
  Vector3 calcNormal(int iy, int ix){
    int ym1 = iy-1;
    int yp1 = iy+1;
    int xm1 = ix-1;
    int xp1 = ix+1;
    
    var r = new Vector3.zero();
    
    var c = new Vector3.zero();
    c.x = ix.toDouble();
    c.y = heightMap[ix][iy];
    c.z = ym1.toDouble();
    
    if(ix > 0 && iy > 0) {
      var n = new Vector3.zero();
      n.x = ix.toDouble();
      n.y = heightMap[ix][ym1];
      n.z = ym1.toDouble();
      
      var w = new Vector3.zero();
      w.x = xm1.toDouble();
      w.y = heightMap[xm1][iy];
      w.z = iy.toDouble();
      
      var u = new Vector3.zero();
      var v = new Vector3.zero();
      var rHolder = new Vector3.zero();
      
      u = n - c;
      v = w - c;
      cross3(u,v,rHolder);
      
      r = r + rHolder;          
    }
    if(ix < (128) && iy > 0) {
      var n = new Vector3.zero();
      n.x = ix.toDouble();
      n.y = heightMap[ix][ym1];
      n.z = ym1.toDouble();
      
      var e = new Vector3.zero();
      e.x = xp1.toDouble();
      e.y = heightMap[xp1][iy];
      e.z = iy.toDouble();
      
      var u = new Vector3.zero();
      var v = new Vector3.zero();
      var rHolder = new Vector3.zero();
      
      u = n - c;
      v = e - c;
      cross3(u,v,rHolder);
      
      r = r + rHolder;       
      
    }
    
    if(ix < (128) && iy < (128)) {
      var s = new Vector3.zero();
      s.x = ix.toDouble();
      s.y = heightMap[ix][yp1];
      s.z = yp1.toDouble();      
      
      var e = new Vector3.zero();
      e.x = xp1.toDouble();
      e.y = e.y = heightMap[xp1][iy];
      e.z = iy.toDouble();
      
      var u = new Vector3.zero();
      var v = new Vector3.zero();
      var rHolder = new Vector3.zero();
      
      u = s - c;
      v = e - c;
      cross3(u,v,rHolder);
      
      r = r + rHolder; 

    }
    
    if(ix > 0 && iy < (128)) {
      var s = new Vector3.zero();
      s.x = ix.toDouble();
      s.y = heightMap[ix][yp1];
      s.z = yp1.toDouble();  
      
      var w = new Vector3.zero();
      w.x = xm1.toDouble();
      w.y = heightMap[xm1][iy];
      w.z = iy.toDouble();
      
      var u = new Vector3.zero();
      var v = new Vector3.zero();
      var rHolder = new Vector3.zero();
      
      u = s - c;
      v = w - c;
      cross3(u,v,rHolder);
      
      r = r + rHolder; 
    }  
    
    return r;
    
  }
  

  
  update(){
    print("Creating Landscape");
    
  }
  
  //creates a walker to find where to spawn water from
  waterWalker(){
    
  }
  
  //creates the normals used for the landscape
  createNormals(){
    
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









