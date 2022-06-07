; Gallego Menor, Francisco Javier
; Grupo: 3

; Ejemplo Dominio PDDL -> diapo 32 Problema del Mono
(define (domain ej1)
    (:requirements :strips :typing :adl)
    (:types 
        ; Definimos los tipos de los objetos del dominio. Los tipos pueden dependeer de un supertipo. 
        ; Diapo 25 -> Ejemplo

        ; Nos vamos a crear tres tipos generales que van a representar: 
        ;       1.- Entidad: representa a las unidades y a los edificios.
        ;       2.- Localización: para representar las localizaciones.
        ;       3.- Recurso: para los recursos, tanto minerales como el gas
        entidad localizacion recurso - object

        ; Definimos la subclase para los tipos de recursos
        tipoRec - recurso

        ; Las unidades y edificios son de tipo entidad. Así mismo, definimos las subclases para los tipos, derivadas de las anteriores
        unidad edificio - entidad
        tipoEdif - edificio
        tipoUnidad - unidad
    )

    ; Ahora, vamos a declarar una serie de constantes. Estas serán las de los tipos de edificios, minerales y el tipo de unidad (VCE). 
	(:constants
		CentroDeMando Barracones - tipoEdif
		GasVespeno Mineral - tipoRec
		VCE - tipoUnidad
	)

    ; Definir los predicados necesarios para:
    ;   1.- Determinar si un edificio o unidad está en una localización concreta.
    ;   2.- Representar que existe un camino entre dos localizaciones.
    ;   3.- Determinar si un edificio está construido.
    ;   4.- Asignar un nodo de un recurso concreto a una localización concreta.
    ;   5.- Indicar si un VCE está extrayendo un recurso.
    (:predicates 
        ; La entidad x, se encuentra en la localización y. Seguimos la nomenclatura de la diapo 32. 
        (entidadEn ?x - entidad ?y - localizacion)

        ; Existe un camino entre la localización ?x e ?y. 
        (caminoEntre ?x - localizacion ?y - localizacion)

        ; Edificio ?x construido
        (edificioConstruido ?x - edificio)

        ; Asignar el el nodo de recurso ?x a la localización ?y
        (recursoEn ?x - recurso ?y - localizacion)

        ; Indicamos si el VCE ?x está extrayendo el recurso ?y
        (vceExtrae ?x - unidad ?y - recurso)        

        ; ========== Predicados Personales ==========
        ; La unidad ?x está libre
        (unidadLibre ?x - unidad)
    )
    
    ; El dominio debe contener únicamente las siguientes dos acciones definidas:
    ;   1.- Navegar: Mueve una unidad entre dos localizaciones.
    ;       1.1.- Parámetros: Unidad, Localización origen, Localización destino
    ;
    ; Ejemplos sobre como implementar las acciones -> Diapo 27 - 32
    (:action navegar
        :parameters (?unidad - unidad ?locOrigen ?locDestino - localizacion)
        ; Las precondiciones que tendré en cuenta serán: 
        ;   1.- La unidad tiene que encontrarse en la localización origen.
        ;   2.- Debe existir una conexióne entre la localización origen y destino. 
        ;   3.- La unidad ha de estar libre (llegado a este punto decido añadir un predicado extra para ver si una unidad está libre o no)
        :precondition (and 
            (unidadLibre ?unidad)
            (caminoEntre ?locOrigen ?locDestino)
            (entidadEn ?unidad ?locOrigen)
        )

        ; Los efectos de esta acción son los siguientes: 
        ;   1.- La unidad ahora ya NO está en la localización origen.
        ;   2.- La unidad se encuentra en la localización destino.
        :effect (and 
            (entidadEn ?unidad ?locDestino)
            (not(entidadEn ?unidad ?locOrigen))
        )    
    )

    ;   2.- Asignar: Asigna un VCE a un nodo de recurso. Además, en este ejercicio será
    ; suficiente asignar un único VCE a un nodo de recursos de un tipo (minerales o gas
    ; vespeno) para tener ilimitados recursos de ese tipo.
    ;       2.1.- Parámetros: Unidad, Localización del recurso, Tipo de recurso
    (:action asignar
        :parameters (?unidad - unidad ?locRecurso - localizacion ?rec - recurso)
        ; Las precondiciones que tendré en cuenta serán: 
        ;   1.- La unidad y el recurso se encuentren en la localización dada como parámetro.
        ;   2.- La unidad ha de estar libre
        :precondition (and 
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?locRecurso)
            (recursoEn ?rec ?locRecurso)
        )

        ; Los efectos de esta acción son los siguientes: 
        ;   1.- La unidad ahora ya NO está libre
        ;   2.- La unidad está extrayendo el recurso ?rec
        :effect (and 
            (vceExtrae ?unidad ?rec)
            (not(unidadLibre ?unidad))
        )    
    )
)