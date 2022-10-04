#
#
#Mod  practica
#
#

/*Set de los  datos parte 1*/
set DIR_ZONA ;
set ZONAS ;

/*Set de los Datos parte 2*/

set FREELANCERS;
set LOCALIZACIONES_SCOOTER;

/*Parametros parte 1*/
param Coste_camino {i in DIR_ZONA};
param Sale_de {i in DIR_ZONA, j in ZONAS};
param Va_a {i in DIR_ZONA, j in ZONAS};
param Necesita {i in ZONAS};
param Le_sobra{i in ZONAS};
param Scooter {i in ZONAS};

/*parámetros parte 2*/
param Coste_recarga{i in LOCALIZACIONES_SCOOTER , j in FREELANCERS};
param Puede_recargar{i in LOCALIZACIONES_SCOOTER, j in FREELANCERS};
param Max_recarga;



/*Variables de decisión parte 1*/
var Units {i in DIR_ZONA} >=0, integer;

/*Variable de decisión parte 2*/

var Recargas {i in LOCALIZACIONES_SCOOTER, j in FREELANCERS}, binary;

/*Función objetivo*/

/*minimize Coste : sum {i in DIR_ZONA, k in LOCALIZACIONES_SCOOTER, j in FREELANCERS} (Units[i]*Coste_camino[i] + Recargas[k,j] * Coste_recarga[k,j]);*/

minimize Coste : sum {i in DIR_ZONA} (Units[i]*Coste_camino[i]) +  sum {j in LOCALIZACIONES_SCOOTER, z in FREELANCERS} (Recargas[j,z] * Coste_recarga[j,z]);

/*Restricciones parte 1*/


/*Las zonas sin demanda deben dar al menos el 90% de sus scooters*/
s.t. Min_salida {j in ZONAS} :  sum {i in DIR_ZONA} (Units[i]*Sale_de[i,j]*Le_sobra[j]) >= 0.9*Scooter[j]*Le_sobra[j];

/*Las zonas sin demanda deben enviar al menos tantos scooters como demanda haya en total*/
s.t. Saca_demanda : sum {j in ZONAS} sum {i in DIR_ZONA} (Units[i]*Sale_de[i,j]*Le_sobra[j]) >= sum {k in ZONAS} Scooter[k]*Necesita[k];

/*Los scooters que llegan a una zona con demanda son como mínimo la demanda de esa zona y los que salen de ella juntos*/
s.t. Cumple_demanda {j in ZONAS} : sum {i in DIR_ZONA} ( Units[i]*Va_a[i,j]*Necesita[j] - Units[i]*Sale_de[i,j]*Necesita[j] ) >= Scooter[j]*Necesita[j];

/*los scooters que salen de una zona sin demanda no pueden ser más que los que entran en ella y los que puede compartir*/
s.t. No_salen_de_mas {j in ZONAS}: sum {i in DIR_ZONA}( Units[i]*Sale_de[i,j]*Le_sobra[j] -Units[i]*Va_a[i,j]*Le_sobra[j] ) <= Scooter[j]*Le_sobra[j];

/*restricciones parte 2*/

/*Comprueba que cada freelancer recargue tres scooters como máximo*/
s.t. Maximo_por_freelancer {j in FREELANCERS} : sum {i in LOCALIZACIONES_SCOOTER} Recargas[i,j] <= Max_recarga;

/*Comprueba que no recarguen en las zonas en las que no puede*/
s.t. Posibilidad_Recargar {i in LOCALIZACIONES_SCOOTER, j in FREELANCERS}: Recargas[i,j] <= Puede_recargar[i,j];

/*Ningún freelancer puede recargar demasiado*/
s.t. Mantener_equilibrio {j in FREELANCERS, k in FREELANCERS : j<>k}: sum {i in LOCALIZACIONES_SCOOTER} (Recargas[i,j]  - 0.5*Recargas[i ,k]) >=   0;

/*Comprobar que no se recarguen varios en un solo scooter*/

s.t. Recarga_unica {i in LOCALIZACIONES_SCOOTER}:sum {j in FREELANCERS} Recargas[i,j] == 1;
