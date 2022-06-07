; Gallego Menor, Francisco Javier
; Grupo: 3

(define (problem ej8)
    (:domain ej8)
    (:objects 
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
                          loc44 - localizacion
        CentroDeMando1 Extractor1 Barracon1 - edificio   
        VCE1 VCE2 VCE3 marine1 marine2 soldado1 - unidad
    )
    (:init

        ; UNIDADES
        (entidadEn VCE1 loc11)
        (unidadLibre VCE1)  
        (unidadConstruida VCE1)
        (unidadEs VCE1 VCE)
        (unidadEs VCE2 VCE)
        (unidadEs VCE3 VCE)
        (unidadEs marine1 Marine)
        (unidadEs marine2 Marine)
        (unidadEs soldado1 Soldado)


        ; (recursoConstruirUnidad VCE Mineral)
        ; (recursoConstruirUnidad Marine Mineral)
        ; (recursoConstruirUnidad Soldado Mineral)
        ; (recursoConstruirUnidad Soldado GasVespeno)

        ; EDIFICIOS
        ;   1.- Centros de Mando
        (entidadEn CentroDeMando1 loc11)
        (edifEs CentroDeMando1 CentroDeMando)   
        (edificioConstruido CentroDeMando1) 
        ;   2.- Extractores
        (edifEs Extractor1 Extractor) 
        (recursoConstruirEdificio Extractor Mineral)
        ;   3.- Barracon
        (edifEs Barracon1 Barracon)
        (recursoConstruirEdificio Barracon Mineral)
        (recursoConstruirEdificio Barracon GasVespeno)

        ; RECURSOS
        (recursoEn Mineral loc22)
        (recursoEn Mineral loc32)
        (recursoEn GasVespeno loc44)

        ; CAMINOS DEL GRAFO
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

        ; Cantidad de unidades de recurso que requieren los tipos de edificios para su construcción
        (= (edificioRequiere Barracon Mineral) 30)
        (= (edificioRequiere Barracon GasVespeno) 10)
        (= (edificioRequiere Extractor Mineral) 10)
        (= (edificioRequiere Extractor GasVespeno) 0)

        ; Cantidad de unidades de recurso que requieren los tipos de edificios para su construcción
        (= (unidadRequiere VCE Mineral) 5)
        (= (unidadRequiere VCE GasVespeno) 0)
        (= (unidadRequiere Marine Mineral) 10)
        (= (unidadRequiere Marine GasVespeno) 15)
        (= (unidadRequiere Soldado Mineral) 30)
        (= (unidadRequiere Soldado GasVespeno) 30)

        ; Cantidad de unidades asignadas a los nodos de recursos
        (= (cantidadVCENodoRecurso loc22) 0)
        (= (cantidadVCENodoRecurso loc32) 0)
        (= (cantidadVCENodoRecurso loc44) 0)
        ; Cantidad almacenada inicial de recursos
        (= (cantidadAlmacenadaRecurso Mineral) 0)
        (= (cantidadAlmacenadaRecurso GasVespeno) 0)

        ; ***** NUEVO ******
        ; Inicializamos el tiempo de las acciones a 0. 
        (= (tiempoAcciones) 0)


    )
    (:goal
        ; NUEVO: El objetivo de este problema es disponer de un marine (Marine1) en la localización LOC31,
        ; otro marine (Marine2) en la localización LOC24, y un soldado (Soldado1) en la localización
        ; LOC12. Nótese que para ello hace falta construir un extractor (Extractor1) con el que obtener gas
        ; vespeno, con el que posteriormente se construirá unos Barracon (Barracon1) donde se
        ; reclutarán estas unidades militares. 
        (and
            ; MARINE 1
            (unidadConstruida marine1)
            (entidadEn marine1 loc31)
            ; MARINE 2
            (unidadConstruida marine2)
            (entidadEn marine2 loc24)
            ; SOLDADO 1
            (unidadConstruida soldado1)
            (entidadEn soldado1 loc12)

            (edificioConstruido Barracon1) 
            (entidadEn Barracon1 loc32)
        )
    )

    ; NUEVO: incluimos la métrica para minimizar el tiempo de las acciones. 
    (:metric minimize (tiempoAcciones))
)