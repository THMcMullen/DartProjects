//bass class which all other objects are created from.
library object;

import 'dart:web_gl' as webgl;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

import 'utils.dart' as utils;

import 'land.dart';

class object{
  
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
}















