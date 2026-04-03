-- ============================================================
-- Gas Station Analytics — Fuel Analysis Queries
-- Author: Rizaan
-- Date: March 2026
-- 
-- Business context: Six analytical queries against 26 months
-- of fuel sales and profit data (Jan 2024 - Feb 2026) from a
-- gas station back office. These queries surface
-- operational and financial patterns not visible in the
-- canned reports provided by the back office.
--
-- All queries verified against source Excel exports.
-- Data quality limitations documented in
-- documentation/business_rules_and_context.md
-- ============================================================

USE GasStationAnalytics;

-- ------------------------------------------------------------
-- QUERY 1: Monthly fuel volume and revenue with 
--          year-over-year comparison
--
-- Business question: How does each fuel grade perform month
-- over month and how does this year compare to last year?
--
-- Key finding: Regular margin is essentially flat year over
-- year. Volume is the primary driver of Regular profit, not
-- pricing. Diesel shows the most YOY variance.
--
-- Results: 2024 rows show NULL for prior year column as
-- expected — data range begins Jan 2024 so no prior year
-- exists for that period.
-- ------------------------------------------------------------
WITH FuelSalesByMonth AS (
    SELECT
        MONTH(a.SaleDate)           AS SaleMonth,
        YEAR(a.SaleDate)            AS SaleYear,
        b.FuelTypeName              AS FuelType,
        SUM(a.AmountSold)           AS TotalAmountSoldCurrentMonth,
        SUM(a.GallonsSold)          AS TotalGallonsSoldCurrentMonth
    FROM fact_FuelSales a
    JOIN dim_FuelType b ON a.FuelTypeID = b.FuelTypeID
    GROUP BY b.FuelTypeName, MONTH(a.SaleDate), YEAR(a.SaleDate)
),
WithPriorYearGallons AS (
    SELECT
        *,
        LAG(TotalGallonsSoldCurrentMonth) OVER (
            PARTITION BY FuelType, SaleMonth
            ORDER BY SaleYear
        ) AS TotalGallonsSoldPreviousYear
    FROM FuelSalesByMonth
)
SELECT
    SaleYear,
    SaleMonth,
    FuelType,
    TotalGallonsSoldCurrentMonth,
    TotalAmountSoldCurrentMonth,
    TotalGallonsSoldPreviousYear,
    COALESCE(
        TotalGallonsSoldCurrentMonth - TotalGallonsSoldPreviousYear,
        0
    ) AS DifferenceInGallonsSold,
    CASE
        WHEN TotalGallonsSoldPreviousYear IS NULL THEN NULL
        WHEN TotalGallonsSoldPreviousYear = 0     THEN NULL
        ELSE (TotalGallonsSoldCurrentMonth - TotalGallonsSoldPreviousYear)
             * 100.0 / TotalGallonsSoldPreviousYear
    END AS PctChangeInGallonsSold
FROM WithPriorYearGallons
ORDER BY FuelType, SaleYear, SaleMonth;


-- ------------------------------------------------------------
-- QUERY 2: Top 5 highest volume days — Regular fuel only,
--          then all grades combined
--
-- Business question: What are our peak volume days and what
-- day of the week do they fall on?
--
-- Key finding: Thursday and Friday are consistently the
-- highest volume days across all grades, suggesting consumer
-- end-of-week fill-up behavior. Top 5 all-grade days cluster
-- in January and February, confirming winter as peak season.
--
-- Note: Regular-only top 5 and all-grades top 5 tell
-- different stories. All-grades is more operationally
-- meaningful for total business performance.
-- ------------------------------------------------------------

-- Top 5 by Regular grade only
WITH RegularFuelSales AS (
    SELECT
        a.SaleDate,
        SUM(a.GallonsSold)      AS TotalGallonsSold,
        SUM(a.AmountSold)       AS TotalRevenue,
        DATENAME(WEEKDAY, a.SaleDate) AS DayOfWeek
    FROM fact_FuelSales a
    JOIN dim_FuelType b ON a.FuelTypeID = b.FuelTypeID
    WHERE b.FuelTypeName = 'Regular'
    GROUP BY a.SaleDate
)
SELECT TOP 5
    SaleDate,
    TotalGallonsSold,
    TotalRevenue,
    DayOfWeek
