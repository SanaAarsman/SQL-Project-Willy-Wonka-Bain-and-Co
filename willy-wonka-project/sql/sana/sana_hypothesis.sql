USE wonka_factory;

-- Hypothesis
-- Customer location is associated with order size, where certain locations show significantly
-- 		higher average order values and units purchased, indicating bulk-purchasing behavior.

SELECT
    factories.factory,
    COUNT(DISTINCT sales.order_id) AS number_of_orders,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_sales,
    SUM(sales.gross_profit) AS total_gross_profit,
    (SUM(sales.gross_profit) / SUM(sales.sales)) * 100 AS profit_percentage,
    AVG(sales.sales) AS average_sales_per_line
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
GROUP BY factories.factory
ORDER BY total_sales DESC;
-- Lot's O' Nuts has most profit % (69%) and most sales (76.340)
-- then Wicked Choccy's hast 2 most profit % (65) and 2 most sales (55.352)

-- Factory performance by location
SELECT
    factories.factory,
    customers.countryregion,
    customers.region,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_revenue,
    SUM(sales.cost) AS total_cost,
    SUM(sales.gross_profit) AS total_gross_profit,
    (SUM(sales.gross_profit) / SUM(sales.sales)) * 100 AS profit_percentage
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
JOIN orders
    ON sales.order_id = orders.order_id
JOIN customers
    ON orders.customer_id = customers.customer_id
GROUP BY
    factories.factory,
    customers.countryregion,
    customers.region
ORDER BY
    factories.factory,
    total_gross_profit DESC;

--
SELECT
    customers.countryregion,
    customers.region,
    customers.city,
    AVG(order_summary.total_order_sales) AS average_order_value,
    AVG(order_summary.total_order_units) AS average_units_per_order,
    COUNT(order_summary.order_id) AS number_of_orders
FROM (
    SELECT
        sales.order_id,
        orders.customer_id,
        SUM(sales.sales) AS total_order_sales,
        SUM(sales.units) AS total_order_units
    FROM sales
    JOIN orders
        ON sales.order_id = orders.order_id
    GROUP BY
        sales.order_id,
        orders.customer_id
) AS order_summary
JOIN customers
    ON order_summary.customer_id = customers.customer_id
GROUP BY
    customers.countryregion,
    customers.region,
    customers.city
ORDER BY
    average_order_value DESC;


-- Bulk percentage per region
SELECT
    customers.countryregion,
    customers.region,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_summary.total_order_units >= 20 THEN 1
            ELSE 0
        END
    ) AS bulk_orders,
    SUM(
        CASE
            WHEN order_summary.total_order_units < 20 THEN 1
            ELSE 0
        END
    ) AS small_orders,
    (SUM(
        CASE
            WHEN order_summary.total_order_units >= 20 THEN 1
            ELSE 0
        END
    ) / COUNT(*)) * 100 AS bulk_order_percentage,
    (SUM(
        CASE
            WHEN order_summary.total_order_units < 20 THEN 1
            ELSE 0
        END
    ) / COUNT(*)) * 100 AS small_order_percentage
FROM (
    SELECT
        sales.order_id,
        orders.customer_id,
        SUM(sales.units) AS total_order_units
    FROM sales
    JOIN orders
        ON sales.order_id = orders.order_id
    GROUP BY
        sales.order_id,
        orders.customer_id
) AS order_summary
JOIN customers
    ON order_summary.customer_id = customers.customer_id
GROUP BY
    customers.countryregion,
    customers.region
ORDER BY bulk_order_percentage DESC;
-- outcome percentage small order:
-- United States,	Interior 	= 	95.3%
-- United States,	Atlantic 	= 	94.8%
-- United States,	Gulf 		= 	94.4%
-- United States,	Pacific		=	94.0%
-- Canada, 			Atlantic	= 	88.9%
-- Canada,			Pacific 	= 	77.8%




-- Sub Hypothesis
-- Orders involving products from the Secret Factory have higher average sales values and
-- 		higher unit counts than orders involving other factories.

-- Looking at highest sales and which factory
SELECT
    sales.order_id,
    factories.factory,
    sales.product_id,
    sales.units,
    sales.sales
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
ORDER BY sales.sales DESC;
-- All highest sales are from the Secret factory, product id: PROD0007

-- Sales overview grouped by factory
SELECT
    factories.factory,
    COUNT(DISTINCT sales.order_id) AS number_of_orders,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_sales,
    AVG(sales.sales) AS average_sales_amount
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
GROUP BY factories.factory
ORDER BY total_sales DESC;

-- Max single sale and avg units per factory
SELECT
    factories.factory,
    MAX(sales.sales) AS maximum_single_sale,
    AVG(sales.units) AS average_units_amount
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
GROUP BY factories.factory
ORDER BY maximum_single_sale DESC;

-- Each sales row + factory
SELECT
    sales.order_id,
    factories.factory,
    sales.product_id,
    sales.units,
    sales.sales
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
ORDER BY sales.sales DESC;

-- Totals per factory
SELECT
    factories.factory,
    COUNT(DISTINCT sales.order_id) AS number_of_orders,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_sales,
    AVG(sales.sales) AS average_sales_per_line
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
GROUP BY factories.factory
ORDER BY total_sales DESC;
-- Lot's O' Nuts (76240) and Wicked Choccy's (55352) have most sales 




-- Secret factory products
SELECT
    products.product_id,
    products.product_name
FROM products
JOIN factories
    ON products.factory_id = factories.factory_id
WHERE factories.factory = 'Secret Factory'
ORDER BY products.product_id;
-- only 3 products

