# Commandes importantes


## activél'environement virtuel : 
```
source oss-cad-suite/environment
```

## Comment lancer le programme sur la carte
1. Commande pour make:
```
make mem1420
``` 

2. lancer cuteCom
3. selectionner port 
4. open (le port)
5. faire `*h` pour afficher que tout est connecté et toutes les options
6. **send file** prendre le *.cmem*
7. `$` pour rendre le program chargé


## Comment lancer un test bench sur verilog
```
iverilog -s counterTestBench -o testbench counter.v counter_tb.v 
./testbench
gtkwave testbench.vcd
```

## Lancer la camera
utiliser cheese

## Flash Hardware
cd virtualprototype/systems/singleCore/sandbox/
../scripts/synthesizeOr1420.sh > logs.txt 2>&1
openFPGALoader -f or1420SingleCore.bit
