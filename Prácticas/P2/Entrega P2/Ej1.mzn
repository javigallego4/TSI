% Alumno: Francisco Javier Gallego. Grupo: 3
% Ejercicio 1. Problema de las monedas
include "globals.mzn";
% ======================== DEFINICION DE VARIABLES ===============================================

int: IMPORTE = 235;    % Cantidad exacta que queremos obtener
set of int: idx = 1..8;    % Número de monedas distintas. En nuestro caso 8. 
array[idx] of int: centimos = [1,2,5,10,20,50,100,200];    % En el siguiente array incluiremos el valor en céntimos de cada una de las monedas. 
array[idx] of var int: monedas_usadas;    % Cantidad usada de cada tipo de moneda
var int: parte_entera; var int: monedas_totales_usadas; 

% ======================== DEFINICION DE RESTRICCIONES ===============================================

% La primera comprobación que haremos será ver que como MINIMO se usan 0 monedas. Es decir, dicha cantidad no puede ser negativa.
constraint forall(i in idx)(monedas_usadas[i] >= 0);

% A continuación, verificamos que la suma de los valores de todas las monedas coincide con el importe que queremos obtener
constraint IMPORTE == sum(i in idx)(monedas_usadas[i] * centimos[i]);

% Restricción para el apartado b)
% 1.- La cantidad restante al quitarle la parte entera, tiene que encontrarse entre 0 y 100. 
% 2.- El valor de los céntimos tiene que ser igual a la cantidad del importe al que ya le hemos quitado la parte entera. (De 4.99 pues serían los 99 céntimos).
% 3.- El número de monedas de 1 y 2 euros tiene que suponer una cantidad que coincida con la parte entera. (De los 4.99 pues los 4)
constraint (IMPORTE - parte_entera * 100 >= 0 /\ sum(i in 7..8)(monedas_usadas[i] * centimos[i]) == parte_entera * 100 /\ IMPORTE - parte_entera * 100 < 100 /\ sum(i in 1..6)(monedas_usadas[i] * centimos[i]) == IMPORTE - parte_entera * 100);

% Restricción mediante la cual obtenemos el valor para la variable que muestra en el output la cantidad de monedas usadas
constraint monedas_totales_usadas == sum(i in idx)(monedas_usadas[i]);
% Restricción para que el conjunto de monedas sea mínimo. 
solve minimize monedas_totales_usadas;

% ======================== SALIDA POR PANTALLA ===============================================

output ["Vector de monedas que se han usado: [" ] ++ ["\(monedas_usadas[i]), " | i in 1..7] ++ [show(monedas_usadas[8]), "]\n"] ++ ["cantidad total monedas: usadas: ", show(monedas_totales_usadas)];