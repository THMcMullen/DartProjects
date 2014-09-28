library camera;

import 'package:vector_math/vector_math.dart';
import 'dart:html';
import 'dart:math';

class camera{
  
  var moving = false;
  var lastX;
  var lastY;
  
  var movingX1;
  var movingY1;
  var movingX2;
  var movingY2;
  
  var orbitX = 0.0;
  var orbitY = 0.0;
  var distance = 100.0;
  
  Vector3 vector = new Vector3(0.0,0.0,0.0);
  Matrix4 viewMat = new Matrix4.identity();
  
  var dirty = true;
  
  CanvasElement canvas;
  
  camera(CanvasElement givenCanvas){
    canvas = givenCanvas;
    
    canvas.onMouseDown.listen(mouseDown);
    
    canvas.onMouseMove.listen(mouseMove);
    
    canvas.onMouseUp.listen(mouseUp);
    
    canvas.onTouchStart.listen(touchDown);
    
    canvas.onTouchMove.listen(touchMove);
    
    
  }
  
  void touchMove(TouchEvent event){
      
    //one finger moving around the scene
      if(event.touches.length == 1){
    
        var xDelta = event.touches[0].client.x - lastX;
        var yDelta = event.touches[0].client.y - lastY;
        
        lastX = event.touches[0].client.x;
        lastY = event.touches[0].client.y;
        
        orbitY += xDelta * 0.025;
        while(orbitY < 0){
          orbitY += 3.14*2;
        }
        while(orbitY >= 3.14*2){
          orbitY -=3.14*2;
        }
        
        orbitX += yDelta * 0.025;
        
        while(orbitX < 0){
          orbitX += 3.14*2;
        }
        while(orbitX >= 3.14*2){
          orbitX -= 3.14*2;
        }
        
         
    //two fingers, zoom in or out
      }else if(event.touches.length == 2){

        int i = movingX1 - movingX2;
        i = i.abs();
        
        int j = event.touches[0].client.x - event.touches[1].client.x;
        j = j.abs();
        
        //zoom out
        if(i > j){
          distance = distance + (((max(j, 5) - max(i, 5))/50));
        }
        //zoom in
        if(j > i){
          distance = distance - (((max(i, 5) - max(j, 5))/50));
        }
        
        distance > 100.0 ? distance = 100.0 : distance;
        distance < 4.0 ? distance = 4.0: distance;
        
        //int tX1 = event.touches[0].client.x - movingX1;
        //movingX1 = event.touches[0].client.x;
        //tX1 = tX1.abs();
        //int tX2 = event.touches[1].client.x - movingX2;
        //movingX2 = event.touches[1].client.x;
        //tX2 = tX2.abs();*/
        
        
        
        //distance = distance + ((i + j)/100);
        //print(j);
        
        
      }
      dirty = true;
  }
  
  void touchDown(TouchEvent event){

    lastX = event.touches[0].client.x;
    lastY = event.touches[0].client.y;
    if(event.touches.length == 2){
      movingX1 = event.touches[0].client.x;
      movingY1 = event.touches[0].client.y;
      movingX2 = event.touches[1].client.x;
      movingY2 = event.touches[1].client.y;
    }
  }
  
  void mouseDown(MouseEvent event){
    if(event.which == 1){
      moving = true;
    };
    lastX = event.client.x;
    lastY = event.client.y;
  }
  
  void mouseMove(MouseEvent event){
    if(moving){
      
      var xDelta = event.client.x - lastX;
      var yDelta = event.client.y - lastY;
      
      lastX = event.client.x;
      lastY = event.client.y;
      
      orbitY += xDelta * 0.025;
      while(orbitY < 0){
        orbitY += 3.14*2;
      }
      while(orbitY >= 3.14*2){
        orbitY -=3.14*2;
      }
      
      orbitX += yDelta * 0.025;
      
      while(orbitX < 0){
        orbitX += 3.14*2;
      }
      while(orbitX >= 3.14*2){
        orbitX -= 3.14*2;
      }
      
      dirty = true;      
    }
  }
  
  void mouseUp(MouseEvent event){
    moving = false;
  }
  
  Matrix4 getViewMat(){
    
    if(dirty){
      Matrix4 mv = viewMat;
      mv = new Matrix4.identity();
      //if i want to movearound the world use this
      mv.translate(0.0, 0.0, -distance);
      
      mv.rotateX(orbitX + (3.14/2));
      mv.translate(vector);
      mv.rotateX(-(3.14/2));
      mv.rotateY(orbitY);
      
      dirty = false;
      
      viewMat = mv;
    }
    
    return viewMat;
  }
  
}