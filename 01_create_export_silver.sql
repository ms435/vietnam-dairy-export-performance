/*--------------------------------------------------------------------
Step 1: Clean raw export data from UN Comtrade
- Normalize partner names (e.g., CIV → Ivory Coast)
- Map HS codes to readable product categories
- Remove invalid records (zero weight/value)
- Calculate unit price per kg
Result: Cleaned table named 'export_silver'
Furthermore: Created Stored Procedure for refreshing table 'export_silver'
--------------------------------------------------------------------*/

CREATE TABLE vietnam_export (
    export_year INT,
    partner_iso VARCHAR(50),
    partner VARCHAR(50),
    hs_code VARCHAR(50),
    prd_desc VARCHAR(50),
    qtyUnitAbbr VARCHAR(50),
    qty INT,
    net_wgt DOUBLE,
    fobvalue DOUBLE
)
;

/* IMPORTANT NOTE
Since my version of MySQL kind of restricted me from importing data from my local device into the table vietnam_export, I had 
to import them through Terminal. Therefore, the importing query is not shown here.
*/

/* Checking for distinctive values to clean data */
SELECT DISTINCT partner,
partner_iso
FROM vietnam_export
ORDER BY partner;

/* CREATE AND INSERT INTO TABLE export_silver */

CREATE TABLE IF NOT EXISTS export_silver (
    export_year INT,
    partner VARCHAR(50),
    hs_code VARCHAR(50),
    prd_desc VARCHAR(100),
    net_wgt DOUBLE,
    export_value_usd DOUBLE,
    unit_price_usd_per_kg DOUBLE
);

INSERT INTO export_silver
(
	export_year,
    partner,
    hs_code,
    prd_desc,
    net_wgt,
    export_value_usd,
    unit_price_usd_per_kg
)

SELECT
	export_year,
    CASE
		WHEN partner_iso = 'CIV' THEN 'Ivory Coast'
        WHEN partner_iso = 'TUR' THEN 'Turkey'
        ELSE partner
    END AS partner,
    hs_code,
    CASE 
		WHEN hs_code = '040110' THEN 'Liquid Milk, fat content ≤1%'
        WHEN hs_code = '040120' THEN 'Liquid Milk, fat content >1% but ≤6%'
        WHEN hs_code = '040229' THEN 'Powdered Milk'
        WHEN hs_code = '040299' THEN 'Condensed Milk'
        WHEN hs_code = '220290' THEN 'Soy Milk'
        ELSE 'Beverages'
	END AS prd_desc,
    net_wgt,
    fobvalue AS export_value_usd,
    CASE
		WHEN net_wgt > 0 THEN ROUND(fobvalue/net_wgt,2)
        ELSE NULL
	END AS unit_price_usd_per_kg
FROM vietnam_export
WHERE partner != 'World' AND partner != 'Other Asia, nes'
	AND fobvalue > 0
    AND net_wgt > 0,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
;

/* CREATE export_log table */

CREATE TABLE IF NOT EXISTS export_log
(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
    refreshed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    row_counted INT,
    remarks TEXT
);

/* CREATE STORED PROCEDURE refresh_export_silver */

DELIMITER $$

CREATE PROCEDURE refresh_export_silver()
BEGIN
-- Truncate old data
	TRUNCATE TABLE export_silver;
-- Insert new data
INSERT INTO export_silver
(
	export_year,
    partner,
    hs_code,
    prd_desc,
    net_wgt,
    export_value_usd,
    unit_price_usd_per_kg
)

SELECT
	export_year,
    CASE
		WHEN partner_iso = 'CIV' THEN 'Ivory Coast'
        WHEN partner_iso = 'TUR' THEN 'Turkey'
        ELSE partner
    END AS partner,
    hs_code,
    CASE 
		WHEN hs_code = '040110' THEN 'Liquid Milk, fat content ≤1%'
        WHEN hs_code = '040120' THEN 'Liquid Milk, fat content >1% but ≤6%'
        WHEN hs_code = '040229' THEN 'Powdered Milk'
        WHEN hs_code = '040299' THEN 'Condensed Milk'
        WHEN hs_code = '220290' THEN 'Soy Milk'
        ELSE 'Beverages'
	END AS prd_desc,
    net_wgt,
    fobvalue AS export_value_usd,
    CASE
		WHEN net_wgt > 0 THEN ROUND(fobvalue/net_wgt,2)
        ELSE NULL
	END AS unit_price_usd_per_kg
FROM vietnam_export
WHERE partner != 'World' AND partner != 'Other Asia, nes'
	AND fobvalue > 0
    AND net_wgt > 0;
    
-- Log imported data
INSERT INTO export_log (row_counted, remarks)
SELECT COUNT(*), 'Silver layer refreshed'
FROM export_silver;

END $$
DELIMITER ;
