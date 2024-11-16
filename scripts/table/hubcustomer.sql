CREATE TABLE hubcustomer (
    id_customer INT PRIMARY KEY,
    hashkeycustomer CHAR(32) NOT NULL UNIQUE,
    dt_load_date TIMESTAMP NOT NULL,
    recordsource  VARCHAR(50) NOT NULL
);