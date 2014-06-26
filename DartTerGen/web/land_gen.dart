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