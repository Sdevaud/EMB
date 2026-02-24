Our work was implemented in the directory `PW_4/pw4/virtualprototype/modules/gpio/verilog`

## **Files Submitted**  
### **Verilog (Hardware)**  
- `ramDmaCI.v` – Part 2.2 Verilog file 
- `ramDmaCI_tb.v` – Part 2.2 test bench for `ramDmaCI.v`
- `DMA_23.v` – Part 2.3 Verilog file
- `DMA_tb.v` – Part 2.3 test bench for `DMA_23.v`
- `ramDmaCi_24.v` – Part 2.4 Verilog file 
- `ramDmaCi_24_tb.v` – Part 2.4 test bench for `ramDmaCi_24.v` 

---

## **Description**  
### **Part 2.2**  
We implemented the first exercise and used a test bench with different input values to verify our results.

### **Part 2.3**  
For this exercise, we implemented only Part 2.3 without merging it with the previous exercise.  
You can run the test bench using the following commands:
```bash
iverilog -s ramDmaCiDMATestBench -o DMAbench_23 DMA_23.v DMA_23_tb.v
./DMAbench_23
gtkwave DMA_23_Signals.vcd
```

### **Part 2.4**  
In this module, we implemented all the exercises, integrating the functionality from previous parts.  
You can run the test bench for Part 2.4 using the following commands:
```bash
iverilog -o ramDmaCi_24_tb.out ramDmaCi_24_tb.v ramDmaCi_24.v
./ramDmaCi_24_tb.out
gtkwave ramDmaCi_24_tb.vcd
```

---

Sebastien Devaud 315144  
Charles Brossard 346186