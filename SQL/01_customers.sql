
/* Verify total customer count and preview customer records */

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT *
FROM customers
LIMIT 10;


/* Analyze customer distribution by country */

SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC;


/* Identify duplicate customer IDs */

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

/* Check missing values in key customer attributes */

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE gender IS NULL) AS missing_gender,
    COUNT(*) FILTER (WHERE birthday IS NULL) AS missing_birthday,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_country
FROM customers;

