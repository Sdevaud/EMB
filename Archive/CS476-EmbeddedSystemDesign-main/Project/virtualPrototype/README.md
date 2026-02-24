Our work was implemented in the directory `Project`
we only submit the file than we modifie and the systeme for dependence
this is only the answer of the question, we need th rest of the virtualPrototype for run
## **Files modified**  
- `Project/modules/verilog/ramDmaCi/ramDmaCi.v` – Increase the size of dma 2KB -> 5KB
- `Project/modules/verilog/ramDmaCi/dualportSSram.v` – Increase the size of dma 2KB -> 5KB
- `Project/virtualprototype/systems/singleCore/scripts/yosysOr1420.script` – adding path
- `Project/virtualprototype/systems/singleCore/verilog/or1420SingleCore.v`  – adding module


## **files added** 
- `Project/virtualprototype/programs/sobel/src/sobel_bad.c` – slow speed version of the sobel filter
- `Project/virtualprototype/programs/sobel/src/sobel.c` higher speed version of sobel filter
- `Project/virtualprototype/modules/sobel/verilog/sobel.v` Ci of sobel computation
- `Project/virtualprototype/modules/sobel/verilog/converterPixel.v` Ci for manage pixel indentetion
- `Project/virtualprototype/modules/sobel/verilog/converterPixel1.v` Ci for manage pixel indentetion
- `Project/virtualprototype/modules/sobel/verilog/sobelISE.v` Ci for manage pixel indentetion
- `Project/Report Embedded System Design.pdf` Ci for manage pixel indentetion

---

---

Sebatien Devaud 315144
Charles Brossard 346186