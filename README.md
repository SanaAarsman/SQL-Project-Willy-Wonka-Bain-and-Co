# 🍫 Wonka Factory SQL Project

## 📌 Project Overview

- This project analyzes sales, profitability, shipping, and customer behavior for the Wonka Factory using SQL. 
- The goal is to design a relational database and run analytical queries that support business decisions across marketing, products, and customer strategy.

## 🔍 Key Analyses

- Sales vs profit margin by region (Marketing)

- Product performance across products

- Profit concentration among customers (Customer Strategy)

## 📊 Business Insights

- High sales volume in a region does not always imply high profitability (TO BE CONFIRMED)

- High sales volume of a product type does not always imply high profitability

- A small group of customers contributes a large share of profit (TO BE CONFIRMED)

## 🗂️ Dataset

Provided dataset that includes:

- Orders and shipping details

- Products and factories

- Customers and regions

- Sales, cost, and profit metrics

## 🏗️ Database Design

The database is normalized to reduce redundancy and improve data integrity

Key tables include:

- products

- factories

- customers

- orders

- Bridge table, sales, to handle many-to-many relationships

An ERD is included to visualize the schema:

***** add the ERD image link****

## 📁 Repository Structure

```text
SQL-project-willy-wonka-bain-and-co/
│
├── data/                     # Raw and cleaned datasets; output from the SQL queries used for analysis 
│
├── notebooks/                # Jupyter notebooks for data exploration + EDA 
│
├── plots/                    # ERD Diagram, all charts and visualisations
│
├── src/                      needed????????
│   ├── utils.py
│   └── __init__.py
│
└── README.md                 # Project documentation

/sql-scripts
   ├── schema.sql
   ├── data_load.sql
   ├── transformations.sql
   └── analysis_queries.sql
/erd
   └── wonka_erd.png
/data
   └── wonka_choc_factory.csv
