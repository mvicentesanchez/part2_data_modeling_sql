CREATE TABLE satproduct (
    hashkeyproducto CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    dt_end_date TIMESTAMP,
    cd_product VARCHAR(255),
    ds_product VARCHAR(100),
    cd_package_group DECIMAL(10, 2),
    ds_package_group VARCHAR(500),
    recordsource VARCHAR(50) NOT NULL,
    PRIMARY KEY (hashkeyproducto, dt_created),
    FOREIGN KEY (hashkeyproducto) REFERENCES hubproduct(hashkeyproducto)S
);