FROM RegularFuelSales
ORDER BY TotalGallonsSold DESC;

-- Top 5 all grades combined
SELECT TOP 5
    fs.SaleDate,
    DATENAME(WEEKDAY, fs.SaleDate)  AS DayOfWeek,
    SUM(fs.GallonsSold)             AS TotalAllGrades,
    SUM(fs.AmountSold)              AS TotalRevenue
FROM fact_FuelSales fs
GROUP BY fs.SaleDate
ORDER BY TotalAllGrades DESC;

-- Verified results (all grades):
-- 2025-01-09  Thursday  1975.48 gallons  $7,389.73
-- 2026-01-23  Friday    1886.64 gallons  $6,430.93
-- 2026-01-22  Thursday  1873.39 gallons  $6,295.00
-- 2026-02-19  Thursday  1782.67 gallons  $6,492.22
-- 2026-02-20  Friday    1764.70 gallons  $6,442.49


-- ------------------------------------------------------------
-- QUERY 3: Average margin per gallon by grade by month
--          with year-over-year trend
--
-- Business question: Is our margin per gallon improving or
-- declining over time? Which grades are most volatile?
--
-- Key findings:
--   - Regular margin is flat — neither improving nor declining
--     meaningfully. Profit growth requires volume not pricing.
--   - Diesel is the most volatile grade. March to March swing
--     between 2024 and 2025 was the most significant variance
--     in the dataset, driven by wholesale cost fluctuations
--     tied to heating oil markets.
--   - January 2026 and August 2025 showed margin drops
--     exceeding 20% vs prior year across multiple grades.
-- ------------------------------------------------------------
WITH FuelProfitByMonth AS (
    SELECT
        b.FuelTypeName              AS FuelType,
        MONTH(a.ProfitDate)         AS ProfitMonth,
        YEAR(a.ProfitDate)          AS ProfitYear,
        AVG(a.ProfitPerGallon)      AS AvgProfitPerGallonCurr
    FROM fact_FuelProfit a
    JOIN dim_FuelType b ON b.FuelTypeID = a.FuelTypeID
    GROUP BY b.FuelTypeName, MONTH(a.ProfitDate), YEAR(a.ProfitDate)
),
WithPriorYearMargin AS (
    SELECT
        *,
        LAG(AvgProfitPerGallonCurr) OVER (
            PARTITION BY FuelType, ProfitMonth
            ORDER BY ProfitYear
        ) AS AvgProfitPerGallonPrev
    FROM FuelProfitByMonth
),
MarginTrend AS (
    SELECT
        *,
        COALESCE(
            AvgProfitPerGallonCurr - AvgProfitPerGallonPrev,
            0
        ) AS DiffInAvgProfitPerGallon,
        CASE
            WHEN AvgProfitPerGallonPrev IS NULL THEN NULL
            WHEN AvgProfitPerGallonPrev = 0     THEN NULL
            ELSE (AvgProfitPerGallonCurr - AvgProfitPerGallonPrev)
                 * 100.0 / AvgProfitPerGallonPrev
        END AS PctChangeMarginTrend
    FROM WithPriorYearMargin
)
SELECT *
FROM MarginTrend
ORDER BY FuelType, ProfitYear, ProfitMonth;


