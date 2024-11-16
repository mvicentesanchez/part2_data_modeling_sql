--Caso de Prueba 1: Inserción de Registro Válido
--Descripción: Verificar que se pueda insertar un registro válido en la tabla.
--Precondiciones: Los valores de id_product y id_customer deben existir en las tablas HubProduct y hubcustomer, respectivamente.
--Pasos:

-- Ejecutar la siguiente instrucción SQL:
INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (1, 1, 1, '2023-10-01 10:00:00', '2023-10-01 10:00:00', 'WEB');

--Resultado: El registro se inserta correctamente sin errores.

--Caso de Prueba 2: Violación de Clave Primaria
--Descripción: Verificar que no se pueda insertar un duplicado de link_key.
--Precondiciones: Un registro con link_key = 1 ya existe.
--Pasos:
--Ejecutar la siguiente instrucción SQL:

INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (1, 1, 1, '2023-10-01 10:00:00', '2023-10-01 10:00:00', 'WEB');

--Resultado: La base de datos devuelve un error indicando que la clave primaria ya existe.

--Caso de Prueba 3: Integridad Referencial para id_customer
--Descripción: Verificar que id_customer debe existir en la tabla hubcustomer.
--Pasos:
--Ejecutar la siguiente instrucción SQL:

INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (1, 1, 1, '2023-10-01 10:00:00', '2023-10-01 10:00:00', 'WEB');

--Resultado : La base de datos devuelve un error de clave externa indicando que id_customer no existe.

--Caso de Prueba 4: Integridad Referencial para id_product
--Descripción: Verificar que id_product debe existir en la tabla HubProduct.
--Pasos:
--Ejecutar la siguiente instrucción SQL:

INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (3, 103, 3, '2023-10-01 15:00:00', '2023-10-01 15:05:00', 'WEB');

--Resultado: La base de datos devuelve un error de clave externa indicando que id_product no existe.

--Caso de Prueba 5: Validación de Campos de Fecha
--Descripción: Verificar que los campos dt_transaction_date y dt_load_date acepten fechas válidas.
--Pasos:
--Ejecutar la siguiente instrucción SQL:

INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (4, 1, 4, 'invalid-date', '2024-10-01 16:05:00', 'WEB');

--Resultado: La base de datos devuelve un error de formato de fecha.

--Caso de Prueba 6: Longitud de recordsource
--Descripción: Verificar que la longitud de recordsource no exceda los 50 caracteres.
--Pasos:
--Ejecutar la siguiente instrucción SQL:

INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (5, 10, 2, '2027-10-01 17:00:00', '2023-10-01 17:05:00', 'THIS_IS_A_VERY_LONG_RECORDSOURCE_EXCEEDING_50_CHARACTERS');

--Resultado: La base de datos devuelve un error indicando que la cadena es demasiado larga.

--Caso de Prueba 7: Inserción con Campos Nulos Prohibidos
--Descripción: Verificar que no se puedan insertar registros con campos obligatorios nulos.
--Pasos:
--Ejecutar la siguiente instrucción SQL:

INSERT INTO linkproductocustomer (link_key, id_product, id_customer, dt_transaction_date, dt_load_date, recordsource)
VALUES (6, NULL, 501, '2023-10-01 18:00:00', '2023-10-01 18:05:00', 'WEB');

--Resultado: La base de datos devuelve un error de restricción de no nulo.

