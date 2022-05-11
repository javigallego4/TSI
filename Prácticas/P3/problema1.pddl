; Gallego Menor, Francisco Javier
; Grupo: 3

(define (problem ej1)
    (:domain ej1)
    (:objects 
        ; Definimos los nombres y tipos de los objetos del mapa. 
        ; Diapo 36 -> Ejemplo         
        ; <nombre del objeto> - <tipo de objeto>                
        
    ; Cada nodo del grafo representará una “localización”, en la que puede haber edificios y unidades
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
                          loc44 - localizacion
        
    ; Puesto que se nos comenta información a cerca de ellos en el enunciado del 
    ; ejercicio, añadimos los siguientes objetos.         
        VCE1 - unidad
        CentroDeMando1 - edificio        
    )
    (:init
        ; Definimos el estado inicial del problema. 
        ; Diapo 37 -> Ejemplo

    ; En la localización LOC11 debe encontrarse el edificio CentroDeMando1 (de tipo CentroDeMando)
    ; y la unidad VCE1 (de tipo VCE).
        (entidadEn CentroDeMando1 loc11)
        (entidadEn VCE1 loc11)

    ; En el mapa existen dos recursos de mineral, en las localizaciones loc22 y loc32
        (recursoEn Mineral loc22)
        (recursoEn Mineral loc32)

    ; Añadimos que la unidad VCE1 se encuentra libre en el estado inicial del problema
        (unidadLibre VCE1)    

    ; El problema debe definir el mapa de localizaciones expuesto anteriormente. Las aristas entre localizaciones representan un camino entre entre ambas.
    ; Añadimos las restricciones en cuanto a aristas entre localizaciones del grafo propuesto.        
        
        ; Aristas que salen de loc11
        (caminoEntre loc11 loc12)
        (caminoEntre loc11 loc21)

        ; Aristas que salen de loc21
        (caminoEntre loc21 loc11)
        (caminoEntre loc21 loc31)

        ; Aristas que salen de loc31
        (caminoEntre loc31 loc21)
        (caminoEntre loc31 loc32)

        ; Aristas que salen de loc12
        (caminoEntre loc12 loc11)
        (caminoEntre loc12 loc22)

        ; Aristas que salen de loc22
        (caminoEntre loc22 loc12)
        (caminoEntre loc22 loc32)
        (caminoEntre loc22 loc23)

        ; Aristas que salen de loc32
        (caminoEntre loc32 loc31)
        (caminoEntre loc32 loc22)

        ; Aristas que salen de loc13
        (caminoEntre loc13 loc14)
        (caminoEntre loc13 loc23)

        ; Aristas que salen de loc23
        (caminoEntre loc23 loc22)
        (caminoEntre loc23 loc13)
        (caminoEntre loc23 loc33)

        ; Aristas que salen de loc33
        (caminoEntre loc33 loc34)
        (caminoEntre loc33 loc23)

        ; Aristas que salen de loc14
        (caminoEntre loc14 loc13)
        (caminoEntre loc14 loc24)
        
        ; Aristas que salen de loc24
        (caminoEntre loc24 loc34)
        (caminoEntre loc24 loc14)

        ; Aristas que salen de loc34
        (caminoEntre loc34 loc24)
        (caminoEntre loc34 loc33)
        (caminoEntre loc34 loc44)

        ; Aristas que salen de loc44
        (caminoEntre loc44 loc34)
    )
    (:goal
    ; generar recursos de tipo Mineral.
        (vceExtrae VCE1 Mineral)
    )
)