CREATE TABLE linkproductocustomer (
    link_key  INT PRIMARY KEY,
    id_product INT NOT NULL,
    id_customer INT NOT NULL,
    dt_transaction_date DATETIME NOT NULL,
    dt_load_date DATETIME NOT NULL,
    recordsource VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_customer) REFERENCES hubcustomer(id_customer),
    FOREIGN KEY (id_product) REFERENCES HubProduct(id_product)
);