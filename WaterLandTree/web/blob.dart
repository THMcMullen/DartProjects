library blob;

import 'dart:web_gl' as webgl;
import 'utils.dart' as utils;
import 'dart:math' as math;

import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';



import 'object.dart';
//import 'water.dart';//replaced by waterTwo
import 'water_two.dart';
import 'tree.dart';


class blob extends object{
  
  var blobInd;
    
  var len = 3;
  
  var d = 129;
  
  List land;
  List blobMap;
  
  int workingX;
  int workingY;
  
  int counter;
  
  int zero = 0;
  int one = 0;
  int two = 0;
  int three = 0;
  
  var blobList;
  
  var treeMap;
  List treeList;
  
  water_two weaterTemp;
  
  blob(webgl.RenderingContext givenGL){
    gl = givenGL;    
    
    
    
    /*
    var nw, nn, ne, ww;
        var minIndex = 0;
        var label = 1;
        
    List labelTable = new List();
    labelTable.add(0);
    
    //walkers not the best idea, so set group level to 0, then do connected-component labeling
    List blobMap = new List(d+2);
    for(int i = 0; i < d+2; i++){
     blobMap[i] = new List(d+2);
      for(int j = 0; j < d+2; j++){
        blobMap[i][j] = 0;
      }
    }
    
    for(int k = 0; k < 2; k++){
      for(int i = 1; i < d; i++){
        for(int j = 1; j < d; j++){
          //check if the hight at the given location is under a given height
          if(meshHeightMap(0).heightMap[i][j] <= -0.5){
            nw = blobMap[i-1][j-1];
            nn = blobMap[i-1][ j ];
            ne = blobMap[i-1][j+1];
            ww = blobMap[ i ][j-1];
            minIndex = ww;
            if( 0 < nw && nw < minIndex){minIndex = nw;}
            if( 0 < nn && nn < minIndex){minIndex = nn;}
            if( 0 < ne && ne < minIndex){minIndex = ne;}
            if( 0 < ww && ww < minIndex){minIndex = ww;}
            
            //not part of a group so join a new one
            if(minIndex == 0){
              blobMap[i][j] = label;
              labelTable.add(label);
              label++;
            }else{//we are part of a group so set our value to that
              if( minIndex < labelTable[nw] ){ labelTable[nw] = minIndex; }
              if( minIndex < labelTable[nn] ){ labelTable[nn] = minIndex; }
              if( minIndex < labelTable[ne] ){ labelTable[ne] = minIndex; }
              if( minIndex < labelTable[ww] ){ labelTable[ww] = minIndex; }
              
              blobMap[i][j] = minIndex;
            }
            
          }else{
            blobMap[i][j] = 0;
          }
        }
      }
      
      var i = labelTable.length;
      while( i != 0 ){
        i--;
        label = labelTable[i];
        while( label != labelTable[label] ){
          label = labelTable[label];
        }
        labelTable[i] = label;
      }
       
      for(int y=0; y<d+2; y++){
        for(int x=0; x<d+2; x++){
          label = blobMap[y][x];
          if( label == 0 ){ continue; }
          while( label != labelTable[label] ){
            label = labelTable[label];
          }
          blobMap[y][x] = label;
        }
      }
  
    }
      
    Set uniqueLabels = new Set();
    
    for(int i = 0; i < labelTable.length; i++){
      uniqueLabels.add(labelTable[i]);
    }
    
    
    List uniqueTable = new List.from(uniqueLabels);
    //print(uniqueTable);
    //print(labelTable);
    
    int z = 0;
    for(int i = 0; i < uniqueTable.length; i++){
      for(int j = 0; j < labelTable.length; j++){
        if(labelTable[j] == uniqueTable[i]){
          labelTable[j] = i;
        }
      }
      
  
    }

    //full with all blob info, for blob 1
    var blobVert = new List();
    for(int x = 1; x < d+2; x++){
      for(int y = 1; y < d+2; y++){
        if(blobMap[x][y] == 1){ 
          blobVert.add(y.toDouble());
          blobVert.add(64.5);
          blobVert.add(x.toDouble());
        }
      }
    }
        
        
        
    blobInd = new List();
    //Try create test blob class
    for(int x = 1; x < d+2; x++){
      for(int y = 1; y < d+2; y++){
        //we are part of blob 1
        if(blobMap[y][x] == 1){
          //test to see if below us is also blob 1
          if(blobMap[y+1][x] == 1){
            int current = null;
            int cm1 = null;
            int cp1 = null;
            int currentp1 = null;
            for(int i = 0; i < blobVert.length; i+=3){
              //check to find out indice
              if(blobVert[i] == x && blobVert[i+2] == y){
                current = i~/3;
              }else if(blobVert[i] == x+1 && blobVert[i+2] == y){
                currentp1 = i~/3;
              }else if(blobVert[i] == x && blobVert[i+2] == y+1){
                cm1 = i~/3;
              }else if(blobVert[i] == x+1 && blobVert[i+2] == y+1){
                cp1 = i~/3;
              }
            }
            if(cp1 == null || cm1 == null || current == null || currentp1 == null){
             // print("$x:, \n $y:");
            }else{
              
              blobInd.add(currentp1);
              blobInd.add(cm1);
              blobInd.add(cp1);
              blobInd.add(current);
              blobInd.add(currentp1);
              blobInd.add(cm1);
              

            }
          }
        }
      }
    }
        
    len = blobInd.length;
    
    //print(blobInd.length);
    
    
    
    gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, indices);
    gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(blobInd), webgl.STATIC_DRAW);
    
    
    
    
    //print(labelTable);
     
    var value;
    
    for(int i = 0; i < blobVert.length; i++){
      blobVert[i] -= 65;
    }

    for(var a = 0; a < d; a++){
      for(var b = 0; b < d; b++){
          //value =(a*d)+(b); 
                              
          //vert[(value*3)+1] = blobMap[b][a] > 0? 10.0: 0.0;
          
      }
    }  
    
    gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, vertices);  
    gl.bufferDataTyped(webgl.ARRAY_BUFFER, new Float32List.fromList(blobVert), webgl.STATIC_DRAW);
    //gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(vert));

    */
     
     
    bool inside = false;
    bool moved = false;
    counter = 0;
    int dir = 2;
    
    //d = 15;
        
    blobMap = new List(d+2);
    for(int i = 0; i < d+2; i++){
      blobMap[i] = new List(d+2);
      for(int j = 0; j < d+2; j++){
        blobMap[i][j] = 0;
      }
    }
    
    land = new List(d+2);
    for(int i = 0; i < d+2; i++){
      land[i] = new List(d+2);
        for(int j = 0; j < d+2; j++){
          if(i == 0 || i == d+1 || j == 0 || j == d+1){
            land[i][j] = 0;
          }else{
            //land[i][j] = 0;
            land[i][j] = meshHeightMap(0).heightMap[i-1][j-1];
          }
          /*if(i == 4 && (j > 3 && j < d-2) || i == d-3 && (j > 3 && j < d-2) || j == d-2 && ( i > 3 && i < d-2) || j == 3 && ( i > 3 && i < d-2)){// || i == d-2 || j == 3 || j == d-2){
            land[i][j] = -1;
          }*/
        }
    }
    dir = 2;
    bool moving;
    bool leftTurn = false;
    bool rightTurn = false;
    

    
    int oDir;
    int o2Dir;
    int turnTries;
    
    for(int Oy = 0; Oy < d+2; Oy++){
      for(int Ox = 0; Ox < d+2; Ox++){ 
        
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
          for(int z = Ox+1; z < d+2; z++){
            //if we are still in the blob and have not found the end of it
            if(blobMap[Oy][z] != temp){
              
            }else{ //we have found the end of the blob, so skip x to the end part, and update z to get out of this loop
              
              Ox = z;
              
            }
          }
        }
        
      }
    }
    
    
    //go through the blobMap, and ladscape to full in each blob
    for(int i = 1; i < d+1; i++){
      for(int j = 1; j < d+1; j++){
        //check that above and left have the same label, and we fit the water condition
        if(blobMap[i-1][j] != 0 &&  land[i][j] <= -0.5){
          
          blobMap[i][j] = blobMap[i-1][j];
          
        }else if(blobMap[i][j-1] != 0 &&  land[i][j] <= -0.5){
          
          blobMap[i][j] = blobMap[i][j-1];
          
        }
      }
    }
    /*
    print("\nblob\z");
    for(int i = 0; i < d+2;i++){
      //for(int j = 0; j < 30; j++){
        print(blobMap[i]);
      //}
    }
    */
    
