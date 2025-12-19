USE wonka_db;

SELECT COUNT(*) AS total_rows FROM wonka_choc_factory_1;


SHOW COLUMNS FROM wonka_choc_factory_1;

SELECT `Customer ID`, `Sales`, `Gross Profit`
FROM wonka_choc_factory_1
LIMIT 10;

### KPI Summary (Total profit, customers, avg profit/customer)

WITH customer_profit AS (
  SELECT
    `Customer ID` AS customer_id,
    SUM(`Gross Profit`) AS customer_profit
  FROM wonka_choc_factory_1
  WHERE `Customer ID` IS NOT NULL
  GROUP BY `Customer ID`
)
SELECT
  (SELECT COUNT(*) FROM wonka_choc_factory_1) AS total_rows,
  COUNT(*) AS total_customers,
  ROUND(SUM(customer_profit), 2) AS total_company_profit,
  ROUND(AVG(customer_profit), 2) AS avg_profit_per_customer,
  ROUND(MAX(customer_profit), 2) AS max_profit_customer
FROM customer_profit;

### VISUAL 1 — Pareto Curve dataset (Line chart)

WITH customer_profit AS (
  SELECT
    `Customer ID` AS customer_id,
    SUM(`Gross Profit`) AS customer_profit
  FROM wonka_choc_factory_1
  WHERE `Customer ID` IS NOT NULL
  GROUP BY `Customer ID`
),
ranked AS (
  SELECT
    customer_id,
    customer_profit,
    ROW_NUMBER() OVER (ORDER BY customer_profit DESC) AS rn,
    COUNT(*) OVER () AS total_customers,
    SUM(customer_profit) OVER (ORDER BY customer_profit DESC) AS cum_profit,
    SUM(customer_profit) OVER () AS total_profit
  FROM customer_profit
)
SELECT
  ROUND(100 * rn / total_customers, 2)      AS customer_percent,
  ROUND(100 * cum_profit / total_profit, 2) AS cumulative_profit_percent
FROM ranked
ORDER BY customer_percent;

### VISUAL 2 — Top 10 customers (Bar chart)

SELECT
  `Customer ID` AS customer_id,
  ROUND(SUM(`Gross Profit`), 2) AS customer_profit
FROM wonka_choc_factory_1
WHERE `Customer ID` IS NOT NULL
GROUP BY `Customer ID`
ORDER BY customer_profit DESC
LIMIT 10;

### VISUAL 3 — Top 20% customers generate X% profit (KPI)

WITH customer_profit AS (
  SELECT
    `Customer ID` AS customer_id,
    SUM(`Gross Profit`) AS customer_profit
  FROM wonka_choc_factory_1
  WHERE `Customer ID` IS NOT NULL
  GROUP BY `Customer ID`
),
ranked AS (
  SELECT
    customer_profit,
    ROW_NUMBER() OVER (ORDER BY customer_profit DESC) AS rn,
    COUNT(*) OVER () AS total_customers
  FROM customer_profit
),
top_group AS (
  SELECT *
  FROM ranked
  WHERE rn <= CEIL(total_customers * 0.20)   -- change 0.20 to 0.10, 0.30, etc.
)
SELECT
  ROUND(100 * SUM(customer_profit) / (SELECT SUM(customer_profit) FROM ranked), 2)
    AS profit_share_percent_top_20;

### How many customers needed to reach 80% profit?

WITH customer_profit AS (
  SELECT
    `Customer ID` AS customer_id,
    SUM(`Gross Profit`) AS customer_profit
  FROM wonka_choc_factory_1
  WHERE `Customer ID` IS NOT NULL
  GROUP BY `Customer ID`
),
ranked AS (
  SELECT
    customer_id,
    customer_profit,
    ROW_NUMBER() OVER (ORDER BY customer_profit DESC) AS rn,
    COUNT(*) OVER () AS total_customers,
    SUM(customer_profit) OVER (ORDER BY customer_profit DESC)
      / SUM(customer_profit) OVER () AS cum_profit_pct
  FROM customer_profit
)
SELECT
  MIN(rn) AS customers_needed_for_80pct_profit,
  MAX(total_customers) AS total_customers,
  ROUND(100 * MIN(rn) / MAX(total_customers), 2) AS percent_of_customers_needed
FROM ranked
WHERE cum_profit_pct >= 0.80;

###Profit contribution per customer (top 50 list)

WITH customer_profit AS (
  SELECT
    `Customer ID` AS customer_id,
    SUM(`Gross Profit`) AS customer_profit
  FROM wonka_choc_factory_1
  WHERE `Customer ID` IS NOT NULL
  GROUP BY `Customer ID`
),
ranked AS (
  SELECT
    customer_id,
    customer_profit,
    customer_profit / SUM(customer_profit) OVER () AS profit_pct,
    SUM(customer_profit) OVER (ORDER BY customer_profit DESC)
      / SUM(customer_profit) OVER () AS cum_profit_pct
  FROM customer_profit
)
SELECT
  customer_id,
  ROUND(customer_profit, 2) AS customer_profit,
  ROUND(100 * profit_pct, 4) AS profit_contribution_percent,
  ROUND(100 * cum_profit_pct, 2) AS cumulative_profit_percent
FROM ranked
ORDER BY customer_profit DESC
LIMIT 50;


### Add Sales: Profit Margin by customer (Top 20)

WITH customer_sales_profit AS (
  SELECT
    `Customer ID` AS customer_id,
    SUM(`Sales`) AS total_sales,
    SUM(`Gross Profit`) AS total_profit
  FROM wonka_choc_factory_1
  WHERE `Customer ID` IS NOT NULL
  GROUP BY `Customer ID`
)
SELECT
  customer_id,
  ROUND(total_sales, 2) AS total_sales,
  ROUND(total_profit, 2) AS total_profit,
  ROUND(100 * total_profit / NULLIF(total_sales, 0), 2) AS profit_margin_percent
FROM customer_sales_profit
ORDER BY total_profit DESC
LIMIT 20;
