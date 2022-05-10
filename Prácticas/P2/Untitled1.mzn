% Ejercicio 6

include "globals.mzn";

% Definición de variables:

  % Número de asignaturas
int: numAsignaturas = 9;

  % Número de días
int: numDias = 5;
    
  % Número de tramos
int: numTramos = 6;

  % Variables que indican que número identifica a cada profesor
int: profesor1 = 1;
int: profesor2 = 2;
int: profesor3 = 3;
int: profesor4 = 4;

  % Variables que indican que número identifica a cada día
int: Lunes = 1;
int: Martes = 2;
int: Miercoles = 3;
int: Jueves = 4;
int: Viernes = 5;

  % Variables que indican que número identifica a cada asignatura
int: Recreo = 0;
int: A1 = 1;
int: A2 = 2;
int: A3 = 3;
int: A4 = 4;
int: A5 = 5;
int: A6 = 6;
int: A7 = 7;
int: A8 = 8;
int: A9 = 9;

  % Nombre de los distintos tramos
array[1..numTramos] of string: tramos = ["08:00-09:00", 
                                         "09:00-10:00",
                                         "10:00-11:00",
                                         "11:00-12:00",
                                         "12:00-13:00",
                                         "13:00-14:00"];

  % Nombre de los distintos bloques de cada asignatura
array[1..numAsignaturas,1..2] of string: bloques = [|"A1-BLOQ1-PROF1", "A1-BLOQ2-PROF1",
                                                    |"A2-BLOQ1-PROF4", "A2-BLOQ2-PROF4",
                                                    |"A3-BLOQ1-PROF1", "A3-BLOQ2-PROF1",
                                                    |"A4-BLOQ1-PROF2", "A4-BLOQ2-PROF2",
                                                    |"A5-BLOQ1-PROF2", "A5-BLOQ2-PROF2",
                                                    |"A6-BLOQ1-PROF3", "A6-BLOQ2-PROF3",
                                                    |"A7-BLOQ1-PROF4", "A7-BLOQ2-PROF4",
                                                    |"A8-BLOQ1-PROF4", "",| "A9-BLOQ1-PROF3", ""|];

  % Vector que indica que profesor imparte cada una de las asignaturas
array[1..numAsignaturas] of int: profAsig = [profesor1, profesor4, profesor1, profesor2, profesor2, profesor3, profesor4, profesor4, profesor3];

  % Vector que indica el número de horas que se deben impartir de cada asignatura
array[1..numAsignaturas] of int: horasAsig = [4,2,4,4,4,2,2,2,1];

  % Matriz que representa la asignación de alguna asignatura a un tramo horario en un cierto día
array[1..numTramos,1..numDias] of var 0..numAsignaturas: horario;

  % Matriz que representa la asignación de un bloque de alguna asignatura a un trmao horario en un cierto día
  % Un bloque se codifica como la codificación de la asignatura por 10 más el número del bloque al que pertenece. Ej: A1-BLOQ2 = 1*10+2
  % Para obtener la asignatura se divide por 10 y para obtener el grupo se hace modulo de 10
array[1..numTramos,1..numDias] of var {0, 11, 12, 21, 22, 31, 32, 41, 42, 51, 52, 61, 62, 71, 72, 81, 91}: horarioBloques;


% Definición de restricciones:

  % Marcar el recreo en el horario
constraint 
forall(j in 1..numDias)(
  forall(i in 1..numTramos)(
    if i == 4 then
      horario[i,j] == Recreo
    else
      horario[i,j] != Recreo
    endif
  )
);

  % Fijar el máximo de horas de cada asignatura por día
constraint
forall(j in 1..numDias)(
  forall(asig in {A1,A3,A4,A5,A8})(
    sum(i in 1..numTramos)(if horario[i,j] == asig then 1 else 0 endif) <= 2
  ) 
  /\
  forall(asig in {A2,A6,A7,A9})(
    sum(i in 1..numTramos)(if horario[i,j] == asig then 1 else 0 endif) <= 1
  )
);

  % Fijar el máximo de horas de cada asignatura por semana
constraint
forall(asig in 1..numAsignaturas)(
  count(horario,asig) == horasAsig[asig]
);

  % Comprobar que las asignaturas se han asignado al horario en bloques
constraint
forall(j in 1..numDias)(
  forall(i in 1..numTramos)(
    forall(asig in {A1,A3,A4,A5,A8})(
      if horario[i,j] == asig then
        if i == 1 then
          horario[i+1,j] == asig
        else if i == 6 then
          horario[i-1,j] == asig
        else
          horario[i-1,j] == asig \/ horario[i+1,j] == asig
        endif endif
      else true endif
    )
  )
);

  % Comprobar que todos los profesores excepto profesor4, sólo imparten una asignatura por día
constraint
forall(j in 1..numDias)(
  sum(i in {1,2,3,5,6})(if profAsig[horario[i,j]] == profesor1 then 1 else 0 endif) <= 2
);
  
