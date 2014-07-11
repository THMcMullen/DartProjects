library water;

import 'dart:web_gl' as webgl;
import 'utils.dart' as utils;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';




class water{
  
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
  
  var X = 129;
  var Y = 129;
  var X1;
  var Y1;  
  
  
  var d = 129;
  
  double t = 0.025;
  
  var bigArray;
  
  //var inter = new List<double>(129*129);
  

  
  water(webgl.RenderingContext givenGl){
    print("Creating Water");
    
    gl = givenGl;
    
    
    setupLand();
    setupBox();
    setupWater();
    
    
    //for testing, creating a box for the water to be placed in.
  }
  
  void setupLand(){
    
   
    
    
    
    
  }
  
  void setupWater(){
    
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

                gl_FragColor = vec4(vLighting, 1.0);

            }""";
    
    waterShader = utils.loadShaderSource(gl, verts, frag);
    
    var attrib = ['aVertexPosition', 'aVertexNormal'];
    var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    waterAttributes = utils.linkAttributes(gl, waterShader, attrib);
    waterUniforms = utils.linkUniforms(gl, waterShader, unif);
    
    
    wVert = new List();
    waterIndices = new List();
    
    var pos;
    
    //d = 129;
    
    waterVert = gl.createBuffer();
    waterInd = gl.createBuffer();
    
    
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
    
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, waterInd);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(waterIndices), webgl.STATIC_DRAW);
   
    
    //print(waterIndices.length);
    
    for(double i = 0.0; i < d; i++){
      for(double j = 0.0; j < d; j++){        
        
        wVert.add(((i)-d/20)-48);
        wVert.add(0.45);
        wVert.add(((j)-d/20)-48);
        
      }
    } 
   
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);    
    gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(wVert), webgl.DYNAMIC_DRAW);
    
    
    
    
    for(int i = 0; i < waterIndices.length; i++){
      wNorm.add(-1.0);
    }
    
    
    waterNorm = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterNorm);
    gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(wNorm), webgl.STATIC_DRAW);
    

      
      
    
    
    initWater();
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
        
        g[iy*X + ix] = bigArray[ix][iy];
        if(bigArray[ix][ix] < 0.0){
          print(bigArray[ix][ix]);
        }

      }
    }
    
    for(int iy = 0; iy < Y; iy++){
      for(int ix = 0; ix < X; ix++){
        h[iy*X + ix] = math.max(g[iy*X + ix]+0.1, 0.0);
        h1[iy*X + ix] = h[iy*X + ix];        
      }
    }
    //print(g[35*X+35]);
    //print(h[35*X+35]);

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
          h[iy*X + ix] += Y * (1/math.sqrt(2 * PI)) * math.exp(-(r*r) / 2);
          
          
          //h[iy*X + ix] += ((Y/4) - r) * ((Y/4) - r);
        }
      }
    }/*
    for(int iy = 50; iy < Y-50; iy++) {
      for(int ix = 50; ix < X-50; ix++) {
        
          h[iy*X + ix] += 5.0;

      }
    }
    */
    
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
  
  swap(List a, List b){
    var temp = new List(a.length);
    for(int i = 0; i < a.length; i ++){
      temp[i] = a[i];
      a[i] = b[i];
      b[i] = temp[i];
    }
  }
  
  void waterUpdate(){
    
    
    //print("h-start");
    
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
    
    

    
    var value;
    
    for(var a = 0; a < d; a++){
      for(var b = 0; b < d; b++){
          value =(a*d)+(b); 
                              
          wVert[(value*3)+1] = h[a*X+b] + g[a*X+b];
          
      }
    }  
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);  
    gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(wVert));
    
    var norm = new List();

    for(int x = 0; x < d ; x++){
      for(int y = 0; y < d; y++){
        
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

  bool _listsAreEqual(list1, list2) {
    var i=-1;
    return list1.every((val) {
      i++;
      if(val is List && list2[i] is List) return _listsAreEqual(val,list2[i]);
      else return list2[i] == val;
    });
  }
  
  void setupBox(){
  
    String verts = """
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
    
    String frag = """
            precision mediump float;

            varying vec3 vLighting;
            varying vec3 vColoring;
        
            void main(void) {

                vec4 color = vec4(vColoring,1);
                float alpha = vColoring.y / 5.0;


                if(vColoring.y < 0.0)
                  color = vec4(0.3+alpha, 0.8, 0.3+alpha, 1.0 );
                else if(vColoring.y < 1.0)
                  color = vec4(0.3+alpha, 0.8, 0.3+alpha, 1.0);
                else
                  color = vec4(0.8, 0.42, 0.42, (.6 + alpha) );
        
                gl_FragColor = color;
                

            }""";
    
