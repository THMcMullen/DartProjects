library waterTwo;

import 'dart:web_gl' as webgl;

import 'blob.dart';
import 'utils.dart' as utils;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

class water_two{
  
  int sizeX = 0;
  int sizeY = 0;
  int startX = 0;
  int startY = 0;
  
  webgl.RenderingContext gl;
    
  Map<String, int> attributes;
  Map<String, int> uniforms;
  
  Map<String, int> waterAttributes;
  Map<String, int> waterUniforms;
  
  var waterShader;
  var shader;
  var boxVert;
  var ind;
  var norm;
  
  List waterIndices;
  var wVert;
  var waterVert;
  var waterInd;
  var waterNorm;
  var wNorm = new List();
  
  var g;
  var b;
  var h, h1;
  var u, u1;
  var v, v1;
  
  var X;
  var Y;

  double dt = 0.01;

  
  var bigArray;
  
  var blobMap;
  
  List indMap;
  
  int noise = 0;
  
  
  water_two(givenGL, passMap, res, locX, locY){
    
    gl = givenGL;
    
    X = res;
    Y = res;
    
    String verts = """
      attribute vec3 aVertexPosition;
      attribute vec3 aVertexNormal;
  
      uniform mat3 uNormalMatrix;
      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      varying vec3 vLighting;

      void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

          vec3 ambientLight = vec3(0.6,0.6,1.0);
          vec3 directionalLightColor = vec3(0.8, 0.8, 0.8);
          vec3 directionalVector = vec3(1.0, 1.0, 1.0);

          vec3 transformedNormal = uNormalMatrix * aVertexNormal;

          float directional = max(dot(transformedNormal, directionalVector), 0.0);
          vLighting = ambientLight + (directionalLightColor * directional);
      }""";

       String frag = """
      precision mediump float;

      varying vec3 vLighting;
  
      void main(void) {

          gl_FragColor = vec4(vLighting, 1.0);

      }""";
       
       waterShader = utils.loadShaderSource(gl, verts, frag);
       
       var attrib = ['aVertexPosition', 'aVertexNormal'];
       var unif = ['uMVMatrix', 'uPMatrix', 'uNormalMatrix'];
       
       waterAttributes = utils.linkAttributes(gl, waterShader, attrib);
       waterUniforms = utils.linkUniforms(gl, waterShader, unif);
       
       blobMap = passMap;
       
       wVert = new List();
       waterIndices = new List();
       
       waterVert = gl.createBuffer();
       waterInd = gl.createBuffer();
       waterNorm = gl.createBuffer();
      
       //add Buffer to the data
       for(int i = 1; i < blobMap.length-1; i++){
         for(int j = 1; j < blobMap[i].length-1; j++){
           //not empty data, so add buffer/false data
           //set value to 200 for false data, as data will not reach that value otherwise
           if(blobMap[i][j] != 0 && blobMap[i][j] != 200){
             if(blobMap[i+1][j+1] == 0){
               blobMap[i+1][j+1] = 200;
             }
             if(blobMap[i+1][j] == 0){
               blobMap[i+1][j] = 200;
             }
             if(blobMap[i+1][j-1] == 0){
               blobMap[i+1][j-1] = 200;
             }
             if(blobMap[i][j+1] == 0){
               blobMap[i][j+1] = 200;
             }
             if(blobMap[i][j-1] == 0){
               blobMap[i][j-1] = 200;
             }
             if(blobMap[i-1][j+1] == 0){
               blobMap[i-1][j+1] = 200;
             }
             if(blobMap[i-1][j] == 0){
               blobMap[i-1][j] = 200;
             }
             if(blobMap[i-1][j-1] == 0){
               blobMap[i-1][j-1] = 200;
             }
           }
         }
       }
       
       
       indMap = new List(blobMap.length-1);
       for(int x = 0; x < blobMap.length-1; x++){
         indMap[x] = new List(blobMap[x].length-1);
         for(int y = 0; y < blobMap[x].length-1; y++){
           indMap[x][y] = 0;
         }
       }
       
       
       
       
       
       
       
       
       
       //start at one to skip the buffer
       
       
       
      /* for(double i = 0.0; i < res; i++){
         for(double j = 0.0; j < res; j++){
           vert.add(i * (128 / (res - 1)) + (128*locX) - (5*128));// + (locX*res) - res);
           vert.add(heightMap[i.toInt()][j.toInt()]);
           vert.add(j * (128 / (res - 1)) + (128*locY) - (5*128));// + (locY*res) - res);
         }
       }*/
       
       
       for(double x = 1.0; x < blobMap.length-1; x++){
         for(double y = 1.0; y < blobMap[x.toInt()].length-1; y++){
           if(blobMap[x.toInt()][y.toInt()] != 0){ 
             wVert.add(y);
             indMap[x.toInt()][y.toInt()] = wVert.length;
             wVert.add(-0.5);
             wVert.add(x);
           }
         }
       }
       
       for(int i = 0; i < indMap.length; i++){
         print(indMap[i]);
       }
       
       
       

       
       
       for(int i = 0; i < blobMap.length-3; i++){
         for(int j = 0; j < blobMap[i].length-3; j++){
           if(blobMap[i][j] != 0){
             if(blobMap[i+1][j] != 0){
               int current = null;
               int cm1 = null;
               int cp1 = null;
               int currentp1 = null;
               for(int k = 0; k < wVert.length; k+=3){
                  if(wVert[k] == j && wVert[k+2] == i){
                    current = k~/3;
                  }else if(wVert[k] == j+1 && wVert[k+2] == i){
                    currentp1 = k~/3;
                  }else if(wVert[k] == j && wVert[k+2] == i+1){
                    cm1 = k~/3;
                  }else if(wVert[k] == j+1 && wVert[k+2] == i+1){
                    cp1 = k~/3;
                  }
               }
               if(cp1 == null || cm1 == null || current == null || currentp1 == null){
                  //print("$i:, \n $j:");
               }else{               
                 waterIndices.add(currentp1);
                 waterIndices.add(cm1);
                 waterIndices.add(cp1);
                 waterIndices.add(current);
                 waterIndices.add(currentp1);
                 waterIndices.add(cm1);
               }
             }
           }
         }
       }
       
       // add the spped up to the map, by adding the values to skip, remembering to ignore points of 0, or 200, only working on "real" data.
       
       var waterMap = new List(blobMap.length);
       
       for(int i = 0; i < blobMap.length; i++){
         var c = 0;
         waterMap[i] = new List();
         waterMap[i].add(0);
         for(int j = 1; j < blobMap[i].length+1; j++){
           if(blobMap[i][j-1] != 0 && blobMap[i][j-1] != 200){
             c++;
             waterMap[i].add(j-1);
           }else{
             waterMap[i].add(0);
           }
         }
         waterMap[i][0] = c;
       }
       
       //for(int i = 0; i < waterMap.length; i++){
       //  print(waterMap[i]); 
       //}
       
       int tempCounter = 0;
       
       for(double x = 1.0; x < blobMap.length-1; x++){
         for(double y = 1.0; y < blobMap[x.toInt()].length-1; y++){
           if(blobMap[x.toInt()][y.toInt()] != 0){ 
             wVert[tempCounter] = y * (128 / (res - 1)) + (128*locX) - (5*128);
             tempCounter += 2;

             wVert[tempCounter] = x * (128 / (res - 1)) + (128*locY) - (5*128);
             tempCounter++;
           }
         }
       }
       
       
       
       
       for(int i = 0; i < waterIndices.length; i++){
         wNorm.add(-1.0);
       }
       
       
       
       
       gl.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, waterInd);
       gl.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(waterIndices), webgl.STATIC_DRAW);
       
       gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);    
       gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(wVert), webgl.DYNAMIC_DRAW);

       gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterNorm);
       gl.bufferData(webgl.ARRAY_BUFFER, new Float32List.fromList(wNorm), webgl.STATIC_DRAW);
          
       waterInit();
    
  }
  
  Vector3 calcNormal(int iy, int ix){
      
      int ym1 = iy-1;
      int yp1 = iy+1;
      int xm1 = ix-1;
      int xp1 = ix+1;
      
      var r = new Vector3.zero();
      
      var c = new Vector3.zero();
      c.x = ix.toDouble();
      c.y = g[iy*X + ix] + h[iy*X + ix];
      c.z = ym1.toDouble();
      
      if(ix > 0 && iy > 0) {
        var n = new Vector3.zero();
        n.x = ix.toDouble();
        n.y = g[ym1*X + ix] + h[ym1*X + ix];
        n.z = ym1.toDouble();
        
        var w = new Vector3.zero();
        w.x = xm1.toDouble();
        w.y = g[iy*X + xm1] + h[iy*X + xm1];
        w.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = n - c;
        v = w - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder;          
      }
      if(ix < (X-1) && iy > 0) {
        var n = new Vector3.zero();
        n.x = ix.toDouble();
        n.y = g[ym1*X + ix] + h[ym1*X + ix];
        n.z = ym1.toDouble();
        
        var e = new Vector3.zero();
        e.x = xp1.toDouble();
        e.y = g[iy*X + xp1] + h[iy*X + xp1];
        e.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = n - c;
        v = e - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder;       
        
      }
      
      if(ix < (X-1) && iy < (Y-1)) {
        var s = new Vector3.zero();
        s.x = ix.toDouble();
        s.y = g[yp1*X + ix] + h[yp1*X + ix];
        s.z = yp1.toDouble();      
        
        var e = new Vector3.zero();
        e.x = xp1.toDouble();
        e.y = g[iy*X + xp1] + h[iy*X + xp1];
        e.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = s - c;
        v = e - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder; 

      }
      
      if(ix > 0 && iy < (Y-1)) {
        var s = new Vector3.zero();
        s.x = ix.toDouble();
        s.y = g[yp1*X + ix] + h[yp1*X + ix];
        s.z = yp1.toDouble();  
        
        var w = new Vector3.zero();
        w.x = xm1.toDouble();
        w.y = g[iy*X + xm1] + h[iy*X + xm1];
        w.z = iy.toDouble();
        
        var u = new Vector3.zero();
        var v = new Vector3.zero();
        var rHolder = new Vector3.zero();
        
        u = s - c;
        v = w - c;
        cross3(u,v,rHolder);
        
        r = r + rHolder; 
      }  
      
      return r;
  }
  
  void waterInit(){
      
        g   = new List<double>(X*Y);
        
        b  = new List<bool>(Y*X);
        h  = new List<double>(X*Y);
        h1 = new List<double>(X*Y);
        u  = new List<double>(X*Y);
        u1 = new List<double>(X*Y);
        v  = new List<double>(X*Y);
        v1 = new List<double>(X*Y);
        
        // Boundaries
        for(int iy = 0; iy < Y; iy++) {
          for(int ix = 0; ix < X; ix++) {
            if(ix == 0 || iy == 0 || ix == X-1 || iy == Y-1) {
              b[iy*X + ix] = true;
            } else {
              b[iy*X + ix] = false;
            }
          }
        } 
        for(int iy = 0; iy < Y; iy++) {
          for(int ix = 0; ix < X; ix++) {
            if(blobMap[iy][ix] == 0){
              b[iy*X + ix] = true;
            }
          }
        }

        // Ground
        for(int iy = 0; iy < Y; iy++) {
          for(int ix = 0; ix < X; ix++) {
            g[iy*X + ix] = 0.0;
            //g[iy*X + ix] = iy * 0.2;
          }
        }

        // Height
        for(int iy = 0; iy < Y; iy++) {
          for(int ix = 0; ix < X; ix++) {
            h[iy*X + ix] = 0.0;
            h1[iy*X + ix]  = h[iy*X + ix];
          }
        }

        // Horizontal Velocity
        for(int iy = 0; iy < Y; iy++) {
          for(int ix = 0; ix < X; ix++) {
            u[iy*X + ix]  = 0.0;
            u1[iy*X + ix] = 0.0;
          }
        }

        // Vertical Velocity
        for(int iy = 0; iy < Y; iy++) {
          for(int ix = 0; ix < X; ix++) {
            v[iy*X + ix]  = 0.0;
            v1[iy*X + ix] = 0.0;
          }
        }
        
        /*for(int i = 0; i < h.length; i++){
          if(h[i] != 0){
            print(h[i]);
          }
        }*/
        /*
        for(int iy = 0; iy < Y; iy++) {
              for(int ix = 0; ix < X; ix++) {
                double r = math.sqrt((ix - X/2) * (ix - X/2) + (iy - Y/2) * (iy - Y/2));
                
                if(r < Y/2) {
                  r = (r / (Y/2)) * 4;
                  double PI = 3.14159;
                  h[iy*X + ix] += Y * (1/math.sqrt(2 * PI)) * math.exp(-(r*r) / 2);
                  
                  
                  //h[iy*X + ix] += ((Y/4) - r) * ((Y/4) - r);
                }
              }
            }
      */
      
      
    }
  
  void upwind(type){
      var t = new List<double>(X*Y);
      
      int x1, x2, y1, y2;
          double u_xy, v_xy;

          // Loop through each point
          for(int iy = 0; iy < Y; iy++) {
              int yp1 = iy + 1;
              int ym1 = iy - 1;
              for(int ix = 0; ix < X; ix++) {
                  int xp1 = ix + 1;
                  int xm1 = ix - 1;
                  // Select a certain array
                  switch(type) {
                      case 0:
                          // h
                          // Don't update a boundary
                          if(b[iy*X + ix] == true) {
                              t[iy*X + ix] = h[iy*X + ix];
                              break;
                          }

                          // Calculate velocity
                          u_xy = (u[iy*X + ix] + u[iy*X + xp1]) / 2.0;
                          v_xy = (v[iy*X + ix] + v[yp1*X + ix]) / 2.0;

                          // Horizontal coordinates
                          x1 = (u_xy < 0) ? xp1 :  ix;
                          x2 = (u_xy < 0) ?  ix : xm1;

                          // Vertical coordinates
                          y1 = (v_xy < 0) ? yp1 :  iy;
                          y2 = (v_xy < 0) ?  iy : ym1;

                          // Advected value
                          t[iy*X + ix] = h[iy*X + ix] - ((u_xy * (h[iy*X + x1] - h[iy*X + x2])) + (v_xy * (h[y1*X + ix] - h[y2*X + ix])))*dt;

                          break;
                      case 1:
                          // u
                          // Don't update a boundary
                          if(b[iy*X + ix] == true) {
                              t[iy*X + ix] = u[iy*X + ix];
                              break;
                          }

                          // Calculate velocity
                          u_xy =  u[iy*X + ix];
                          v_xy = (v[iy*X + xm1] + v[iy*X + ix] + v[yp1*X + xm1] + v[yp1*X + ix]) / 4.0;

                          // Horizontal coordinates
                          x1 = (u_xy < 0) ? xp1 :  ix;
                          x2 = (u_xy < 0) ?  ix : xm1;

                          // Vertical coordinates
                          y1 = (v_xy < 0) ? yp1 :  iy;
                          y2 = (v_xy < 0) ?  iy : ym1;

                          // Advected value
                          t[iy*X + ix] = u[iy*X + ix] - ((u_xy * (u[iy*X + x1] - u[iy*X + x2])) + (v_xy * (u[y1*X + ix] - u[y2*X + ix])))*dt;
                          break;
                      case 2:
                          // v
                          // Don't update a boundary
                          if(b[iy*X + ix] == true) {
                              t[iy*X + ix] = v[iy*X + ix];
                              break;
                          }

                          // Calculate velocity
                          u_xy = (u[ym1*X + ix] + u[ym1*X + xp1] + u[iy*X + ix] + u[iy*X + xp1]) / 4.0;
                          v_xy =  v[iy*X + ix];

                          // Horizontal coordinates
                          x1 = (u_xy < 0) ? xp1 :  ix;
                          x2 = (u_xy < 0) ?  ix : xm1;

                          // Vertical coordinates
                          y1 = (v_xy < 0) ? yp1 :  iy;
                          y2 = (v_xy < 0) ?  iy : ym1;

                          // Advected value
                          t[iy*X + ix] = v[iy*X + ix] - ((u_xy * (v[iy*X + x1] - v[iy*X + x2])) + (v_xy * (v[y1*X + ix] - v[y2*X + ix])))*dt;
                          break;
                  }
              }
          }
                    
          switch(type) {
            case 0:
              copy(h, t);
              break;
            case 1:
              copy(u, t);
              break;
            case 2:
              copy(v, t);
              break;
          }
    }
    
    void copy(List orignal, List update){
      for(int i = 0; i < orignal.length; i++){
        orignal[i] = update[i];
      }
    }
  
  void waterUpdate(){
          upwind(0);
          upwind(1);
          upwind(2);
          
                
          
          
          // Update h
          //#pragma omp parallel for
          for(int iy = 0; iy < Y; iy++) {
            for(int ix = 0; ix < X; ix++) {
              // Temporary variables
              double u_yx;
              double u_yxp1;
              double v_yx;
              double v_yp1x;

              // Don't update boundaries
              if(b[iy*X + ix] == false) {
                // Velocity across a boundary is zero
                if(b[iy*X + ix-1] == true) {
                  u_yx = 0.0;
                } else {
                  u_yx = u[iy*X + ix];
                }
                
                // Velocity across a boundary is zero
                if(b[iy*X + ix+1] == true) {
                  u_yxp1 = 0.0;
                } else {
                  u_yxp1 = u[iy*X + ix+1];
                }

                // Velocity across a boundary is zero
                if(b[(iy-1)*X + ix] == true) {
                  v_yx = 0.0;
                } else {
                  v_yx = v[iy*X + ix];
                }
                
                // Velocity across a boundary is zero
                if(b[(iy+1)*X + ix] == true) {
                  v_yp1x = 0.0;
                } else {
                  v_yp1x = v[(iy+1)*X + ix];
                }

                // Update the Height
                h[iy*X + ix] = h[iy*X + ix] + 0.5 * h[iy*X + ix] * ((u_yx - u_yxp1) + (v_yx - v_yp1x)) * dt;                
              } else {
                h[iy*X + ix] = 0.0;
              }
            }
          }

          // Update U
          //#pragma omp parallel for
          for(int iy = 0; iy < Y; iy++) {
            for(int ix = 0; ix < X; ix++) {
              // Don't update boundaries
              if(b[iy*X + ix] == false) {
                if(b[iy*X + ix-1] == true) {
                  u[iy*X + ix ] = 0.0;
                } else {
                  u[iy*X + ix] = u[iy*X + ix] + (0.98 * ((g[iy*X + ix-1] + h[iy*X + ix-1]) - (g[iy*X + ix] + h[iy*X + ix])) * dt);
                }
              } else {
                u[iy*X + ix] = 0.0;
              }
            }
          }

          //Update V
          //#pragma omp parallel for
          for(int iy = 0; iy < Y; iy++) {
            for(int ix = 0; ix < X; ix++) {
              // Don't update boundaries
              if(b[iy*X + ix] == false) {
                if(b[(iy-1)*X + ix] == true) {
                  v[iy*X + ix ] = 0.0;
                } else {
                  v[iy*X + ix] = v[iy*X + ix] + (0.98 * ((g[(iy-1)*X + ix] + h[(iy-1)*X + ix]) - (g[iy*X + ix] + h[iy*X + ix])) * dt);
                }
              } else {
                v[iy*X + ix] = 0.0;
              }
            }
          }
          
          
          //add height to a random point, but remove the same amount from another

          /*for(int i = 0; i < h.length; i++){
            if(h[i] != 0){
              print(h[i]);
            }
          }*/
          if(noise % 99999 == 1){
            var randX = new math.Random();
            int raX = 1 + randX.nextInt(X-2);
            var randY = new math.Random();
            int raY = 1 + randY.nextInt(Y-2);
            if(b[raX * X+raY] == false){
              if(b[(raX * X)+raY +1] == false && b[(raX * X)+raY -1] == false ){
                if(b[((raX+1) * X)+raY ] == false && b[((raX-1) * X)+raY] == false ){
                  
                  h[raX * X+raY] +=  h[raX * X+raY] < 5.0 ? 2.0: 0.0;
                  h[((raX * X))+raY +1] -= h[((raX * X))+raY +1] < 0.5? 0.0: 0.5;
                  h[((raX * X))+raY -1] -= h[((raX * X))+raY -1] < 0.5? 0.0: 0.5;
                  h[((raX+1 )* X)+raY ] -= h[((raX+1 )* X)+raY ] < 0.5? 0.0: 0.5;
                  h[((raX-1) * X)+raY ] -= h[((raX-1) * X)+raY ] < 0.5? 0.0: 0.5;
                }
              }
            }
            noise = 0;
          }else{
            noise++;
          }
          
          /*
           * view-source:http://www.ibiblio.org/e-notes/webgl/waves/water.html
          for ( var i = 1; i < n1; i++ )
            for ( var j = 1; j < n1; j++ ){
                 normz[t++] = h[i][j+1] - h[i][j-1];
                 normz[t++] = h[i+1][j] - h[i-1][j];
                 normz[t++] = h[i][j];
            }
          */
          
          
          var norm = new List();
          for(int x = 1; x < X; x++){
            for(int y = 1; y < Y; y++){
              if(indMap[x-1][y-1] != 0){
                wVert[(indMap[x-1][y-1])] = h[x*X+y] - 0.5;//10.0;
                var r = new Vector3.zero();
                r = calcNormal(y, x);
                norm.add(r.x);
                norm.add(r.y);
                norm.add(r.z);
              }
            }
          }
          gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterVert);  
          gl.bufferSubData(webgl.RenderingContext.ARRAY_BUFFER, 0, new Float32List.fromList(wVert));


          gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, waterNorm);
          gl.bufferSubData(webgl.ARRAY_BUFFER, 0, new Float32List.fromList(norm));
  }
  
 
    
    
  void drawWater(Matrix4 viewMat, Matrix4 projectMat){
     
    gl.useProgram(waterShader);
    
    utils.setMatrixUniforms(gl, viewMat, projectMat, waterUniforms['uPMatrix'], waterUniforms['uMVMatrix'], waterUniforms['uNormalMatrix']);
    
    gl.enableVertexAttribArray(waterAttributes['aVertexPosition']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, waterVert);
    gl.vertexAttribPointer(waterAttributes['aVertexPosition'], 3, webgl.FLOAT, false, 0, 0);
    
    gl.enableVertexAttribArray(waterAttributes['aVertexNormal']);
    gl.bindBuffer(webgl.ARRAY_BUFFER, waterNorm);
    gl.vertexAttribPointer(waterAttributes['aVertexNormal'], 3, webgl.FLOAT, false, 0, 0);
    
        
    gl.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, waterInd);
    
    gl.drawElements(webgl.TRIANGLES, waterIndices.length, webgl.UNSIGNED_SHORT, 0);
    //print(waterIndices.length);
    //print("h");
    
    
  }
    
    
    
    
  
}