-- En la tabla origen source_customer contiene la información de los productos y tiene una columna last_modified_date que
-- indica cuándo fue modificado cada registro por última vez.

-- Creamos tabla de control para registrar la última fecha de carga:

CREATE TABLE IF NOT EXISTS load_control (
    table_name VARCHAR(255) PRIMARY KEY,
    last_load_date DATETIME
);

-- Inicializar con una fecha de carga anterior

INSERT INTO load_control (table_name, last_load_date)
VALUES ('satcustomer', '2024-10-01 00:00:00')
ON DUPLICATE KEY UPDATE
    last_load_date = VALUES(last_load_date);

-- Extraer nuevos o modificados registros

SELECT *
FROM source_customer
WHERE last_modified_date > (
    SELECT last_load_date
    FROM load_control
    WHERE table_name = 'satcustomer'
);

-- Integramos claves sustitutas (surrogate keys) en el proceso ETL

ALTER TABLE satcustomer
ADD COLUMN surrogate_key INT AUTO_INCREMENT PRIMARY KEY;

-- Actualizamos en la tabla original

INSERT INTO satcustomer (
    hashkeycustomer,
    customer_no,
    dt_load_date,
    dt_end_date,
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
    hashkeycustomer,
    customer_no,
    dt_load_date,
    dt_end_date,
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
    source_product
WHERE
    last_modified_date > (
        SELECT last_load_date
        FROM load_control
        WHERE table_name = 'satcustomer'
    )
ON DUPLICATE KEY UPDATE
    dt_load_date = VALUES(dt_load_date),
    recordsource = VALUES(recordsource);

--Actualizar la Tabla de Control

UPDATE load_control
SET last_load_date = CURRENT_TIMESTAMP
WHERE table_name = 'satcustomer';

--El siguiente paso seria programar un proceso ETL que se ejecute automáticamente a intervalos regulares mediante Talend por ejemplo.