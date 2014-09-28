//creates and setups the enviroment to be ready to run

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:async';

import 'core.dart';

void main() {
  
  //Select the canvas as our rneder tatget
  CanvasElement canvas = querySelector("#render-target"); 
  webgl.RenderingContext gl = canvas.getContext3d();
  
  var nexus = new core(gl, canvas);
  
  //set up the enviroment
  nexus.setup();
  
  double locX = 0.0;
  double locY = 0.0;
  
  bool auto = true;
   
  //create a rneder loop
  render(time){
    window.requestAnimationFrame(render);
    nexus.draw(locX, locY); 
  }
  
  //insures the logic will not be tied to the frame rate.
  logic(){
   
    var future = new Future.delayed(const Duration(milliseconds: 1), logic);
   
    if(auto){
      nexus.update();
    }
  }
 
  //Lets the user have the scene run automatically or one step each time space is hit
  keyDown(KeyboardEvent e){
    //hit space to update the water sim one time step
    if(e.keyCode == 32){
      nexus.update();
    }
    //hit "A" to make the simulation run automatically, or off
    if(e.keyCode == 223){
      auto == true? auto = false : auto = true;
    }
    
    //W == 87  
    if(e.keyCode == 87){
      locX += 1.0;
    }
    //S == 83
    if(e.keyCode == 83){
      locX -= 1.0;
    }
    //A == 65
    if(e.keyCode == 65){
      locY -= 1.0;
    }
    //D == 68
    if(e.keyCode == 68){
      locY += 1.0;
    }
    
    //print(e.keyCode);
  }

  window.onKeyDown.listen(keyDown);
 
  logic();
  render(1);
  
}
