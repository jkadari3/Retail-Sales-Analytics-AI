/* Create the products table with appropriate data types */

CREATE TABLE products (
    product_key INTEGER PRIMARY KEY,
    product_name VARCHAR(255),
    brand VARCHAR(100),
    color VARCHAR(50),
    unit_cost_usd NUMERIC(12,2),
    unit_price_usd NUMERIC(12,2),
    subcategory_key VARCHAR(10),
    subcategory VARCHAR(100),
    category_key VARCHAR(10),
    category VARCHAR(100)
);

SELECT *
FROM products
LIMIT 5;

/* Create a staging table to import raw product prices stored as text, including currency symbols.*/

CREATE TABLE products_staging (
    product_key TEXT,
    product_name TEXT,
    brand TEXT,
    color TEXT,
    unit_cost_usd TEXT,
    unit_price_usd TEXT,
    subcategory_key TEXT,
    subcategory TEXT,
    category_key TEXT,
    category TEXT
);


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


/* Verify the number of imported staging records. */

SELECT COUNT(*) AS total_products
FROM products_staging;

/* Original product data, including the dollar signs in the price columns. */

SELECT *
FROM products_staging
LIMIT 5;

/* Inspect the raw prices */

SELECT
    product_key,
    product_name,
    unit_cost_usd,
    unit_price_usd
FROM products_staging
LIMIT 5;

/* Preview conversion of price fields from text to numeric.*/
/* This query only previews the transformation. It does not modify either table.*/

SELECT
    product_key,
    product_name,
    unit_cost_usd AS original_cost,

    TRIM(
        REPLACE(
            REPLACE(unit_cost_usd, '$', ''),
            ',', ''
        )
    )::NUMERIC(12,2) AS cleaned_cost,

    unit_price_usd AS original_price,

    TRIM(
        REPLACE(
            REPLACE(unit_price_usd, '$', ''),
            ',', ''
        )
    )::NUMERIC(12,2) AS cleaned_price

FROM products_staging
LIMIT 5;

/*Verify that the destination table is empty before loading. */

SELECT COUNT(*) AS total_products
FROM products;

/* Load cleaned product records from the staging table.
   Skip existing product keys to prevent duplicate inserts. */

INSERT INTO products (
    product_key,
    product_name,
    brand,
    color,
    unit_cost_usd,
    unit_price_usd,
    subcategory_key,
    subcategory,
    category_key,
    category
)
SELECT
    product_key::INTEGER,
    product_name,
    brand,
    color,

    TRIM(
        REPLACE(
            REPLACE(unit_cost_usd, '$', ''),
            ',', ''
        )
    )::NUMERIC(12,2),

    TRIM(
        REPLACE(
            REPLACE(unit_price_usd, '$', ''),
            ',', ''
        )
    )::NUMERIC(12,2),

    subcategory_key,
    subcategory,
    category_key,
    category

FROM products_staging
ON CONFLICT (product_key) DO NOTHING;

/* Validate the number of records loaded into the products table. */

SELECT COUNT(*) AS total_products
FROM products;

/* Verify that product prices are stored as numeric values. */

SELECT
    product_key,
    product_name,
    unit_cost_usd,
    unit_price_usd
FROM products
LIMIT 5;

/* Identify products with selling prices below unit cost.*/

SELECT
    product_name,
	unit_cost_usd,
	unit_price_usd
FROM products
WHERE unit_price_usd < unit_cost_usd;

/* Check total records and missing cost or price values using conditional aggregation.*/

SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE unit_cost_usd IS NULL) AS missing_cost,
    COUNT(*) FILTER (WHERE unit_price_usd IS NULL) AS missing_price
FROM products;

