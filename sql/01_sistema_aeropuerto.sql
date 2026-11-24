-- =====================================================================
-- AeroManage: sistema de gestión aeroportuaria (MySQL 8.0)
-- Las contraseñas de los usuarios se reemplazaron por 'CAMBIAR_PASSWORD'.
-- Antes de ejecutar este script, define tus propias contraseñas.
-- =====================================================================

-- a) Creacion de base de datos:
DROP DATABASE IF EXISTS sistema_aeropuertos;
CREATE DATABASE sistema_aeropuertos;
USE sistema_aeropuertos;

-- CREACION DE TABLESPACES:
CREATE TABLESPACE datos_tb01 ADD DATAFILE 'datos_tb01.ibd' ENGINE = InnoDB;
CREATE TABLESPACE datos_tb02 ADD DATAFILE 'datos_tb02.ibd' ENGINE = InnoDB;
CREATE TABLESPACE datos_tb03 ADD DATAFILE 'datos_tb03.ibd' ENGINE = InnoDB;
CREATE TABLESPACE datos_tb04 ADD DATAFILE 'datos_tb04.ibd' ENGINE = InnoDB;
CREATE TABLESPACE datos_tb05 ADD DATAFILE 'datos_tb05.ibd' ENGINE = InnoDB;
CREATE TABLESPACE datos_tb06 ADD DATAFILE 'datos_tb06.ibd' ENGINE = InnoDB;

-- b) Creacion de las tablas sin PK, ni FK:
-- Tabla aeropuerto:
CREATE TABLE aeropuerto (
    aeropuerto_id INT NOT NULL,
    aeropuerto_nombre VARCHAR(100) NOT NULL,
    aeropuerto_ciudad VARCHAR(100) NOT NULL,
    aeropuerto_estado VARCHAR(100) NOT NULL,
    aeropuerto_pais VARCHAR(100) NOT NULL
) TABLESPACE datos_tb01;

-- Tabla aerolinea:
CREATE TABLE aerolinea (
    aerolinea_id INT NOT NULL,
    aerolinea_nombre VARCHAR(100) NOT NULL,
    aerolinea_codigo VARCHAR(30) NOT NULL,
    aerolinea_pais_origen VARCHAR(100) NOT NULL
) TABLESPACE datos_tb02;

-- Tabla avion:
CREATE TABLE avion (
    avion_id INT NOT NULL,
    aerolinea_id INT NOT NULL, 
    avion_modelo VARCHAR(100) NOT NULL,
    avion_capacidad INT NOT NULL
) TABLESPACE datos_tb03;

-- Tabla pasajero
CREATE TABLE pasajero (
    pasajero_id INT NOT NULL,
    pasajero_nombre VARCHAR(60) NOT NULL,
    pasajero_apellido_paterno VARCHAR(60) NOT NULL,
    pasajero_apellido_materno VARCHAR(60) NOT NULL,
    pasajero_pasaporte VARCHAR(40) NOT NULL,
    pasajero_nacionalidad VARCHAR(60) NOT NULL,
    pasajero_email VARCHAR(100) NOT NULL,
    pasajero_telefono VARCHAR(30)
) TABLESPACE datos_tb04;

-- Tabla boleto:
CREATE TABLE boleto (
    boleto_id INT  NOT NULL,
    vuelo_id INT NOT NULL,
    pasajero_id INT NOT NULL,
    boleto_clase VARCHAR(30) NOT NULL,
    boleto_asiento VARCHAR(10) NOT NULL,
    boleto_precio DECIMAL(10,2) NOT NULL,
    boleto_fecha_emision DATE NOT NULL,
    boleto_estado VARCHAR(30) NOT NULL
) TABLESPACE datos_tb05;

-- Tabla horario:
CREATE TABLE horario (
    horario_id INT NOT NULL,
    vuelo_id INT NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    hora_programada TIME NOT NULL,
    hora_real TIME NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(30) NOT NULL
) TABLESPACE datos_tb06;

