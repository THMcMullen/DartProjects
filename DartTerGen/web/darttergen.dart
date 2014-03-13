//Setup basic webgl
//Add camera class
//Add single square landscape
  // - Extend to allow for multiple squares to be added to it
  // - Us multiple draw calls to split up the program to allow for larger and more detailed terrian to be created

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'landscape.dart';

void main(){
  print("Landscape Gen");
  
  //In this we launch the main loop of the engine
  //Set up our gl context within WebGL, based on the canvas  
  CanvasElement canvas =  querySelector("#game-canvas");  
  webgl.RenderingContext gl = canvas.getContext("experimental-webgl");
  
  //Set up and load in the shaders, shader code is stored in a string, and will be placed here.
  //The multilined string storing our fragment shader
  String fragShaderSource = """
      precision mediump float;

      varying vec4 vColor;

      void main(void) {

        vec4 color = vColor;
        float alpha = vColor.z / 5.0;


        if(vColor.z < -1.3)
          color = vec4(0.0, 0.0,1.0, 1.0+alpha );
        else if(vColor.z < 1.0)
          color = vec4(0.3+alpha, 0.8, 0.3+alpha, 1.0);
        else
          color = vec4(0.8, 0.42, 0.42, (.6 + alpha) );

        gl_FragColor = color;

    }""";
    
  //Same as above but stores our vertex shader
  String vertShaderSource = """

    attribute vec3 aVertexPosition;
  
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;

    varying vec4 vColor;
  
    void main(void) {

      gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
      vColor = vec4(aVertexPosition, 1);
    }""";
  
  var land = new landscape(gl, canvas, vertShaderSource, fragShaderSource);
  
  renderLoop(time){
    window.requestAnimationFrame(renderLoop);
    land.draw(gl);
  }
  
  renderLoop(1);
  
  
}