constraint
forall(j in 1..numDias)(
  sum(i in {1,2,3,5,6})(if profAsig[horario[i,j]] == profesor2 then 1 else 0 endif) <= 2
);
  
constraint
forall(j in 1..numDias)(
  sum(i in {1,2,3,5,6})(if profAsig[horario[i,j]] == profesor3 then 1 else 0 endif) <= 1
);
    
  % Restricciones de los profesores
constraint
forall(j in 1..numDias)(
  forall(i in {1,2,3})(
    profAsig[horario[i,j]] != profesor1
  )
);
    
constraint
forall(j in 1..numDias)(
  forall(i in {3,5,6})(
    profAsig[horario[i,j]] != profesor2
  )
);
    
constraint
forall(j in 1..numDias)(
  forall(i in {1,2,5,6})(
    profAsig[horario[i,j]] != profesor3
  )
);
  
  % Restricciones de las asignaturas
constraint
forall(j in {3,4,5})(
  forall(i in 1..numTramos)(
    horario[i,j] != A1
  )
);
    
constraint
forall(j in {1,2,5})(
  forall(i in 1..numTramos)(
    horario[i,j] != A3
  )
);
    
constraint
forall(j in {3,4,5})(
  forall(i in 1..numTramos)(
    horario[i,j] != A4
  )
);
    
constraint
forall(j in {1,2,3})(
  forall(i in 1..numTramos)(
    horario[i,j] != A5
  )
);

constraint
forall(j in {1,2,4})(
  forall(i in 1..numTramos)(
    horario[i,j] != A6
  )
);
    
constraint
forall(j in {1,3,4})(
  forall(i in 1..numTramos)(
    horario[i,j] != A7
  )
);

constraint
forall(j in {1,2,4,5})(
  forall(i in 1..numTramos)(
    horario[i,j] != A8
  )
);
    
constraint
forall(j in {2,3,4,5})(
  forall(i in 1..numTramos)(
    horario[i,j] != A9
  )
);
    
  % Asignar los bloques respecto de la asignación de las asignaturas en el horario
  
    % Asignar los bloques del recreo
constraint
forall(j in 1..numDias)(
  horarioBloques[4,j] = horario[4,j]
);

    % Asignar los bloques de las asignaturas que están compruestas por dos bloques, en esta asignación se comprueba que los bloque de una misma asignaturas se coloquen en el orden correcto
constraint
forall(j in 1..numDias)(
  forall(asig in 1..7)(
    if sum(i in {1,2,3,5,6})(if horario[i,j] == asig then 1 else 0 endif) > 0 then
      if sum(i in {1,2,3,5,6}, z in (j+1)..numDias)(if horario[i,z] == asig then 1 else 0 endif) > 0 then
        forall(i in {1,2,3,5,6})(
          if horario[i,j] == asig then
            horarioBloques[i,j] = (horario[i,j]*10 + 1)
          else true endif
        )
      else
        forall(i in {1,2,3,5,6})(
          if horario[i,j] == asig then
            horarioBloques[i,j] = (horario[i,j]*10 + 2)
          else true endif
        )
      endif
    else
      true
    endif
  )
);
  
    % Asignar los bloques de las asignaturas que están compruestas por un sólo bloque
constraint
forall(j in 1..numDias)(
  forall(i in 1..numTramos)(
    if horario[i,j] == 8 then
      horarioBloques[i,j] = 81
    else true endif
    /\
    if horario[i,j] == 9 then
      horarioBloques[i,j] = 91
    else true endif
  )
);
    
    
% Indica que es un CSP
solve satisfy;


% Salida por pantalla

output ["                      Lunes            Martes         Miercoles          Jueves          Viernes\n"]++
       [show(tramos[1])++" -> "]++
       [show(bloques[fix((horarioBloques[1,i] div 10)),fix((horarioBloques[1,i] mod 10))])++" " | i in 1..numDias]++
       ["\n"]++
       [show(tramos[2])++" -> "]++
       [show(bloques[fix((horarioBloques[2,i] div 10)),fix((horarioBloques[2,i] mod 10))])++" " | i in 1..numDias]++
       ["\n"]++
       [show(tramos[3])++" -> "]++
       [show(bloques[fix((horarioBloques[3,i] div 10)),fix((horarioBloques[3,i] mod 10))])++" " | i in 1..numDias]++
       ["\n"]++
       [show(tramos[4])++" -> "]++
       ["       NA       "++" " | i in 1..numDias]++
       ["\n"]++
       [show(tramos[5])++" -> "]++
       [show(bloques[fix((horarioBloques[5,i] div 10)),fix((horarioBloques[5,i] mod 10))])++" " | i in 1..numDias]++
       ["\n"]++
       [show(tramos[6])++" -> "]++
       [show(bloques[fix((horarioBloques[6,i] div 10)),fix((horarioBloques[6,i] mod 10))])++" " | i in 1..numDias];