-- ------------------------------------------------------------
-- QUERY 4: Top 3 and bottom 3 months by total fuel profit
--
-- Business question: Which months generated the most and
-- least total fuel profit across all grades?
--
-- Key findings:
--   - Best month:  December 2025 — $37,646
--   - Worst month: January 2025  — $24,004
--   - Average monthly fuel profit: $29,170
--   - Gap between best and worst:  $13,642
--
--   January 2025 worst month coincides with anomalous 22%
--   drop in Plus grade volume that month. Root cause
--   undetermined but financial impact is quantified.
--
--   November 2024 bottom 3 coincides with 9 consecutive
--   zero Diesel days around Thanksgiving — possible pump
--   issue that cost real profit dollars.
-- ------------------------------------------------------------
WITH TotalProfitByMonth AS (
    SELECT
        MONTH(ProfitDate)       AS ProfitMonth,
        YEAR(ProfitDate)        AS ProfitYear,
        SUM(TotalProfit)        AS TotalProfitAllGrades,
        SUM(GallonsSold)        AS TotalGallonsSoldAllGrades
    FROM fact_FuelProfit
    GROUP BY MONTH(ProfitDate), YEAR(ProfitDate)
),
WithRank AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY TotalProfitAllGrades DESC
        ) AS ProfitRank
    FROM TotalProfitByMonth
)
SELECT *, 'Top 3'    AS Category
FROM (
    SELECT TOP 3 * FROM WithRank ORDER BY ProfitRank ASC
) TopResults
UNION ALL
SELECT *, 'Bottom 3' AS Category
FROM (
    SELECT TOP 3 * FROM WithRank ORDER BY ProfitRank DESC
) BottomResults
ORDER BY TotalProfitAllGrades DESC;

-- Verified results:
-- Top 3:
--   December 2025  $37,646  38,604 gallons
--   August 2024    $35,339  37,886 gallons
--   June 2024      $33,228  36,213 gallons
-- Bottom 3:
--   January 2025   $24,004  32,666 gallons
--   February 2024  $24,448  34,557 gallons
--   November 2024  $24,649  32,895 gallons


-- ------------------------------------------------------------
-- QUERY 5: Daily average, min, max, and standard deviation
--          by fuel grade
--
-- Business question: How consistent is daily volume for each
-- grade? Which grades are predictable vs volatile?
--
-- Key findings:
--   - Regular avg 752 gallons/day, StdDev 148 (20% CV)
--     — highly predictable, good for delivery scheduling
--   - Diesel avg 57 gallons/day, StdDev 45 (79% CV)
--     — highly volatile, requires larger buffer inventory
--     relative to average daily volume
--   - All grades show minimum of 0 — see data quality notes
-- ------------------------------------------------------------
SELECT
    ft.FuelTypeName,
    AVG(fs.GallonsSold)     AS AvgDailyGallons,
    MIN(fs.GallonsSold)     AS MinDailyGallons,
    MAX(fs.GallonsSold)     AS MaxDailyGallons,
    STDEV(fs.GallonsSold)   AS StdDevGallons
FROM fact_FuelSales fs
JOIN dim_FuelType ft ON ft.FuelTypeID = fs.FuelTypeID
GROUP BY ft.FuelTypeName
ORDER BY AvgDailyGallons DESC;

-- Verified results:
-- Regular  avg 752.79  min 0  max 1300.58  stdev 148.41
-- Super    avg 257.14  min 0  max 567.58   stdev 75.85
-- Plus     avg 117.91  min 0  max 238.24   stdev 41.75
-- Diesel   avg  56.88  min 0  max 248.78   stdev 44.99


-- ------------------------------------------------------------
-- QUERY 6: Zero gallon days investigation
--
-- Business question: Are there days with no fuel sales and
-- what explains them?
--
-- Key findings:
--   - 51 Diesel zero days — mostly Sundays and Saturdays,
--     consistent with no commercial traffic on weekends.
--     Legitimate zero-sale days not missing data.
--   - Exception: Nov 20-29 2024 shows 9 consecutive Diesel
--     zero days including weekdays. Tank issue.
--   - January 25 2026 shows ALL grades at zero. Station
--     interior was closed due to ice storm. Fuel pumps were
--     operational but no sales recorded — likely a
--     data import failure.
-- ------------------------------------------------------------
SELECT
    fs.SaleDate,
    DATENAME(WEEKDAY, fs.SaleDate)  AS DayOfWeek,
    ft.FuelTypeName,
    fs.GallonsSold
FROM fact_FuelSales fs
JOIN dim_FuelType ft ON ft.FuelTypeID = fs.FuelTypeID
WHERE fs.GallonsSold = 0
ORDER BY ft.FuelTypeName, fs.SaleDate;