    var waterMap = new List(d+1);
    
    for(int i = 0; i < blobMap.length-1; i++){
      var c = 0;
      waterMap[i] = new List();
      waterMap[i].add(0);
      for(int j = 0; j < blobMap[i].length; j++){
        if(blobMap[i][j] != 0){
          c++;
          waterMap[i].add(j);
        }else{
          waterMap[i].add(0);
        }
      }
      waterMap[i][0] = c;
    }
    
    for(int i = 0; i < d+1;i++){
      //for(int j = 0; j < 30; j++){
        //print(waterMap[i]);
      //}
    }
    weaterTemp = new water_two(gl, blobMap);
    
    
    
    
    
    var minX = new List(counter);
    var maxX = new List(counter);
    var minY = new List(counter);
    var maxY = new List(counter);
    //initilise each list
    for(int i = 0; i < counter; i++){
      minX[i] = 129;
      maxX[i] = 0;
      minY[i] = 129;
      maxY[i] = 0;
    }
    
    
    
    //now put each blob into a different blob class
    for(int h = 1; h < counter+1; h++){
      for(int i = 1; i < d+2; i++){
        for(int j = 1; j < d+2; j++){
          if(blobMap[i][j] == h){
            if(i < minX[h-1]){
              //new lowest X value
              minX[h-1] = i;
            }
            if(i > maxX[h-1]){
              maxX[h-1] = i;
            }
            if(j < minY[h-1]){
              minY[h-1] = j;
            }
            if(j > maxY[h-1]){
              maxY[h-1] = j;
            }
          }
        }
      }
    }
    


    
    var blobPass = new List(counter);
    for(int h = 0; h < counter; h++){
      blobPass[h] = new List(math.max(maxX[h]-minX[h]+1 , 1));
      for(int i = 0; i < blobPass[h].length ; i++){
        blobPass[h][i] = new List(math.max(maxY[h] - minY[h]+1 , 1));
        for(int j = 0; j < blobPass[h][i].length; j++){
          if(blobMap[i+minX[h]][j+minY[h]] == h+1){
            blobPass[h][i][j] = 1;
          }else{
            blobPass[h][i][j] = 0;
          }
          
        }
      }
    }

