/*Create the Product table */

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

/*Create products_staging bcz CSV contains prices like $6.62, which cannot be imported directly into the NUMERIC columns of products.*/

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


/*verify products count*/
SELECT COUNT(*) AS total_products
FROM products_staging;

/*original product data, including the dollar signs in the price columns.*/
SELECT *
FROM products_staging
LIMIT 5;

/*inspect the raw prices */
SELECT
    product_key,
    product_name,
    unit_cost_usd,
    unit_price_usd
FROM products_staging
LIMIT 5;


/* cleaned prices from Text to Numeric*/
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

/*Check the final table before inserting.output should be zero since table is empty*/

SELECT COUNT(*) AS total_products
FROM products;

/*Insert the cleaned records*/
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

FROM products_staging;

/*retest the product table , now with data, output 2517*/
SELECT COUNT(*) AS total_products
FROM products;

/*Numeric values without dollar sign in original table*/
SELECT
    product_key,
    product_name,
    unit_cost_usd,
    unit_price_usd
FROM products
LIMIT 5;

/*Find products where the selling price is lower than the cost price.for negative values*/
SELECT
    product_name,
	unit_cost_usd,
	unit_price_usd
FROM products
WHERE unit_price_usd < unit_cost_usd;

/* Using FILTER insted of where(it gives only one result)
What if we want to check total products, missing costs, and missing prices in one query?*/

SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE unit_cost_usd IS NULL) AS missing_cost,
    COUNT(*) FILTER (WHERE unit_price_usd IS NULL) AS missing_price
FROM products;

