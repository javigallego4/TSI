% Alumno: Francisco Javier Gallego. Grupo: 3
% Ejercicio 2. Problema de los horarios
include "globals.mzn";
% ======================== DEFINICION DE VARIABLES ===============================================

int: lunes = 1;    % identificador del lunes
int: martes = 2;   % identificador del martes
int: miercoles = 3; % identificador del miercoles
int: jueves = 4;    % identificador del jueves
int: viernes = 5;    % identificador del viernes

array[1..numero_dias] of string: dias_semana = ["Lunes", "Martes", "Miércoles","Jueves","Viernes"];

int: p1 = 1;    % profesor 1
int: p2 = 2;    % profesor 2
int: p3 = 3;    % profesor 3
int: p4 = 4;    % profesor 4

% Array que indica qué profesor da la asignatura i-ésima
array[1..numero_asignaturas] of int: profesores_asignaturas = [p1, p4, p1, p2, p2, p3, p4, p4, p3];

% Identificadores de las Asignaturas + Recreo
int: A1 = 1;
int: A2 = 2;
int: A3 = 3;
int: A4 = 4;
int: A5 = 5;
int: A6 = 6;
int: A7 = 7;
int: A8 = 8;
int: A9 = 9;
int: Recreo = 0;

int: numero_asignaturas = 9;    % número de asignaturas
int: numero_dias = 5;    % número de días
int: numero_franjas = 6;    % númeor de franjas_horarias horarios

% Array que indica cuantas horas de clase se han de dar de cada asignatura
array[1..numero_asignaturas] of int: horas_por_asignatura = [4,2,4,4,4,2,2,2,1];

% Matriz que representa la asignación de cierta asignatura en una franja horaria de cierto dia
array[1..numero_franjas,1..numero_dias] of var 0..numero_asignaturas: horario;

% Matriz que representa la asignación de un bloque de alguna asignatura a una franja horaria en un cierto día
% Un bloque se codifica como la codificación de la asignatura por 10 más el número del bloque al que pertenece. Ej: A1-BLOQ2 = 1*10+2
% Para obtener la asignatura se divide por 10 y para obtener el grupo se hace modulo de 10
array[1..numero_franjas,1..numero_dias] of var {0, 11, 12, 21, 22, 31, 32, 41, 42, 51, 52, 61, 62, 71, 72, 81, 91}: horarioBloques;

% Variables que vamos a usar para el output final del ejercicio
array[1..numero_franjas] of string: franjas_horarias = ["08:00-09:00", "09:00-10:00", "10:00-11:00", "11:00-12:00", "12:00-13:00", "13:00-14:00"];
 array[1..numero_asignaturas,1..2] of string: asignaturas = [|"A1", "A1", |"A2", "A2", |"A3", "A3", |"A4", "A4", |"A5", "A5", |"A6", "A6",| "A7", "A7 ", |"A8", "",| "A9", ""|];
  
% ======================== DEFINICION DE RESTRICCIONES ===============================================

%============= Restricción b) ============
% Número de horas semanales de cada asignatura
constraint
forall(i in 1..numero_asignaturas)(
  count(horario,i) == horas_por_asignatura[i]
);

%============= Restricción c, d) ============
% En cada día de la semana solo puede impartirse un solo bloque de cada asignatura. Empezamos por aquellas asignaturas con bloques de 2h consecutivas
constraint
forall(j in 1..numero_dias)(
  % Bloques de 2h consecutivas
  forall(a in {A1,A3,A4,A5,A8})(
    sum(i in 1..numero_franjas)
    (if horario[i,j] == a then 
      1 
    else 
      0 
    endif) <= 2
  ) 
); 