    //print(blobPass);
    
    //clean up remove old and un needed data
    land = null;
    
    //blobMap = null;
    
    
    
    
    
    //blobList = new List<waterSim>();
    var size;
    for(int i = 0; i < counter; i++){
      size = (blobPass[i].length + blobPass[i][0].length)/2;
      if(size > 5){
        //blobList.add(new waterSim(blobPass[i],maxX[i], minX[i], maxY[i], minY[i], gl));
      }
    }
    
    var rng = new math.Random();
    
    var offset = 0;
    var treeRate = 100; // atleast once every X cells will be a tree;
    
    //rng.nextInt(50); 
    
    treeList = new List();
    int treeOfffset = 0;
    for(int i = 1; i < d; i++){
      for(int j = 1; j < d; j++){
        if(meshHeightMap(0).heightMap[i][j] > -0.6 && meshHeightMap(0).heightMap[i][j] < 10.0){
          //we are above water and below a set height, so add some trees around randomly, could give a proper algorithm, if a suitable one is found
          if(rng.nextInt(80) + offset > treeRate ){
            
            treeList.add(j); // the x of where to place a tree
            treeList.add(meshHeightMap(0).heightMap[i][j]);
            treeList.add(i); // the y
            
            offset = 0;

          }else{
            offset++;
          }

        }
        
      }
      
    }

