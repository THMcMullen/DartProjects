import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:async';

import 'core.dart';

void main() {
  
  CanvasElement canvas = querySelector("#render-target"); 
  webgl.RenderingContext gl = canvas.getContext3d();
  
  var nexus = new core(gl, canvas);
  
  bool auto = true;
  
  render(time){
    
    window.requestAnimationFrame(render);
    nexus.draw();
    
  }
  
  logic(){
    
    var future = new Future.delayed(const Duration(milliseconds: 15), logic);
    
    if(auto){
      nexus.update();
    }
    
    //logic();

  }
  
  keyDown(KeyboardEvent e){
    //hit space to update the water sim one time step
    if(e.keyCode == 32){
      nexus.update();
    }
    //hit "A" to make the simulation run automatically, or off
    if(e.keyCode == 65){
       auto == true? auto = false : auto = true;
     }
     
    
    //print(e.keyCode);
  }

  
  logic();
  render(1);

  window.onKeyDown.listen(keyDown);

  
}

