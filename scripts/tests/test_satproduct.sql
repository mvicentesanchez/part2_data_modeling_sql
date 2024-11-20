-- Test: Verificar que la tabla se creó correctamente
SELECT COUNT(*) AS table_exists
FROM information_schema.tables
WHERE table_name = 'satproduct';

-- Test: Verificar que el primary key está configurado correctamente
SELECT COUNT(*) AS primary_key_exists
FROM information_schema.table_constraints
WHERE table_name = 'satproduct'
  AND constraint_type = 'PRIMARY KEY';

-- Test: Intentar insertar un registro válido
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
) VALUES (
    'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P',  -- Asegúrate de que este hashkey exista en hubproduct
    CURRENT_TIMESTAMP,                  -- Fecha y hora actuales de carga
    '2023-10-01',                       -- Fecha de inicio de validez
    NULL,                               -- Fecha de fin NULL para el registro actual
    TRUE,                               -- Valor booleano para el registro actual
    'P001',                             -- Código del producto
    'Product 1',                        -- Descripción del producto
    1.00,                               -- Grupo de paquete
    'Package Group 1',                  -- Descripción del grupo de paquete
    'ProductSourceA'                    -- Fuente de los datos
);

-- Test: Intentar insertar un registro con un hashkeyproducto duplicado y verificar que falla (si aplica la lógica de negocio)

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
) VALUES (
    'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P',  -- Asegúrate de que este hashkey exista en hubproduct
    CURRENT_TIMESTAMP,                  -- Fecha y hora actuales de carga
    '2023-10-01',                       -- Fecha de inicio de validez
    NULL,                               -- Fecha de fin NULL para el registro actual
    TRUE,                               -- Valor booleano para el registro actual
    'P001',                             -- Código del producto
    'Product 1',                        -- Descripción del producto
    1.00,                               -- Grupo de paquete
    'Package Group 1',                  -- Descripción del grupo de paquete
    'ProductSourceA'                    -- Fuente de los datos
);

-- Test: Verificar la restricción de la clave foránea

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
) VALUES (
    'nonexistenthashkey',  -- Asegúrate de que este hashkey exista en hubproduct
    CURRENT_TIMESTAMP,                  -- Fecha y hora actuales de carga
    '2023-10-01',                       -- Fecha de inicio de validez
    NULL,                               -- Fecha de fin NULL para el registro actual
    TRUE,                               -- Valor booleano para el registro actual
    'P003',                             -- Código del producto
    'Product 3',                        -- Descripción del producto
    3.00,                               -- Grupo de paquete
    'Package Group 3',                  -- Descripción del grupo de paquete
    'ProductSourceC'                    -- Fuente de los datos
);


-- Test: Implementación de SCD Tipo 2

-- Paso 1: Actualizar el registro anterior para establecer la fecha de fin y marcarlo como no actual
UPDATE satproduct
SET dt_end_date = CURRENT_TIMESTAMP,  -- Establece la fecha de fin con la fecha actual
    current_record = FALSE            -- Marca el registro como no actual
WHERE hashkeyproducto = 'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P' -- Hash key del producto que estás actualizando
  AND current_record = TRUE;          -- Asegúrate de actualizar solo el registro actual

-- Paso 2: Insertar un nuevo registro con la información actualizada
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
) VALUES (
    'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P',                    -- Hash key del producto
    CURRENT_TIMESTAMP,                -- Fecha y hora actuales de carga
    CURRENT_TIMESTAMP,                -- Fecha de inicio de validez
    NULL,                             -- Fecha de fin NULL para el registro actual
    TRUE,                             -- Marcar como registro actual
    'P004',                           -- Nuevo código del producto
    'Updated Product 4',              -- Nueva descripción del producto
     4.00,                             -- Nuevo grupo de paquete
    'Updated Package Group 4',        -- Nueva descripción del grupo de paquete
    'ProductSourceD'                  -- Nueva fuente de los datos
);