% Mediante la siguiente restricción nos aseguramos de que las asignaturas con bloques de 2h consecutivas se asignen al horario de tal forma. Es decir, si la A1 se da de 9-10 entonces tiene que darse si o si en la hora de antes o en la de después. 
constraint
forall(j in 1..numero_dias)(
  forall(i in 1..numero_franjas)(
    % Restricciones para las asignaturas cuyos bloques son de 2h
    forall(a in {A1,A3,A4,A5,A8})(
      if horario[i,j] == a then
        % En caso de ser la última -> La anterior franja horaria ha de ser de la misma asignatura
        if i == 6 then
          horario[i-1,j] == a
        % Primera franja horaria -> La segunda franja horaria tambien tiene que ser para dicha asignatura          
        else if i == 1 then
          horario[i+1,j] == a
        % En otro caso, se tiene que verificar que dicha asignatura se de o bien en la hora de antes, o bien en la de después
        else
          horario[i-1,j] == a \/ horario[i+1,j] == a
        endif endif
      else true endif
    )
  )
);

% Restricción para asignaturas con bloques de 1h
constraint
forall(j in 1..numero_dias)(
  % Bloques de 1h
  forall(a in {A2,A6,A7,A9})(
    sum(i in 1..numero_franjas)
    (if horario[i,j] == a then 
      1 
    else 
      0 
    endif) <= 1
  )
);

% ======== Restriccion f) ============ 
% Restricción sobre las clases que da cada profesor en un día. Todos, excepto el profesor nº 4, imparten una única clase por día
constraint
forall(j in 1..numero_dias)(
  % La suma de horas que el profesor 1 da en un dia tiene que ser <= 2. Sus asignaturas son de bloques de 2h consecutivas
  % REMINDER1: horario[i,j] nos devuelve el indice de la asignatura de esa hora.
  % REMINDER2: no tenemos en cuenta la cuarta franja horaria pues corresponde al recreo
  sum(i in {1,2,3,5,6})
  (if profesores_asignaturas[horario[i,j]] == p1 then 
    1 
  else 
    0 
  endif) <= 2
  
  /\

  % La suma de horas que el profesor 2 da en un dia tiene que ser <= 2. Sus asignaturas son de bloques de 2h consecutivas
  sum(i in {1,2,3,5,6})
  (if profesores_asignaturas[horario[i,j]] == p2 then 
    1 
  else 
    0 
  endif) <= 2
  
  /\
  
  % La suma de horas que el profesor 3 da en un dia tiene que ser <= 1. Sus asignaturas son de bloques de 1h
  sum(i in {1,2,3,5,6})
  (if profesores_asignaturas[horario[i,j]] == p3 then 
    1 
  else 
    0 
  endif) <= 1
);

%============ Restricción apartado g) ==============
% Restricción del apartado g: La cuarta franja horaria debe reservarse para el recreo. 
constraint 
forall(j in 1..numero_dias)(
  forall(i in 1..numero_franjas)(
    if i == 4 then
      horario[i,j] == Recreo
    else
      horario[i,j] != Recreo
    endif
  )
);

% ======= Restriccion h ) =============    
% Varios profesores tienen ciertas restricciones horarias
constraint
forall(j in 1..numero_dias)(
  % El profesor 1 solo puede dar clase en las dos últimas horas de la mañana. Por eso verificamos que no de en ninguna de las tres primeras. 
  forall(i in {1,2,3})(
    profesores_asignaturas[horario[i,j]] != p1
  )
  
  /\
  
  % El profesor 2 solo puede dar clase en las dos primeras horas. Por eso verificamos que no de ninguna en las franjas horarias: {3,5,6}
  forall(i in {3,5,6})(
    profesores_asignaturas[horario[i,j]] != p2
  )
  
  /\
  
  % El profesor 3 solo puede dar clase en la tercera franja horaria. Verificamos que no de en ninguna otra. 
  forall(i in {1,2,5,6})(
    profesores_asignaturas[horario[i,j]] != p3
  )
);
  
