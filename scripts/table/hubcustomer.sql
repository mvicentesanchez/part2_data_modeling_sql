CREATE TABLE hubcustomer (
    id_customer INT PRIMARY KEY,                  -- Identificador único para cada cliente
    hashkeycustomer CHAR(32) NOT NULL UNIQUE,     -- Clave hash única para identificar al cliente
    dt_load_date TIMESTAMP NOT NULL,              -- Fecha y hora de carga del registro
    recordsource VARCHAR(50) NOT NULL             -- Fuente del registro
);