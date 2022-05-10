% Alumno: Francisco Javier Gallego. Grupo: 3
% Problema 4. Asignación de Tareas
include "globals.mzn";
% ======================== DEFINICION DE VARIABLES ===============================================
set of int: ntareas = 1..9;    % número de tareas del ejercicio
set of int: ntrabajadores = 1..3;    % número de trabajadores disponible
set of int: ntrabajadores_v4 = 1..4;    % número de trabajadores disponibles, contando con la modificación del segundo apartado (4º trabajador)
array[ntareas, ntrabajadores] of int: tiempos = [|4,7,10 |3,5,7 |3,1,4 |2,5,8 | 4,2,6 |3,2,1 | 1,2,3 |1,3,5 |2,3,4|];    % matriz con los tiempos de cada trabajador por tarea
array[ntareas] of var int: tiempo_inicio;    % vector para los días en que se inicia cada tarea
array[ntareas] of var int: tiempo_fin;    % vector para los días en que se termina cada tarea
array[ntrabajadores_v4, ntareas] of var 0..1: asignacion_tareas;    % matriz para la asignación de una tarea a un trabajador
var int: duracion_total;  

% ======================== DEFINICION DE RESTRICCIONES ===============================================
% 1ª Restricción: En la matriz de asignación_tareas, la suma de unos en una columna (SOLO TENIENDO EN CUENTA A LOS 3 PRIMEROS TRABAJADORES) tiene que ser exactamente 1 . Con esto controlamos que SOLO uno de esos trabajadores puede realizar la tarea i-ésima. 
constraint forall(j in ntareas)(
  sum(i in ntrabajadores)(if asignacion_tareas[i,j] == 1 then 1 else 0 endif) == 1                                     
);

% 2ª Restricción: Un trabajador solo puede desempeñar una tarea al mismo tiempo
constraint forall(i in ntrabajadores_v4, j,k in ntareas)(
  % Si el mismo trabajador realiza dos tareas distintas, entonces sus tiempos no pueden solaparse. En otras palabras, el tiempo de inicio de una tiene que ser mayor que el tiempo fin de la otra.
  if ( j != k /\ asignacion_tareas[i,j] == 1 /\ asignacion_tareas[i,k] == 1) then
    tiempo_fin[j] < tiempo_inicio[k] \/ tiempo_fin[k] < tiempo_inicio[j]    
  endif
);

% 3ª Restricción: El tiempo de fin debe ser el tiempo de inicio de la tarea, más lo que tarde el trabajador j-ésimo en realizarla. Dividimos por casos, según la participación o no del 4º trabajador. 
constraint forall(i in ntareas)(
  forall(j in ntrabajadores)(
  % Si se le ha asignado la tarea i-ésima al trabajador j-ésimo, entonces cogemos el tiempo que tarda este para la tarea en cuestión. En este caso, no tenemos en cuenta la aportación del trabajador 4. 
  if ( asignacion_tareas[j,i] == 1 /\ ( ( asignacion_tareas[4,i] == 1 /\ tiempos[i,j] < 3 ) \/ asignacion_tareas[4,i] == 0) ) then
      tiempo_fin[i] == tiempo_inicio[i] + tiempos[i,j] - 1

  % En caso de que la duración sea mayor o igual que 3, y el 4ª trabajador pueda entrar en escena, se reduce la duración en 2 días.     
  else if ( asignacion_tareas[j,i] == 1 /\ asignacion_tareas[4,i] == 1 /\ tiempos[i,j] >= 3 ) then
      tiempo_fin[i] == tiempo_inicio[i] + tiempos[i,j] - 3
  else true endif  endif
  )  
);

% 4ª Restricción: Los tiempos deben ser mayores a 0
constraint forall(i in ntareas)(tiempo_inicio[i] > 0 /\ tiempo_fin[i] > 0);

% 5ª Restricción: Establecemos las distintas restricciones de precedencia
constraint tiempo_inicio[2] > tiempo_fin[1];    % predecesoras de B: A
constraint tiempo_inicio[3] > tiempo_fin[2];    % predecesoras de C: B
constraint tiempo_inicio[4] > tiempo_fin[1];    % predecesoras de D: A
constraint tiempo_inicio[5] > tiempo_fin[3] /\ tiempo_inicio[5] > tiempo_fin[4];    % predecesoras de E: C,D
constraint tiempo_inicio[6] > tiempo_fin[3] /\ tiempo_inicio[6] > tiempo_fin[4];    % predecesoras de F: C,D
constraint tiempo_inicio[7] > tiempo_fin[3] /\ tiempo_inicio[7] > tiempo_fin[4];    % predecesoras de G: C,D
constraint tiempo_inicio[8] > tiempo_fin[1];    % predecesoras de H: A
constraint tiempo_inicio[9] > tiempo_fin[6] /\ tiempo_inicio[9] > tiempo_fin[8];    % predecesoras de I: F, H

% Minimizamos la duración total 
constraint duracion_total == max(tiempo_fin);
solve minimize duracion_total;