% ======= Restriccion i ) =============    
% Restricciones en cuanto a los dias en los que se puede impartir cada asignatura
constraint
forall(j in {3,4,5})(
  % Asignatura 1 y 4: lunes o martes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A1
    /\
    horario[i,j] != A4
  )
);
    
constraint
forall(j in {1,2,5})(
% Asignatura 3: miércoles o jueves. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A3
  )
);   
    
constraint
forall(j in {1,2,3})(
% Asignatura 5: jueves o viernes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A5
  )
);

constraint
forall(j in {1,2,4})(
% Asignatura 6: miércoles o viernes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A6
  )
);
    
constraint forall(j in {1,3,4})(
% Asignatura 7: martes o viernes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A7
  )
);

constraint forall(j in {1,2,4,5})(
% Asignatura 8: miércoles. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A8
  )
);
    
constraint forall(j in {2,3,4,5})(
% Asignatura 9: lunes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(i in 1..numero_franjas)(
    horario[i,j] != A9
  )
);
    
  
% Con esta nueva restricción pretendemos asignar los bloques de las asignaturas.
constraint forall(j in 1..numero_dias)(
  % Restricción que asigna el bloque del recreo a la 4ª franja horaria de todos los dias
  horarioBloques[4,j] = horario[4,j]
  /\
  % Las asignaturas 1 .. 7 son las que tienen 2 bloques, cada una. 
  forall(asig in 1..7)(
    if sum(i in {1,2,3,5,6})(if horario[i,j] == asig then 1 else 0 endif) > 0 then
      % En el caso de que en uno de los siguientes dias haya una franja horaria para esta asignatura, la que estamos examinado corresponderá con el 
      % primero de los dos bloques de dicha asignatura.
      if sum(i in {1,2,3,5,6}, z in (j+1)..numero_dias)(if horario[i,z] == asig then 1 else 0 endif) > 0 then
        forall(i in {1,2,3,5,6})(
          if horario[i,j] == asig then
            horarioBloques[i,j] = (horario[i,j]*10 + 1)
          else true endif
        )
      % En el caso contrario, dicho franja horaria corresponderá con el segundo bloque de la asignatura en cuestión
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
  /\
  % Asignar los bloques de las asignaturas que están compruestas por un sólo bloque
  forall(i in 1..numero_franjas)(
    if horario[i,j] == 8 then
      horarioBloques[i,j] = 81
    else true endif
    /\
    if horario[i,j] == 9 then
      horarioBloques[i,j] = 91
    else true endif
  )
);
          
solve satisfy;

% Output
output ["                     L   M    X    J    V \n"]++
       [show(franjas_horarias[1])++" -> "]++
       [show(asignaturas[fix((horarioBloques[1,i] div 10)),fix((horarioBloques[1,i] mod 10))])++" " | i in 1..numero_dias]++
       ["\n"]++
       [show(franjas_horarias[2])++" -> "]++
       [show(asignaturas[fix((horarioBloques[2,i] div 10)),fix((horarioBloques[2,i] mod 10))])++" " | i in 1..numero_dias]++
       ["\n"]++
       [show(franjas_horarias[3])++" -> "]++
       [show(asignaturas[fix((horarioBloques[3,i] div 10)),fix((horarioBloques[3,i] mod 10))])++" " | i in 1..numero_dias]++
       ["\n"]++
       [show(franjas_horarias[4])++" -> "]++
       [" NA "++"  NA "++" NA "++" NA "++" NA "]++
       ["\n"]++
       [show(franjas_horarias[5])++" -> "]++
       [show(asignaturas[fix((horarioBloques[5,i] div 10)),fix((horarioBloques[5,i] mod 10))])++" " | i in 1..numero_dias]++
       ["\n"]++
       [show(franjas_horarias[6])++" -> "]++
       [show(asignaturas[fix((horarioBloques[6,i] div 10)),fix((horarioBloques[6,i] mod 10))])++" " | i in 1..numero_dias];     
