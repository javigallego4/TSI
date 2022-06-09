% Alumno: Francisco Javier Gallego. Grupo: 3
% Ejercicio 1. Problema de las monedas
include "globals.mzn";
% ======================== DEFINICION DE VARIABLES ===============================================

set of int: numero_casas = 1..5; 
set of int: numero_caracteristicas = 1..6; 
array[numero_caracteristicas, numero_casas] of var numero_casas: matriz_valores;    % matriz que usaremos para el problema

% Emplearemos una matriz en donde cada fila se corresponderá con una de las características. Cada columna uno de los posibles valores. 
% Cada posible valor de una característica dentro de una fila, lo identificaremos por algún nº del 1 al 5. 
% Región:                        1 - Andaluz, 2 - Catalán, 3 - Gallego, 4 - Navarro, 5 - Vasco
% Casas:                          1 - 1ª izqda ... 5 - 1ª drcha
% Mascota:                        1 - Perro, 2 - Caracoles, 3 - Zorro, 4 - Caballo, 5 - Cebra
% Profesión:                       1 - Pintor, 2 - Escultor, 3 - Diplomático, 4 - Violinista, 5 - Médico
% Color casa:                      1 - Roja, 2 - Azul, 3 - Verde, 4 - Amarilla, 5 - blanca
% Bebida:                          1 - Té, 2 - Café, 3 - Leche, 4 - Zumo, 5 - Agua

array[numero_casas] of string : region = ["Andaluz", "Catalan","Gallego", "Navarro", "Vasco"];
array[numero_casas] of string : casas = ["1º Izqda", "2º Izqda","Centro", "2º Drcha", "1º Drcha"];
array[numero_casas] of string : mascota = ["Perro", "Caracoles","Zorro", "Caballo", "Cebra"];
array[numero_casas] of string : profesion = ["Pintor", "Escultor","Diplomático", "Violinista", "Médico"];
array[numero_casas] of string : color_casa = ["Rojo", "Azul","Verde", "Amarillo", "Blanco"];
array[numero_casas] of string : bebida = ["Te", "Cafe","Leche", "Zumo", "Agua"];


% ======================== DEFINICION DE RESTRICCIONES ===============================================

% Restricción: los valores de una fila han de ser todos únicos (entre el 1 y 5)
constraint 
forall(i in numero_caracteristicas)(
  alldifferent([matriz_valores[i, j] | j in numero_casas])
);

% Restricción APARTADO a): el vasco vive en la casa roja. 
constraint
forall(i in numero_casas)(
  if ( matriz_valores[1,i] == 5 ) then
    matriz_valores[5, i] == 1
  endif
);

% Restricción APARTADO b): el catalán tiene un perro
constraint
forall(i in numero_casas)(
  if ( matriz_valores[1,i] == 2 ) then
    matriz_valores[3, i] == 1
  endif
);

% Restricción APARTADO c): el gallego es un pintor
constraint
forall(i in numero_casas)(
  if ( matriz_valores[1,i] == 3 ) then
    matriz_valores[4, i] == 1
  endif
);

% Restricción APARTADO d): el navarro bebe te
constraint
forall(i in numero_casas)(
  if ( matriz_valores[1,i] == 4 ) then
    matriz_valores[6, i] == 1
  endif
);

% Restricción APARTADO e): el andaluz vive en la primera casa de la izquierda
constraint
forall(i in numero_casas)(
  if ( matriz_valores[1,i] == 1 ) then
    matriz_valores[2, i] == 1
  endif
);

% Restricción APARTADO f): el de la casa verde bebe café
constraint
forall(i in numero_casas)(
  if ( matriz_valores[5,i] == 3 ) then
    matriz_valores[6, i] == 2
  endif
);

% Restricción APARTADO g): la casa verde está al lado de la casa blanca y a su derecha 
constraint
forall(i,j in numero_casas)(
  % Casa verde - Casa blanca
  if ( matriz_valores[5,i] == 3 /\ matriz_valores[5,j] ==  5) then    
    matriz_valores[2, i] == matriz_valores[2,j] + 1
  endif
);

% Restricción APARTADO h): el escultor cría caracoles
constraint
forall(i in numero_casas)(
  if ( matriz_valores[4,i] == 2 ) then
    matriz_valores[3, i] == 2
  endif
);

% Restricción APARTADO i): el diplomático vive en la casa amarilla
constraint
forall(i in numero_casas)(
  if ( matriz_valores[4,i] == 3 ) then
    matriz_valores[5, i] == 4
  endif
);

% Restricción APARTADO j): en la casa central se bebe leche
constraint
forall(i in numero_casas)(
  if ( matriz_valores[2,i] == 3 ) then
    matriz_valores[6, i] == 3
  endif
);

% Restricción APARTADO k): la casa del andaluz esta al lado de la azul. Como la casa del andaluz es la 1ª a la izquierda -> la azul es la 2ª a la izquierda
constraint
forall(i in numero_casas)(
  if ( matriz_valores[5,i] == 2 ) then
    matriz_valores[2, i] == 2
  endif
);

% Restricción APARTADO l): el violinista bebe zumo
constraint
forall(i in numero_casas)(
  if ( matriz_valores[4,i] == 4 ) then
    matriz_valores[6, i] == 4
  endif
);

% Restricción APARTADO m): el zorro está en una casa al lado de la del médico
constraint
forall(i in numero_casas)(
  % Columna del médico
  if ( matriz_valores[4,i] == 5 ) then
    forall(j in numero_casas)(
        % Casa del zorro
        if ( matriz_valores[3,j] == 3 ) then
          % Su casa tiene que ser una de las contiguas con el medico
          matriz_valores[2,j] == matriz_valores[2,i] + 1 \/ matriz_valores[2,j] == matriz_valores[2,i] - 1
        endif
    ) 
  endif
);

% Restricción APARTADO n): el caballo está en una casa al lado del diplomatico
constraint
forall(i in numero_casas)(
  % Columna del diplomático
  if ( matriz_valores[4,i] == 3 ) then
    forall(j in numero_casas)(
        % Casa del caballo
        if ( matriz_valores[3,j] == 4 ) then
          % Su casa tiene que ser una de las contiguas con el medico
          matriz_valores[2,j] == matriz_valores[2,i] + 1 \/ matriz_valores[2,j] == matriz_valores[2,i] - 1
        endif
    ) 
  endif
);

% Restricción para solo mostrar una solución. De no incluirla, saldrían 5! = 120 soluciones posibles, pues se permutarían las filas. 
constraint matriz_valores[1,1] == 1 /\ matriz_valores[1,2] == 2 /\ matriz_valores[1,3] == 3 /\ matriz_valores[1,4] == 4 /\ matriz_valores[1,5] == 5; 

solve satisfy;
% Output
output[
"El " ++ show( region[ fix( matriz_valores[1,i] )] ) ++ "  es " ++ show( profesion[ fix( matriz_valores[4,i] )] ) ++ ", vive en la casa nº " ++  show( casas[ fix( matriz_valores[2,i] )] ) ++", su mascota es/son el/la " ++ show( mascota[ fix( matriz_valores[3,i] )] ) ++", su casa es de color " ++ show( color_casa[ fix( matriz_valores[5,i] )] ) ++
"y por último, bebe " ++ show( bebida[ fix( matriz_valores[6,i] )] ) ++ "\n" | i in numero_casas
];