-- Secret factory:
SELECT
    products.product_id,
    products.product_name,
    AVG(sales.cost) AS average_cost,
    MIN(sales.cost) AS minimum_cost,
    MAX(sales.cost) AS maximum_cost
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
WHERE factories.factory = 'Secret Factory'
GROUP BY products.product_id, products.product_name
ORDER BY products.product_id;

-- Secret factory: Looking at all money related to the products
SELECT
    products.product_id,
    products.product_name,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_revenue,
    SUM(sales.cost) AS total_cost,
    SUM(sales.gross_profit) AS total_gross_profit,

    -- per-unit metrics
    SUM(sales.sales) / SUM(sales.units) AS revenue_per_unit,
    SUM(sales.cost) / SUM(sales.units) AS cost_per_unit,
    SUM(sales.gross_profit) / SUM(sales.units) AS profit_per_unit,

    -- profit margin per unit (%)
    (SUM(sales.gross_profit) / SUM(sales.sales)) * 100 AS profit_percentage_per_unit

FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
WHERE factories.factory = 'Secret Factory'
GROUP BY products.product_id, products.product_name
ORDER BY profit_percentage_per_unit DESC;
-- Everlasting Gobstopper makes most profit --> more promotion?
-- Everlasting Gobstopper sell the least
-- Wonka Gum sells best but makes the least profit per unit
-- Lickable Wallpaper sells fine, profit is fine. Makes for the biggest sales


-- Secret factory: money and location
SELECT
    customers.countryregion,
    customers.region,
    customers.city,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_revenue,
    SUM(sales.cost) AS total_cost,
    SUM(sales.gross_profit) AS total_gross_profit,
    (SUM(sales.gross_profit) / SUM(sales.sales)) * 100 AS profit_percentage
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
JOIN orders
    ON sales.order_id = orders.order_id
JOIN customers
    ON orders.customer_id = customers.customer_id
WHERE  factories.factory = 'Secret Factory'
GROUP BY
    customers.countryregion,
    customers.region,
    customers.city
ORDER BY total_gross_profit DESC;
-- 2 highest sales (760,780) are both from US Atlantic (New York city, Philadelphia). +- 90 unit. BUT +- 50% profit
-- 2 highest profit (80%)

-- Secret factory: location, product, all sales/money info
SELECT
    customers.countryregion,
    customers.region,
    customers.city,
    products.product_id,
    SUM(sales.units) AS total_units_sold,
    SUM(sales.sales) AS total_revenue,
    SUM(sales.cost) AS total_cost,
    SUM(sales.gross_profit) AS total_gross_profit,
    (SUM(sales.gross_profit) / SUM(sales.sales)) * 100 AS profit_percentage
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
JOIN orders
    ON sales.order_id = orders.order_id
JOIN customers
    ON orders.customer_id = customers.customer_id
WHERE factories.factory = 'Secret Factory'
GROUP BY
    customers.countryregion,
    customers.region,
    customers.city,
    products.product_id
ORDER BY total_gross_profit DESC;
-- atlantic sells the most units (when not filtering on city)
-- canada sells the least units (when not filtering on city)
-- most profit comes from the Gulf








-- Extra thoughts:
-- High volume sales does not mean most profit. on the contuary.


-- Next steps:
-- 1. promote Everlasting Gobstopper makes most profit
-- 1.2 (do not put to much money in Everlasting Gobstopper) because, they are ever lasting. sales will go up and then drop. 
-- 1.3 Lickable Wallpaper gives most sales. 50% profit. But, people will buy again, when they've licked it all up. 


-- Certain factories dominate in specific regions
SELECT
    factories.factory,
    customers.countryregion,
    customers.region,
    SUM(sales.sales) AS total_revenue,
    SUM(sales.gross_profit) AS total_gross_profit
FROM sales
JOIN products
    ON sales.product_id = products.product_id
JOIN factories
    ON products.factory_id = factories.factory_id
JOIN orders
    ON sales.order_id = orders.order_id
JOIN customers
    ON orders.customer_id = customers.customer_id
GROUP BY
    factories.factory,
    customers.countryregion,
    customers.region
ORDER BY
    factories.factory,
    total_revenue DESC;
-- shows where te factories get there order from and how much.

-- Customer location is associated with order size, where certain locations show significantly higher bulk-purchasing behavior.
SELECT
    customers.countryregion,
    customers.region,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_summary.total_order_units >= 15 THEN 1 ELSE 0 END) AS bulk_orders,
    SUM(CASE WHEN order_summary.total_order_units < 15 THEN 1 ELSE 0 END) AS small_orders,
    (SUM(CASE WHEN order_summary.total_order_units >= 15 THEN 1 ELSE 0 END) / COUNT(*)) * 100
        AS bulk_order_percentage,
    (SUM(CASE WHEN order_summary.total_order_units < 15 THEN 1 ELSE 0 END) / COUNT(*)) * 100
        AS small_order_percentage
FROM (
    SELECT
        sales.order_id,
        orders.customer_id,
        SUM(sales.units) AS total_order_units
    FROM sales
    JOIN orders
        ON sales.order_id = orders.order_id
    GROUP BY
        sales.order_id,
        orders.customer_id
) AS order_summary
JOIN customers
    ON order_summary.customer_id = customers.customer_id
GROUP BY
    customers.countryregion,
    customers.region
ORDER BY small_order_percentage DESC;
-- U.S. regions are dominated by small, individual purchases
-- Canadian regions—especially Pacific Canada—have a higher proportion of bulk orders



