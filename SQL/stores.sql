/* Create the stores table with store attributes.*/

CREATE TABLE stores (
    store_key INTEGER PRIMARY KEY,
    country VARCHAR(100),
    state VARCHAR(100),
    square_meters INTEGER,
    open_date DATE
);


/* Verify the total number of imported stores.*/

select count(*) as total_stores from stores;


/* Preview imported store records */

SELECT *
FROM stores
ORDER BY store_key
LIMIT 5;


/* Identify the online sales channel.
   Store Key 0 represents online sales rather than a physical store.
   Therefore, square_meters doesn't apply to this record. */

SELECT *
FROM stores
WHERE store_key = 0;


/* Identify sales records without a matching store.*/

SELECT
    s.order_number,
    s.line_item,
    s.store_key
FROM sales s
LEFT JOIN stores st
    ON s.store_key = st.store_key
WHERE st.store_key IS NULL;

/* Analyze missing delivery dates by sales channel. */

SELECT
    CASE
        WHEN s.store_key = 0 THEN 'Online'
        ELSE 'Physical Store'
    END AS sales_channel,
    COUNT(*) AS total_sales_records,
    COUNT(*) FILTER (
        WHERE s.delivery_date IS NULL
    ) AS missing_delivery_dates,
    COUNT(*) FILTER (
        WHERE s.delivery_date IS NOT NULL
    ) AS recorded_delivery_dates
FROM sales s
GROUP BY
    CASE
        WHEN s.store_key = 0 THEN 'Online'
        ELSE 'Physical Store'
    END;