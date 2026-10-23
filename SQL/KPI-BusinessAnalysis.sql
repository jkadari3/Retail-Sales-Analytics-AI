/*First Business KPI — Total Revenue
we're moving from data preparation into actual business analysis.
Business qn: How much total sales revenue did the retailer generate across all recorded transactions?*/

/* s.quantity * p.unit_price_usd	Revenue for one sales line
SUM(s.quantity)	Total units sold
SUM(s.quantity * p.unit_price_usd)	Total sales revenue*/

SELECT
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd
FROM sales s
JOIN products p
    ON s.product_key = p.product_key;
	

/*Calculate Total Cost and Gross Profit.

how much the products cost the retailer and how much gross profit they generated.

Revenue = Quantity × Selling Price
Cost = Quantity × Unit Cost
Gross Profit = Revenue − Cost
ex: if a product sells for $200 and costs $120, the gross profit per unit is $80*/

SELECT
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    ROUND(SUM(s.quantity * p.unit_cost_usd), 2) AS total_cost_usd,
    ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd
FROM sales s
JOIN products p
    ON s.product_key = p.product_key;
	
/* Gross Profit Margin % */

SELECT 
    ROUND(
        (SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd))
        / SUM(s.quantity * p.unit_price_usd)) * 100,
        2
    ) AS gross_profit_margin
FROM sales s
JOIN products p
    ON s.product_key = p.product_key;


/*Which product categories generate the most revenue and gross profit?
category | total_revenue_usd | gross_profit_usd */

SELECT 
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd
FROM sales s
JOIN products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue_usd DESC;

/*Which categories have the strongest margins?*/

SELECT 
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd,
	ROUND(
        (SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd))
        / SUM(s.quantity * p.unit_price_usd)) * 100,
        2
    ) AS gross_profit_margin
FROM sales s
JOIN products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY gross_profit_margin DESC;

/*Which products generate the most revenue? top 10
product_name | category | total_revenue_usd*/

SELECT p.product_name,
       p.category,
	   ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd
FROM sales s
JOIN products p
     ON s.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY total_revenue_usd DESC LIMIT 10;

/*product_name | category | total_revenue_usd | gross_profit_usd

Req: group at the product level, round the financial values to 2 decimals, 
and return the Top 10 by gross profit, highest first.*/

SELECT p.product_name,
       p.category,
	   ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
	   ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd
FROM sales s
JOIN products p
     ON s.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY gross_profit_usd DESC LIMIT 10;


SELECT p.product_name,
       p.category,
	   ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
	   ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd
FROM sales s
JOIN products p
     ON s.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY gross_profit_usd ASC LIMIT 10;


SELECT p.product_name,
       p.category,
       SUM(s.quantity) AS units_sold
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY units_sold DESC LIMIT 10;

/*Write a query that returns: total_revenue_usd|total_orders|average_order_value 
AOV = Total Revenue ÷ Distinct Number of Orders */

SELECT ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
COUNT (DISTINCT s.order_number) as total_orders,
ROUND(
    SUM(s.quantity * p.unit_price_usd)
    / COUNT(DISTINCT s.order_number),
    2
) AS AOV
FROM sales s JOIN products p
ON s.product_key = p.product_key;


/*Average Selling Price (ASP)->ASP = Revenue ÷ Units Sold*/
/*AOV asks:  How much revenue do we generate per order?
ASP asks:  How much revenue do we generate per unit sold?*/

SELECT
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    SUM(s.quantity) AS total_units_sold,
    ROUND(
        SUM(s.quantity * p.unit_price_usd) / SUM(s.quantity),
        2
    ) AS average_selling_price
FROM sales s
JOIN products p
    ON s.product_key = p.product_key;

/*How has revenue changed by year?
year | total_revenue_usd
EXTRACT(YEAR FROM s.order_date)->EXTRACT, SUM, GROUP BY, and ORDER BY year.*/

SELECT 
    EXTRACT(YEAR FROM s.order_date) AS annual,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd
FROM sales s
JOIN products p
    ON s.product_key = p.product_key
GROUP BY annual
ORDER BY annual;


/*What period does our sales data actually cover?*/

SELECT MIN(s.order_date) as first_order_date ,
MAX(s.order_date) as last_order_date
FROM sales s


