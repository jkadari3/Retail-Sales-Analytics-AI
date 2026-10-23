/*Creating Sales Table*/

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

/* verify the table*/
SELECT *
FROM sales
LIMIT 5;

/*Verify the import in pgAdmin*/
SELECT COUNT(*) AS total_sales_records
FROM sales;

/*Duplicate sales records: Every combination of order_number and line_item should be unique.*/
SELECT
    order_number,
    line_item,
    COUNT(*) AS duplicate_count
FROM sales
GROUP BY order_number, line_item
HAVING COUNT(*) > 1;


/*Retail Analytics Sales Validation — Missing Delivery Dates.*/
SELECT
    COUNT(*) AS total_sales,
    COUNT(*) FILTER (WHERE delivery_date is NULL) AS missing_date
FROM sales;

/*identify records where:
- quantity is zero.
- quantity is negative.
- quantity is NULL.*/

SELECT
    order_number,
    line_item,
    product_key,
    quantity
FROM sales
WHERE quantity <= 0 OR quantity IS NULL;

/*Customer Relationship Validation*/

SELECT
    s.order_number,
    s.line_item,
    s.customer_key
FROM sales s
LEFT JOIN customers c
    ON s.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

/*Product Relationship Validation*/

SELECT
    s.order_number,
    s.line_item,
    s.product_key
FROM sales s
LEFT JOIN products p
    ON s.product_key = p.product_key
WHERE p.product_key IS NULL;






















