-- ============================================================
-- Gas Station Analytics — Data Load Verification
-- Run after initial data load to confirm counts and totals
-- match source Excel files from Modisoft
-- ============================================================

USE GasStationAnalytics;

-- ------------------------------------------------------------
-- Table row counts
-- Expected results after full load:
--   dim_FuelType:         4 rows
--   dim_Date:           790 rows
--   fact_FuelSales:    3160 rows
--   fact_FuelProfit:   3160 rows
--   fact_FuelReconcile:3160 rows
--   fact_FuelPaymentMix:  4 rows
-- ------------------------------------------------------------
SELECT 'dim_FuelType'        AS TableName, COUNT(*) AS RecordCount
FROM dim_FuelType
UNION ALL
SELECT 'dim_Date',            COUNT(*) FROM dim_Date
UNION ALL
SELECT 'fact_FuelSales',      COUNT(*) FROM fact_FuelSales
UNION ALL
SELECT 'fact_FuelProfit',     COUNT(*) FROM fact_FuelProfit
UNION ALL
SELECT 'fact_FuelReconcile',  COUNT(*) FROM fact_FuelReconcile
UNION ALL
SELECT 'fact_FuelPaymentMix', COUNT(*) FROM fact_FuelPaymentMix
ORDER BY TableName;

-- ------------------------------------------------------------
-- Total gallons and revenue by fuel type
-- Verified against Fuel-FuelAnalytics source file
-- Expected:
--   Regular:  594,705 gallons   $2,066,529
--   Super:    203,143 gallons     $907,797
--   Plus:      93,147 gallons     $370,286
--   Diesel:    44,932 gallons     $211,730
-- ------------------------------------------------------------
SELECT
    ft.FuelTypeName,
    SUM(fs.GallonsSold)  AS TotalGallons,
    SUM(fs.AmountSold)   AS TotalRevenue
FROM fact_FuelSales fs
JOIN dim_FuelType ft ON ft.FuelTypeID = fs.FuelTypeID
GROUP BY ft.FuelTypeName
ORDER BY TotalGallons DESC;

-- ------------------------------------------------------------
-- Date range and coverage check
-- Expected: 2024-01-01 through 2026-02-28, 790 unique days
-- ------------------------------------------------------------
SELECT
    MIN(SaleDate) AS EarliestDate,
    MAX(SaleDate) AS LatestDate,
    COUNT(DISTINCT SaleDate) AS UniqueDays
FROM fact_FuelSales;