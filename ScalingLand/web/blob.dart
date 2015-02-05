library blob;

import 'water_two.dart';
import 'package:vector_math/vector_math.dart';

class blob{
  
  int res;
  var blobMap;
  var land;
  
  int workingX;
  int workingY;
  
  var counter = 0;
  
  water_two water;
  var gl;
  
  var locX;
  var locY;
  
  blob(givenGL, heightMap, givenRes, givenLocX, givenLocY){
    gl = givenGL;
    res = givenRes;
    
    locX = givenLocX;
    locY = givenLocY;
    
    
    blobMap = new List(res+2);
    for(int i = 0; i < res+2; i++){
      blobMap[i] = new List(res+2);
      for(int j = 0; j < res+2; j++){
        blobMap[i][j] = 0;
      }
    }
    
    land = new List(res+2);
    for(int i = 0; i < res+2; i++){
      land[i] = new List(res+2);
      for(int j = 0; j < res+2; j++){
        if(i == 0 || i == res+1 || j == 0 || j == res+1){
          land[i][j] = 0;
        }else{
          land[i][j] = heightMap[j-1][i-1];
        }
      }
    }    
  
  
      var dir = 2;
      bool moving;
      bool leftTurn = false;
      bool rightTurn = false;
      
      
      

      int oDir;
      int o2Dir;
      int turnTries;
      
      for(int Oy = 0; Oy < res+2; Oy++){
        for(int Ox = 0; Ox < res+2; Ox++){ 
          
          workingY = Oy;
          workingX = Ox;
                  
          if((land[workingY][workingX] <= -0.5) && (blobMap[workingY][workingX] == 0)){
            
            counter++;
            
            blobMap[workingY][workingX] = counter;

            dir = 2;
            
            

            do{
              //print("Orignal X: $Ox, Y: $Oy"); 
              dir = turnLeft(dir);
              turnTries = 0;
              while(move(dir) == false){
                //print("turn: $dir");
                var Ndir = turnRight(dir);
                turnTries++;
                if(turnTries >= 4){
                  break;
                }
                dir = Ndir;
              }  
              if(turnTries >= 4){
                break;
              }
              //print("h");
              if(move(dir)){
                //print(dir);
                //print("move");
                moveX(dir);
                moveY(dir);
              }
              
              //print("Working X: $workingX, Y: $workingY"); 
              //print(blobMap[3]);
              //print(blobMap[4]);

            }while(workingX != Ox || workingY != Oy);
            
            
          //break; //part of a found area, skip to the end of it on this row
          }
          

          else if(land[workingY][workingX] <= -0.5 && blobMap[workingY][workingX] != 0){
            //print("h");
            int temp = blobMap[workingY][workingX];
            for(int z = Ox+1; z < res+2; z++){
              //if we are still in the blob and have not found the end of it
              if(blobMap[Oy][z] != temp){
                
              }else{ //we have found the end of the blob, so skip x to the end part, and update z to get out of this loop
                
                Ox = z;
                
              }
            }
          }
          
        }
      }
      
      for(int i = 1; i < res+1; i++){
        for(int j = 1; j < res+1; j++){
          //check that above and left have the same label, and we fit the water condition
          if(blobMap[i-1][j] != 0 &&  land[i][j] <= -0.5){
            
            blobMap[i][j] = blobMap[i-1][j];
            
          }else if(blobMap[i][j-1] != 0 &&  land[i][j] <= -0.5){
            
            blobMap[i][j] = blobMap[i][j-1];
            
          }
        }
      }
      
      /*for(int i = 0; i < blobMap.length; i++){
        print(blobMap[i]);
      }*/
      
      water = new water_two(gl, blobMap, res, locX, locY);
      
      
      
  }
  
  int turnLeft(var dir){
    
    if(dir == 0){
        dir = 3;
    }else if(dir == 1){
        dir = 0;
    }else if(dir == 2){
        dir = 1;
    }else if(dir == 3){
        dir = 2;
    }
    return dir;
  }
  
  int turnRight(var dir){
    
    if(dir == 0){
        dir = 1;
    }else if(dir == 1){
        dir = 2; 
    }else if(dir == 2){
        dir = 3;
    }else if(dir == 3){
        dir = 0;
    }
    return dir;
  }
  
  bool move(var dir){
    
    bool moving = false;
    
    if(dir == 0){
      if(land[workingY-1][workingX] <= -0.5 && ((blobMap[workingY-1][workingX] == 0) || (blobMap[workingY-1][workingX] == counter))){
        moving = true;
      }
    }else if(dir == 1){
      if(land[workingY][workingX+1] <= -0.5 && ((blobMap[workingY][workingX+1] == 0)|| (blobMap[workingY][workingX+1] == counter))){
        moving = true;
      }
    }else if(dir == 2){
      if(land[workingY+1][workingX] <= -0.5 && ((blobMap[workingY+1][workingX] == 0)|| (blobMap[workingY+1][workingX] == counter))){
        moving = true;
      }
    }else if(dir == 3){
      if(land[workingY][workingX-1] <= -0.5 && ((blobMap[workingY][workingX-1] == 0)|| (blobMap[workingY][workingX-1] == counter))){
        moving = true;
      }
    }
    
    return moving;
    
  }
  
  void moveX(dir){
    //right
    if(dir == 1){
      if(land[workingY][workingX+1] <= -0.5){
        workingX = workingX + 1;
        blobMap[workingY][workingX] = counter;
      }
    //left  
    }else if(dir == 3){
      if(land[workingY][workingX-1] <= -0.5){
        workingX = workingX - 1;
        blobMap[workingY][workingX] = counter;
      }
    }
    //return workingX;
  }
  
  void moveY(dir){
    //up
    if(dir == 0){
      if(land[workingY-1][workingX] <= -0.5){
        workingY = workingY - 1;
        blobMap[workingY][workingX] = counter;
      }
    //down 
    }else if(dir == 2){
      if(land[workingY+1][workingX] <= -0.5){
        workingY = workingY + 1;
        blobMap[workingY][workingX] = counter;
      }
    }
    //return workingY;
  }
  
  void update(){
    water.waterUpdate();
  }
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
    water.drawWater(viewMat, projectMat);
  }
  
}