; Gallego Menor, Francisco Javier
; Grupo: 3

(define (domain ej5)
    (:requirements :strips :adl :fluents)
    (:types 
        entidad localizacion recurso investigacion - object
        tipoRec - recurso
        unidad edificio - entidad
        tipoEdif - edificio
        tipoUnidad - unidad
        tipoInv - investigacion
    )
	(:constants
		CentroDeMando Barracones Extractor BahiaDeIngenieria - tipoEdif
		GasVespeno Mineral - tipoRec
		VCE Marine Soldado - tipoUnidad
        InvestigarSoldadoUniversal - tipoInv
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
        (recursoInvestigacion ?inv - investigacion ?rec - recurso)
        (investigacionRealizada ?inv - investigacion)
        (investigacionEs ?inv - investigacion ?tipoInv - tipoInv)
    )

    (:functions
        ; Nos vamos a crear una función que nos permite llevar el conteo de acciones que vamos a realizarlo, para realizar la comparación luego. 
        (costePlan)
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

            ; NUEVO: Siempre que se realice una acción debemos incrementar en 1 el coste del plan. 
            ; REMINDER: el coste es siempre 1. 
            (increase (costePlan) 1)
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
            ; NUEVO: Siempre que se realice una acción debemos incrementar en 1 el coste del plan. 
            ; REMINDER: el coste es siempre 1. 
            (increase (costePlan) 1)
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
            ; NUEVO: Siempre que se realice una acción debemos incrementar en 1 el coste del plan. 
            ; REMINDER: el coste es siempre 1. 
            (increase (costePlan) 1)
        )    
    )

    (:action reclutar
        :parameters (?edif - edificio ?unidad - unidad ?locUnidad - localizacion)
        :precondition (and
            (not(unidadConstruida ?unidad))
            (or
                (edifEs ?edif CentroDeMando)
                (edifEs ?edif Barracones)
            )                                      
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
            (imply (unidadEs ?unidad Soldado)
                (exists (?inv - investigacion) 
                    (and
                        (investigacionEs ?inv InvestigarSoldadoUniversal)
                        (investigacionRealizada ?inv)
                    )                    
                )   
            )
        )
        :effect (and
            (unidadConstruida ?unidad)
            (unidadLibre ?unidad)
            (entidadEn ?unidad ?locUnidad)
            ; NUEVO: Siempre que se realice una acción debemos incrementar en 1 el coste del plan. 
            ; REMINDER: el coste es siempre 1. 
            (increase (costePlan) 1)
        )
    )

    ; ESTA ACCION SE AÑADE NUEVA
    ; Investigar: permitirá realizar nuevas investigaciones para la base.
    ;   *.- Parámetros: Edificio, Investigación. 
    (:action investigar
        :parameters (?edif - edificio ?inv - investigacion)
        ; Las precondiciones de esta acción son las siguientes: 
        ;   1.- La investigación no puede estar ya realizada
        ;   2.- Las investigaciones se realizan en los edificios Bahía de Ingeniería. 
        ;   3.- "Investigar Soldado Unviersal" requiere tanto de minerales como de gas. 
        :precondition (and
            ; ===== PRECONDICION 1 ========
            (not(investigacionRealizada ?inv))
            ; ===== PRECONDICION 2 ========
            (edifEs ?edif BahiaDeIngenieria)
            ; El edificio tiene que estar construido
            (edificioConstruido ?edif)
            ; ===== PRECONDICION 3 ========
            (imply (investigacionEs ?inv InvestigarSoldadoUniversal)
                (and                
                    (recursoDisponible GasVespeno)
                    (recursoDisponible Mineral)
                )
            )
        )

        ; Los efectos serán los siguientes: 
        ;   1.- La investigación ?inv se pone como realizada. 
        :effect (and
           (investigacionRealizada ?inv) 
           ; NUEVO: Siempre que se realice una acción debemos incrementar en 1 el coste del plan. 
            ; REMINDER: el coste es siempre 1. 
            (increase (costePlan) 1)
        )
    )
)