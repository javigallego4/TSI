; Gallego Menor, Francisco Javier
; Grupo: 3

(define (domain ej2)
    (:requirements :strips :typing :adl)
    (:types 
        entidad localizacion recurso - object
        tipoRec - recurso
        unidad edificio - entidad
        tipoEdif - edificio
        tipoUnidad - unidad
    )
	(:constants
		CentroDeMando Barracones - tipoEdif
		GasVespeno Mineral - tipoRec
		VCE - tipoUnidad

        ; NUEVO: AÑADIMOS EL TIPO DE EDIFICIO EXTRACTOR
        Extractor - tipoEdif
	)

    (:predicates 
        (entidadEn ?x - entidad ?y - localizacion)
        (caminoEntre ?x - localizacion ?y - localizacion)
        (edificioConstruido ?x - edificio)
        (recursoEn ?x - recurso ?y - localizacion)
        (vceExtrae ?x - unidad ?y - recurso)          
        (unidadLibre ?x - unidad) 

        ; PREDICADO AÑADIDO PARA EJERCICIO 2: Definir qué recurso necesita cada edificio para ser construido. 
        ; Indicamos que el tipo de edificio ?x necesita el recurso ?rec para ser construido
        (recursoConstruirEdificio ?x - tipoEdif ?rec - recurso)             

        ; A parte, añado los siguientes predicado: 
        ; Indico si hay recursos ?x disponibles
        (recursoDisponible ?x - recurso)
        ; Indicamos que el edificio ?x es del tipo ?y
        (edifEs ?x - edificio ?y - tipoEdif )
        ; Indicamos que el recurso ?x es del tipo ?y
        (recursoEs ?x - recurso ?y - tipoRec)
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

    ; ESTA ACCION SE MODIFICA
    ;   2.- Asignar: Para poder obtener Gas Vespeno (es decir, asignar un VCE a un nodo de gas
    ;       vespeno), debe existir un edificio Extractor construido previamente sobre dicho nodo de recurso. No hay cambios para obtener recursos de mineral.
    (:action asignar
        :parameters (?unidad - unidad ?locRecurso - localizacion ?rec - recurso)
        ; PRECONDICIONES NUEVAS: 
        ;   *.- En dicha localización debe de haber, o bien un edificio extractor (por si el recurso es gas), o bien un recurso de tipo mineral. 
        :precondition (and 
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?locRecurso)
            (recursoEn ?rec ?locRecurso)
            
            ; NUEVAS
            ; Cuando el recurso sea de tipo Gas, tenemos que comprobar que existe un extractor ya situado en dicha localización. 
            ; En caso de que el recurso sea de tipo mineral se asigna directamente, llegados a este punto. 
            ; (imply (recursoEn GasVespeno ?locRecurso) 
            ;     (exists (?edif - edificio) 
            ;         (and 
            ;             (edifEs ?edif Extractor) 
            ;             (entidadEn ?edif ?locRecurso) 
            ;         )
            ;     )
            ; )
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

        ; EFECTOS NUEVOS: 
        ;   *.- Se dispone del recurso que extraemos
        :effect (and 
            (vceExtrae ?unidad ?rec)
            (not(unidadLibre ?unidad))

            ; NUEVO
            ; Extraemos minerales -> Minerales disponibles
            (when (recursoEn Mineral ?locRecurso) 
                (recursoDisponible Mineral)
            )
            ; Extraemos gas -> Gas Vespeno disponible. 
            (when (recursoEn GasVespeno ?locRecurso)
                (recursoDisponible GasVespeno)
            )
        )    
    )

    ; ESTA ACCION SE AÑADE NUEVA
    ;   3.- Construir: Ordena a un VCE libre que construya un edificio en una localización. En
    ;        este ejercicio, cada edificio sólo requerirá un único tipo de recurso para ser construido.
    ;        Adicionalmente y por simplicidad, en este ejercicio se permite que existan varios
    ;        edificios en la misma localización.
    ;        ▪ Parámetros: Unidad, Edificio, Localización, Recurso
    (:action construir
        :parameters (?unidad - unidad ?loc - localizacion ?rec - recurso ?edif - edificio)
        ; Las precondiciones que tendré en cuenta serán: 
        ;   1.- La unidad ha de estar libre
        ;   2.- La localización en la que se encuentra la unidad tiene que ser aquella en la que se quiere construir el edificio
        ;   3.- El edificio dado como parámetro no puede estar ya construido
        ;   4.- Tenemos que disponer de recursos disponibles, del tipo dado
        :precondition (and 
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?loc)
            (not(edificioConstruido ?edif))
            ; Con esto vemos que tipo de edificio es, para así saber que recurso necesita para su construcción
            ; Hace falta meter el exists porque sino, al no ser un parámetro no lo reconoce. 
            (exists (?tipo - tipoEdif)
                (and
                    (edifEs ?edif ?tipo)
                    (recursoConstruirEdificio ?tipo ?rec)
                    (recursoDisponible ?rec)
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