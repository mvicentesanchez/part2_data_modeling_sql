CREATE TABLE hubproduct (
    id_product INT PRIMARY KEY,
    hashkeyproduct CHAR(32) NOT NULL UNIQUE,
    dt_load_date TIMESTAMP NOT NULL,
    recordsource VARCHAR(50) NOT NULL
);