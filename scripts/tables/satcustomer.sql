-- Paso 1: Crear la Tabla Principal con Particionado

CREATE TABLE IF NOT EXISTS satcustomer (
    customer_id CHAR(32) NOT NULL,  -- Clave foránea que referencia al hub
    dt_load_date TIMESTAMP NOT NULL,  -- Fecha y hora de carga del registro
    dt_start_date TIMESTAMP NOT NULL,  -- Fecha cuando el registro se vuelve efectivo
    dt_end_date TIMESTAMP,  -- Fecha cuando el registro deja de ser efectivo
    current_record BOOLEAN NOT NULL,  -- Indicador de si el registro es el actual
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(100),
    social_scrty_no VARCHAR(20),
    cd_natural_legal VARCHAR(20),
    ds_natural_legal VARCHAR(20),
    dt_birth TIMESTAMP,
    address VARCHAR(255),  -- Permitir direcciones más largas
    phone_number VARCHAR(255),
    recordsource VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES hubcustomer(customer_id),
    PRIMARY KEY (customer_id, dt_start_date)  -- Clave compuesta para permitir múltiples versiones
) ENGINE=InnoDB ROW_FORMAT=COMPRESSED
PARTITION BY RANGE (TO_DAYS(dt_start_date)) (
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
VALUES ('satcustomer', '2025-01-01 00:00:00')
ON DUPLICATE KEY UPDATE last_load_date = VALUES(last_load_date);

-- Paso 3: Extraer Nuevos o Modificados Registros. Crear Tablas Sustitutas (Staging Tables)

CREATE TABLE IF NOT EXISTS staging_satcustomer (
    customer_id CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    dt_start_date TIMESTAMP NOT NULL,
    dt_end_date TIMESTAMP,
    current_record BOOLEAN NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(100),
    social_scrty_no VARCHAR(20),
    cd_natural_legal VARCHAR(20),
    ds_natural_legal VARCHAR(20),
    dt_birth TIMESTAMP,
    address VARCHAR(255),
    phone_number VARCHAR(255),
    recordsource VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Obtener la última fecha de carga
SET @last_load_date = (SELECT last_load_date FROM load_control WHERE table_name = 'satcustomer');

-- Insertar nuevos o modificados registros en la tabla de staging

INSERT INTO staging_satcustomer (
    customer_id, 
    dt_load_date, 
    dt_start_date, 
    dt_end_date, 
    current_record, 
    first_name, 
    last_name, 
    full_name, 
    social_scrty_no, 
    cd_natural_legal, 
    ds_natural_legal, 
    dt_birth, 
    address, 
    phone_number, 
    recordsource
)
SELECT 
    customer_id, 
    dt_load_date, 
    dt_start_date, 
    dt_end_date, 
    current_record, 
    first_name, 
    last_name, 
    full_name, 
    social_scrty_no, 
    cd_natural_legal, 
    ds_natural_legal, 
    dt_birth, 
    address, 
    phone_number, 
    recordsource
FROM 
    source_satcustomer
WHERE 
    dt_load_date > @last_load_date;

-- Paso 4: Implementar Carga Incremental
-- Insertar nuevos registros en la tabla principal

INSERT INTO satcustomer (
    customer_id,
    dt_load_date,
    dt_start_date,
    dt_end_date,
    current_record,
    first_name,
    last_name,
    full_name,
    social_scrty_no,
    cd_natural_legal,
    ds_natural_legal,
    dt_birth,
    address,
    phone_number,
    recordsource
)
SELECT
    s.customer_id,
    s.dt_load_date,
    s.dt_start_date,
    s.dt_end_date,
    s.current_record,
    s.first_name,
    s.last_name,
    s.full_name,
    s.social_scrty_no,
    s.cd_natural_legal,
    s.ds_natural_legal,
    s.dt_birth,
    s.address,
    s.phone_number,
    s.recordsource
FROM
    staging_satcustomer s
LEFT JOIN
    satcustomer c ON s.customer_id = c.customer_id AND s.dt_start_date = c.dt_start_date
WHERE
    c.customer_id IS NULL;

-- Paso 5: Actualizar la Tabla de Control
-- Actualizar la última fecha de carga en la tabla de control

UPDATE load_control
SET last_load_date = (SELECT MAX(dt_load_date) FROM staging_satcustomer)
WHERE table_name = 'satcustomer';

-- Paso 6: Limpiar la Tabla de Staging

TRUNCATE TABLE staging_satcustomer;