    shader = utils.loadShaderSource(gl, verts, frag);
    
    
    var attrib = ['aVertexPosition', 'aVertexNormal'];
    var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    attributes = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    var rng = new math.Random();
       
     var hi = 10;
     
     bigArray = new List(d);
         for(int i = 0; i < d; i++){
           bigArray[i] = new List(d);
           for(int j = 0; j < d; j++){
             bigArray[i][j] = 0.1; 
           }      
         }
         
         
     bigArray[0][0] = 2.0;
                 
     for(int sideLength = d-1; sideLength >= 2; sideLength = sideLength ~/ 2, hi /=2 ){
       
       int halfSide = sideLength~/2;
       
       for(int x = 0; x < d-1; x+=sideLength){
         for(int y = 0; y < d-1; y +=sideLength){
           
           double avg = bigArray[x][y]     +
               bigArray[x+sideLength][y]   +
               bigArray[x][y+sideLength]   +
               bigArray[x+sideLength][y+sideLength];
           
           
           avg /= 4.0;
           
           double offset = (-hi) + rng.nextDouble() * (hi- (-hi));
           bigArray[x+halfSide][y+halfSide] = avg + offset;
           
         }
       }
       
       for(int x = 0; x < d; x+=halfSide){
         for(int y = (x+halfSide)%sideLength ; y < d; y+= sideLength){
           
           double avg = 
               bigArray[(x-halfSide+d)%d][y] +
               bigArray[(x+halfSide)%d][y]   +
               bigArray[x][(y+halfSide)%d]   +
               bigArray[x][(y-halfSide+d)%d];
           
           avg /= 4;
           
           double offset = (-hi) + rng.nextDouble() * (hi- (-hi));
           
           //if x == 0 and givenX != 0, set to buffered data
           //if y == 0 and givenY != 0, ^
           
           bigArray[x][y] = avg + offset;

         }
       }          
     }
     
     var min = 0.0;
     
     /*for(int i = 0; i < X; i++){
       for(int j = 0; j < Y; j++){
         if(bigArray[i][j] < min){
           min = bigArray[i][j];
         }//+= 0.0;//(i.toDouble() + j.toDouble()) / 10;; 
       }
     }*/
     for(int i = 0; i < X; i++){
       for(int j = 0; j < Y; j++){
         bigArray[i][j] = min.abs();//(i.toDouble() + j.toDouble()) / 10;; 
       }
     }
     
     //print(min);
     /*
     for(int i = 50; i < X-50; i++){
       for(int j = 50; j < Y-50; j++){
         bigArray[i][j] += 5.0;
       }
     }*/
     /*
     for(int i = 30; i < 40; i++){
           for(int j = 30; j < 40; j++){
             bigArray[i][j] += 15.0;
           }
         }

    */ 
     
     var vert = new List();
     for(double i = 0.0; i < d; i++){
       for(double j = 0.0; j < d; j++){

         vert.add(((i)-d/20)-48);
         vert.add((bigArray[j.toInt()][i.toInt()]));
         vert.add(((j)-d/20)-48);

          //print(bigArray[j.toInt()][i.toInt()]);         
         
         
       }
     } 
     
     
    boxVert = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, boxVert);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);

    


  }
  
   void draw(Matrix4 viewMat, Matrix4 projectMat){
    drawBox(viewMat, projectMat);
    drawWater(viewMat, projectMat);
  }
  
  void drawBox(Matrix4 viewMat, Matrix4 projectMat){
    
    gl.useProgram(shader);
    
    utils.setMatrixUniforms(gl, viewMat, projectMat, uniforms['uPMatrix'], uniforms['uMVMatrix'], uniforms['uNormalMatrix']);
    
    gl.enableVertexAttribArray(attributes['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, boxVert);
    gl.vertexAttribPointer(attributes['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    //gl.enableVertexAttribArray(attributes['aVertexNormal']);
    //gl.bindBuffer(webgl.ARRAY_BUFFER, norm);
    //gl.vertexAttribPointer(attributes['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, waterInd);
    gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);

    
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
    gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);
    //gl.drawElements(webgl.TRIANGLE_STRIP, 480, webgl.UNSIGNED_SHORT, 0);
    
    //print(waterIndices.length);
    
    
  }
  
  
  
  
}