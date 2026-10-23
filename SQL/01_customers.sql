/*SELECT
    current_database(),
    current_user,
    version();*/

/*Check customer distribution by country*/
SELECT COUNT(*) AS total_customers
FROM customers;	
SELECT *
FROM customers
LIMIT 10;
/*Check for duplicate customer IDs*/
SELECT country, COUNT(*) AS total_customers FROM customers
GROUP BY country
ORDER BY total_customers DESC;
/*3. Check missing values*/
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
	