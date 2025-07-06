-- Step 3: Create view 'vw_product_performance'
-- - Summarize export trends by product category and year
-- - Analyze average unit price and volume change
-- - Identify core and emerging product categories
-- Result: View supports product portfolio strategy

/*-----------------------------------------
PRODUCT PERFORMANCE ANALYSIS
-----------------------------------------*/

/* Product performance YoY */
SELECT
    export_year,
    prd_desc,
    ROUND(SUM(export_value_usd),2) AS total_export_value_usd,
    SUM(net_wgt) AS total_weight_kg,
    ROUND(SUM(export_value_usd) / SUM(net_wgt), 2) AS avg_unit_price_usd_per_kg
FROM export_silver
GROUP BY export_year, prd_desc
ORDER BY export_year, total_export_value_usd DESC;

/* Average unit price per product */

SELECT 
  prd_desc,
  COUNT(*) AS total_records,
  ROUND(SUM(export_value_usd),2) AS total_export_value,
  ROUND(SUM(net_wgt), 2) AS total_weight_kg,
  ROUND(SUM(export_value_usd) / SUM(net_wgt), 2) AS avg_unit_price_usd_per_kg
FROM export_silver
GROUP BY prd_desc
ORDER BY avg_unit_price_usd_per_kg DESC
;

/* Average unit price per product + PER YEAR */

SELECT 
    export_year,
    prd_desc,
    COUNT(*) AS total_records,
    SUM(export_value_usd) AS total_export_value,
    SUM(net_wgt) AS total_weight_kg,
    ROUND(SUM(export_value_usd) / SUM(net_wgt), 2) AS avg_unit_price_usd_per_kg
FROM
    export_silver
GROUP BY export_year , prd_desc
ORDER BY export_year , avg_unit_price_usd_per_kg DESC;

/*-----------------------------------------
CREATING VIEW: Product Performance
-----------------------------------------*/
CREATE OR REPLACE VIEW vw_product_performance AS
    SELECT 
        export_year,
        prd_desc,
        COUNT(*) AS total_records,
        ROUND(SUM(export_value_usd), 2) AS total_export_value,
        ROUND(SUM(net_wgt), 2) AS total_weight_kg,
        ROUND(SUM(export_value_usd) / SUM(net_wgt), 2) AS avg_unit_price_usd_per_kg
    FROM
        export_silver
    GROUP BY export_year , prd_desc
    ORDER BY export_year ASC , avg_unit_price_usd_per_kg DESC;
