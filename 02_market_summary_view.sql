-- Step 2: Create view `vw_market_summary`
-- - Summarize export value, volume, and unit price by country & year
-- - Compute YoY growth in value and volume
-- - Identify high-growth or declining markets
-- Result: View supports market-level strategic insights

/*-----------------------------------------
MARKET ANALYSIS
-----------------------------------------*/

/* 
Query: Total FOB values by country and by year 

This analysis is crucial because it shows:
- Identify key markets: Countries with the highest total export value each year.
- Detect growing markets: If FOB value increases continuously year over year → the market is expanding.
- Detect declining markets: Which countries are falling in rank/negative growth.
- Propose strategic proposals: Prioritize maintaining market share in top countries, 
  promote exploration of countries with strong growth.
*/

SELECT * FROM export_silver;

SELECT 
    export_year,
    partner,
    SUM(export_value_usd) AS total_export_value_usd
FROM
    export_silver
GROUP BY export_year , partner
ORDER BY export_year , total_export_value_usd DESC
;

/* Top 5 markets by year */

SELECT *
FROM (
    SELECT 
        export_year,
        partner,
        SUM(export_value_usd) AS total_export_value_usd,
        RANK() OVER (PARTITION BY export_year ORDER BY SUM(export_value_usd) DESC) AS rn
    FROM export_silver
    GROUP BY export_year, partner
) AS ranked
WHERE rn <= 5
;

/* YoY values by partners */

SELECT 
    cur.partner,
    cur.export_year,
    cur.total_export_value_usd,
    pre.total_export_value_usd AS pre_year_value,
    ROUND(
        100.0 * (cur.total_export_value_usd - pre.total_export_value_usd) / pre.total_export_value_usd,2
    ) AS yoy_growth_pct
FROM (
    SELECT 
        export_year,
        partner,
        SUM(export_value_usd) AS total_export_value_usd
    FROM export_silver
    GROUP BY export_year, partner
) AS cur
LEFT JOIN (
    SELECT 
        export_year,
        partner,
        SUM(export_value_usd) AS total_export_value_usd
    FROM export_silver
    GROUP BY export_year, partner
) AS pre
ON cur.partner = pre.partner
AND cur.export_year = pre.export_year + 1
ORDER BY cur.export_year, cur.partner
;

/* Average unit price by country and year */

SELECT
    export_year,
    partner,
    ROUND(SUM(export_value_usd) / SUM(net_wgt), 2) AS avg_unit_price_usd_per_kg,
    ROUND(SUM(export_value_usd), 2) AS total_export_value_usd,
    ROUND(SUM(net_wgt),2) AS total_weight_kg
FROM export_silver
GROUP BY export_year, partner
ORDER BY export_year, avg_unit_price_usd_per_kg DESC;

/* Partner with highest average orders */
SELECT *
FROM (
    SELECT
        export_year,
        partner,
        ROUND(SUM(export_value_usd) / SUM(net_wgt), 2) AS avg_unit_price_usd_per_kg,
        RANK() OVER (PARTITION BY export_year ORDER BY SUM(export_value_usd) / SUM(net_wgt) DESC) AS rank_price
    FROM export_silver
    GROUP BY export_year, partner
) ranked
WHERE rank_price <= 5
ORDER BY export_year, avg_unit_price_usd_per_kg DESC;

/*-----------------------------------------
CREATING VIEW: Market Summary
-----------------------------------------*/
CREATE OR REPLACE VIEW vw_market_summary AS
WITH yearly_summary AS
(
SELECT
	export_year,
    partner,
    ROUND(SUM(export_value_usd),2) AS total_export_value_usd,
    ROUND(SUM(net_wgt),2) AS total_weight_kg,
    ROUND(SUM(export_value_usd) / SUM(net_wgt),2) AS avg_unit_price_usd_per_kg
FROM export_silver
GROUP BY export_year, partner
),

growth_calculation AS
(
    SELECT 
        cur.export_year,
        cur.partner,
        cur.total_export_value_usd,
        cur.total_weight_kg,
        cur.avg_unit_price_usd_per_kg,
        pre.total_export_value_usd AS pre_year_export_value,
        pre.total_weight_kg AS pre_year_weight,
        ROUND(
            100.0 * (cur.total_export_value_usd - pre.total_export_value_usd) / NULLIF(pre.total_export_value_usd, 0), 2) 
            AS yoy_growth_value_pct,
        ROUND(100.0 * (cur.total_weight_kg - pre.total_weight_kg) / NULLIF(pre.total_weight_kg, 0), 2) 
			AS yoy_growth_weight_pct
    FROM yearly_summary cur
    LEFT JOIN yearly_summary pre
        ON cur.partner = pre.partner 
        AND cur.export_year = pre.export_year + 1
)

SELECT *
FROM growth_calculation
ORDER BY export_year DESC, total_export_value_usd DESC;
