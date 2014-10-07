import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:async';

import 'core.dart';

void main() {
  
  //Select the canvas as our rneder tatget
  CanvasElement canvas = querySelector("#render-target"); 
  //canvas.requestFullscreen();
  //canvas.width = window.innerWidth;
  //canvas.height = window.innerHeight;
  webgl.RenderingContext gl = canvas.getContext3d();
  
  var nexus = new core(gl, canvas);
  
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
  
  logic();
  render(1);
  
  
}
