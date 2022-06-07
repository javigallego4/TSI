; Gallego Menor, Francisco Javier
; Grupo: 3

(define (domain ej4)
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
		VCE - tipoUnidad

        ; NUEVO: Se incluyen dos tipos nuevos de unidades: 
        Marine Soldado - tipoUnidad
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

        ; PREDICADOS QUE AÑADO NUEVOS
        ; Indicamos que la unidad ?unidad se genera en el tipo de edificio ?tipoEdif
        (unidadGeneraEn ?unidad - unidad ?tipoEdif - tipoEdif)
        ; Indicamos que la unidad ?unidad es del tipo ?tipoUnidad
        (unidadEs ?unidad - unidad ?tipoUnidad - tipoUnidad)
        ; Indicamos que la unidad ?unidad esta ya construida
        (unidadConstruida ?unidad - unidad)
        ; Indicamos que el tipo de unidad ?tipoUni necesita del recurso ?rec para su construcción
        (recursoConstruirUnidad ?tipoUni - tipoUnidad ?rec - recurso)
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
        )
        :effect (and             
            (edificioConstruido ?edif)
            (entidadEn ?edif ?loc)
        )    
    )

    ; ESTA ACCION SE AÑADE NUEVA:
    ; Reclutar: mediante esta acción reclutaremos nuevas unidades. Puesto ahora, cada unidad se genera en un edificio concreto, los parámetros son: 
    ;   *.- Edificio, Unidad, Localización 
    (:action reclutar
        :parameters (?edif - edificio ?unidad - unidad ?locUnidad - localizacion)
        ; Las precondiciones que tendré en cuenta serán: 
        ;   1.- Dicha unidad no puede estar construida ya. 
        ;   2.- Los VCEs se reclutan en los Centros de Mando. Por su parte, los Marines y Soldados se reclutan  en los Barracones. 
        ;   3.- Para crear VCEs y Marines se necesitan minerales, mientras que para los soldados se necesita tanto mineral como gas. 
        :precondition (and
            ; ========== PRECONDICION 1 ============
            (not(unidadConstruida ?unidad))
            ; ========== PRECONDICION 2 ============
            ; Las unidades SOLO PUEDEN RECLUTARSE EN CENTROS DE MANDO Y BARRACONES. Por tanto, no pueden reclutarse en los Extractores. 
            (not(edifEs ?edif Extractor ))                                      
            ; Los VCEs se reclutan en Centros de Mando. 
            (imply (edifEs ?edif CentroDeMando) 
                (unidadEs ?unidad VCE)            
            )
            ; Marines y Soldados en Barracones. 
            (imply(edifEs ?edif Barracones )
                (or (unidadEs ?unidad Soldado) (unidadEs ?unidad Marine))
            )
            ; El edificio tiene que estar en la localización dada. 
            (entidadEn ?edif ?locUnidad) 
            ; ========== PRECONDICION 3 ============
            ; Para VCEs y Marines -> Minerales
            (imply (or (unidadEs ?unidad VCE) (unidadEs ?unidad Marine))
                (recursoDisponible Mineral)                
            )
            ; Para Soldados -> ambos
            (imply (unidadEs ?unidad Soldado)
                (and
                    (recursoDisponible Mineral)                
                    (recursoDisponible GasVespeno) 
                )
            )
        )
        
        ; Los efectos serán: 
        ;   1.- La unidad pasa a estar construida.
        ;   2.- La unidad está libre
        ;   3.- Entidad unidad en dicha localización 
        :effect (and
            (unidadConstruida ?unidad)
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?locUnidad)
        )
    )
)