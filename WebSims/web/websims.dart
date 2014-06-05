import 'dart:html';
import 'dart:math';

void main() {
  List sim = new List();
  
  List temp = Init();
  
  sim = GameOfLife(temp);
  temp = GameOfLife(sim);
  
  
  
}

List GameOfLife(List Grid){
  //print(Grid);
  

  
  int width = 5;
  int height = 5;
  
  int count = 0;
  
  int above = 0;
  int below = 0;
  int left  = 0;
  int right = 0;
  int abop1 = 0;
  int abom1 = 0;
  int belp1 = 0;
  int belm1 = 0;
  
  int cell = 0;
  
  
  List Gridtemp = new List<int>(width*height);
  
  
  
  
  //game of life logic goes here0
  
  for(int i = 0; i < height; i++){
    for(int j = 0; j < width; j++){
      
      cell = j+i*height;
      
      //print(cell);
      
      count = 0;
      
      below = (cell+width) % Grid.length;
      above = (cell-width) % Grid.length;
      
      left  = ((cell-1) % width) + i*height;
      
      abom1 = (((above-1) % width) + (above~/width)*height)%Grid.length;
      belm1 = (((below-1) % width) + (below~/width)*height)%Grid.length;
      

      
      
      right = ((cell+1) % width) + i*height;
      
      abop1 = (((above+1) % width) + (above~/width)*height)%Grid.length;
      belp1 = (((below+1) % width) + (below~/width)*height)%Grid.length;
            
      if(Grid[above] == 1){
        count++;
      }
      if(Grid[below] == 1){
        count++;
      }
      if(Grid[left] == 1){
        count++;
      }
      if(Grid[right] == 1){
        count++;
      }
      if(Grid[abop1] == 1){
        count++;
      }
      if(Grid[abom1] == 1){
        count++;
      }
      if(Grid[belp1] == 1){
        count++;
      }
      if(Grid[belm1] == 1){
        count++;
      }
      /*if(Grid[cell] == 1){
        count++;
      }*/
      
      if(count < 2){
        Gridtemp[cell] = 0;
      }else if(count == 2 || (count == 3 && Grid[cell] == 1)){
        Gridtemp[cell] = 1;
      }else{
        Gridtemp[cell] = 0;
      }
      
      if(count == 2 && Grid[cell] == 0){
        Gridtemp[cell] == 1;
      }
      
      
      //Gridtemp[cell] = count;
      
      
     /* 
      if(cell == 11){
        print("above - 1: $abom1");
        print("above: $above");
        print("above + 1: $abop1");
        
        print("-1: $left");
        print("center: $cell");
        print("+1: $right");
        
        print("below - 1: $belm1");
        print("below: $below");
        print("below + 1: $belp1");
      }
      
      */
      //print("cell number is: $cell, count is: $count");
      
    }
  }
  print(Gridtemp);
  
  
  return Gridtemp;
  
  
  
  
  
  
}

List Init(){

  List data = new List();
  
  for(int i = 0; i < 5; i++){
    for(int j = 0; j < 5; j++){
      if(i == 2){
        data.add(1);
      }else{
        data.add(0);
      }
    }
  }
  
  data[10]  = 0;
  data[14] = 0;
  
  
  return data;
}