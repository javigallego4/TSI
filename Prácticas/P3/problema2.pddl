; Gallego Menor, Francisco Javier
; Grupo: 3

(define (problem ej2)
    (:domain ej2)
    (:objects 
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
                          loc44 - localizacion
        CentroDeMando1 - edificio   
        VCE1 - unidad
        
        ; NUEVO: añadimos la unidad VCE2 y el Extractor1
        VCE2 - unidad
        Extractor1 - edificio
        mineral1 mineral2 gas1 - recurso
    )
    (:init
        (entidadEn CentroDeMando1 loc11)
        (entidadEn VCE1 loc11)
        (recursoEn Mineral loc22)
        (recursoEn Mineral loc32)
        (unidadLibre VCE1)    
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


        ; NUEVO: 
        (entidadEn VCE2 loc11)
        (unidadLibre VCE2)         
        (edifEs CentroDeMando1 CentroDeMando)   
        (edificioConstruido CentroDeMando1) 
        (edifEs Extractor1 Extractor)  

        ; Existe un nodo de gas vespeno en la localización LOC44
        (recursoEn GasVespeno loc44)

        ; El edificio de tipo extractor necesita minerales para su construcción. 
        (recursoConstruirEdificio Extractor Mineral)
        
    )
    (:goal
        ; NUEVO: el objetivo de este ejercicio es generar recursos de tipo gas vespeno. 
        (recursoDisponible GasVespeno)
    )
)