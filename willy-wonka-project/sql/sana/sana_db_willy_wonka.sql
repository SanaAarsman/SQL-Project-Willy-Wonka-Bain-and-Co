CREATE DATABASE IF NOT EXISTS db_willy_wonka;
USE db_willy_wonka;

DROP TABLE IF EXISTS factories;
CREATE TABLE factories (
    factory_id VARCHAR(50),
    factory VARCHAR(100),
    latitude FLOAT,
    longitude FLOAT
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT,
    `country/region` VARCHAR(100),
    city VARCHAR(100),
    `state/province` VARCHAR(100),
    postal_code INT,
    region VARCHAR(100)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id INT,
    `order date` DATE,
    `ship date` DATE,
    `ship mode` VARCHAR(100)
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id VARCHAR(50),
    factory_id VARCHAR(50),
    division VARCHAR(100),
    product_name VARCHAR(100)
);

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    sales_id INT,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    sales FLOAT,
    units INT,
    gross_profit FLOAT,
    cost FLOAT
);












