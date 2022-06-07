; Gallego Menor, Francisco Javier
; Grupo: 3

(define (domain ej7)
    (:requirements :strips :adl :fluents)
    (:types 
        entidad localizacion recurso - object
        tipoRec - recurso
        unidad edificio - entidad
        tipoEdif - edificio
        tipoUnidad - unidad
    )
	(:constants
		CentroDeMando Barracones Extractor - tipoEdif
		GasVespeno Mineral - tipoRec
		VCE Marine Soldado - tipoUnidad
	)

    (:predicates 
        (entidadEn ?x - entidad ?y - localizacion)
        (caminoEntre ?x - localizacion ?y - localizacion)
        (edificioConstruido ?x - edificio)
        (recursoEn ?x - recurso ?y - localizacion)
        (vceExtrae ?x - unidad ?y - recurso)          
        (unidadLibre ?x - unidad) 
        (recursoConstruirEdificio ?x - tipoEdif ?rec - recurso)             
        (recursoDisponible ?x - recurso)
        (edifEs ?x - edificio ?y - tipoEdif )
        (unidadGeneraEn ?unidad - unidad ?tipoEdif - tipoEdif)
        (unidadEs ?unidad - unidad ?tipoUnidad - tipoUnidad)
        (unidadConstruida ?unidad - unidad)
        (recursoConstruirUnidad ?tipoUni - tipoUnidad ?rec - recurso)
    )

    ; Añadimos las siguientes funciones
    (:functions
        ; Mediante esta función vamos a llevar la cuenta de cuantas unidades almacenadas que tenemos de un recurso.
        (cantidadAlmacenadaRecurso ?rec - recurso)
        ; Mediante la siguiente función llevaremos la cuenta de las unidades que están extrayendo un recurso en una localización
        (cantidadVCENodoRecurso ?locRecurso - localizacion)

        ; Indicamos la cantidad de unidades del recurso ?rec, que el tipo de edificio ?tipoEdif necesita para su construcción
        (edificioRequiere ?tipEdif - tipoEdif ?rec - recurso)
        ; Indicamos la cantidad de unidades del recurso ?rec, que el tipo de edificio ?tipoEdif necesita para su reclutamiento
        (unidadRequiere ?tipoUnidad - tipoUnidad ?rec - recurso)
    )
    
    (:action navegar
        :parameters (?unidad - unidad ?locOrigen ?locDestino - localizacion)
        :precondition (and 
            (unidadLibre ?unidad)
            (caminoEntre ?locOrigen ?locDestino)
            (entidadEn ?unidad ?locOrigen)
        )
        :effect (and 
            (entidadEn ?unidad ?locDestino)
            (not(entidadEn ?unidad ?locOrigen))
        )    
    )

    (:action asignar
        :parameters (?unidad - unidad ?locRecurso - localizacion ?rec - recurso)
        :precondition (and 
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?locRecurso)
            (recursoEn ?rec ?locRecurso)
            (or
                (recursoEn Mineral ?locRecurso)
                (exists (?ed - edificio)
                    (and
                        (edifEs ?ed Extractor)
                        (entidadEn ?ed ?locRecurso)
                    )
                )
            )
        )
        :effect (and 
            (vceExtrae ?unidad ?rec)
            (not(unidadLibre ?unidad))
            (when (recursoEn Mineral ?locRecurso) 
                (recursoDisponible Mineral)
            )
            (when (recursoEn GasVespeno ?locRecurso)
                (recursoDisponible GasVespeno)
            )

            ; NUEVO
            ; Incrementamos en uno el nº de de unidades VCE extrayendo en el nodo de recurso. 
            (increase (cantidadVCENodoRecurso ?locRecurso) 1)
        )    
    )

    (:action construir
        :parameters (?unidad - unidad ?edif - edificio ?loc - localizacion)
        :precondition (and 
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?loc)
            (not(edificioConstruido ?edif))
            (exists (?ed - edificio) 
                (not (entidadEn ?ed ?loc))
            )
            (exists (?tipo - tipoEdif)
                (and
                    (edifEs ?edif ?tipo)
                    (or
                        (and
                            (recursoConstruirEdificio ?tipo Mineral)
                            (not(recursoConstruirEdificio ?tipo GasVespeno))
                            (recursoDisponible Mineral)
                        )
                        (and
                            (recursoConstruirEdificio ?tipo GasVespeno)
                            (not(recursoConstruirEdificio ?tipo Mineral))
                            (recursoDisponible GasVespeno)
                        )
                        (and
                            (recursoConstruirEdificio ?tipo Mineral)
                            (recursoDisponible Mineral)
                            (recursoConstruirEdificio ?tipo GasVespeno)
                            (recursoDisponible GasVespeno)
                        )
                    )
                )
            )

            ; NUEVO
            ; Comprobamos que disponemos de la cantidad necesaria para la construcción del edificio. 
            ; Tanto de minerales como de gas vespeno. 
            (exists (?tipoEdif - tipoEdif) 
                (and
                    (edifEs ?edif ?tipoEdif)
                    (>=
                        (cantidadAlmacenadaRecurso Mineral)
                        (edificioRequiere ?tipoEdif Mineral)
                    )
                    (>=
                        (cantidadAlmacenadaRecurso GasVespeno)
                        (edificioRequiere ?tipoEdif GasVespeno)
                    )
                )
            )            
        )
        :effect (and             
            (edificioConstruido ?edif)
            (entidadEn ?edif ?loc)

            ; NUEVO
            ; *** Barracones ***
            (when (edifEs ?edif Barracones)
                (and
                    ; Decrementamos la cantidad de recursos almacenados
                    (decrease (cantidadAlmacenadaRecurso Mineral) 30)
                    (decrease (cantidadAlmacenadaRecurso GasVespeno) 10)
                )
            )
            ; *** Extractor ***
            (when (edifEs ?edif Extractor)
                (decrease (cantidadAlmacenadaRecurso Mineral) 10)
            )
        )    
    )

    (:action reclutar
        :parameters (?edif - edificio ?unidad - unidad ?locUnidad - localizacion)
        :precondition (and
            (not(unidadConstruida ?unidad))
            (not(edifEs ?edif Extractor ))                                      
            (imply (edifEs ?edif CentroDeMando) 
                (unidadEs ?unidad VCE)            
            )
            (imply(edifEs ?edif Barracones )
                (or (unidadEs ?unidad Soldado) (unidadEs ?unidad Marine))
            )
            (entidadEn ?edif ?locUnidad) 
            (imply (or (unidadEs ?unidad VCE) (unidadEs ?unidad Marine))
                (recursoDisponible Mineral)                
            )
            (imply (unidadEs ?unidad Soldado)
                (and
                    (recursoDisponible Mineral)                
                    (recursoDisponible GasVespeno) 
                )
            )
            
            ; NUEVO
            ; Comprobamos que disponemos de la cantidad necesaria para el reclutamiento de la unidad. 
            ; Tanto de minerales como de gas vespeno.
            (exists (?tipoUnidad - tipoUnidad) 
                (and
                    (unidadEs ?unidad ?tipoUnidad)
                    (>=
                        (cantidadAlmacenadaRecurso Mineral)
                        (unidadRequiere ?tipoUnidad Mineral)
                    )
                    (>=
                        (cantidadAlmacenadaRecurso GasVespeno)
                        (unidadRequiere ?tipoUnidad GasVespeno)
                    )
                )
            )
        )
        :effect (and
            (unidadConstruida ?unidad)
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?locUnidad)

            ; NUEVO
            ; *** SOLDADO ***
            (when (unidadEs ?unidad Soldado)
                (and
                    ; Decrementamos la cantidad de recursos almacenados
                    (decrease (cantidadAlmacenadaRecurso Mineral) 30)
                    (decrease (cantidadAlmacenadaRecurso GasVespeno) 30)
                )
            )
            ; *** MARINE ***
            (when (unidadEs ?unidad Marine)
                (and
                    ; Decrementamos la cantidad de recursos almacenados
                    (decrease (cantidadAlmacenadaRecurso Mineral) 10)
                    (decrease (cantidadAlmacenadaRecurso GasVespeno) 15)
                )
            )
            ; *** VCE ***
            (when (unidadEs ?unidad VCE)
                (decrease (cantidadAlmacenadaRecurso Mineral) 5)
            )
        )
    )

    ; ESTA ACCION SE AÑADE NUEVA
    ; Recolectar: extraer recursos de un nodo y almacenarlos.
    ; Cada vez que se llame a esta acción se actualizará el número de minerales o gas
    ; vespeno almacenado. En concreto, la acción se ejecuta sobre un nodo de recurso, y
    ; como efecto se incrementará la cantidad de este recurso en 10 unidades por cada VCE
    ; asignado a dicho nodo. Además, se debe establecer un límite a la cantidad de recursos
    ; almacenados; es decir, esta acción no se podrá llevar a cabo si la cantidad recolectada
    ; más la almacenada previamente exceden el límite de recursos almacenable. Este límite
    ; se establece en 60 unidades, tanto para minerales como para gas vespeno. Inicialmente,
    ; dichos depósitos están vacíos.
    ;       ▪ Parámetros: Recurso, Localización
    (:action recolectar
        :parameters (?rec - recurso ?locRecurso - localizacion)
        ; Las precondiciones que tendremos en cuenta serán: 
        ;   1.- La suma de unidades recolectadas + las almacenadas ha de ser <= que el tope
        ;   2.- Debe haber un nodo de recurso en la localización dada. 
        ;   3.- El nº de unidades VCE asignadas al nodo de recurso tiene que ser >= 1
        :precondition (and
            ; ======= PRECONDICION 1 ========
            (<=
                (+
                    (cantidadAlmacenadaRecurso ?rec)
                    (* 10 (cantidadVCENodoRecurso ?locRecurso))
                )
                60
            )
            ; ======== PRECONDICION 2 ========
            (recursoEn ?rec ?locRecurso)                                
            ; ======== PRECONDICION 3 ========
            (>=
                (cantidadVCENodoRecurso ?locRecurso)
                1
            )            
        )

        ; Los efectos de esta acción son: 
        ;   1.- Se incrementan las unidades almacenadas del recurso dado como parámetro.
        :effect
            (increase (cantidadAlmacenadaRecurso ?rec) (* 10 (cantidadVCENodoRecurso ?locRecurso)))
    )
)