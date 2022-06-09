% Alumno: Francisco Javier Gallego. Grupo: 3
% Ejercicio 2. Problema de los horarios
include "globals.mzn";
% ======================== DEFINICION DE VARIABLES ===============================================
int: lunes = 1;    % identificador del lunes
int: martes = 2;   % identificador del martes
int: miercoles = 3; % identificador del miercoles
int: jueves = 4;    % identificador del jueves
int: viernes = 5;    % identificador del viernes
int: p1 = 1; int :p2 = 2; int: p3 = 3; int: p4 = 4;   % identificadores de cada uno de los profesores

set of int: nasignaturas = 1..9;    % set para simplificar los forall
set of int: ndias = 1..5;    % set para simplificar los forall 
set of int: nfranjas = 1..6;    % set para simplificar los forall 

array[nasignaturas] of int: profesores_asignaturas = [p1, p4, p1, p2, p2, p3, p4, p4, p3];    % Array que indica qué profesor da la asignatura i-ésima

int: A1 = 1; int: A2 = 2; int: A3 = 3; int: A4 = 4; int: A5 = 5; int: A6 = 6; int: A7 = 7; int: A8 = 8; int: A9 = 9; int: Recreo = 10;    % Identificadores de las Asignaturas + Recreo

% Array que indica cuantas horas de clase se han de dar de cada asignatura
array[nasignaturas] of int: horas_por_asignatura = [4,2,4,4,4,2,2,2,1];

% Matriz que representa la asignación de cierta asignatura en una franja horaria de cierto dia
array[nfranjas,ndias] of var 1..10: horario;

array[nfranjas] of string: franjas_horarias = ["8-9", "9-10", "10-11", "11-12", "12-13", "13-14"];    % array con las franjas horarias que usaremos posteriormente para el output
 array[1..10] of string: asignaturas = ["A1","A2","A3","A4","A5","A6","A7","A8", "A9","Recreo"];  % array con las asignaturasA ver  que usaremos posteriormente para el output
 array[ndias] of string: dias_semana = ["Lunes", "Martes", "Miércoles","Jueves","Viernes"];    % array con los días de la semana que usaremos posteriormente para el output
  
% ======================== DEFINICION DE RESTRICCIONES ===============================================

%============= Restricción b) =============
% Número de horas semanales de cada una de las asignaturas. El nº de veces que aparece la asignatura en el horario tiene que ser igual al nº de horas que le corresponden, según el vector con las horas de cada asignatura.
constraint forall( i in nasignaturas )( count(horario,i) == horas_por_asignatura[i] );

%============= Restricción c, d) ============
% En cada día de la semana solo puede impartirse un solo bloque de cada asignatura. Empezamos por aquellas asignaturas con bloques de 2h consecutivas
constraint forall(i in ndias)(
  % En cada día solo puede impartirse un bloque -> Solo puede aparecer un total de 2 veces una asignatura de las siguientes en el horario del día i-esimo.
  forall(a in {A1,A3,A4,A5,A8})(
    sum(j in nfranjas)
    (if horario[j,i] == a then 
      1 
    else 
      0 
    endif) <= 2    
    /\
    % Mediante la siguiente restricción nos aseguramos de que las asignaturas con bloques de 2h consecutivas se asignen al horario de tal forma. Es decir, si la A1 se da de 9-10 entonces tiene que darse si o si en la hora de antes o en la de después. 
    forall(j in nfranjas)(
      if horario[j,i] == a then
        % En caso de ser la última -> La anterior franja horaria ha de ser de la misma asignatura
        if j == 6 then
          horario[j-1,i] == a
        % Primera franja horaria -> La segunda franja horaria tambien tiene que ser para dicha asignatura          
        else if j == 1 then
          horario[j+1,i] == a
        % En otro caso, se tiene que verificar que dicha asignatura se de o bien en la hora de antes, o bien en la de después
        else
          horario[j-1,i] == a \/ horario[j+1,i] == a
        endif endif
      else true endif
    )
  ) 
); 

