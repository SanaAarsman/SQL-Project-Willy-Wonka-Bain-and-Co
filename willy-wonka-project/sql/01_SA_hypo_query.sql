USE wonka_factory;

SELECT
    region_totals.countryregion,
    region_totals.region,
    region_totals.total_sales,
    region_totals.total_gross_profit,
    region_totals.profit_percentage,
    region_totals.sales_rank,
    region_totals.profit_percentage_rank
FROM (
    SELECT
        customers.countryregion AS countryregion,
        customers.region AS region,

        ROUND(SUM(sales.sales), 2) AS total_sales,
        ROUND(SUM(sales.gross_profit), 2) AS total_gross_profit,
        ROUND(
            (SUM(sales.gross_profit) / SUM(sales.sales)) * 100,
            2
        ) AS profit_percentage,

        DENSE_RANK() OVER (
            ORDER BY SUM(sales.sales) DESC
        ) AS sales_rank,

        DENSE_RANK() OVER (
            ORDER BY (SUM(sales.gross_profit) / SUM(sales.sales)) DESC
        ) AS profit_percentage_rank

    FROM sales
    JOIN orders
        ON sales.order_id = orders.order_id
    JOIN customers
        ON orders.customer_id = customers.customer_id
    GROUP BY
        customers.countryregion,
        customers.region
) AS region_totals
ORDER BY region_totals.total_sales DESC;