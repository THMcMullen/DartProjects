import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:async';

import 'core.dart';

void main() {
  
  CanvasElement canvas = querySelector("#render-target"); 
  webgl.RenderingContext gl = canvas.getContext3d();
  
  var nexus = new core(gl, canvas);
  
  render(time){
    window.requestAnimationFrame(render);
    nexus.draw();
  }
  
  logic(){
    var future = new Future.delayed(const Duration(milliseconds: 25), logic);
    nexus.update();
    //logic();

  }

  
  logic();
  render(1);

  
}