% En cada día de la semana solo puede impartirse un solo bloque de cada asignatura. Restricción para asignaturas con bloques de 1h
constraint forall(i in ndias)(
  % En cada día solo puede impartirse un bloque -> Solo puede aparecer un total de 1 vez una asignatura de las siguientes en el horario del día i-esimo.
  forall(a in {A2,A6,A7,A9})(
    sum(j in nfranjas)
    (if horario[j,i] == a then 
      1 
    else 
      0 
    endif) <= 1
  )
);

% ======== Restriccion f) ============ 
% Restricción sobre las clases que da cada profesor en un día. Todos, excepto el profesor nº 4, imparten una única clase por día
constraint forall(j in ndias)(
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
constraint  forall(i in ndias)(
  forall(j in nfranjas)(
    if j != 4 then
      horario[j,i] != Recreo
    else
      horario[j,i] == Recreo
    endif
  )
);

% ======= Restriccion h ) =============    
% Varios profesores tienen ciertas restricciones horarias
constraint forall(i in ndias)(
  % El profesor 1 solo puede dar clase en las dos últimas horas de la mañana. Por eso verificamos que no de en ninguna de las tres primeras. 
  forall(j in {1,2,3})(
    profesores_asignaturas[horario[j,i]] != p1
  )
  
  /\
  
  % El profesor 2 solo puede dar clase en las dos primeras horas. Por eso verificamos que no de ninguna en las franjas horarias: {3,5,6}
  forall(j in {3,5,6})(
    profesores_asignaturas[horario[j,i]] != p2
  )
  
  /\
  
  % El profesor 3 solo puede dar clase en la tercera franja horaria. Verificamos que no de en ninguna otra. 
  forall(j in {1,2,5,6})(
    profesores_asignaturas[horario[j,i]] != p3
  )
);
  
% ======= Restriccion i ) =============    
% Restricciones en cuanto a los dias en los que se puede impartir cada asignatura
constraint forall(i in nfranjas)(
  % Asignatura 1 y 4: lunes o martes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {3,4,5})(
    horario[i,j] != A1
    /\
    horario[i,j] != A4
  )
  
  /\
  
  % Asignatura 3: miércoles o jueves. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {1,2,5})(
    horario[i,j] != A3
  )
  
  /\
  
  % Asignatura 5: jueves o viernes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {1,2,3})(
    horario[i,j] != A5
  )
  
  /\ 
  
  % Asignatura 6: miércoles o viernes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {1,2,4})(
    horario[i,j] != A6
  )
  
  /\
  
  % Asignatura 7: martes o viernes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {1,3,4})(
    horario[i,j] != A7
  )
  
  /\
  
  % Asignatura 8: miércoles. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {1,2,4,5})(
    horario[i,j] != A8
  )
  
  /\
  
  % Asignatura 9: lunes. Entonces verificamos que no se imparta en ninguna franja horaria del resto de dias
  forall(j in {2,3,4,5})(
    horario[i,j] != A9
  )
);  
          
solve satisfy;
output
["El lunes hay: "] ++ [ "de " ++ show(franjas_horarias[i]) ++ ": " ++ show(asignaturas[fix(horario[i,1])]) ++", " | i in nfranjas ] ++ ["\n"]++
["El martes hay: "] ++ [ "de " ++ show(franjas_horarias[i]) ++ ": " ++ show(asignaturas[fix(horario[i,2])]) ++", " | i in nfranjas] ++ ["\n"]++
["El miercoles hay: "] ++ [ "de " ++ show(franjas_horarias[i]) ++ ": " ++ show(asignaturas[fix(horario[i,3])]) ++", " | i in nfranjas] ++ ["\n"]++
["El jueves hay: "] ++ [ "de " ++ show(franjas_horarias[i]) ++ ": " ++ show(asignaturas[fix(horario[i,4])]) ++", " | i in nfranjas]++ ["\n"]++
["El viernes] hay: "] ++ [ "de " ++ show(franjas_horarias[i]) ++ ": " ++ show(asignaturas[fix(horario[i,5])]) ++", " | i in nfranjas ];

