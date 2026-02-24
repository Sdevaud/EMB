Our work was implemented in the directory `PW_2/virtualprototype/programs/grayscale/src/`
## **Files Submitted**  
### **Verilog (Hardware)**  
- `Profiler.v` – part 1 verilog file 
- `Profiler_tb.v` – part 1 test bench of Profiler.v
- `vga_controller.v` – Handles VGA output.  
- `rgb565GrayscaleIsE`  – part 2 verilog
- `rgb565GrayscaleIsE_tb`  – part 2 test bench

### **C (Software)**  
- `grayscale.c` – Main program with profiling logic.  


---

## **Changes Made**  
### **Hardware (Verilog)**  
**Added custom instruction** (`opcode 0xC`) in `grayscale_processor.v`:  
   - Takes **RGB565 input**, outputs **8-bit grayscale** using the formula:  
     \[
     \text{Gray} = (R \times 54 + G \times 183 + B \times 19) \gg 8
     \]  

### **Software (C)**  
 **Profiling logic** in `grayscale.c`:  
   - Reads:  
     - **Execution cycles** (total clock cycles).  
     - **Stall cycles** (CPU waiting for memory).  
     - **Bus-idle cycles** (no memory transactions).  
   - Computes **real execution time**:  
     \[
     \text{Real Cycles} = \text{Execution Cycles} - \text{Stall Cycles}
     \]  


---

## **Performance Results**  

| Metric                  | Given Conversion | Standard Conversion | Custom Instruction |  
|-------------------------|------------------|---------------------|--------------------|  
| **Execution Cycles**    | 3910993042       | 3538520145          | 3218631939         |  
| **Stall Cycles**        | 3407945687       | 3235672105          | 3086401744         |  
| **Bus-Idle Cycles**     | 3694880479       | 3468640266          | 3274310989         |  
| **Real Execution Time** | 503047355        | 302848040           | 132229195          |  

**Speedup Comparisons:**  
1. **Given Conversion vs. Standard Conversion:**  
  \[
  \text{Speedup} = \frac{\text{Given Cycles}}{\text{Standard Cycles}} = \frac{503047355}{302848040} \approx 1.66
  \]  

2. **Standard Conversion vs. Custom Instruction:**  
  \[
  \text{Speedup} = \frac{\text{Standard Cycles}}{\text{Custom Cycles}} = \frac{302848040}{132229195} \approx 2.29
  \]  

3. **Given Conversion vs. Custom Instruction:**  
  \[
  \text{Speedup} = \frac{\text{Given Cycles}}{\text{Custom Cycles}} = \frac{503047355}{132229195} \approx 3.81
  \]  

---

## **Conclusion**  

The addition of the custom instruction has significantly improved the performance of the grayscale conversion. Compared to the given conversion, the custom instruction achieved a speedup of approximately **3.81**, demonstrating the substantial benefits of hardware acceleration. Even when compared to the standard conversion, the custom instruction provided a speedup of **2.29**, further highlighting its efficiency. These results validate the effectiveness of optimizing embedded systems for computationally intensive tasks.


---

Sebatien Devaud 315144
Charles Brossard 346186