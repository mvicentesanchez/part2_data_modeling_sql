-- Paso 1: Crear la Tabla Principal con Particionado

CREATE TABLE IF NOT EXISTS hubproduct (
    product_id INT AUTO_INCREMENT PRIMARY KEY,  -- Clave sustituta
    hashkeyproduct CHAR(32) NOT NULL UNIQUE,
    dt_load_date TIMESTAMP NOT NULL,
    recordsource VARCHAR(50) NOT NULL
) ENGINE=InnoDB
PARTITION BY RANGE (TO_DAYS(dt_load_date)) (
    PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
    PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
    PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
    PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);

-- Paso 2: Crear la Tabla de Control

CREATE TABLE IF NOT EXISTS load_control (
    table_name VARCHAR(50) PRIMARY KEY,
    last_load_date TIMESTAMP
);

INSERT INTO load_control (table_name, last_load_date)
VALUES ('hubproduct', '2025-01-01 00:00:00')
ON DUPLICATE KEY UPDATE last_load_date = VALUES(last_load_date);

-- Paso 3: Extraer Nuevos o Modificados Registros. Crear Tablas Sustitutas (Staging Tables)
-- Supongamos que los datos nuevos o modificados están en una tabla de origen llamada `source_product`

CREATE TABLE IF NOT EXISTS staging_hubproduct (
    product_id CHAR(32) NOT NULL,
    hashkeyproduct CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    recordsource VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Obtener la última fecha de carga

SET @last_load_date = (SELECT last_load_date FROM load_control WHERE table_name = 'hubproduct');

-- Insertar nuevos o modificados registros en la tabla de staging

INSERT INTO staging_hubproduct (product_id, hashkeyproduct, dt_load_date, recordsource)
SELECT 
    product_id, 
    hashkeyproduct, 
    dt_load_date, 
    recordsource
FROM 
    source_product
WHERE 
    dt_load_date > @last_load_date;

-- Paso 4: Implementar Carga Incremental
-- Insertar nuevos registros en la tabla principal

INSERT INTO hubproduct (product_id, hashkeyproduct, dt_load_date, recordsource)
SELECT 
    s.product_id, 
    s.hashkeyproduct, 
    s.dt_load_date, 
    s.recordsource
FROM 
    staging_hubproduct s
LEFT JOIN 
    hubproduct h 
ON 
    s.hashkeyproduct = h.hashkeyproduct
WHERE 
    h.hashkeyproduct IS NULL;

-- Paso 5: Actualizar la Tabla de Control
-- Actualizar la última fecha de carga en la tabla de control

UPDATE load_control
SET last_load_date = (SELECT MAX(dt_load_date) FROM staging_hubproduct)
WHERE table_name = 'hubproduct';

-- Paso 6: Limpiar la Tabla de Staging

TRUNCATE TABLE staging_hubproduct;