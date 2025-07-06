/*----------------------------------------------------------------------------
Step 4: Create view 'vw_country_product_matrix'
- Calculate the export share (%) of each product in each country
- Detect concentration risks and underrepresented categories
- Suggest product-market fit opportunities
Result: View supports tailored export strategies by country
----------------------------------------------------------------------------*/

/*-----------------------------------------
PRODUCT BY COUNTRY ANALYSIS
-----------------------------------------*/

WITH product_export_by_country AS (
  SELECT 
    partner,
    prd_desc,
    SUM(export_value_usd) AS total_export_value_usd
  FROM export_silver
  GROUP BY partner, prd_desc
),

ranked_products AS (
  SELECT *,
    RANK() OVER (PARTITION BY partner ORDER BY total_export_value_usd DESC) AS product_rank
  FROM product_export_by_country
)

SELECT 
  partner,
  prd_desc,
  total_export_value_usd
FROM ranked_products
WHERE product_rank <= 3
ORDER BY partner, product_rank;

/* Product share by countries */
CREATE OR REPLACE VIEW vw_country_product_matrix AS
WITH total_export_per_country AS (
  SELECT 
    partner,
    SUM(export_value_usd) AS total_export_value
  FROM export_silver
  GROUP BY partner
),

product_export_per_country AS (
  SELECT 
    partner,
    prd_desc,
    SUM(export_value_usd) AS product_export_value
  FROM export_silver
  GROUP BY partner, prd_desc
),

product_share AS (
  SELECT 
    p.partner,
    p.prd_desc,
    p.product_export_value,
    t.total_export_value,
    ROUND(100.0 * p.product_export_value / t.total_export_value, 2) AS product_share_pct
  FROM product_export_per_country p
  JOIN total_export_per_country t
    ON p.partner = t.partner
)

SELECT *
FROM product_share
ORDER BY partner, product_share_pct DESC;
