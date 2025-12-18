 -- creating a temp table for product performance summary
CREATE TEMPORARY TABLE product_perf AS
SELECT
  p.product_id,
  p.product_name,
  SUM(s.sales) AS total_sales, -- total sales amount, per product
  SUM(s.gross_profit) AS total_profit, -- total profit from sales, per product
  SUM(s.gross_profit) / SUM(s.sales) AS profit_margin -- profit margin from sales, per product
FROM sales s
JOIN products p -- join table using keys
  ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

-- total_sales, total_profit, profit_margin calc. checked
SELECT * FROM product_perf ORDER BY total_sales DESC;

-- ranking the product by sales and profit margin
SELECT
  product_name,
  total_sales,
  total_profit,
  profit_margin,
  RANK() OVER (ORDER BY total_sales DESC) AS sales_rank, -- to assign integers for ranking, 1 for product with the highest sales value
  RANK() OVER (ORDER BY profit_margin DESC) AS margin_rank -- to assign integers for ranking, 1 for product with the highest profit margin value
FROM product_perf
ORDER BY sales_rank;