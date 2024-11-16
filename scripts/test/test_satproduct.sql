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
INSERT INTO satproduct (hashkeyproducto, dt_load_date, cd_product, ds_product, cd_package_group, ds_package_group, recordsource)
VALUES ('A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P', CURRENT_TIMESTAMP, 'P001', 'Product 1', 1.00, 'Package Group 1', 'ProductSourceA');

-- Test: Intentar insertar un registro con un hashkeyproducto duplicado y verificar que falla (si aplica la lógica de negocio)
INSERT INTO satproduct (hashkeyproducto, dt_load_date, cd_product, ds_product, cd_package_group, ds_package_group, recordsource)
VALUES ('A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P', CURRENT_TIMESTAMP, 'P001', 'Product 1', 1.00, 'Package Group 1', 'ProductSourceA');

-- Test: Verificar la restricción de la clave foránea
INSERT INTO satproduct (hashkeyproducto, dt_load_date, cd_product, ds_product, cd_package_group, ds_package_group, recordsource)
VALUES ('nonexistenthashkey', CURRENT_TIMESTAMP, 'P003', 'Product 3', 3.00, 'Package Group 3', 'ProductSourceC');