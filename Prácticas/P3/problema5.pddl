; Gallego Menor, Francisco Javier
; Grupo: 3

(define (problem ej5)
    (:domain ej5)
    (:objects 
        loc11 loc12 loc13 loc14 - localizacion
        loc21 loc22 loc23 loc24 - localizacion
        loc31 loc32 loc33 loc34 - localizacion
                          loc44 - localizacion
        CentroDeMando1 Extractor1 Barracones1 - edificio   
        VCE1 VCE2 VCE3 marine1 marine2 soldado1 - unidad

        ; NUEVO
        Bahia1 - edificio
        investigacion1 - investigacion
    )
    (:init

        ; ****** UNIDADES ******
        (entidadEn VCE1 loc11)
        (unidadLibre VCE1)  
        (unidadConstruida VCE1)
        (unidadEs VCE1 VCE)
        (unidadEs VCE2 VCE)
        (unidadEs VCE3 VCE)
        (unidadEs marine1 Marine)
        (unidadEs marine2 Marine)
        (unidadEs soldado1 Soldado)        

        ; ****** EDIFICIOS ******
        ;   1.- Centros de Mando
        (entidadEn CentroDeMando1 loc11)
        (edifEs CentroDeMando1 CentroDeMando)   
        (edificioConstruido CentroDeMando1) 
        ;   2.- Extractores
        (edifEs Extractor1 Extractor) 
        (recursoConstruirEdificio Extractor Mineral)
        ;   3.- Barracones
        (edifEs Barracones1 Barracones)
        (recursoConstruirEdificio Barracones Mineral)
        (recursoConstruirEdificio Barracones GasVespeno)
        ; NUEVO
        ;   4.- Bahía de Ingeniería
        (edifEs Bahia1 BahiaDeIngenieria)
        (recursoConstruirEdificio BahiaDeIngenieria Mineral)
        (recursoConstruirEdificio BahiaDeIngenieria GasVespeno)

        ; ****** RECURSOS *******
        (recursoEn Mineral loc22)
        (recursoEn Mineral loc32)
        (recursoEn GasVespeno loc44)

        ; ***** INVESTIGACIONES *****
        ; NUEVO
        (investigacionEs investigacion1 InvestigarSoldadoUniversal)

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
    )
    (:goal
        ; NUEVO: El objetivo de este ejercicio es construir unos barracones en la localización LOC14, construir
        ; una Bahía de Ingeniería en la localización LOC12, y que el Marine1, el Marine2 y el Soldado1
        ; estén en la localización LOC14. 
        (and
            ; MARINE 1
            (unidadConstruida marine1)
            (entidadEn marine1 loc14)
            ; MARINE 2
            (unidadConstruida marine2)
            (entidadEn marine2 loc14)
            ; SOLDADO 1
            (unidadConstruida soldado1)
            (entidadEn soldado1 loc14)

            (edificioConstruido Barracones1) 
            (entidadEn Barracones1 loc14)

            ; NUEVO
            ; Bahía
            (edificioConstruido Bahia1)
            (entidadEn Bahia1 loc12)
        )
    )
)