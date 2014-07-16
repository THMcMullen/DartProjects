import 'dart:html';
import 'dart:async';
import 'dart:web_gl' as webgl;

import 'core.dart';

void main() {
  
  //everything starts here.
  
  //Select the canvas as our rneder tatget
  CanvasElement canvas = querySelector("#render-target"); 
  webgl.RenderingContext gl = canvas.getContext3d();
  
  
  core nexus = new core(gl, canvas);

  
  //create and split up our lagic and rendering functions.
  logic(){
    
    var future = new Future.delayed(const Duration(milliseconds: 1), logic);
    
    nexus.logic();
  }
  
  render(timer){
    
    window.requestAnimationFrame(render);
    
    nexus.draw();
  }
  
  //now to start everything
  logic();
  render(1);
  
}
