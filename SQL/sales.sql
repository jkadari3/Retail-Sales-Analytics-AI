/* Create the sales table with a composite primary key. */

CREATE TABLE sales (
    order_number INTEGER,
    line_item INTEGER,
    order_date DATE,
    delivery_date DATE,
    customer_key INTEGER,
    store_key INTEGER,
    product_key INTEGER,
    quantity INTEGER,
    currency_code VARCHAR(3),

    PRIMARY KEY (order_number, line_item)
);

/* Preview the sales table structure and records.*/

SELECT *
FROM sales
LIMIT 5;

/* Verify the total number of imported sales records. */

SELECT COUNT(*) AS total_sales_records
FROM sales;

/* Identify duplicate order_number and line_item combinations.*/

SELECT
    order_number,
    line_item,
    COUNT(*) AS duplicate_count
FROM sales
GROUP BY order_number, line_item
HAVING COUNT(*) > 1;


/* Check the number of sales records with missing delivery dates.*/

SELECT
    COUNT(*) AS total_sales,
    COUNT(*) FILTER (WHERE delivery_date is NULL) AS missing_date
FROM sales;

/* Identify sales records with zero, negative, or missing quantities.*/

SELECT
    order_number,
    line_item,
    product_key,
    quantity
FROM sales
WHERE quantity <= 0 OR quantity IS NULL;

/* Identify sales records without a matching customer.*/

SELECT
    s.order_number,
    s.line_item,
    s.customer_key
FROM sales s
LEFT JOIN customers c
    ON s.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

/* Identify sales records without a matching product.*/

SELECT
    s.order_number,
    s.line_item,
    s.product_key
FROM sales s
LEFT JOIN products p
    ON s.product_key = p.product_key
WHERE p.product_key IS NULL;






