    treeMap = new tree(gl, treeList);
    
    
    
    //create a new pool of water for each blob over a set size
    //create the waterSim, by passing the data of the blobs to the water class
    //blobList = new waterSim(blobPass[0],maxX[0], minX[0], maxY[0], minY[0], gl);
    //blobList.waterUpdate();
    
    
    //print(blobMap);
   /* print("\nLand\n");
    for(int i = 0; i < d+2;i++){
      //for(int j = 0; j < 30; j++){
        //print(land[i]);
      //}
    }
    print("\nblob\z");
    for(int i = 0; i < d+2;i++){
      //for(int j = 0; j < 30; j++){
        print(blobMap[i]);
      //}
    }
    print(counter);
    print("Zero Total:$zero");
    print("One Total:$one");
    print("Two Total:$two");
    print("Three Total:$three");
    
    print(minX);
    print(maxX);
    print(minY);
    print(maxY);*/
    

    
    
    
    

    
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
        one++;
      }
    //left  
    }else if(dir == 3){
      if(land[workingY][workingX-1] <= -0.5){
        workingX = workingX - 1;
        blobMap[workingY][workingX] = counter;
        three++;
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
        zero++;
      }
    //down 
    }else if(dir == 2){
      if(land[workingY+1][workingX] <= -0.5){
        workingY = workingY + 1;
        blobMap[workingY][workingX] = counter;
        two++;
      }
    }
    //return workingY;
  }
  
  void update(){
    //blobList.waterUpdate();
    //for(int i = 0; i < blobList.length; i++){
      //blobList[i].waterUpdate();
    //}
    weaterTemp.waterUpdate();
  }

  
  List<int> walk(int tX, int tY){
      List walker = new List<int>(2);
      
      int cX;//current X and Y
      int cY;
      
      int nX;//new X and Y
      int nY;
      
      var rng = new math.Random();
      //Random value to spawn walker at
      int locX = tX;//rng.nextInt(128);
      int locY = tY;//rng.nextInt(128);
      
      double lowest = meshHeightMap(0).heightMap[locX][locY];
      
      bool walking = true;
      
      nX = tX;//locX;
      nY = tY;//locY;
      int temp = 0;
      //while(walking){
        temp ++;
        for(int i = 0; i < 20; i++){
          for(int j = 0; j < 20; j++){
            cX = (nX + i-10) % 128;
            cY = (nX + j-10) % 128;
            
            if(meshHeightMap(0).heightMap[cX][cY] < lowest){
              locX = cX;
              locY = cY;
              lowest = meshHeightMap(0).heightMap[cX][cY]; 
            }
          }
        }
        
        //if the lowest point has not changed
        if(locX == nX && locY == nY){
          //walking = false;
          //print(lowest);
        }
        
        //nX = locX;
        //nY = locY;
        
        
        
      //}
      
      walker[0] = locX;
      walker[1] = locY;
      
      
      
      return walker;
    }
  
  draw(Matrix4 viewMat, Matrix4 projectMat){
      //print("drawing water");
      
      //need to render 5 walkers
      //blobList.drawWater(viewMat, projectMat);
    
      //for(int i = 0; i < blobList.length; i++){
        //blobList[i].drawWater(viewMat, projectMat);
      //}
      weaterTemp.drawWater(viewMat, projectMat);
      
      treeMap.draw(viewMat, projectMat);


    }
}