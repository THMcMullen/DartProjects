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
  
  var wVert;
  var waterVert;
  var waterInd;
  
  var g;
  var h, h1;
  var vx, vx1;
  var vy, vy1;
  
  var X = 100;
  var Y = 100;
  var X1;
  var Y1;  
  
  double t = 0.025;
  
  water(webgl.RenderingContext givenGl){
    print("Creating Water");
    
    gl = givenGl;  
    
    setupBox();
    setupWater();
    
    //for testing, creating a box for the water to be placed in.
  }
  
  void setupWater(){
    
    String verts = """
            attribute vec3 aVertexPosition;
           
            uniform mat4 uMVMatrix;
            uniform mat4 uPMatrix;
            uniform mat3 uNormalMatrix;
        
            void main(void) {
                gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
            }""";

    String frag = """
            precision mediump float;
      
            void main(void) {
                gl_FragColor = vec4(0.0,0.0,0.9,0.4);

            }""";
    
    waterShader = utils.loadShaderSource(gl, verts, frag);
    
    var attrib = ['aVertexPosition'];
    var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    waterAttributes = utils.linkAttributes(gl, waterShader, attrib);
    waterUniforms = utils.linkUniforms(gl, waterShader, unif);
    
    
    wVert = new List();
    var indices = new List();
    
    var pos;
    
    var d = 100;
    
    waterVert = gl.createBuffer();
    waterInd = gl.createBuffer();
    
    
    for(int i = 0; i < d-1; i++){
      for(int j = 0; j < d-1; j++){
       
        //the possition of the vertic in the indice array we want to draw.
        pos = (i*d+j);
        
        //print(pos);
        
        //top half of triangle
        indices.add(pos);
        indices.add(pos+1);
        indices.add(pos+d);
        
        //bottem half of triangle
        indices.add(pos+d);
        indices.add(pos+d+1);
        indices.add(pos+1);
        

        
      }
    }
    
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, waterInd);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(indices), webgl.STATIC_DRAW);
   
    
    for(double i = 0.0; i < d; i++){
      for(double j = 0.0; j < d; j++){

        wVert.add((i/10)-2.0);
        wVert.add(0.45);

        wVert.add((j/10)-2.0);
        
        
      }
    } 
    
   
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);    
    gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(wVert), webgl.DYNAMIC_DRAW);
    
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
        g[iy*X + ix] = 0.0;
      }
    }
    
    for(int iy = 0; iy < Y; iy++){
      for(int ix = 0; ix < X; ix++){
        h[iy*X + ix] = math.max(2.0 - g[iy*X + ix], 0);
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
          h[iy*X + ix] += Y * (1/math.sqrt(2 * PI)) * math.exp(-(r*r) / 2);
          
          
          //h[iy*X + ix] += ((Y/4) - r) * ((Y/4) - r);
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
        
        xp1 = math.min(nx+1, X-1);
        yp1 = math.min(ny+1, Y-1);
        
        h1[iy*X + ix] = h[ny*X + nx]*(1.0-ax)*(1.0-ay) + h[ny*X + xp1]*(ax)*(1.0-ay) + h[yp1*X + nx]*(1.0-ax)*(ay) + h[yp1*X + xp1]*(ax)*(ay);
      }    
    }
    
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

      }
    }
    
    for(int iy = 0; iy < Y; iy++) {
      for(int ix = 1; ix < X1-1; ix++) {
  
        
        int ym1 = math.max(iy - 1, 0);
        int xm1 = math.max(ix - 1, 0);
        int xp1 = math.min(ix + 1, X-1);
        int yp1 = math.min(iy + 1, Y-1);
        
        vx1[iy*X1 + ix] = vx[iy*X1 + ix] + 9.8 * ((g[iy*X + xm1] + h[iy*X + xm1]) - (g[iy*X + ix] + h[iy*X + ix])) * t;
        
      }
    }
  
  
    for(int iy = 1; iy < Y1-1; iy++) {
      for(int ix = 0; ix < X; ix++) {
  
        int ym1 = math.max(iy - 1, 0);
        int xm1 = math.max(ix - 1, 0);
        int xp1 = math.min(ix + 1, X-1);
        int yp1 = math.min(iy + 1, Y-1);
        
       
        vy1[iy*X + ix] = vy[iy*X + ix] + 9.8 * ((g[ym1*X + ix] + h[ym1*X + ix]) - (g[iy*X + ix] + h[iy*X + ix])) * t;
      }
    }
    
    //swap(h,h1);
    swap(vx,vx1);
    swap(vy,vy1);
    
    //_listsAreEqual(vx, vx1)? print("true") : print("false");
    
    

    
    var value;
    
    for(var a = 0; a < 100; a++){
      for(var b = 0; b < 100; b++){
          value =(a*100)+(b);

          wVert[(value*3)+1] = h1[a*X+b];
          
      }
    }  
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);  
    gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(wVert));
    

    
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
  
            void main(void) {
                gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

                vec3 ambientLight = vec3(0.6,0.6,0.6);
                vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
                vec3 directionalVector = vec3(0.85, 0.8, 0.75);

                vec3 transformedNormal = uNormalMatrix * aVertexNormal;

                float directional = max(dot(transformedNormal, directionalVector), 0.0);
                vLighting = ambientLight + (directionalLightColor * directional);


               

            }""";
    
    String frag = """
            precision mediump float;

            varying vec3 vLighting;
        
            void main(void) {
                gl_FragColor = vec4(vLighting, 0.9);

            }""";
    
    shader = utils.loadShaderSource(gl, verts, frag);
    
    
    var attrib = ['aVertexPosition', 'aVertexNormal'];
    var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
    
    attributes = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    var vert = [// Front face
                -2.0, -0.5,  2.0,
                2.0, -0.5,  2.0,
                2.0,  0.5,  2.0,
                -2.0,  0.5,  2.0,

                // Back face
                -2.0, -0.5, -2.0,
                -2.0,  0.5, -2.0,
                2.0,  0.5, -2.0,
                2.0, -0.5, -2.0,

                // Top face
                -1.0,  1.0, -1.0,
                -1.0,  1.0,  1.0,
                1.0,  1.0,  1.0,
                1.0,  1.0, -1.0,

                // Bottom face
                -2.0, -0.5, -2.0,
                2.0, -0.5, -2.0,
                2.0, -0.5,  2.0,
                -2.0, -0.5,  2.0,

                // Right face
                2.0, -0.5, -2.0,
                2.0,  0.5, -2.0,
                2.0,  0.5,  2.0,
                2.0, -0.5,  2.0,

                // Left face
                -2.0, -0.5, -2.0,
                -2.0, -0.5,  2.0,
                -2.0,  0.5,  2.0,
                -2.0,  0.5, -2.0
                ];
    boxVert = gl.createBuffer();
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, boxVert);
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.STATIC_DRAW);
    
    norm = gl.createBuffer();
    gl.bindBuffer(webgl.ARRAY_BUFFER, norm);
    
    var vertexNormals = [
                         // Front
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         
                         // Back
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         
                         // Top
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         
                         // Bottom
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         
                         // Right
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         
                         // Left
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0
                         ];
    
    gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(vertexNormals), webgl.STATIC_DRAW);
    
    ind = gl.createBuffer();
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, ind);
    gl.bufferDataTyped(webgl.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList([
                0, 1, 2,      0, 2, 3,    // Front face
                4, 5, 6,      4, 6, 7,    // Back face
                //8, 9, 10,     8, 10, 11,  // Top face
                12, 13, 14,   12, 14, 15, // Bottom face
                16, 17, 18,   16, 18, 19, // Right face
                20, 21, 22,   20, 22, 23  // Left face
                ]), webgl.STATIC_DRAW);

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
    
    gl.enableVertexAttribArray(attributes['aVertexNormal']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, norm);
    gl.vertexAttribPointer(attributes['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, ind);
    gl.drawElements(webgl.TRIANGLES, 30, webgl.UNSIGNED_SHORT, 0);

    
  }
  
  void drawWater(Matrix4 viewMat, Matrix4 projectMat){
    
    gl.useProgram(waterShader);
    
    utils.setMatrixUniforms(gl, viewMat, projectMat, waterUniforms['uPMatrix'], waterUniforms['uMVMatrix'], waterUniforms['uNormalMatrix']);

    gl.enableVertexAttribArray(waterAttributes['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, waterVert);
    gl.vertexAttribPointer(waterAttributes['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);

        
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, waterInd);
    gl.drawElements(webgl.TRIANGLES, 58806, webgl.UNSIGNED_SHORT, 0);
    
    
  }
  
  
  
  
}