/*reate ex-rates table*/
CREATE TABLE exchange_rates (
    exchange_date DATE,
    currency_code VARCHAR(3),
    exchange_rate NUMERIC(12,6),
    PRIMARY KEY (exchange_date, currency_code)
);

/*import verification from terminal to pgAdmin*/
SELECT COUNT(*) AS total_exchange_rate_records
FROM exchange_rates;

SELECT *
FROM exchange_rates
ORDER BY exchange_date, currency_code
LIMIT 10;


/* verify the total count and check for invalid values */
SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE exchange_rate IS NULL
    ) AS missing_rates,
    COUNT(*) FILTER (
        WHERE exchange_rate <= 0
    ) AS invalid_rates
FROM exchange_rates;



/*Validate Sales-to-Exchange-Rates Relationship
query that identifies sales records without a matching exchange rate.*/
SELECT
    s.order_number,
    s.line_item,
    s.order_date,
    s.currency_code
FROM sales s
LEFT JOIN exchange_rates er
    ON s.order_date = er.exchange_date
    AND s.currency_code = er.currency_code
WHERE er.exchange_date IS NULL;







