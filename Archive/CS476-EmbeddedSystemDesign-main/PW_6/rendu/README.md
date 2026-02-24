Our work was implemented in the directory `rendu`
we only submit the file than we modifie and the systeme for dependence
this is only the answer of the question, we need th rest of the virtualPrototype for run
## **Files Submitted**  
### **Verilog (Hardware) in module**  
- `rendu/modules/camera/verilog/camera_origin.v` – the origin code of the camera
- `rendu/modules/camera/verilog/camera_2.3.v` – part 2.3 the implementation of the camera (we use the default streaming.c)
- `rendu/modules/camera/verilog/camera_2.4.v` – part 2.4 the implementation of the camera (we use streaming_2.4.c)
- `rendu/modules/grayscaleCi/verilog/rgb565Grayscale.v`  – the grayscale verilog file for part 2.2
- `rendu/modules/grayscaleCi/verilog/rgb565ISE.v`  – the grayscale verilog file for part 2.2

### **C file** 
- `rendu/programs/camera/src/` – the origin code of the camera.C (trhee files)
- `rendu/programs/grayscale/src/grayscale_2.2.c` part 2.2 implement DMA and grayscale with 4 pixels
- `rendu/programs/grayscale/src/grayscale_origin.c` the origin code of part 2.2
- `rendu/programs/streaming/src/streaming_origin.c` the orgin code (use for part 2.3)
- `rendu/programs/streaming/src/streaming_2.4.c` code for part 2.4

---

## **description**  
### **part 2.2**  
we can observe than with this methode the camera is faster and the can compute more picture per seconds

### **2.3**  
we implement the exercise 2.3

### **2.4**
we implement the exercise 2.4
---

---

Sebatien Devaud 315144
Charles Brossard 346186