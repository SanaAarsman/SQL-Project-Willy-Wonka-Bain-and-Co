WITH customer_profit AS (
    SELECT
        customer_id,
        SUM(gross_profit) AS total_gross_profit
    FROM raw_wonka
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_gross_profit,
        RANK() OVER (ORDER BY total_gross_profit DESC) AS profit_rank,
        SUM(total_gross_profit) OVER () AS company_total_profit,
        SUM(total_gross_profit) OVER (
            ORDER BY total_gross_profit DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_profit
    FROM customer_profit
)
SELECT
    customer_id,
    total_gross_profit,
    profit_rank,
    total_gross_profit / company_total_profit AS customer_profit_pct,
    cumulative_profit / company_total_profit AS cumulative_profit_pct
FROM ranked_customers
ORDER BY profit_rank;

