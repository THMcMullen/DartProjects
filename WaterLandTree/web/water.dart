library water;

import 'dart:web_gl' as webgl;

import 'blob.dart';
import 'utils.dart' as utils;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

//takes everything it needs from the blob class
class waterSim{
  
  int sizeX;
  int sizeY;
  int startX;
  int startY;
  
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
  
  waterSim(var blobCon, maxX, minX, maxY, minY, givenGl){
    
    gl = givenGl;
    
    startX = maxX;
    startY = maxY;
    
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

          gl_FragColor = vec4(vLighting, 0.6);

      }""";
    
    waterShader = utils.loadShaderSource(gl, verts, frag);
    
    var attrib = ['aVertexPosition', 'aVertexNormal'];
    var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    waterAttributes = utils.linkAttributes(gl, waterShader, attrib);
    waterUniforms = utils.linkUniforms(gl, waterShader, unif);
    
    
    wVert = new List();
    waterIndices = new List();
    
    var pos;
    

    
    blobMap = blobCon;
    
    X = blobMap.length;//maxX - minX;
    Y = blobMap[0].length;//maxY - minY;

    /*for(int i = 0; i < blobMap.length;i++){
       print(blobMap[i]);
    }*/
    
    print("X: $X");
    print("Y: $Y");
    
    for(int i = 0; i < blobMap.length; i++){
      for(int j = 0; j < blobMap[i].length-1; j++){
        //if the next cell is water
        if(blobMap[i][j+1] == 1){
          //then our value is 1
          //so do nothing
        }else{
          //the next cell is water, so try find how long till we hit water again
          for(int k = j; k < blobMap[i].length-1; k++){
            if(blobMap[i][k] == 1){
              //we have hit water        
              blobMap[i][j] = k-j;
              j=k;
              break;
            }
          }
        }
      }
    }
    print("\n\nNew Blob at 1\n");
    for(int i = 0; i < blobMap.length;i++){
       //print(blobMap[i]);
    }
    
    waterVert = gl.createBuffer();
    waterInd = gl.createBuffer();
    
    for(int i = 0; i < blobMap.length-1; i++){
      for(int j = 0; j < blobMap[i].length-1; j++){
       
        //the possition of the vertic in the indice array we want to draw.
        pos = (i*blobMap[i].length+j);
        
        //top half of square
        waterIndices.add(pos);
        waterIndices.add(pos+1);
        waterIndices.add(pos+blobMap[i].length);
        
        //bottem half of square
        waterIndices.add(pos+blobMap[i].length);
        waterIndices.add(pos+blobMap[i].length+1);
        waterIndices.add(pos+1);
        
      }
    }
    
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, waterInd);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(waterIndices), webgl.STATIC_DRAW);
       
        
    //print(waterIndices.length);
    
    for(double i = 0.0; i < blobMap.length; i++){
      for(double j = 0.0; j < blobMap[0].length; j++){  
        
        wVert.add(((j + startY.toDouble())-blobMap[i.toInt()].length));
        wVert.add(-0.5);
        wVert.add(((i + startX.toDouble())-blobMap.length));

        
        /*vert.add(((i+posx*res-posx)-res/8)-48);
                vert.add((heightMap[j.toInt()][i.toInt()]));
                vert.add(((j+posy*res-posy)-res/8)-48);*/
        
      }
    } 
   
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);    
    gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(wVert), webgl.DYNAMIC_DRAW);
    
    
    
    
    for(int i = 0; i < waterIndices.length; i++){
      wNorm.add(-1.0);
    }
    
    var wVSize = wVert.length;
    
    //print("size: $wVSize");
    
    
    waterNorm = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterNorm);
    gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(wNorm), webgl.STATIC_DRAW);
        

          
          
        
        
        
      
    
    
    
    
    
    
    
    
    
    
    
   
    
    initWater();
    
  }
  
  
  Vector3 calcNormal(int iy, int ix){
      
      int ym1 = iy-1;
      int yp1 = iy+1;
      int xm1 = ix-1;
      int xp1 = ix+1;
      
      var r = new Vector3.zero();
      
      var c = new Vector3.zero();
      c.x = ix.toDouble();
      c.y = g[iy*X + ix] + h[iy*X + ix];
      c.z = ym1.toDouble();
      
      if(ix > 0 && iy > 0) {
        var n = new Vector3.zero();
        n.x = ix.toDouble();
        n.y = g[ym1*X + ix] + h[ym1*X + ix];
        n.z = ym1.toDouble();
        
        var w = new Vector3.zero();
        w.x = xm1.toDouble();
        w.y = g[iy*X + xm1] + h[iy*X + xm1];
        w.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = n - c;
        v = w - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder;          
      }
      if(ix < (X-1) && iy > 0) {
        var n = new Vector3.zero();
        n.x = ix.toDouble();
        n.y = g[ym1*X + ix] + h[ym1*X + ix];
        n.z = ym1.toDouble();
        
        var e = new Vector3.zero();
        e.x = xp1.toDouble();
        e.y = g[iy*X + xp1] + h[iy*X + xp1];
        e.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = n - c;
        v = e - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder;       
        
      }
      
      if(ix < (X-1) && iy < (Y-1)) {
        var s = new Vector3.zero();
        s.x = ix.toDouble();
        s.y = g[yp1*X + ix] + h[yp1*X + ix];
        s.z = yp1.toDouble();      
        
        var e = new Vector3.zero();
        e.x = xp1.toDouble();
        e.y = g[iy*X + xp1] + h[iy*X + xp1];
        e.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = s - c;
        v = e - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder; 

      }
      
      if(ix > 0 && iy < (Y-1)) {
        var s = new Vector3.zero();
        s.x = ix.toDouble();
        s.y = g[yp1*X + ix] + h[yp1*X + ix];
        s.z = yp1.toDouble();  
        
        var w = new Vector3.zero();
        w.x = xm1.toDouble();
        w.y = g[iy*X + xm1] + h[iy*X + xm1];
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
  
  
  void initWater(){
    X1 = X + 1;
    Y1 = Y + 1;
    
    g = new List<double>(X*Y);
    h = new List<double>(X*Y);
    h1 = new List<double>(X*Y);
    
    vx = new List<double>(X1*Y);
    vx1 = new List<double>(X1*Y);
    
    vy = new List<double>(X*Y1);
    vy1 = new List<double>(X*Y1);  
       
    for(int iy = 0; iy < Y; iy++){
      for(int ix = 0; ix < X; ix++){
        
        g[iy*X + ix] =  0.0;

      }
    }
    
    for(int iy = 0; iy < Y; iy++){
      for(int ix = 0; ix < X; ix++){
        h[iy*X + ix] = math.max(g[iy*X + ix]+0.01, 0.0);
        h1[iy*X + ix] = h[iy*X + ix];        
      }
    }

    for(int iy = 0; iy < Y; iy++) {
      for(int ix = 0; ix < X1; ix++) {
        vx[iy*X1 + ix]  = 0.0;
        vx1[iy*X1 + ix] = 0.0;
      }
    }

    for(int iy = 0; iy < Y1; iy++) {
      for(int ix = 0; ix < X; ix++) {
        vy[iy*X + ix]  = 0.0;
        vy1[iy*X + ix] = 0.0;
      }
    }
    
    for(int iy = 0; iy < Y; iy++) {
      for(int ix = 0; ix < X; ix++) {
        double r = math.sqrt((ix - X/2) * (ix - X/2) + (iy - Y/2) * (iy - Y/2));
        
        if(r < Y/2) {
          r = (r / (Y/2)) * 4;
          double PI = 3.14159;
          h[iy*X + ix] += (Y * (1/math.sqrt(2 * PI)) * math.exp(-(r*r) / 2))/10;
          
        }
      }
    }
  }
  
  swap(List a, List b){
      var temp = new List(a.length);
      for(int i = 0; i < a.length; i ++){
        temp[i] = a[i];
        a[i] = b[i];
        b[i] = temp[i];
      }
    }
  
  void waterUpdate(){
    
    var t = 0.025;
    
    //print("hello");
    
    for(int iy = 0; iy < Y; iy++){
         for(int ix = 0; ix < X; ix++){
           int ym1 = math.max(iy - 1, 0);
           int xm1 = math.max(ix - 1, 0);
           int yp1 = math.min(iy + 1, Y1 - 1);
           int xp1 = math.min(ix + 1, X1 - 1);
           
           double ax = ix - ((vx[iy*X1 + ix] + vx[iy*X1 + xp1]) / 2.0) * t;
           double ay = iy - ((vy[iy*X  + ix] + vy[yp1*X +  ix]) / 2.0) * t;
           
           int nx = ax.toInt();
           int ny = ay.toInt();
           
           
           
           ax = ax - nx;
           ay = ay - ny;
           
           if(nx < 0 || nx > X-1) {
             print("($ax, $ay)\n");
             print("($nx, $ny)\n");
           }
           if(ny < 0 || ny > Y-1) {
             print("($ax, $ay)\n");
             print("($nx, $ny)\n");
           }
           
           xp1 = math.min(nx+1, X-1);
           yp1 = math.min(ny+1, Y-1);
           
           //print(iy*X + ix);
           
           h1[iy*X + ix] = h[ny*X + nx]*(1.0-ax)*(1.0-ay) + h[ny*X + xp1]*(ax)*(1.0-ay) + h[yp1*X + nx]*(1.0-ax)*(ay) + h[yp1*X + xp1]*(ax)*(ay);
           //h1[iy*X + ix] = h1[iy*X + ix].abs();
        
         }    
       }
       
       //print("h-end");
       //print("----------------");
       //print("vx-start");
       
       for(int iy = 0; iy < Y; iy++) {
         for(int ix = 1; ix < X1-1; ix++) {
           int ym1 = math.max(iy - 1, 0);
           int xm1 = math.max(ix - 1, 0);
           int xp1 = math.min(ix + 1, X-1);
           int yp1 = math.min(iy + 1, Y1-1);
                  
           double ax = ix -   vx[iy*X1 +  ix] * t;
           double ay = iy - ((vy[iy*X + xm1] + vy[iy*X + ix] + vy[yp1*X + xm1] + vy[yp1*X + ix])/4.0) * t;
           
           int nx = ax.toInt();
           int ny = ay.toInt();
           
           ax = ax - nx;
           ay = ay - ny;
           
           xp1 = math.min(nx+1, X1-1);
           yp1 = math.min(ny+1, Y-1);
           
           

           vx1[iy*X1 + ix] = vx[ny*X1 + nx]*(1.0-ax)*(1.0-ay) + vx[ny*X1 + xp1]*(ax)*(1.0-ay) + vx[yp1*X1 + nx]*(1.0-ax)*(ay) + vx[yp1*X1 + xp1]*(ax)*(ay);
         }
       }
       
       //print("vx-end");
       //print("----------------");
       //print("vy-start");
       
       for(int iy = 1; iy < Y1-1; iy++) {
         for(int ix = 0; ix < X; ix++) {
           int ym1 = math.max(iy - 1, 0);
           int xm1 = math.max(ix - 1, 0);
           int xp1 = math.min(ix + 1, X1-1);
           int yp1 = math.min(iy + 1, Y-1);
           
           double ax = ix - ((vx[ym1*X1 + ix] + vx[ym1*X1 + xp1] + vx[iy*X1 + ix] + vx[iy*X1 + xp1])/4.0) * t;
           double ay = iy -   vy[iy*X  + ix] * t;
           
           int nx = ax.toInt();
           int ny = ay.toInt();
           
           ax = ax - nx;
           ay = ay - ny;
           
           xp1 = math.min(nx+1, X-1);
           yp1 = math.min(ny+1, Y1-1);
           
           vy1[iy*X + ix] = vy[ny*X + nx]*(1.0-ax)*(1.0-ay) + vy[ny*X + xp1]*(ax)*(1.0-ay) + vy[yp1*X + nx]*(1.0-ax)*(ay) + vy[yp1*X + xp1]*(ax)*(ay);
         }
       }
       
       //swaps go here
       //print("vy-end");
       //print("----------------");
       
       
       //print(h[35*X+35]);
       
       swap(h,h1);    
       swap(vx,vx1);
       swap(vy,vy1);
       
      
       
       
       
       for(int iy = 0; iy < Y; iy++) {
         for(int ix = 0; ix < X; ix++) {
           int ym1 = math.max(iy - 1, 0);
           int xm1 = math.max(ix - 1, 0);
           int xp1 = math.min(ix + 1, X-1);
           int yp1 = math.min(iy + 1, Y-1);
           
            h[iy*X + ix] = h[iy*X + ix] + h[iy*X + ix] * ((vx[iy*X1 + ix] - vx[iy*X1 + ix+1]) + (vy[iy*X + ix] - vy[(iy+1)*X + ix])) * t;
            /*if( g[iy*X + ix] - h[iy*X + ix] < 0.0 && h[iy*X + ix] != 0.0){
              //print(h[iy*X + ix]);
              h[iy*X + ix] = h1[iy*X + ix];
            }*/
            //h[iy*X + ix] = h[iy*X + ix].abs();
         }
       }
       
       for(int iy = 0; iy < Y; iy++) {
         for(int ix = 1; ix < X1-1; ix++) {
     
           
           int ym1 = math.max(iy - 1, 0);
           int xm1 = math.max(ix - 1, 0);
           int xp1 = math.min(ix + 1, X-1);
           int yp1 = math.min(iy + 1, Y-1);
           
           
           //if(g[iy*X + ix] < h[iy*X + ix]){
            // h[iy*X + ix] = 0.0;          
            // vx1[iy*X1 + ix] = vx[iy*X1 + ix];
           //}else{
             vx1[iy*X1 + ix] = vx[iy*X1 + ix] + 9.8 * ((g[iy*X + xm1] + h[iy*X + xm1]) - (g[iy*X + ix] + h[iy*X + ix])) * t;
           //}
           
         }
       }
     
     
       for(int iy = 1; iy < Y1-1; iy++) {
         for(int ix = 0; ix < X; ix++) {
     
           int ym1 = math.max(iy - 1, 0);
           int xm1 = math.max(ix - 1, 0);
           int xp1 = math.min(ix + 1, X-1);
           int yp1 = math.min(iy + 1, Y-1);
           
           if((h[iy*X + ix]) < 0.0){
             //print(h[iy*X + ix]);
           }
           
           //if(g[iy*X + ix] < h[iy*X + ix]){
             //h[iy*X + ix] = 0.0;
            // vy1[iy*X + ix] = vy[iy*X + ix];
          // }else{
           vy1[iy*X + ix] = vy[iy*X + ix] + 9.8 * ((g[ym1*X + ix] + h[ym1*X + ix]) - (g[iy*X + ix] + h[iy*X + ix])) * t;
          // }
         }
       }
       
       
       //print(vx1[130]);
       
       //swap(h,h1);
       swap(vx,vx1);
       swap(vy,vy1);
       
       //_listsAreEqual(vx, vx1)? print("true") : print("false");
       
       //print(wVert.length);

       
       var value = 0.0;
       
       for(var a = 0; a < blobMap.length; a++){
         for(var b = 0; b < blobMap[0].length; b++){
           
           value = (a * (blobMap[0].length))+(b); 
           
           wVert[(value*3)+1] = h[a*Y+b] -0.6;

         }
       }
       
       
       
       
       gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);  
       gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(wVert));
       
       var norm = new List();

       for(int x = 0; x < blobMap.length ; x++){
         for(int y = 0; y < blobMap[x].length; y++){
           
           var r = new Vector3.zero();
           
           r = calcNormal(y, x);
           
           //r.normalize();
           
           norm.add(r.x);
           norm.add(r.y);
           norm.add(r.z);
           
           
         }
       }
       
           
       //print(norm.length);
       
       
       gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterNorm);
       gl.bufferSubData(webgl.ARRAY_BUFFER, 0, new Float32List.fromList(norm));
       
       

  }
  
  void draw(Matrix4 viewMat, Matrix4 projectMat){
    print("bye");
  }
  
  
  void drawWater(Matrix4 viewMat, Matrix4 projectMat){
     
    gl.useProgram(waterShader);
    
    utils.setMatrixUniforms(gl, viewMat, projectMat, waterUniforms['uPMatrix'], waterUniforms['uMVMatrix'], waterUniforms['uNormalMatrix']);
  
    gl.enableVertexAttribArray(waterAttributes['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, waterVert);
    gl.vertexAttribPointer(waterAttributes['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(waterAttributes['aVertexNormal']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, waterNorm);
    gl.vertexAttribPointer(waterAttributes['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
  
        
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, waterInd);
    
    //gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);
    
    //print(waterIndices.length);
   
    
  }
  
  
  
  
}