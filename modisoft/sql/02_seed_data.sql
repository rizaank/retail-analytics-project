-- ============================================================
-- Gas Station Analytics — Seed Data
-- Populates dimension tables with reference data
-- Run once after schema creation, before loading fact tables
-- ============================================================

USE GasStationAnalytics;

-- ------------------------------------------------------------
-- dim_FuelType — four grades sold at this location
-- Plus is a blended grade mixed at the dispenser
-- Cash/Debit retail is the same price at this location
-- Credit retail is 10 cents per gallon higher
-- ------------------------------------------------------------
INSERT INTO dim_FuelType
    (FuelTypeName, ColorCode, CashDebitRetail, CreditRetail)
VALUES
    ('Regular', '#4DC1B4', 3.299, 3.399),
    ('Plus',    '#2978A7', 3.799, 3.899),
    ('Super',   '#F8BC2E', 4.299, 4.399),
    ('Diesel',  '#A4CF5C', 4.699, 4.799);

-- ------------------------------------------------------------
-- dim_Date — one row per calendar day for the project range
-- Used for time intelligence in Power BI
-- MAXRECURSION 800 required for ranges over 100 days
-- ------------------------------------------------------------
WITH DateSeries AS (
    SELECT CAST('2024-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM DateSeries
    WHERE d < '2026-02-28'
)
INSERT INTO dim_Date (
    DateKey, FullDate, Year, Quarter, Month,
    MonthName, Week, DayOfWeek, DayName, IsWeekend
)
SELECT
    CAST(FORMAT(d, 'yyyyMMdd') AS INT),
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    MONTH(d),
    DATENAME(MONTH, d),
    DATEPART(WEEK, d),
    DATEPART(WEEKDAY, d),
    DATENAME(WEEKDAY, d),
    CASE WHEN DATEPART(WEEKDAY, d) IN (1,7) THEN 1 ELSE 0 END
FROM DateSeries
OPTION (MAXRECURSION 800);