library tree;

import 'dart:math' as math;
import 'dart:web_gl' as webgl;

import 'utils.dart' as utils;

import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

class tree{
  
    var radiusTop = 0;
    var radiusBottom = 1;
    var height = 5;
    var radialSegments = 16;
    var heightSegments = 1;

    var heightHalf;
  
    var vertices;
    
    webgl.RenderingContext gl;  
    
    Map<String, int> attributes;
    Map<String, int> uniforms;
    
    var shader;
    
    var vert;
    
    var treeList;
    
  tree(givenGL, givenTreeList){
    
    treeList = givenTreeList;
    
    var holder1;
    var holder2;
    
    for(int i = 0 ; i < treeList.length; i += 3){
      
      holder1 = treeList[i];
      holder2 = treeList[i+1];
      
      //print("X: $holder1");
      //print("Y: $holder2");
    }
    
    //print(treeList.length/2);
    
    
    gl = givenGL;
    
    String verts = """
      attribute vec3 aVertexPosition;
      attribute vec3 aVertexNormal;

      uniform mat3 uNormalMatrix;
      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      varying vec3 vLighting;

      void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

          vec3 ambientLight = vec3(0.6,1.0,0.6);
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

          gl_FragColor = vec4(0.25,0.3,0.24, 1.0);

      }""";
        
        shader = utils.loadShaderSource(gl, verts, frag);
        
        var attrib = ['aVertexPosition', 'aVertexNormal'];
        var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
        
        attributes = utils.linkAttributes(gl, shader, attrib);
        uniforms = utils.linkUniforms(gl, shader, unif);
  
    heightHalf = height / 2;
    
    vert = gl.createBuffer();
    
    vertices = new List();
    
    for(int i = 0; i <= heightSegments; i++){
      
      var verticesRow = new List();
      
      var v = i / heightSegments;
      
      var radius = v * ( radiusBottom - radiusTop ) + radiusTop;
      
      for(int j = 0; j <= radialSegments; j++){
        var u = j / radialSegments;
        
        vertices.add(radius * math.sin( u * math.PI * 2 ));
        vertices.add(- v * height + heightHalf);
        vertices.add(radius * math.cos( u * math.PI * 2 ));
        
        
        
        
      }
    
    
    }
    
    var size = vertices.length;
    
    print("cone vert: $size");
    
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vert);    
    gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), webgl.DYNAMIC_DRAW);
    
    
    
    
    
    
    
    
  }
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    
    gl.useProgram(shader);
    
    utils.setMatrixUniforms(gl, viewMat, projectMat, uniforms['uPMatrix'], uniforms['uMVMatrix'], uniforms['uNormalMatrix']);
  
    gl.enableVertexAttribArray(attributes['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, vert);
    gl.vertexAttribPointer(attributes['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(attributes['aVertexNormal']);
    //gl.bindBuffer(webgl.ARRAY_BUFFER, waterNorm);
    //gl.vertexAttribPointer(waterAttributes['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
  
        
    //gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, waterInd);
    
    //gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);
    
    double locX;
    double locY;
    double locZ;
    
    Matrix4 state = viewMat;
    viewMat.translate(0.0, 3.0, 0.0);
    for(int i = 0 ; i < treeList.length; i += 3){
      
      locX = treeList[i].toDouble();
      locY = treeList[i+1].toDouble();
      locZ = treeList[i+2].toDouble();
      viewMat.translate(locX, locY-1.0, locZ);
      
      utils.setMatrixUniforms(gl, viewMat, projectMat, uniforms['uPMatrix'], uniforms['uMVMatrix'], uniforms['uNormalMatrix']);
      
      gl.drawArrays(webgl.TRIANGLE_FAN, 0, 34);
      
      viewMat.translate(-locX, -locY+1.0, -locZ);
      
      viewMat = state;
      
    }
    
    
  }
}

