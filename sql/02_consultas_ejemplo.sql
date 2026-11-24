SELECT * FROM vuelo ;
SELECT * FROM vuelo WHERE hora_salida = '12:00:00';
SELECT * FROM boleto;
SELECT * FROM boleto WHERE NOT boleto_clase = "Economy";
SELECT * FROM boleto WHERE boleto_estado = "Cancelado";
SELECT * FROM vuelo;
SELECT * FROM vuelo WHERE NOT duracion = 150 AND codigo_vuelo = "VL0001";
SELECT AVG(duracion) FROM vuelo;
SELECT * FROM avion;
SELECT * FROM avion WHERE avion_modelo LIKE 'Boeing%';
SELECT * FROM avion WHERE avion_capacidad LIKE '1%';
SELECT avion_modelo, avion_capacidad AS "capacidad" FROM avion WHERE avion_capacidad BETWEEN 150 AND 200;
SELECT * FROM avion;
SELECT CONCAT(avion_modelo,' CAPACIDAD:', avion_capacidad) AS 'Modelo y Capacidad' FROM avion;

