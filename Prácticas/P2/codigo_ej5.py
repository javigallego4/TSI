import numpy as np

#Función para generar un grafo aleatorio
#con N nodos y M aristas
def randomgraph(N,M,seed):
    
    print("int: NUM_NODOS=", N, ";")
    print("int: NUM_ARISTAS=", M, ";")
    print("array[1..NUM_ARISTAS,1..2] of int: aristas =[|", end='')
    
    #Fijamos la semilla
    np.random.seed(seed)
    
    #Iteramos para cada arista
    for i in range(M):
        
        #Generamos dos nodos en [1,N]
        n1 = np.random.randint(0,N)+1
        n2 = np.random.randint(0,N)+1
        
        #Si son el mismo se re-genera
        while n1==n2:
            n2 = np.random.randint(0,N)+1
            
        #Se imprime la arista
        print(n1, ",", n2, "|", end='')
        
    print("];")
    print("")

randomgraph(14,91,1)
randomgraph(14,91,2)
randomgraph(14,91,3)

