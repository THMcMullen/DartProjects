import 'dart:html';
import 'dart:async';
import 'dart:web_gl' as webgl;

import 'dart_matter.dart';

void main() {
  //Select the canvas as our rneder tatget
  CanvasElement canvas = querySelector("#render-target"); 
  //canvas.requestFullscreen();
  
  webgl.RenderingContext gl = canvas.getContext3d();
  
  var nexus = new dart_matter(gl, canvas);
  
  //set up the enviroment
  nexus.setup();
  
  logic(){
     
    var future = new Future.delayed(const Duration(milliseconds: 1), logic);
    nexus.update();
      
  }
  render(time){
    window.requestAnimationFrame(render);
    nexus.draw(); 
  }
  
  window.onKeyDown.listen(nexus.keyDown);
  
  logic();
  render(1);
  
  


}

