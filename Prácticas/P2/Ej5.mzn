% Alumno: Francisco Javier Gallego. Grupo: 3
% Ejercicio 2. Problema de los horarios
include "globals.mzn";
% ======================== DEFINICION DE VARIABLES ===============================================

int: numero_nodos = 14;    % número de nodos del grafo generado
int: numero_aristas = 91;    % número de aristas del grafo generado
array[1..numero_aristas] of var int: colores_aristas;    % array para representar el color que va a tener cada una de las aristas. Cada color estará asociado a un nº 
set of int: set_numero_aristas = 1..numero_aristas;

% matriz para representar las aristas. La 1º columna representa el nodo inicio de la arista, y la segunda el nodo destino.
array [1..numero_aristas, 1..2] of 1..numero_nodos: aristas = [|9 , 14 |9 , 7 |12 , 3 |12 , 9 |8 , 3 |2 , 12 |6 , 11 |5 , 13 |5 , 6 |8 , 4 |7 , 5 |11 , 12 |4 , 8 |7 , 11 |2 , 11 |13 , 4 |6 , 9 |5 , 7 |4 , 10 |3 , 1 |5 , 13 |3 , 5 |11 , 2 |8 , 9 |3 , 14 |11 , 10 |14 , 9 |8 , 2 |7 , 9 |11 , 6 |10 , 13 |11 , 4 |1 , 12 |1 , 11 |3 , 9 |13 , 11 |9 , 3 |13 , 10 |7 , 6 |7 , 4 |9 , 3 |2 , 5 |9 , 2 |14 , 7 |10 , 14 |6 , 2 |3 , 5 |11 , 8 |7 , 12 |5 , 6 |11 , 9 |11 , 4 |12 , 1 |1 , 6 |8 , 12 |6 , 12 |14 , 1 |9 , 7 |11 , 6 |12 , 2 |14 , 11 |8 , 12 |5 , 4 |7 , 12 |2 , 5 |11 , 12 |1 , 9 |11 , 6 |13 , 5 |12 , 3 |10 , 8 |2 , 10 |3 , 2 |12 , 1 |8 , 2 |9 , 13 |12 , 10 |12 , 1 |8 , 1 |6 , 12 |11 , 3 |6 , 11 |2 , 4 |14 , 13 |4 , 2 |9 , 12 |7 , 9 |12 , 2 |12 , 6 |12 , 8 |1 , 10 |];

% ======================== DEFINICION DE RESTRICCIONES ===============================================

constraint forall(i in 1..numero_aristas)(colores_aristas[i] > 0);

% 1ª Restricción: un par de aristas contiguas no pueden tener el mismo color. Posibles casos para que dos aristas sean contiguas, PERO NO IGUALES: 
%     1.- Si coincide el primer nodo de ambas aristas y no el segundo
%     2.- Si coincide el primer nodo de la 1ª arista con el segundo nodo de la 2ª arista, pero no al contrario
%     3.- Si coincide el segundo nodo de ambas aristas, pero no el primero. 
%     4.- Si coincide el segundo nodo de la 1ª arista con el primero de la 2ª arista, pero no al contrario
constraint 
forall(i,j in set_numero_aristas)(
  if ( ( aristas[i,1] == aristas[j,1] /\ aristas[i,2] != aristas[j,2] ) \/ ( aristas[i,2] == aristas[j,1] /\ aristas[i,1] != aristas[j,2])  \/ ( aristas[i,1] != aristas[j,1] /\ aristas[i,2] == aristas[j,2] ) \/ (  aristas[i,2] != aristas[j,1] /\ aristas[i,1] == aristas[j,2] ) ) then
    colores_aristas[i] != colores_aristas[j]
  endif
); 

% 2ª Restricción: cuando dos aristas sean iguales, su color ha de ser el mismo. Casos:
%    1.- Si coinciden los primeros nodos de ambas, y también los segundos.
%    2.- Si coinciden el primero de la 1ª arista con el segundo de la 2ª arista, y viceversa. 

constraint 
forall(i,j in set_numero_aristas)(
  if ( ( aristas[i,1] == aristas[j,1] /\ aristas[i,2] == aristas[j,2] ) \/ ( aristas[i,2] == aristas[j,1] /\ aristas[i,1] == aristas[j,2]) ) then
    colores_aristas[i] == colores_aristas[j]
  endif
) ;

solve minimize max(colores_aristas);