-- Tabla vuelo (con particion por año de fecha_salida):
CREATE TABLE vuelo (
    vuelo_id INT NOT NULL,
    avion_id INT NOT NULL,
    origen_id INT NOT NULL,
    destino_id INT NOT NULL,
    codigo_vuelo VARCHAR(30) NOT NULL,
    hora_salida TIME NOT NULL,
    hora_llegada TIME NOT NULL,
    fecha_salida DATE NOT NULL,
    duracion INT NOT NULL
)
PARTITION BY RANGE (YEAR(fecha_salida)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- c) Sentencias para agregar la informacion:

DELIMITER $$

-- 1. SP para AEROPUERTO (Tabla Maestra)
CREATE PROCEDURE sp_insertar_aeropuertos(IN total_inserts INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE contador_base INT;
    SELECT COALESCE(MAX(aeropuerto_id), 0) INTO contador_base FROM aeropuerto;

    WHILE i <= total_inserts DO
        INSERT INTO aeropuerto (aeropuerto_id, aeropuerto_nombre, aeropuerto_ciudad, aeropuerto_estado, aeropuerto_pais)
        VALUES (contador_base + i, CONCAT('Aeropuerto ', contador_base + i), CONCAT('Ciudad ', contador_base + i), CONCAT('Estado ', contador_base + i), CONCAT('País ', (i % 190) + 1));
        SET i = i + 1;
    END WHILE;
    SELECT CONCAT(total_inserts, ' aeropuertos insertados.') AS Resultado;
END$$

-- 2. SP para AEROLINEA (Tabla Maestra)
CREATE PROCEDURE sp_insertar_aerolineas(IN total_inserts INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE contador_base INT;
    SELECT COALESCE(MAX(aerolinea_id), 0) INTO contador_base FROM aerolinea;

    WHILE i <= total_inserts DO
        INSERT INTO aerolinea (aerolinea_id, aerolinea_nombre, aerolinea_codigo, aerolinea_pais_origen)
        VALUES (contador_base + i, CONCAT('Aerolinea ', contador_base + i), CONCAT(CHAR(FLOOR(RAND() * 26) + 65), CHAR(FLOOR(RAND() * 26) + 65), LPAD(contador_base + i, 3, '0')), CONCAT('País ', (i % 190) + 1));
        SET i = i + 1;
    END WHILE;
    SELECT CONCAT(total_inserts, ' aerolineas insertadas.') AS Resultado;
END$$

-- 3. SP para PASAJERO (Tabla Maestra)
CREATE PROCEDURE sp_insertar_pasajeros(IN total_inserts INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE contador_base INT;
    SELECT COALESCE(MAX(pasajero_id), 0) INTO contador_base FROM pasajero;

    WHILE i <= total_inserts DO
        INSERT INTO pasajero (pasajero_id, pasajero_nombre, pasajero_apellido_paterno, pasajero_apellido_materno, pasajero_pasaporte, pasajero_nacionalidad, pasajero_email, pasajero_telefono)
        VALUES (contador_base + i, CONCAT('Nombre_', contador_base + i), CONCAT('Paterno_', contador_base + i), CONCAT('Materno_', contador_base + i), CONCAT('P', LPAD(contador_base + i, 8, '0')), CONCAT('Nacionalidad ', (i % 190) + 1), CONCAT('user', contador_base + i, '@dominio.com'), CONCAT('55', LPAD(FLOOR(RAND() * 90000000) + 10000000, 8, '0')));
        SET i = i + 1;
    END WHILE;
    SELECT CONCAT(total_inserts, ' pasajeros insertados.') AS Resultado;
END$$

-- 4. SP para AVION (Depende de AEROLINEA)
CREATE PROCEDURE sp_insertar_aviones(IN total_inserts INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE contador_base INT;
    DECLARE max_aerolinea_id INT;
    DECLARE v_aerolinea_id INT;
    DECLARE v_capacidad INT;
    
    SELECT COALESCE(MAX(avion_id), 0) INTO contador_base FROM avion;
    SELECT MAX(aerolinea_id) INTO max_aerolinea_id FROM aerolinea;
    
    IF max_aerolinea_id IS NULL THEN
        SELECT 'Error: No hay aerolineas en la base de datos.' AS Resultado;
    ELSE
        WHILE i <= total_inserts DO
            SET v_aerolinea_id = (SELECT FLOOR(RAND() * max_aerolinea_id) + 1);
            SET v_capacidad = (SELECT FLOOR(RAND() * 300) + 100);
            INSERT INTO avion (avion_id, aerolinea_id, avion_modelo, avion_capacidad)
            VALUES (contador_base + i, v_aerolinea_id, CONCAT(IF(RAND() > 0.5, 'Boeing ', 'Airbus '), 'Modelo ', LPAD(i, 3, '0')), v_capacidad);
            SET i = i + 1;
        END WHILE;
        SELECT CONCAT(total_inserts, ' aviones insertados.') AS Resultado;
    END IF;
END$$

-- 5. SP para VUELO y HORARIO (Depende de AVION y AEROPUERTO)
CREATE PROCEDURE sp_insertar_vuelos_y_horarios(IN total_inserts INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE contador_base_vuelo INT;
    DECLARE contador_base_horario INT;
    DECLARE max_avion_id INT;
    DECLARE max_aeropuerto_id INT;
    DECLARE v_avion_id INT;
    DECLARE v_origen_id INT;
    DECLARE v_destino_id INT;
    DECLARE v_fecha_salida DATE;
    DECLARE v_hora_salida TIME;
    DECLARE v_hora_llegada TIME;
    DECLARE v_duracion INT;
    DECLARE v_nuevo_vuelo_id INT;
    
    SELECT COALESCE(MAX(vuelo_id), 0) INTO contador_base_vuelo FROM vuelo;
    SELECT COALESCE(MAX(horario_id), 0) INTO contador_base_horario FROM horario;
    SELECT MAX(avion_id) INTO max_avion_id FROM avion;
    SELECT MAX(aeropuerto_id) INTO max_aeropuerto_id FROM aeropuerto;
    
    IF max_avion_id IS NULL OR max_aeropuerto_id IS NULL THEN
        SELECT 'Error: Faltan datos en tablas avion o aeropuerto.' AS Resultado;
    ELSE
        WHILE i <= total_inserts DO
            SET v_avion_id = (SELECT FLOOR(RAND() * max_avion_id) + 1);
            SET v_origen_id = (SELECT FLOOR(RAND() * max_aeropuerto_id) + 1);
            SET v_destino_id = (SELECT FLOOR(RAND() * max_aeropuerto_id) + 1);
            WHILE v_destino_id = v_origen_id DO
                SET v_destino_id = (SELECT FLOOR(RAND() * max_aeropuerto_id) + 1);
            END WHILE;
            SET v_fecha_salida = DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 1095) DAY);
            SET v_duracion = (SELECT FLOOR(RAND() * 240) + 60);
            SET v_hora_salida = MAKETIME(FLOOR(RAND() * 24), FLOOR(RAND() * 60), 0);
            SET v_hora_llegada = ADDTIME(v_hora_salida, SEC_TO_TIME(v_duracion * 60));
            SET v_nuevo_vuelo_id = contador_base_vuelo + i;

            INSERT INTO vuelo (vuelo_id, avion_id, origen_id, destino_id, codigo_vuelo, hora_salida, hora_llegada, fecha_salida, duracion)
            VALUES (v_nuevo_vuelo_id, v_avion_id, v_origen_id, v_destino_id, CONCAT('VL', LPAD(v_nuevo_vuelo_id, 5, '0')), v_hora_salida, v_hora_llegada, v_fecha_salida, v_duracion);
            
            INSERT INTO horario (horario_id, vuelo_id, tipo, hora_programada, hora_real, fecha, estado)
            VALUES (contador_base_horario + i, v_nuevo_vuelo_id, 'Salida', v_hora_salida, IF(RAND() > 0.3, v_hora_salida, ADDTIME(v_hora_salida, MAKETIME(0, FLOOR(RAND() * 15), 0))), v_fecha_salida, IF(RAND() > 0.1, 'Programado', 'Retrasado'));
            
            SET i = i + 1;
        END WHILE;
        SELECT CONCAT(total_inserts, ' vuelos y horarios insertados.') AS Resultado;
    END IF;
END$$

-- 6. SP para BOLETO (Depende de VUELO y PASAJERO)
CREATE PROCEDURE sp_insertar_boletos(IN total_inserts INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE contador_base INT;
    DECLARE max_vuelo_id INT;
    DECLARE max_pasajero_id INT;
    DECLARE v_vuelo_id INT;
    DECLARE v_pasajero_id INT;
    DECLARE v_precio DECIMAL(10,2);
    
    SELECT COALESCE(MAX(boleto_id), 0) INTO contador_base FROM boleto;
    SELECT MAX(vuelo_id) INTO max_vuelo_id FROM vuelo;
    SELECT MAX(pasajero_id) INTO max_pasajero_id FROM pasajero;

    IF max_vuelo_id IS NULL OR max_pasajero_id IS NULL THEN
        SELECT 'Error: Faltan datos en tablas vuelo o pasajero.' AS Resultado;
    ELSE
        WHILE i <= total_inserts DO
            SET v_vuelo_id = (SELECT FLOOR(RAND() * max_vuelo_id) + 1);
            SET v_pasajero_id = (SELECT FLOOR(RAND() * max_pasajero_id) + 1);
            SET v_precio = (SELECT FLOOR(RAND() * 4500) + 500);
            
            INSERT INTO boleto (boleto_id, vuelo_id, pasajero_id, boleto_clase, boleto_asiento, boleto_precio, boleto_fecha_emision, boleto_estado)
            VALUES (contador_base + i, v_vuelo_id, v_pasajero_id, IF(RAND() > 0.8, 'Business', 'Economy'), CONCAT(CHAR(FLOOR(RAND() * 6) + 65), (FLOOR(RAND() * 30) + 1)), v_precio, DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 1095) DAY), 'Emitido');
            
            SET i = i + 1;
        END WHILE;
        SELECT CONCAT(total_inserts, ' boletos insertados.') AS Resultado;
    END IF;
END$$
DELIMITER ;


-- -----------------------------------------------------------------
-- INICIO LLAMADA A PROCEDIMIENTOS PARA POBLAR TABLAS --
-- -----------------------------------------------------------------

-- 1. Insertar tablas maestras
CALL sp_insertar_aeropuertos(5000);
CALL sp_insertar_aerolineas(5000);
CALL sp_insertar_pasajeros(5000);

-- 2. Insertar aviones (depende de aerolineas)
CALL sp_insertar_aviones(5000);

-- 3. Insertar vuelos y horarios (depende de avion y aeropuerto)
CALL sp_insertar_vuelos_y_horarios(5000);

-- 4. Insertar boletos (depende de vuelo y pasajero)
CALL sp_insertar_boletos(5000);
-- -----------------------------------------------------------------
-- FIN LLAMADA A PROCEDIMIENTOS --
-- -----------------------------------------------------------------

SELECT 'aeropuerto' AS tabla, COUNT(*) AS total_registros FROM aeropuerto
UNION ALL
SELECT 'aerolinea' AS tabla, COUNT(*) AS total_registros FROM aerolinea
UNION ALL
SELECT 'avion' AS tabla, COUNT(*) AS total_registros FROM avion
UNION ALL
SELECT 'pasajero' AS tabla, COUNT(*) AS total_registros FROM pasajero
UNION ALL
SELECT 'vuelo' AS tabla, COUNT(*) AS total_registros FROM vuelo
UNION ALL
SELECT 'horario' AS tabla, COUNT(*) AS total_registros FROM horario
UNION ALL
SELECT 'boleto' AS tabla, COUNT(*) AS total_registros FROM boleto;

-- d) Agregar PKs a cada tabla mediante ALTER:

ALTER TABLE aeropuerto
  MODIFY aeropuerto_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (aeropuerto_id);

ALTER TABLE aerolinea
  MODIFY aerolinea_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (aerolinea_id);

ALTER TABLE avion
  MODIFY avion_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (avion_id);

ALTER TABLE pasajero
  MODIFY pasajero_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (pasajero_id);

ALTER TABLE vuelo REMOVE PARTITIONING;
ALTER TABLE vuelo
MODIFY vuelo_id INT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (vuelo_id);

ALTER TABLE horario
  MODIFY horario_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (horario_id);

ALTER TABLE boleto
  MODIFY boleto_id INT NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (boleto_id);

-- AGREGAR FKs mediante ALTER TABLE:

-- avion.aerolinea_id -> aerolinea(aerolinea_id)
ALTER TABLE avion
  ADD CONSTRAINT fk_avion_aerolinea FOREIGN KEY (aerolinea_id)
    REFERENCES aerolinea(aerolinea_id);

-- vuelo.avion_id -> avion(avion_id)
ALTER TABLE vuelo
  ADD CONSTRAINT fk_vuelo_avion FOREIGN KEY (avion_id)
    REFERENCES avion(avion_id);

-- vuelo.origen_id -> aeropuerto(aeropuerto_id)
ALTER TABLE vuelo
  ADD CONSTRAINT fk_vuelo_origen FOREIGN KEY (origen_id)
    REFERENCES aeropuerto(aeropuerto_id);

-- vuelo.destino_id -> aeropuerto(aeropuerto_id)
ALTER TABLE vuelo
  ADD CONSTRAINT fk_vuelo_destino FOREIGN KEY (destino_id)
    REFERENCES aeropuerto(aeropuerto_id);

-- horario.vuelo_id -> vuelo(vuelo_id)
ALTER TABLE horario
  ADD CONSTRAINT fk_horario_vuelo FOREIGN KEY (vuelo_id)
    REFERENCES vuelo(vuelo_id);

-- boleto.vuelo_id -> vuelo(vuelo_id)
ALTER TABLE boleto
  ADD CONSTRAINT fk_boleto_vuelo FOREIGN KEY (vuelo_id)
    REFERENCES vuelo(vuelo_id);

-- boleto.pasajero_id -> pasajero(pasajero_id)
ALTER TABLE boleto
  ADD CONSTRAINT fk_boleto_pasajero FOREIGN KEY (pasajero_id)
    REFERENCES pasajero(pasajero_id);

SELECT 
    TABLE_NAME, 
    CONSTRAINT_TYPE 
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE 
    TABLE_SCHEMA = 'sistema_aeropuertos'
ORDER BY 
    TABLE_NAME, CONSTRAINT_TYPE;

##### ROLES Y PERMISOS: #####

CREATE ROLE IF NOT EXISTS 'rol_administrador';
GRANT ALL PRIVILEGES ON sistema_aeropuertos.* TO 'rol_administrador' WITH GRANT OPTION;

CREATE ROLE IF NOT EXISTS 'rol_analista';
GRANT SELECT ON sistema_aeropuertos.* TO 'rol_analista';

CREATE ROLE IF NOT EXISTS 'rol_agente_reservas';

-- Permisos de LECTURA sobre vuelos
GRANT SELECT ON sistema_aeropuertos.vuelo TO 'rol_agente_reservas';
GRANT SELECT ON sistema_aeropuertos.horario TO 'rol_agente_reservas';
GRANT SELECT ON sistema_aeropuertos.aeropuerto TO 'rol_agente_reservas';
GRANT SELECT ON sistema_aeropuertos.aerolinea TO 'rol_agente_reservas';
GRANT SELECT ON sistema_aeropuertos.avion TO 'rol_agente_reservas';

-- Permisos de LECTURA/ESCRITURA sobre pasajeros y boletos
GRANT SELECT, INSERT, UPDATE ON sistema_aeropuertos.pasajero TO 'rol_agente_reservas';
GRANT SELECT, INSERT, UPDATE ON sistema_aeropuertos.boleto TO 'rol_agente_reservas';

CREATE ROLE IF NOT EXISTS 'rol_operaciones_vuelo';

-- Permisos de LECTURA
GRANT SELECT ON sistema_aeropuertos.vuelo TO 'rol_operaciones_vuelo';
GRANT SELECT ON sistema_aeropuertos.horario TO 'rol_operaciones_vuelo';
GRANT SELECT ON sistema_aeropuertos.avion TO 'rol_operaciones_vuelo';

-- Permiso de ESCRITURA (muy específico)
GRANT UPDATE ON sistema_aeropuertos.horario TO 'rol_operaciones_vuelo';

## CREACION DE USUARIOS ##

-- Usuario 1: El Administrador/DBA de esta base de datos
CREATE USER 'db_admin1'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 2: El Administrador/DBA de esta base de datos
CREATE USER 'db_admin2'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 3: El Administrador/DBA de esta base de datos
CREATE USER 'db_admin3'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 4: La analista de datos que solo puede leer
CREATE USER 'ana_garcia'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 5: El usuario para la aplicación de ventas (Agente de Reservas)
CREATE USER 'app_ventas_boletos1'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 6: El usuario para la aplicación de ventas (Agente de Reservas)
CREATE USER 'app_ventas_boletos2'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 7: El usuario para el personal de operaciones en tierra
CREATE USER 'torre_control1'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Usuario 8: El usuario para el personal de operaciones en tierra
CREATE USER 'torre_control22'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
    
-- 1. ASIGNACION DE ROLES 
GRANT 'rol_administrador' TO 'db_admin1'@'localhost', 'db_admin2'@'localhost', 'db_admin3'@'localhost';
GRANT 'rol_analista' TO 'ana_garcia'@'localhost';
GRANT 'rol_agente_reservas' TO 'app_ventas_boletos1'@'localhost', 'app_ventas_boletos2'@'localhost';

-- LA LÍNEA QUE HA ESTADO FALTANDO/FALLANDO:
GRANT 'rol_operaciones_vuelo' TO 'torre_control1'@'localhost', 'torre_control22'@'localhost';

-- 2. ACTIVACION DE ROLES (Ejecuta esto como ROOT)
SET DEFAULT ROLE ALL TO 
    'db_admin1'@'localhost',
    'db_admin2'@'localhost',
    'db_admin3'@'localhost',
    'ana_garcia'@'localhost',
    'app_ventas_boletos1'@'localhost',
    'app_ventas_boletos2'@'localhost',
    'torre_control1'@'localhost',
    'torre_control22'@'localhost'; 
######################################
-- 1. Crea el usuario que faltaba (si ya existe, no importa)
CREATE USER IF NOT EXISTS 'torre_control2'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- 2. Asigna el rol (¡Ahora SÍ funcionará para ambos!)
GRANT 'rol_operaciones_vuelo' TO 'torre_control1'@'localhost', 'torre_control2'@'localhost';
-- 3. Activa los roles por defecto para futuros inicios de sesión
SET DEFAULT ROLE ALL TO 'torre_control1'@'localhost', 'torre_control2'@'localhost';
CREATE ROLE IF NOT EXISTS 'rol_gestor_vuelos';
-- 1. Permisos que ya tenía 'rol_operaciones_vuelo'
GRANT SELECT, UPDATE ON sistema_aeropuertos.horario TO 'rol_gestor_vuelos';
GRANT SELECT ON sistema_aeropuertos.avion TO 'rol_gestor_vuelos';
-- 2. Permisos de "Manager" (Control Total sobre Vuelo)
-- ESTA ES LA LÍNEA CLAVE PARA TU DRP:
GRANT SELECT, INSERT, UPDATE, DELETE, DROP ON sistema_aeropuertos.vuelo TO 'rol_gestor_vuelos';
-- 3. Permisos extra para ver aeropuertos
GRANT SELECT ON sistema_aeropuertos.aeropuerto TO 'rol_gestor_vuelos';

#### USUARIO JEFE DE OPERACIONES ###
CREATE USER 'jefe_operaciones'@'localhost' IDENTIFIED BY 'CAMBIAR_PASSWORD';
-- Le "damos" el rol al usuario
GRANT 'rol_gestor_vuelos' TO 'jefe_operaciones'@'localhost';
-- Activamos el rol por defecto para ese usuario
SET DEFAULT ROLE ALL TO 'jefe_operaciones'@'localhost';

## BITACORA (TABLA AUDITORIA): ###

DROP TABLE IF EXISTS log_auditoria;
CREATE TABLE log_auditoria (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(100) NOT NULL,
    id_afectado INT,
    accion VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    usuario_db VARCHAR(255) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos_viejos TEXT,
    datos_nuevos TEXT
);

## TRIGGERS:
-- -----------------------------------------------------------------
-- Triggers para la tabla "aeropuerto"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_aeropuerto_after_insert AFTER INSERT ON aeropuerto FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('aeropuerto', NEW.aeropuerto_id, 'INSERT', USER(), CONCAT('Nombre: ', NEW.aeropuerto_nombre, ', Ciudad: ', NEW.aeropuerto_ciudad, ', Pais: ', NEW.aeropuerto_pais));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_aeropuerto_after_update AFTER UPDATE ON aeropuerto FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('aeropuerto', NEW.aeropuerto_id, 'UPDATE', USER(),
            CONCAT('Nombre: ', OLD.aeropuerto_nombre, ', Ciudad: ', OLD.aeropuerto_ciudad, ', Pais: ', OLD.aeropuerto_pais),
            CONCAT('Nombre: ', NEW.aeropuerto_nombre, ', Ciudad: ', NEW.aeropuerto_ciudad, ', Pais: ', NEW.aeropuerto_pais));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_aeropuerto_after_delete AFTER DELETE ON aeropuerto FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('aeropuerto', OLD.aeropuerto_id, 'DELETE', USER(), CONCAT('Nombre: ', OLD.aeropuerto_nombre, ', Ciudad: ', OLD.aeropuerto_ciudad, ', Pais: ', OLD.aeropuerto_pais));
END$$
DELIMITER ;

-- -----------------------------------------------------------------
-- Triggers para la tabla "aerolinea"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_aerolinea_after_insert AFTER INSERT ON aerolinea FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('aerolinea', NEW.aerolinea_id, 'INSERT', USER(), CONCAT('Nombre: ', NEW.aerolinea_nombre, ', Codigo: ', NEW.aerolinea_codigo));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_aerolinea_after_update AFTER UPDATE ON aerolinea FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('aerolinea', NEW.aerolinea_id, 'UPDATE', USER(),
            CONCAT('Nombre: ', OLD.aerolinea_nombre, ', Codigo: ', OLD.aerolinea_codigo),
            CONCAT('Nombre: ', NEW.aerolinea_nombre, ', Codigo: ', NEW.aerolinea_codigo));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_aerolinea_after_delete AFTER DELETE ON aerolinea FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('aerolinea', OLD.aerolinea_id, 'DELETE', USER(), CONCAT('Nombre: ', OLD.aerolinea_nombre, ', Codigo: ', OLD.aerolinea_codigo));
END$$
DELIMITER ;

-- -----------------------------------------------------------------
-- Triggers para la tabla "avion"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_avion_after_insert AFTER INSERT ON avion FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('avion', NEW.avion_id, 'INSERT', USER(), CONCAT('AerolineaID: ', NEW.aerolinea_id, ', Modelo: ', NEW.avion_modelo, ', Capacidad: ', NEW.avion_capacidad));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_avion_after_update AFTER UPDATE ON avion FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('avion', NEW.avion_id, 'UPDATE', USER(),
            CONCAT('Modelo: ', OLD.avion_modelo, ', Capacidad: ', OLD.avion_capacidad),
            CONCAT('Modelo: ', NEW.avion_modelo, ', Capacidad: ', NEW.avion_capacidad));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_avion_after_delete AFTER DELETE ON avion FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('avion', OLD.avion_id, 'DELETE', USER(), CONCAT('AerolineaID: ', OLD.aerolinea_id, ', Modelo: ', OLD.avion_modelo, ', Capacidad: ', OLD.avion_capacidad));
END$$
DELIMITER ;

-- -----------------------------------------------------------------
-- Triggers para la tabla "pasajero"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_pasajero_after_insert AFTER INSERT ON pasajero FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('pasajero', NEW.pasajero_id, 'INSERT', USER(), CONCAT('Nombre: ', NEW.pasajero_nombre, ', Pasaporte: ', NEW.pasajero_pasaporte, ', Email: ', NEW.pasajero_email));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_pasajero_after_update AFTER UPDATE ON pasajero FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('pasajero', NEW.pasajero_id, 'UPDATE', USER(),
            CONCAT('Nombre: ', OLD.pasajero_nombre, ', Pasaporte: ', OLD.pasajero_pasaporte, ', Email: ', OLD.pasajero_email),
            CONCAT('Nombre: ', NEW.pasajero_nombre, ', Pasaporte: ', NEW.pasajero_pasaporte, ', Email: ', NEW.pasajero_email));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_pasajero_after_delete AFTER DELETE ON pasajero FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('pasajero', OLD.pasajero_id, 'DELETE', USER(), CONCAT('Nombre: ', OLD.pasajero_nombre, ', Pasaporte: ', OLD.pasajero_pasaporte, ', Email: ', OLD.pasajero_email));
END$$
DELIMITER ;

-- -----------------------------------------------------------------
-- Triggers para la tabla "vuelo"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_vuelo_after_insert AFTER INSERT ON vuelo FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('vuelo', NEW.vuelo_id, 'INSERT', USER(), CONCAT('AvionID: ', NEW.avion_id, ', OrigenID: ', NEW.origen_id, ', DestinoID: ', NEW.destino_id, ', Codigo: ', NEW.codigo_vuelo, ', Fecha: ', NEW.fecha_salida));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_vuelo_after_update AFTER UPDATE ON vuelo FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('vuelo', NEW.vuelo_id, 'UPDATE', USER(),
            CONCAT('Codigo: ', OLD.codigo_vuelo, ', Fecha: ', OLD.fecha_salida, ', Hora: ', OLD.hora_salida),
            CONCAT('Codigo: ', NEW.codigo_vuelo, ', Fecha: ', NEW.fecha_salida, ', Hora: ', NEW.hora_salida));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_vuelo_after_delete AFTER DELETE ON vuelo FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('vuelo', OLD.vuelo_id, 'DELETE', USER(), CONCAT('AvionID: ', OLD.avion_id, ', OrigenID: ', OLD.origen_id, ', DestinoID: ', OLD.destino_id, ', Codigo: ', OLD.codigo_vuelo, ', Fecha: ', OLD.fecha_salida));
END$$
DELIMITER ;

-- -----------------------------------------------------------------
-- Triggers para la tabla "horario"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_horario_after_insert AFTER INSERT ON horario FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('horario', NEW.horario_id, 'INSERT', USER(), CONCAT('VueloID: ', NEW.vuelo_id, ', Hora Prog: ', NEW.hora_programada, ', Fecha: ', NEW.fecha, ', Estado: ', NEW.estado));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_horario_after_update AFTER UPDATE ON horario FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('horario', NEW.horario_id, 'UPDATE', USER(),
            CONCAT('Hora Real: ', OLD.hora_real, ', Estado: ', OLD.estado),
            CONCAT('Hora Real: ', NEW.hora_real, ', Estado: ', NEW.estado));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_horario_after_delete AFTER DELETE ON horario FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('horario', OLD.horario_id, 'DELETE', USER(), CONCAT('VueloID: ', OLD.vuelo_id, ', Hora Prog: ', OLD.hora_programada, ', Fecha: ', OLD.fecha, ', Estado: ', OLD.estado));
END$$
DELIMITER ;

-- -----------------------------------------------------------------
-- Triggers para la tabla "boleto"
-- -----------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_boleto_after_insert AFTER INSERT ON boleto FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_nuevos)
    VALUES ('boleto', NEW.boleto_id, 'INSERT', USER(), CONCAT('VueloID: ', NEW.vuelo_id, ', PasajeroID: ', NEW.pasajero_id, ', Asiento: ', NEW.boleto_asiento, ', Precio: ', NEW.boleto_precio, ', Estado: ', NEW.boleto_estado));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_boleto_after_update AFTER UPDATE ON boleto FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos, datos_nuevos)
    VALUES ('boleto', NEW.boleto_id, 'UPDATE', USER(),
            CONCAT('Asiento: ', OLD.boleto_asiento, ', Precio: ', OLD.boleto_precio, ', Estado: ', OLD.boleto_estado),
            CONCAT('Asiento: ', NEW.boleto_asiento, ', Precio: ', NEW.boleto_precio, ', Estado: ', NEW.boleto_estado));
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_boleto_after_delete AFTER DELETE ON boleto FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabla_afectada, id_afectado, accion, usuario_db, datos_viejos)
    VALUES ('boleto', OLD.boleto_id, 'DELETE', USER(), CONCAT('VueloID: ', OLD.vuelo_id, ', PasajeroID: ', OLD.pasajero_id, ', Asiento: ', OLD.boleto_asiento, ', Precio: ', OLD.boleto_precio, ', Estado: ', OLD.boleto_estado));
END$$
DELIMITER ; 

