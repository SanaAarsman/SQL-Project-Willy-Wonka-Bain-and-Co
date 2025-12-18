SHOW VARIABLES LIKE 'local_infile';




DROP DATABASE wonka_factory;
CREATE DATABASE wonka_factory;
USE wonka_factory;

-- creating a table for the raw csv data
CREATE TABLE raw_wonka (
    row_id INT, -- Unnamed: 0 as per Python
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id INT,
    country_region VARCHAR(100),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20), -- FIXED: allows Canadian codes which has numbers
    division VARCHAR(100),
    region VARCHAR(100),
    product_name VARCHAR(255),
    sales DOUBLE,
    units INT,
    gross_profit DOUBLE,
    cost DOUBLE,
    factory VARCHAR(100),
    latitude DOUBLE,
    longitude DOUBLE
);

-- loading the csv file
LOAD DATA LOCAL INFILE '/Users/sanaaarsman/Desktop/ironhack/data-analyst-pt/projects/project-unit-8-willy-wonka/willy-wonka-project/data/wonka_choc_factory.csv'
INTO TABLE raw_wonka
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM raw_wonka; -- checking if all the rows in csv loaded

-- creating 'factories' table
CREATE TABLE factories (
    factory_id VARCHAR(10) PRIMARY KEY,
    factory VARCHAR(100),
    latitude DOUBLE,
    longitude DOUBLE
);

-- creating 'products' table
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    factory_id VARCHAR(10),
    division VARCHAR(100),
    product_name VARCHAR(255),
    FOREIGN KEY (factory_id) REFERENCES factories(factory_id)
);

-- creating 'customers' table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    countryregion VARCHAR(100),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(100)
);

-- creating 'orders' table
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- creating 'sales' table
CREATE TABLE sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(20),
    product_id VARCHAR(10),
    sales DOUBLE,
    units INT,
    gross_profit DOUBLE,
    cost DOUBLE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- seeding factories table from csv file and creating unique Primary key
INSERT INTO factories (factory_id, factory, latitude, longitude)
SELECT 
    CONCAT('FAC', LPAD(ROW_NUMBER() OVER (ORDER BY factory), 4, '0')), 
    factory,
    latitude,
    longitude
FROM (
    SELECT DISTINCT factory, latitude, longitude
    FROM raw_wonka
) AS f;

-- seeding products table from csv file and creating unique Primary key
INSERT INTO products (product_id, factory_id, division, product_name)
SELECT 
    CONCAT('PROD', LPAD(ROW_NUMBER() OVER (ORDER BY p.product_name), 4, '0')),
    f.factory_id,
    p.division,
    p.product_name
FROM (
    SELECT DISTINCT product_name, division, factory
    FROM raw_wonka
) AS p
JOIN factories f
    ON p.factory = f.factory;
    
-- seeding customers table from csv file (FAILED CODE)
INSERT INTO customers (
    customer_id, 
    countryregion, 
    city, 
    state_province, 
    postal_code, 
    region
)
SELECT DISTINCT
    customer_id,
    country_region,
    city,
    state_province,
    postal_code,
    region
FROM raw_wonka; -- THIS FAILED BECAUSE THERE WAS A DUPLICATE IN THE PRIMARY KEY

-- seeding customers table from csv file (successful)
INSERT INTO customers (
    customer_id, 
    countryregion, 
    city, 
    state_province, 
    postal_code, 
    region
)
SELECT
    customer_id,
    ANY_VALUE(country_region), -- the PK had more than one values (same customer ordered to many addresses), so we chose the first consistent value
    ANY_VALUE(city),
    ANY_VALUE(state_province),
    ANY_VALUE(postal_code),
    ANY_VALUE(region)
FROM raw_wonka
GROUP BY customer_id;

-- seeding orders table from csv file and creating unique Primary key
INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    ship_date,
    ship_mode
)
SELECT
    CONCAT('ORD', LPAD(ROW_NUMBER() OVER (ORDER BY customer_id, order_date), 6, '0')),
    customer_id,
    order_date,
    ship_date,
    ship_mode
FROM (
    SELECT DISTINCT
        customer_id,
        order_date,
        ship_date,
        ship_mode
    FROM raw_wonka
) AS unique_orders;

SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 5;

-- seeding sales table from csv file and creating an auto increment Primary key
INSERT INTO sales (
    order_id,
    product_id,
    sales,
    units,
    gross_profit,
    cost
)
SELECT
    o.order_id,
    p.product_id,
    r.sales,
    r.units,
    r.gross_profit,
    r.cost
FROM raw_wonka r
JOIN orders o
    ON r.customer_id = o.customer_id
   AND r.order_date = o.order_date
   AND r.ship_date = o.ship_date
   AND r.ship_mode = o.ship_mode
JOIN products p
    ON r.product_name = p.product_name; -- sales_id key remains auto increment INT since it is better for joins
