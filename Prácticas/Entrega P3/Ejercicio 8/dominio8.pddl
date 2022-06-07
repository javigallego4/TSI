; Gallego Menor, Francisco Javier
; Grupo: 3

(define (domain ej8)
    (:requirements :strips :adl :fluents)
    (:types 
        entidad localizacion recurso - object
        tipoRec - recurso
        unidad edificio - entidad
        tipoEdif - edificio
        tipoUnidad - unidad
    )
	(:constants
		CentroDeMando Barracon Extractor - tipoEdif
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

    (:functions
        (cantidadAlmacenadaRecurso ?rec - recurso)
        (cantidadVCENodoRecurso ?locRecurso - localizacion)
        (edificioRequiere ?tipEdif - tipoEdif ?rec - recurso)
        (unidadRequiere ?tipoUnidad - tipoUnidad ?rec - recurso)

        ; NUEVO: añadimos la siguiente funcion para llevar el conteo de uds. de tiempo requeridas para la realización del plan. 
        (tiempoAcciones)
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

            ; NUEVO: incrementamos el tiempo total consumido por esta acción
            ; ; *** NAVEGAR ***
            ; La distancia entre cualesquiera dos localizaciones conectadas es de 20 unidades. 
            ; Velocidades de las unidades: 
            ;   1.- VCE: 1 unidad de distancia / unidad de tiempo
            ;   2.- Marine: 5 unidad de distancia / unidad de tiempo
            ;   3.- Soldado: 10 unidad de distancia / unidad de tiempo

            ; Si la unidad es un VCE. Como son 20 ud. de distancia y la velocidad es de 1 ud. dstancia / 1 ud. de tiempo
            ; incrementamos el valor en 20 unidades. 
            (when (unidadEs ?unidad VCE)
                (increase (tiempoAcciones) 20)
            )
            ; Si la unidad es un Soldado. Como son 20 ud. de distancia y la velocidad es de 10 ud. dstancia / 1 ud. de tiempo
            ; incrementamos el valor en 2 unidades.
            (when (unidadEs ?unidad Soldado)
                (increase (tiempoAcciones) 2)
            )
            ; Si la unidad es un Marine. Como son 20 ud. de distancia y la velocidad es de 5 ud. dstancia / 1 ud. de tiempo
            ; incrementamos el valor en 4 unidades.
            (when (unidadEs ?unidad Marine)
                (increase (tiempoAcciones) 4)
            )
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
            (increase (cantidadVCENodoRecurso ?locRecurso) 1)
        )    
    )

    (:action construiredificio
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
            (when (edifEs ?edif Barracon)
                (and
                    (decrease (cantidadAlmacenadaRecurso Mineral) 30)
                    (decrease (cantidadAlmacenadaRecurso GasVespeno) 10)
                )
            )
            (when (edifEs ?edif Extractor)
                (decrease (cantidadAlmacenadaRecurso Mineral) 10)
            )

            ; NUEVO: incrementamos el tiempo total consumido por esta acción
            ; *** CONSTRUIR ***
            ; Los tiempos de creación de cada elemento son los siguientes
            ;   1.- Barracon: 50
            ;   2.- Extractor: 20
            ; Barracon 
            (when (edifEs ?edif Barracon)
                (increase (tiempoAcciones) 50)
            )
            ; Extractor
            (when (edifEs ?edif Extractor)
                (increase (tiempoAcciones) 20)
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
            (imply(edifEs ?edif Barracon )
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
            (when (unidadEs ?unidad Soldado)
                (and
                    (decrease (cantidadAlmacenadaRecurso Mineral) 30)
                    (decrease (cantidadAlmacenadaRecurso GasVespeno) 30)
                )
            )
            (when (unidadEs ?unidad Marine)
                (and
                    (decrease (cantidadAlmacenadaRecurso Mineral) 10)
                    (decrease (cantidadAlmacenadaRecurso GasVespeno) 15)
                )
            )
            (when (unidadEs ?unidad VCE)
                (decrease (cantidadAlmacenadaRecurso Mineral) 5)
            )

            ; NUEVO: incrementamos el tiempo total consumido por esta acción
            ; *** RECLUTAR ***
            ; Los tiempos de reclutameinto son: 
            ;   1.- VCE: 10
            ;   2.- Marine: 20
            ;   3.- Soldado: 30
            ; VCE
            (when (unidadEs ?unidad VCE)
                (increase (tiempoAcciones) 10)
            )
            ; Soldado
            (when (unidadEs ?unidad Soldado)
                (increase (tiempoAcciones) 30)
            )
            ; Marine
            (when (unidadEs ?unidad Marine)
                (increase (tiempoAcciones) 20)
            )
        )
    )

    (:action recolectar
        :parameters (?rec - recurso ?locRecurso - localizacion)
        :precondition (and
            (<=
                (+
                    (cantidadAlmacenadaRecurso ?rec)
                    (* 10 (cantidadVCENodoRecurso ?locRecurso))
                )
                60
            )
            (recursoEn ?rec ?locRecurso)                                
            (>=
                (cantidadVCENodoRecurso ?locRecurso)
                1
            )            
        )

        :effect (and
            (increase (cantidadAlmacenadaRecurso ?rec) (* 10 (cantidadVCENodoRecurso ?locRecurso)))
            ; NUEVO: incrementamos en 5 el tiempo consumido por esta acción. 
            (increase (tiempoAcciones) 5)        
        )
    )
)