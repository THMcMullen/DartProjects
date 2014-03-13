//creates a container, which holds several landscapes which mesh together, based on a given size
  // - generates the mesh
  // - links meshes together
  // - contain the draw function for each given mesh
import 'package:vector_math/vector_math.dart';
import 'dart:web_gl' as webgl;
import 'utils.dart' as utils;
import 'dart:typed_data';
import 'dart:math' as math;

class landgen{
  
  var masterMesh;
  var gl;
  
  var water;
  
  Map<String, int> attribute;
  Map<String, int> uniforms;
  
  
  webgl.Program shader; 
  
  landgen(int size, webgl.RenderingContext givenGl, String vert, String frag){
    
    gl = givenGl;
    shader = utils.loadShaderSource(gl, vert, frag);
    
    var attrib = ['aVertexPosition'];
    var unif = ['uPMatrix','uMVMatrix'];
    
    attribute = utils.linkAttributes(gl, shader, attrib);
    uniforms = utils.linkUniforms(gl, shader, unif);
    
    var gridSize = 129;
    
    var edge = new List(gridSize*size);
    for(int i = 0; i < gridSize*size ; i++){
      edge[i] = new List(size*2);
      for(int j = 0; j < size*2; j++){
        edge[i][j] = 10.0;
      }
    }

    
    masterMesh = new List<mesh>();
    
    for(int x = 0; x < size; x++){
      for(int y = 0; y < size; y++){
        masterMesh.add(new mesh(x,y, gl, edge, gridSize, size));
        
        
      }
    }
    
    for(int i = 0; i < gridSize*size; i++){
      for(int j = 0; j < size*2; j++){
        if(edge[i][j] == 10.0){
          //print("I: $i, J: $j");
        }
      }      
    }
    
    //water = new shallowWater(masterMesh[0], gl);
    
    
    
  }
  
  drawMesh(Matrix4 viewMat, Matrix4 projectionMat){  
    //water.update();
    //water.draw(gl, attribute, uniforms, viewMat, projectionMat);
    
    for(int i = 0; i < masterMesh.length; i++){
      masterMesh[i].draw(gl, attribute, uniforms, viewMat, projectionMat);
    }
  }

}

//*****************************************************************
//*****************************************************************
//********************Water Code Starts Here***********************
//*****************************************************************
//*****************************************************************


class shallowWater{
  
  var g;
  
  var t;
  
  var h, h1;
  var vx, vx1;
  var vy, vy1;
  
  var X = 129;
  var Y = 129;
  var X1;
  var Y1;
  
  var gl;
  
  var indexBuffer;
  var vertexBuffer;
  
  var vert = new List();
  var indices = new List();
  
  var size;
  
  
  
  
  shallowWater(var meshData, webgl.RenderingContext givenGl){
    
    gl = givenGl;
     
    int d = X;
    
    int pos;
    var h = 5;
    t = 0.25;
    //var indices = new List();
    //var vert = new List();
    

    
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

    vertexBuffer = gl.createBuffer();
    indexBuffer = gl.createBuffer();  
 
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    //Uint16List indArray = new Uint16List.fromList(temp["indices"]);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(indices), webgl.RenderingContext.STATIC_DRAW);
      
    for(double i = 0.0; i < d; i++){
      for(double j = 0.0; j < d; j++){

        vert.add(((i + (d))/8)-24);
        vert.add(((j + (d))/8)-24);

        vert.add(0.0);
        
        
      }
    }  
    
    
    init();
    update();
    
  }
  
  swap(var a, var b){
    var temp = a;
    a = b;
    b = temp;
  }
  
  init(){
    
    X1 = X + 1;
    Y1 = Y + 1;
    
    g = new List<double>(X*Y);
    h = new List<double>(X*Y);
    h1 = new List<double>(X*Y);
    
    vx = new List<double>(Y*X1);
    vx1 = new List<double>(Y*X1);
    
    vy = new List<double>(Y1*X);
    vy1 = new List<double>(Y1*X);
    
    for(int iy = 0; iy < Y; iy++) {
      for(int ix = 0; ix < X; ix++) {
        g[iy*X + ix] = 0.0;
      }
    }

    for(int iy = 0; iy < Y; iy++) {
      for(int ix = 0; ix < X; ix++) {
        h[iy*X + ix]   = math.max(2.0 - g[iy*X + ix], 0.0);
        h1[iy*X + ix]  = h[iy*X + ix];
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
    
    size = indices.length;
    
    
    var value;
    
    for(var a = 0; a < X; a++){
      for(var b = 0; b < X; b++){
          value =(a*129)+(b);

          vert[(value*3)+2] = h[a*X+b];//bigArray[a][b];
         
      }
    }  

    
    vertexBuffer = gl.createBuffer();
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertexBuffer);    
    gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.RenderingContext.DYNAMIC_DRAW);
    
    
  }

  
  update(){

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
    
    print(h);
    print(h1);
    
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

    
    
    
    
    var value;
    
    for(var a = 0; a < X; a++){
      for(var b = 0; b < X; b++){
          value =(a*129)+(b);

          vert[(value*3)+2] = h1[a*X+b];//bigArray[a][b];
          
      }
    }  
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertexBuffer);  
    gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(vert));
    
    


    
  }
  
  draw(webgl.RenderingContext givenGl, Map<String, int> attribute, Map<String, int> uniforms, Matrix4 viewMat, Matrix4 projectionMat){


    givenGl.enableVertexAttribArray(attribute['aVertexPosition']);
    //Seems to work so far, as the data is not passed as ints, but as they are meant to be.
    utils.setMatrixUniforms(givenGl, viewMat, projectionMat, uniforms['uPMatrix'], uniforms['uMVMatrix']);
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertexBuffer);
    gl.vertexAttribPointer(attribute['aVertexPosition'], 3, webgl.RenderingContext.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.drawElements(webgl.RenderingContext.TRIANGLES, size, webgl.RenderingContext.UNSIGNED_SHORT, 0);
    
    
    
    
  }
  
}


