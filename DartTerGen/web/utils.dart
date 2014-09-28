import 'dart:web_gl' as webgl;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

webgl.Program loadShaderSource(webgl.RenderingContext gl, String vertShaderSource, String fragShaderSource){
  
  webgl.Shader fragShader = gl.createShader(webgl.RenderingContext.FRAGMENT_SHADER);
  webgl.Shader vertShader = gl.createShader(webgl.RenderingContext.VERTEX_SHADER);
  
  //Links the Shader with the source code
  gl.shaderSource(fragShader, fragShaderSource);
  gl.shaderSource(vertShader, vertShaderSource);
  
  //Compiles the Shader code
  gl.compileShader(fragShader);
  gl.compileShader(vertShader);
  
  //Create Shader program, and link the Fragment and Vertex Shader to it.
  webgl.Program shaderProgram = gl.createProgram();
  gl.attachShader (shaderProgram, vertShader);
  gl.attachShader (shaderProgram, fragShader);
  gl.linkProgram  (shaderProgram);
  gl.useProgram   (shaderProgram);
  
  //Check to make sure the shaders were compiled and linked correctly
  if(!gl.getProgramParameter(shaderProgram, webgl.RenderingContext.LINK_STATUS)){
    
    gl.deleteProgram(shaderProgram);
    print("shaders failed");
    
  }else{
    
  //Only return shaders if they compiled correctly  
  print("O Holy God of the Web, and all things Dart, please make these shadders work");
  return shaderProgram;
  
  }
}


Map<String, int> linkAttributes(webgl.RenderingContext gl, webgl.Program shader, attr){
  
  Map<String, int> attrib = new Map.fromIterable(attr,
        key: (item) => item,
        value: (item) => gl.getAttribLocation(shader, item));
  
  return attrib;
  
}


Map<String, int> linkUniforms(webgl.RenderingContext gl, webgl.Program shader, uni){
  
  Map<String, int> uniform = new Map.fromIterable(uni,
        key: (item) => item,
        value: (item) => gl.getUniformLocation(shader, item));
  
  return uniform;
  
}

void setMatrixUniforms(webgl.RenderingContext gl,  Matrix4 mvMatrix,  Matrix4 pMatrix, webgl.UniformLocation pMatrixUniform, webgl.UniformLocation mvMatrixUniform) {
  
  Float32List tempMV = new Float32List(16);
  Float32List tempP = new Float32List(16);
  for(int i = 0; i < 16; i++){
    tempMV[i] = mvMatrix[i];
    tempP[i] = pMatrix[i];
    //print(pMatrix[i]);
  }   
  
  gl.uniformMatrix4fv(pMatrixUniform, false, tempP);
  gl.uniformMatrix4fv(mvMatrixUniform, false, tempMV);
}


