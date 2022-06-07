"""
Para ejecutarlo:

$ ./Metric-FF/ff -o Soluciones/dominio8.pddl -f Soluciones/problema8.pddl -O -g 1 -h 1 | python3 Evaluacion/getCostFromPlanEj8.py

o 

$ ./Metric-FF/ff -o Soluciones/dominio8.pddl -f Soluciones/problema8.pddl -O -g 1 -h 1 > solucion
$ python3 Evaluacion/getCostFromPlanEj8.py solucion
"""

import sys
import fileinput

cost = 0
printPlan = False

Lines = []

# Leer de fichero (ej: solucion.txt)
if len(sys.argv)>1:
    plan = open(sys.argv[1], 'r')
    Lines = plan.readlines()
# Leer de stdin
else:
    Lines = fileinput.input()


processLine = False
for line in Lines:
    
    # Procesar líneas entre "step" y "time spent"
    if line.startswith("step"):
        processLine = True
    elif line.startswith("time spent"):
        processLine = False
    
    # Procesar líneas que definen una acción: contienen el caracter ":" (ignorar líneas vacías)
    if ":" in line and processLine:
        
        # La acción se define a partir del caracter 11 de la línea
        actionStr = line[11:]
        if printPlan:
            print(actionStr, end='')
        
        # Dividimos los distintos argumentos de la acción
        actionArr = actionStr.split(" ")
        
        # COSTES:
        
        # Navegar: Coste = Distancia / Velocidad
        #    - Todas las casillas a distancia 20
        #    - velocidad(VCE)=1, vel(MARINE)=5, vel(SOLDADO=10)
        if actionArr[0] == "NAVEGAR" and actionArr[1].startswith("VCE"):
            cost += 20
        elif actionArr[0] == "NAVEGAR" and actionArr[1].startswith("MARINE"):
            cost += 4
        elif actionArr[0] == "NAVEGAR" and actionArr[1].startswith("SOLDADO"):
            cost += 2
            
        # Asignar: No tiene coste    
        elif actionArr[0] == "ASIGNAR":
            cost += 0
            
        # ConstruirEdificio: Coste = tiempo de construcción
        #    - tiempo(Extractor)=20, tiempo(Barracones)=50
        elif actionArr[0]=="CONSTRUIREDIFICIO" and actionArr[2].startswith("EXTRACTOR"):
            cost += 20
        elif actionArr[0]=="CONSTRUIREDIFICIO" and actionArr[2].startswith("BARRACON"):
            cost += 50
            
        # Reclutar:  Coste = tiempo de reclutar
        #    - tiempo(VCE)=10, tiempo(MARINE)=20, tiempo(SOLDADO)=30
        elif actionArr[0]=="RECLUTAR" and actionArr[2].startswith("VCE"):
            cost += 10
        elif actionArr[0]=="RECLUTAR" and actionArr[2].startswith("MARINE"):
            cost += 20
        elif actionArr[0]=="RECLUTAR" and actionArr[2].startswith("SOLDADO"):
            cost += 30
            
        # Recolectar: coste fijo de 5 unidades
        elif actionArr[0]=="RECOLECTAR":
            cost += 5
            
            
print("TOTAL COST = ", cost)
