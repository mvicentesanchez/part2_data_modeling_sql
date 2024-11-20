-- Paso 1: Crear la Tabla Principal con Particionado

CREATE TABLE IF NOT EXISTS linkproductocustomer (
    link_key INT AUTO_INCREMENT,  -- Clave surrogada opcional
    customer_id CHAR(32) NOT NULL,  -- Clave foránea que referencia al hubcustomer
    product_id CHAR(32) NOT NULL,  -- Clave foránea que referencia al hubproduct
    dt_load_date TIMESTAMP NOT NULL,  -- Fecha y hora de carga del registro
    dt_transaction_date DATETIME NOT NULL,  -- Fecha de la transacción
    recordsource VARCHAR(50) NOT NULL,  -- Fuente del registro
    PRIMARY KEY (customer_id, product_id, dt_transaction_date),  -- Clave primaria compuesta
    FOREIGN KEY (customer_id) REFERENCES hubcustomer(customer_id),
    FOREIGN KEY (product_id) REFERENCES hubproduct(product_id)
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED
PARTITION BY RANGE (TO_DAYS(dt_load_date)) (
    PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')) ROW_FORMAT=COMPRESSED,
    PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')) ROW_FORMAT=COMPRESSED
);

-- Paso 2: Crear la Tabla de Control

CREATE TABLE IF NOT EXISTS load_control (
    table_name VARCHAR(50) PRIMARY KEY,
    last_load_date TIMESTAMP
);

INSERT INTO load_control (table_name, last_load_date)
VALUES ('linkproductocustomer', '2025-01-01 00:00:00')
ON DUPLICATE KEY UPDATE last_load_date = VALUES(last_load_date);

-- Paso 3: Extraer Nuevos o Modificados Registros. Crear Tablas Sustitutas (Staging Tables)

CREATE TABLE IF NOT EXISTS staging_linkproductocustomer (
    customer_id CHAR(32) NOT NULL,
    product_id CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    dt_transaction_date DATETIME NOT NULL,
    recordsource VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Obtener la última fecha de carga
SET @last_load_date = (SELECT last_load_date FROM load_control WHERE table_name = 'linkproductocustomer');

-- Insertar nuevos o modificados registros en la tabla de staging

INSERT INTO staging_linkproductocustomer (
    customer_id, 
    product_id, 
    dt_load_date, 
    dt_transaction_date, 
    recordsource
)
SELECT 
    customer_id, 
    product_id, 
    dt_load_date, 
    dt_transaction_date, 
    recordsource
FROM 
    source_linkproductocustomer
WHERE 
    dt_load_date > @last_load_date;

-- Paso 4: Implementar Carga Incremental
-- Insertar nuevos registros en la tabla principal

INSERT INTO linkproductocustomer (
    customer_id,
    product_id,
    dt_load_date,
    dt_transaction_date,
    recordsource
)
SELECT
    s.customer_id,
    s.product_id,
    s.dt_load_date,
    s.dt_transaction_date,
    s.recordsource
FROM
    staging_linkproductocustomer s
LEFT JOIN
    linkproductocustomer l ON s.customer_id = l.customer_id 
                           AND s.product_id = l.product_id 
                           AND s.dt_transaction_date = l.dt_transaction_date
WHERE
    l.customer_id IS NULL;

-- Paso 5: Actualizar la Tabla de Control
-- Actualizar la última fecha de carga en la tabla de control

UPDATE load_control
SET last_load_date = (SELECT MAX(dt_load_date) FROM staging_linkproductocustomer)
WHERE table_name = 'linkproductocustomer';

-- Paso 6: Limpiar la Tabla de Staging

TRUNCATE TABLE staging_linkproductocustomer;