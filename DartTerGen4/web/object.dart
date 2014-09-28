library object;

import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

import 'utils.dart' as utils;

import 'land.dart';

class object{
  
  
  //water and land classes are based on this.
  //and share several variables.
  
  //Allows for a cleaner linking of attributes and uniforms
  Map<String, int> attribute;
  Map<String, int> uniforms;
  
  //vertex shader and fragment shader
  String vertex;
  String fragment;
  
  var attrib;
  var unif;
  
  var indices;
  var vertices;
  var normals;

  webgl.Program shader;
  
  static List masterMesh = new List<land>();
  
  webgl.RenderingContext gl;
  
  
  
  object(){
    //print("object - init");
  }
  
  //keeps track of the land which we have created so far
  updateMesh(var mesh){
    masterMesh.add(mesh);
  }
  int meshLength(){
    return masterMesh.length;
  }
  
  land meshHeightMap(int i){
    return masterMesh[i];
  }
  
  logic(){
    print("object - Logic");
  }
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    print("object - Draw");
  }
  
  
}