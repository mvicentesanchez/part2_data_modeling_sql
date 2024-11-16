CREATE TABLE satClientes (
    hashkeycustomer CHAR(32) NOT NULL,
    customer_no CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    dt_end_date TIMESTAMP,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(100),
    social_scrty_no VARCHAR(20),
    cd_natural_legal VARCHAR(20),
    ds_natural_legal VARCHAR(20),
    dt_birth TIMESTAMP,
    address VARCHAR(20),
    phone_number VARCHAR(255),
    recordsource VARCHAR(50) NOT NULL,
    PRIMARY KEY (hashkeycustomer, dt_created),
    FOREIGN KEY (hashkeycustomer) REFERENCES hubcustomer(hashkeycustomer)
);