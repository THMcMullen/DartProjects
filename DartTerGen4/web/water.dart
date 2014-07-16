library water;

import 'object.dart';

import 'package:vector_math/vector_math.dart';

import 'blob.dart';

class water extends object{
  
  water(gl){
    print("water - Init");
  }
  
  logic(){
    print("water - Logic");
  }
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    print("water - Draw");
  }
  
  
}