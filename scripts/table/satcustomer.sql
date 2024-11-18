CREATE TABLE satcustomer (
    hashkeycustomer CHAR(32) NOT NULL,
    dt_load_date TIMESTAMP NOT NULL,
    dt_start_date TIMESTAMP, -- Date when the record becomes effective
    dt_end_date TIMESTAMP,   -- Date when the record is no longer effective
    current_record BOOLEAN, -- Indicator if the record is the current one
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(100),
    social_scrty_no VARCHAR(20),
    cd_natural_legal VARCHAR(20),
    ds_natural_legal VARCHAR(20),
    dt_birth TIMESTAMP,
    address VARCHAR(255), -- Ajustado para permitir direcciones más largas
    phone_number VARCHAR(255),
    recordsource VARCHAR(50) NOT NULL,
    FOREIGN KEY (hashkeycustomer) REFERENCES hubcustomer(hashkeycustomer)
);
