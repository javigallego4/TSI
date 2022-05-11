; Gallego Menor, Francisco Javier
; Grupo: 3

(define (domain ej3)
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

    ; ESTA ACCION SE MODIFICA
    ;   3.- Construir: Partiendo del ejercicio anterior, modificar la acción Construir para que tenga en cuenta que un
    ;       edificio puede requerir más de un tipo de recurso. Esta acción debe inferir por sí misma si se tiene
    ;       el tipo de recursos necesarios para poder ejecutarse. Además, debe evitar que se construya más de
    ;       un edificio en la misma localización.
    ;        ▪ Parámetros: Unidad, Edificio, Localización
    (:action construir
        :parameters (?unidad - unidad ?loc - localizacion ?edif - edificio)
        ; Las precondiciones que tendré en cuenta serán: 
        ;   1.- La unidad ha de estar libre
        ;   2.- La localización en la que se encuentra la unidad tiene que ser aquella en la que se quiere construir el edificio
        ;   3.- El edificio dado como parámetro no puede estar ya construido
        ;   4.- No puede haber ningún otro edificio construido en dicha localización. 
        ;   4.- Tenemos que disponer de recursos disponibles para la construcción. 
        :precondition (and 
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?loc)
            (not(edificioConstruido ?edif))

            ; PRECONDICIONES NUEVAS  
            ; Con esto evitamos que haya más de un edificio construido en la misma localización.           
            (exists (?ed - edificio) 
                (not (entidadEn ?ed ?loc))
            )
            ; Con esto vemos que tipo de edificio es, para así saber que recurso necesita para su construcción
            ; Hace falta meter el exists porque sino, al no ser un parámetro no lo reconoce. 
            (exists (?tipo - tipoEdif)
                (and
                    (edifEs ?edif ?tipo)
                    ; Dividimos por casos: 
                    ;   1.- Solo necesita Mineral.
                    ;   2.- Solo necesita Gas.
                    ;   3.- Necesita de ambos. 
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

        ; Los efectos de esta acción son los siguientes: 
        ;   1.- El edificio ?edif se encuentra construido
        ;   2.- El nuevo edificio está en la localización ?loc.
        :effect (and             
            (edificioConstruido ?edif)
            (entidadEn ?edif ?loc)
        )    
    )
)