//*****************************************************************
//*****************************************************************
//*********************Water Code Ends Here************************
//*****************************************************************
//*****************************************************************



class mesh{
  
  int x;
  int y;

  var gl;
  var cubeVertexPositionBuffer;
  var cubeVertexIndexBuffer;
  
  var vertices;
  var size; 
  
  
  var vertexBuffer;
  var indexBuffer;
  

  
  mesh(int givenX, int givenY, webgl.RenderingContext givenGl, var edge, int gridSize, var grid){
    x = givenX;
    y = givenY;
    
    gl = givenGl;
    
    var rng = new math.Random();
    
    int pos;
    var d = gridSize;
    var h = 5;
    var indices = new List();
    var vert = new List();
    

    
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
    
    indexBuffer = gl.createBuffer();  
 
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    //Uint16List indArray = new Uint16List.fromList(temp["indices"]);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(indices), webgl.RenderingContext.STATIC_DRAW);
      
    for(double i = 0.0; i < d; i++){
      for(double j = 0.0; j < d; j++){

        vert.add(((i + (givenX*d-givenX))/8)-24);
        vert.add(((j + (givenY*d-givenY))/8)-24);

        vert.add(0.0);
        
        
      }
    }  
    
    vert[2] = 2.0;
    vert[(d*3)-1] = 2.0;
    vert[(d*d*3)-1] = 2.0;
    vert[(d*d*3)-(d*3)+2] = 2.0;
       
    //if we are not x == 0 && y == 0 edge update these values to the correst ones

    
    
    var bigArray = new List(d);
    for(int i = 0; i < d; i++){
      bigArray[i] = new List(d);
      for(int j = 0; j < d; j++){
        bigArray[i][j] = 0.0; 
      }      
    }
    
    var date = new DateTime.now().millisecondsSinceEpoch;
    
    for(int sideLength = d-1; sideLength >= 2; sideLength = sideLength ~/ 2, h /=2 ){
      
      int halfSide = sideLength~/2;
      
      for(int x = 0; x < d-1; x+=sideLength){
        for(int y = 0; y < d-1; y +=sideLength){
          
          double avg = bigArray[x][y]     +
              bigArray[x+sideLength][y]   +
              bigArray[x][y+sideLength]   +
              bigArray[x+sideLength][y+sideLength];
          
          
          avg /= 4.0;
          
          double offset = (-h) + rng.nextDouble() * (h- (-h));
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
          
          double offset = (-h) + rng.nextDouble() * (h- (-h));
          
          //if x == 0 and givenX != 0, set to buffered data
          //if y == 0 and givenY != 0, ^
          
          bigArray[x][y] = avg + offset;
          
          if(x == 0 && givenX != 0){
            bigArray[x][y] = edge[y+((givenY)*d)][givenX-1];
          }
          if(y == 0 && givenY != 0){
            bigArray[x][y] = edge[x][givenY+grid-1];
            
          }
          
          //store into a buffer
          
          if(x == d-1){
            //bigArray[x][y] = (y.toDouble()/60+givenY);
            edge[y+(givenY*d)][givenX] = bigArray[x][y];
            
          }
          if(y == d-1){
            edge[x][givenY+grid] = bigArray[x][y];
            
          }
          
          
          
        }
      }
      
      
      
    }
    
    var value;
    
    for(var a = 0; a < d; a++){
      for(var b = 0; b < d; b++){

        //if(((a == 0) || (a==(d-1))) && ((b == 0) || (b==(d-1)))){

          value =(a*d)+(b);
          //alert(value*3+2);

          vert[(value*3)+2] = bigArray[a][b];
          
        //}
        

      }
    }  
    

    
    
    bigArray = null;
    
    size = indices.length;
    
    vertexBuffer = gl.createBuffer();
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertexBuffer);    
    gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vert), webgl.RenderingContext.STATIC_DRAW);
    
    var finaldate = new DateTime.now().millisecondsSinceEpoch;
    
    print(finaldate - date);
  

    
  }
  
  draw(webgl.RenderingContext givenGl, Map<String, int> attribute, Map<String, int> uniforms, Matrix4 viewMat, Matrix4 projectionMat){
    
    
    //print(viewMat);

    givenGl.enableVertexAttribArray(attribute['aVertexPosition']);
    //Seems to work so far, as the data is not passed as ints, but as they are meant to be.
    utils.setMatrixUniforms(givenGl, viewMat, projectionMat, uniforms['uPMatrix'], uniforms['uMVMatrix']);
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertexBuffer);
    gl.vertexAttribPointer(attribute['aVertexPosition'], 3, webgl.RenderingContext.FLOAT, false, 0, 0);
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.drawElements(webgl.RenderingContext.TRIANGLES, size, webgl.RenderingContext.UNSIGNED_SHORT, 0);
    
    
    
    
  }
  
}