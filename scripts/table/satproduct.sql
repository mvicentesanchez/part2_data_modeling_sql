-- En la tabla origen source_product contiene la información de los productos y tiene una columna last_modified_date que
-- indica cuándo fue modificado cada registro por última vez.

-- Creamos tabla de control para registrar la última fecha de carga:

CREATE TABLE IF NOT EXISTS load_control (
    table_name VARCHAR(255) PRIMARY KEY,
    last_load_date DATETIME
);

-- Inicializar con una fecha de carga anterior

INSERT INTO load_control (table_name, last_load_date)
VALUES ('satproduct', '2024-10-01 00:00:00')
ON DUPLICATE KEY UPDATE
    last_load_date = VALUES(last_load_date);

-- Extraer nuevos o modificados registros

SELECT *
FROM source_product
WHERE last_modified_date > (
    SELECT last_load_date
    FROM load_control
    WHERE table_name = 'satproduct'
);

-- Actualizamos en la tabla original

INSERT INTO satproduct (
    hashkeyproducto,
    dt_load_date,
    dt_end_date,
    cd_product,
    ds_product,
    cd_package_group,
    ds_package_group,
    recordsource
)
SELECT
    hashkeyproducto,
    dt_load_date,
    dt_end_date,
    cd_product,
    ds_product,
    cd_package_group,
    ds_package_group,
    recordsource
FROM
    source_product
WHERE
    last_modified_date > (
        SELECT last_load_date
        FROM load_control
        WHERE table_name = 'satproduct'
    )
ON DUPLICATE KEY UPDATE
    dt_load_date = VALUES(dt_load_date),
    recordsource = VALUES(recordsource);

--Actualizar la Tabla de Control

UPDATE load_control
SET last_load_date = CURRENT_TIMESTAMP
WHERE table_name = 'satproduct';

--El siguiente paso seria programar un proceso ETL que se ejecute automáticamente a intervalos regulares mediante Talend por ejemplo.