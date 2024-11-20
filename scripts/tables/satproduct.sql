-- Paso 1: Crear la Tabla Principal con Particionado

CREATE TABLE IF NOT EXISTS satproduct (
    product_id CHAR(32) NOT NULL,  -- Clave de negocio o compuesta
    dt_load_date TIMESTAMP NOT NULL,
    dt_start_date TIMESTAMP,       -- Fecha cuando el registro se vuelve efectivo
    dt_end_date TIMESTAMP,         -- Fecha cuando el registro deja de ser efectivo
    current_record BOOLEAN,        -- Indicador de si el registro es el actual
    cd_product VARCHAR(255),
    ds_product VARCHAR(100),
    cd_package_group DECIMAL(10, 2),
    ds_package_group VARCHAR(500),
    recordsource VARCHAR(50) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES hubproduct(product_id),
    PRIMARY KEY (product_id, dt_start_date)  -- Clave compuesta para permitir múltiples versiones
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
    PARTITION pmax VALUES LESS THAN MAXVALUE ROW_FORMAT=COMPRESSED
);

-- Paso 2: Crear la Tabla de Control

CREATE TABLE IF NOT EXISTS load_control (
    table_name VARCHAR(50) PRIMARY KEY,
    last_load_date TIMESTAMP
);

INSERT INTO load_control (table_name, last_load_date)
VALUES ('satproduct', '2025-01-01 00:00:00')
ON DUPLICATE KEY UPDATE last_load_date = VALUES(last_load_date);

-- Paso 3: Extraer Nuevos o Modificados Registros. Crear Tablas Sustitutas (Staging Tables)

CREATE TABLE IF NOT EXISTS staging_satproduct (
    product_id CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    dt_start_date TIMESTAMP,
    dt_end_date TIMESTAMP,
    current_record BOOLEAN,
    cd_product VARCHAR(255),
    ds_product VARCHAR(100),
    cd_package_group DECIMAL(10, 2),
    ds_package_group VARCHAR(500),
    recordsource VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Obtener la última fecha de carga
SET @last_load_date = (SELECT last_load_date FROM load_control WHERE table_name = 'satproduct');

-- Insertar nuevos o modificados registros en la tabla de staging

INSERT INTO staging_satproduct (
    product_id, 
    dt_load_date, 
    dt_start_date, 
    dt_end_date, 
    current_record, 
    cd_product, 
    ds_product, 
    cd_package_group, 
    ds_package_group, 
    recordsource
)
SELECT 
    product_id, 
    dt_load_date, 
    dt_start_date, 
    dt_end_date, 
    current_record, 
    cd_product, 
    ds_product, 
    cd_package_group, 
    ds_package_group, 
    recordsource
FROM 
    source_satproduct
WHERE 
    dt_load_date > @last_load_date;

-- Paso 4: Implementar Carga Incremental
-- Insertar nuevos registros en la tabla principal

INSERT INTO satproduct (
    product_id,
    dt_load_date,
    dt_start_date,
    dt_end_date,
    current_record,
    cd_product,
    ds_product,
    cd_package_group,
    ds_package_group,
    recordsource
)
SELECT
    s.product_id,
    s.dt_load_date,
    s.dt_start_date,
    s.dt_end_date,
    s.current_record,
    s.cd_product,
    s.ds_product,
    s.cd_package_group,
    s.ds_package_group,
    s.recordsource
FROM
    staging_satproduct s
LEFT JOIN
    satproduct p ON s.product_id = p.product_id AND s.dt_start_date = p.dt_start_date
WHERE
    p.product_id IS NULL;

-- Paso 5: Actualizar la Tabla de Control
-- Actualizar la última fecha de carga en la tabla de control

UPDATE load_control
SET last_load_date = (SELECT MAX(dt_load_date) FROM staging_satproduct)
WHERE table_name = 'satproduct';

-- Paso 6: Limpiar la Tabla de Staging

TRUNCATE TABLE staging_satproduct;