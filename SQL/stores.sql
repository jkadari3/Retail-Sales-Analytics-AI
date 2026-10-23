/*Create the table in pgAdmin*/

CREATE TABLE stores (
    store_key INTEGER PRIMARY KEY,
    country VARCHAR(100),
    state VARCHAR(100),
    square_meters INTEGER,
    open_date DATE
);


/*total store count*/
select count(*) as total_stores from stores;


/*imported dates and columns*/
SELECT *
FROM stores
ORDER BY store_key
LIMIT 5;


/*Investigating Store Key 0
Store 0 represents the online sales channel.
Its missing square-meter value makes sense because it isn't a physical retail location.*/
SELECT *
FROM stores
WHERE store_key = 0;


/*Sales-to-Stores relationship validation
to ensure every store_key in Sales has a matching record in Stores.*/
SELECT
    s.order_number,
    s.line_item,
    s.store_key
FROM sales s
LEFT JOIN stores st
    ON s.store_key = st.store_key
WHERE st.store_key IS NULL;

/*missing delivery dates by sales channel */
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