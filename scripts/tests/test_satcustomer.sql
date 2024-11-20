-- Test: Inserta algunos datos de prueba en la tabla hubcustomer: 

INSERT INTO hubcustomer (id_customer, hashkeycustomer, dt_load_date, recordsource)
VALUES
    (1, 'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6', '2023-10-01 10:00:00', 'SourceA'),
    (2, 'P6O5N4M3L2K1J0I9H8G7F6E5D4C3B2A1', '2023-10-02 11:30:00', 'SourceB');

-- Test: Insertar Datos de Prueba en satClientes

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
) VALUES
(
    'CUST001',
    CURRENT_TIMESTAMP,
    '2023-10-01',
    NULL,
    TRUE,
    'Test',
    'Prueba',
    'Datos',
    '91127802P',
    'NL1',
    'Natural',
    '1980-01-01',
    'C/Sol n1 Madrid CP 28010',
    '34699000000',
    'TestSource'
),
(
    'CUST002',
    CURRENT_TIMESTAMP,
    '2023-10-02',
    NULL,
    TRUE,
    'Test2',
    'Prueba2',
    'Datos2',
    '11883773H',
    'NL2',
    'Legal',
    '1990-02-02',
    'C/Gran Via n1 Madrid CP 28007',
    '34699000001',
    'TestSource'
);

-- Test: Ejecuta una consulta simple para verificar la inserción de datos:7

SELECT * FROM satcustomer;

-- Test: Limpiar los datos de prueba después de realizar las pruebas:
DELETE FROM satcustomer WHERE recordsource = 'TestSource';
DELETE FROM hubcustomer WHERE hashkeycustomer IN ('1234567890abcdef1234567890abcdef', 'abcdef1234567890abcdef1234567890');

-- Test: Implementación de SCD Tipo 2


-- Paso 1: Actualizar el registro anterior para establecer la fecha de fin y marcarlo como no actual
UPDATE satcustomer
SET dt_end_date = CURRENT_TIMESTAMP,  -- Establece la fecha de fin con la fecha actual
    current_record = FALSE            -- Marca el registro como no actual
WHERE hashkeyproducto = 'A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6' -- Hash key del producto que estás actualizando
  AND current_record = TRUE;          -- Asegúrate de actualizar solo el registro actual

-- Paso 2: Insertar un nuevo registro con la información actualizada

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
) VALUES
(
    'CUST001',
    CURRENT_TIMESTAMP,
    '2023-10-01',
    NULL,
    TRUE,
    'Test',
    'Prueba',
    'Datos',
    '91127802P',
    'NL1',
    'Natural',
    '1980-01-01',
    'Nueva direccion',
    '34699000000',
    'TestSource'
);