/*YoY growth step by step*/
WITH annual_sales AS (
    SELECT
        EXTRACT(YEAR FROM s.order_date) AS annual,
        SUM(s.quantity * p.unit_price_usd) AS total_revenue_usd
    FROM sales s
    JOIN products p
        ON s.product_key = p.product_key
    GROUP BY annual
)
SELECT
    annual,
    ROUND(total_revenue_usd, 2) AS total_revenue_usd,
    ROUND(
        LAG(total_revenue_usd) OVER (ORDER BY annual),
        2
    ) AS previous_year_revenue
FROM annual_sales
ORDER BY annual;


/*YoY Revenue Growth %*/
WITH annual_sales AS (
    SELECT
        EXTRACT(YEAR FROM s.order_date) AS annual,
        SUM(s.quantity * p.unit_price_usd) AS total_revenue_usd
    FROM sales s
    JOIN products p
        ON s.product_key = p.product_key
    GROUP BY annual
)
SELECT
    annual,
    ROUND(total_revenue_usd, 2) AS total_revenue_usd,

    ROUND(
        LAG(total_revenue_usd) OVER (ORDER BY annual),
        2
    ) AS previous_year_revenue,

    ROUND(
        (
            total_revenue_usd -
            LAG(total_revenue_usd) OVER (ORDER BY annual)
        )
        /
        LAG(total_revenue_usd) OVER (ORDER BY annual)
        * 100,
        2
    ) AS yoy_growth_pct

FROM annual_sales
ORDER BY annual;


/*YTD comparison: Jan 1–Feb 20, 2020 vs Jan 1–Feb 20, 2021*/
SELECT
    EXTRACT(YEAR FROM s.order_date) AS year,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS ytd_revenue_usd
FROM sales s
JOIN products p
    ON s.product_key = p.product_key
WHERE
    s.order_date BETWEEN '2020-01-01' AND '2020-02-20'
    OR
    s.order_date BETWEEN '2021-01-01' AND '2021-02-20'
GROUP BY year
ORDER BY year;


/*How much did YTD revenue change in 2021 compared with the same period in 2020?*/
WITH ytd_sales AS (
    SELECT
        EXTRACT(YEAR FROM s.order_date) AS year,
        SUM(s.quantity * p.unit_price_usd) AS ytd_revenue_usd
    FROM sales s
    JOIN products p
        ON s.product_key = p.product_key
    WHERE
        s.order_date BETWEEN '2020-01-01' AND '2020-02-20'
        OR
        s.order_date BETWEEN '2021-01-01' AND '2021-02-20'
    GROUP BY year
)
SELECT
    year,
    ROUND(ytd_revenue_usd, 2) AS ytd_revenue_usd,
    ROUND(
        LAG(ytd_revenue_usd) OVER (ORDER BY year),
        2
    ) AS previous_year_ytd_revenue,
    ROUND(
        (
            ytd_revenue_usd -
            LAG(ytd_revenue_usd) OVER (ORDER BY year)
        )
        /
        LAG(ytd_revenue_usd) OVER (ORDER BY year)
        * 100,
        2
    ) AS ytd_growth_pct
FROM ytd_sales
ORDER BY year;

/*How did revenue change month by month?*/
SELECT
    DATE_TRUNC('month', s.order_date)::DATE AS month,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS monthly_revenue_usd
FROM sales s
JOIN products p
    ON s.product_key = p.product_key
GROUP BY month
ORDER BY month;


/*Which countries generate the most revenue and gross profit?*/
/*o/p:country | total_revenue_usd | gross_profit_usd*/
SELECT st.country, 
       ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
       ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd
FROM stores st
JOIN sales s
ON s.store_key = st.store_key
JOIN products p
ON s.product_key = p.product_key
WHERE s.store_key>0
GROUP BY st.country
ORDER BY total_revenue_usd desc;/*it shows online in output, so do below*/

/*Sales-channel wise*/
Select 
CASE
    WHEN s.store_key = 0 THEN 'Online'
    ELSE 'Physical Store'
END AS sales_channel,
ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
       ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)), 2) AS gross_profit_usd
FROM sales s
JOIN products p
ON s.product_key = p.product_key
Group by sales_channel
ORDER BY total_revenue_usd desc;



