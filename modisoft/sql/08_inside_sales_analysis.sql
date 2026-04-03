-- ============================================================
-- Gas Station Analytics — Inside Sales Analysis Queries
-- Author: Rizaan
-- Date: April 2026
--
-- Business context: Six analytical queries against 26 months
-- of inside sales data (Jan 2024 - Feb 2026) covering
-- merchandise, lottery, and vendor purchases.
-- Companion to fuel analysis queries in
-- 04_fuel_analysis.sql.
--
-- All queries verified against source exports.
-- Data quality limitations documented in
-- documentation/business_rules_and_context.md
-- ============================================================

USE GasStationAnalytics;

-- ------------------------------------------------------------
-- QUERY 1: Top departments by total net sales
--          with percentage share of inside revenue
--
-- Business question: Which departments drive inside sales
-- and how concentrated is revenue across categories?
--
-- ------------------------------------------------------------
WITH DeptTotals AS (
    SELECT
        d.DepartmentName,
        d.DepartType,
        SUM(s.Amount)       AS TotalSales
    FROM fact_DeptSales s
    JOIN dim_Department d ON d.DepartmentID = s.DepartmentID
    GROUP BY d.DepartmentName, d.DepartType

    UNION ALL

    SELECT
        d.DepartmentName,
        d.DepartType,
        SUM(l.NetSales)     AS TotalSales
    FROM fact_DeptSalesLottery l
    JOIN dim_Department d ON d.DepartmentID = l.DepartmentID
    GROUP BY d.DepartmentName, d.DepartType
),
GrandTotal AS (
    SELECT SUM(TotalSales) AS Total
    FROM DeptTotals
    WHERE TotalSales > 0    -- exclude LOTTO PAYOUT negative values from share calc
)
SELECT
    dt.DepartmentName,
    dt.DepartType,
    SUM(dt.TotalSales)                              AS TotalNetSales,
    RANK() OVER (ORDER BY SUM(dt.TotalSales) DESC)  AS RevenueRank,
    ROUND(
        SUM(dt.TotalSales) * 100.0 / gt.Total, 2
    )                                               AS PctOfInsideRevenue
FROM DeptTotals dt
CROSS JOIN GrandTotal gt
GROUP BY dt.DepartmentName, dt.DepartType, gt.Total
ORDER BY TotalNetSales DESC;


-- ------------------------------------------------------------
-- QUERY 2: Monthly inside sales trend with year over year.
--
-- Business question: Is inside revenue growing year over year?
-- Which category is driving the trend?
--
-- ------------------------------------------------------------
WITH MonthlySales AS (
    SELECT
        YEAR(s.SaleDate)            AS SaleYear,
        MONTH(s.SaleDate)           AS SaleMonth,
        DATENAME(MONTH, s.SaleDate) AS MonthName,
        d.DepartType,
        SUM(s.Amount)               AS NetSales
    FROM fact_DeptSales s
    JOIN dim_Department d ON d.DepartmentID = s.DepartmentID
    GROUP BY
        YEAR(s.SaleDate), MONTH(s.SaleDate),
        DATENAME(MONTH, s.SaleDate), d.DepartType

    UNION ALL

    SELECT
        YEAR(l.SaleDate),
        MONTH(l.SaleDate),
        DATENAME(MONTH, l.SaleDate),
        d.DepartType,
        SUM(l.NetSales)
    FROM fact_DeptSalesLottery l
    JOIN dim_Department d ON d.DepartmentID = l.DepartmentID
    GROUP BY
        YEAR(l.SaleDate), MONTH(l.SaleDate),
        DATENAME(MONTH, l.SaleDate), d.DepartType
),
MonthlyByType AS (
    SELECT
        SaleYear,
        SaleMonth,
        MonthName,
        DepartType,
        SUM(NetSales)   AS TotalNetSales
    FROM MonthlySales
    GROUP BY SaleYear, SaleMonth, MonthName, DepartType
),
WithPriorYear AS (
    SELECT
        *,
        LAG(TotalNetSales) OVER (
            PARTITION BY DepartType, SaleMonth
            ORDER BY SaleYear
        ) AS PriorYearSales
    FROM MonthlyByType
)
SELECT
    SaleYear,
    SaleMonth,
    MonthName,
    DepartType,
    TotalNetSales,
    PriorYearSales,
    COALESCE(TotalNetSales - PriorYearSales, 0)     AS YOYDollarChange,
    CASE
        WHEN PriorYearSales IS NULL THEN NULL
        WHEN PriorYearSales = 0     THEN NULL
        ELSE ROUND(
            (TotalNetSales - PriorYearSales) * 100.0 / PriorYearSales,
        2)
    END                                             AS YOYPctChange
FROM WithPriorYear
ORDER BY DepartType, SaleYear, SaleMonth;


-- ------------------------------------------------------------
-- QUERY 3: Fuel vs inside sales correlation by month
--
-- Business question: On high fuel volume months, does inside
-- revenue follow? Are pump customers converting inside?
--
-- This connects the the fuel data to the inside sales 
-- data.
-- ------------------------------------------------------------
WITH FuelMonthly AS (
    SELECT
        YEAR(SaleDate)              AS SaleYear,
        MONTH(SaleDate)             AS SaleMonth,
        DATENAME(MONTH, SaleDate)   AS MonthName,
        SUM(GallonsSold)            AS TotalGallons,
        SUM(AmountSold)             AS TotalFuelRevenue
    FROM fact_FuelSales
    GROUP BY
        YEAR(SaleDate), MONTH(SaleDate), DATENAME(MONTH, SaleDate)
),
InsideMonthly AS (
    SELECT
        YEAR(s.SaleDate)            AS SaleYear,
        MONTH(s.SaleDate)           AS SaleMonth,
        SUM(s.Amount)               AS MerchRevenue
    FROM fact_DeptSales s
    GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate)
),
LotteryMonthly AS (
    SELECT
        YEAR(l.SaleDate)            AS SaleYear,
        MONTH(l.SaleDate)           AS SaleMonth,
        SUM(l.NetSales)             AS LotteryRevenue
    FROM fact_DeptSalesLottery l
    JOIN dim_Department d ON d.DepartmentID = l.DepartmentID
    WHERE d.DepartType IN ('Lottery', 'Services')
    GROUP BY YEAR(l.SaleDate), MONTH(l.SaleDate)
)
SELECT
    f.SaleYear,
    f.SaleMonth,
    f.MonthName,
    f.TotalGallons,
    f.TotalFuelRevenue,
    i.MerchRevenue,
    COALESCE(l.LotteryRevenue, 0)               AS LotteryRevenue,
    i.MerchRevenue
        + COALESCE(l.LotteryRevenue, 0)         AS TotalInsideRevenue,
    f.TotalFuelRevenue
        + i.MerchRevenue
        + COALESCE(l.LotteryRevenue, 0)         AS TotalStoreRevenue,
    ROUND(
        (i.MerchRevenue
            + COALESCE(l.LotteryRevenue, 0))
        * 100.0
        / NULLIF(f.TotalFuelRevenue
            + i.MerchRevenue
            + COALESCE(l.LotteryRevenue, 0), 0),
    2)                                          AS InsidePctOfTotal
FROM FuelMonthly f
JOIN InsideMonthly i
    ON i.SaleYear = f.SaleYear AND i.SaleMonth = f.SaleMonth
LEFT JOIN LotteryMonthly l
    ON l.SaleYear = f.SaleYear AND l.SaleMonth = f.SaleMonth
ORDER BY f.SaleYear, f.SaleMonth;


-- ------------------------------------------------------------
-- QUERY 4: Scratch-off revenue by ticket value tier
--          with month over month trend
--
-- Business question: Which ticket value tier drives the most
-- scratch-off revenue? Are higher value tickets worth the
-- inventory investment?
--
-- ------------------------------------------------------------
WITH ScratchByTier AS (
    SELECT
        YEAR(SaleDate)              AS SaleYear,
        MONTH(SaleDate)             AS SaleMonth,
        DATENAME(MONTH, SaleDate)   AS MonthName,
        TicketValue,
        SUM(TicketsOut)             AS TotalTicketsSold,
        SUM(AmountSold)             AS TotalRevenue
    FROM fact_ScratchOffSales
    GROUP BY
        YEAR(SaleDate), MONTH(SaleDate),
        DATENAME(MONTH, SaleDate), TicketValue
),
TierTotals AS (
    SELECT
        TicketValue,
        SUM(TotalTicketsSold)   AS AllTimeTicketsSold,
        SUM(TotalRevenue)       AS AllTimeRevenue,
        AVG(TotalRevenue)       AS AvgMonthlyRevenue,
        RANK() OVER (
            ORDER BY SUM(TotalRevenue) DESC
        )                       AS RevenueRank
    FROM ScratchByTier
    GROUP BY TicketValue
)
SELECT
    tt.TicketValue,
    tt.AllTimeTicketsSold,
    tt.AllTimeRevenue,
    tt.AvgMonthlyRevenue,
    tt.RevenueRank,
    ROUND(
        tt.AllTimeRevenue * 100.0
        / SUM(tt.AllTimeRevenue) OVER (),
    2)                          AS PctOfScratchRevenue
FROM TierTotals tt
ORDER BY tt.RevenueRank;


-- ------------------------------------------------------------
-- QUERY 5: Day of week pattern — inside sales vs fuel sales
--
-- Business question: Thursday/Friday are peak fuel days.
-- Does inside revenue peak on the same days or different days?
-- Is there a weekend inside sales pattern distinct from fuel?
--
-- ------------------------------------------------------------
WITH FuelByDOW AS (
    SELECT
        DATENAME(WEEKDAY, SaleDate) AS DayName,
        DATEPART(WEEKDAY, SaleDate) AS DayNum,
        AVG(GallonsSold)            AS AvgDailyGallons,
        AVG(AmountSold)             AS AvgDailyFuelRevenue
    FROM fact_FuelSales
    GROUP BY
        DATENAME(WEEKDAY, SaleDate),
        DATEPART(WEEKDAY, SaleDate)
),
MerchByDOW AS (
    SELECT
        DATENAME(WEEKDAY, SaleDate) AS DayName,
        DATEPART(WEEKDAY, SaleDate) AS DayNum,
        AVG(Amount)                 AS AvgDailyMerchRevenue
    FROM fact_DeptSales s
    GROUP BY
        DATENAME(WEEKDAY, SaleDate),
        DATEPART(WEEKDAY, SaleDate)
),
LotteryByDOW AS (
    SELECT
        DATENAME(WEEKDAY, SaleDate) AS DayName,
        DATEPART(WEEKDAY, SaleDate) AS DayNum,
        AVG(NetSales)               AS AvgDailyLotteryRevenue
    FROM fact_DeptSalesLottery l
    JOIN dim_Department d ON d.DepartmentID = l.DepartmentID
    WHERE d.DepartmentName NOT IN ('LOTTO PAYOUT', 'Money Order')
    GROUP BY
        DATENAME(WEEKDAY, SaleDate),
        DATEPART(WEEKDAY, SaleDate)
)
SELECT
    f.DayName,
    f.DayNum,
    ROUND(f.AvgDailyGallons, 2)             AS AvgGallons,
    ROUND(f.AvgDailyFuelRevenue, 2)         AS AvgFuelRevenue,
    ROUND(m.AvgDailyMerchRevenue, 2)        AS AvgMerchRevenue,
    ROUND(l.AvgDailyLotteryRevenue, 2)      AS AvgLotteryRevenue,
    ROUND(
        m.AvgDailyMerchRevenue
        + l.AvgDailyLotteryRevenue, 2
    )                                       AS AvgTotalInsideRevenue,
    RANK() OVER (
        ORDER BY f.AvgDailyGallons DESC
    )                                       AS FuelRank,
    RANK() OVER (
        ORDER BY m.AvgDailyMerchRevenue
            + l.AvgDailyLotteryRevenue DESC
    )                                       AS InsideRank
FROM FuelByDOW f
JOIN MerchByDOW m
    ON m.DayNum = f.DayNum
JOIN LotteryByDOW l
    ON l.DayNum = f.DayNum
ORDER BY f.DayNum;


-- ------------------------------------------------------------
-- QUERY 6: Vendor purchase frequency and cost analysis
--
-- Business question: Which vendors does the store buy from
-- most often and what is the total cost by vendor?
--
-- Context: Cost data is from actual invoices entered into
-- back office. Missed invoices are possible.
-- Retail values present where entered.
--
-- ------------------------------------------------------------

WITH PurchasesWithLag AS (
    SELECT
        Payee,
        PurchaseDate,
        Cost,
        Retail,
        LAG(PurchaseDate) OVER (
            PARTITION BY Payee
            ORDER BY PurchaseDate
        ) AS PrevPurchaseDate
    FROM fact_Purchases
),
DaysBetween AS (
    SELECT
        Payee,
        PurchaseDate,
        Cost,
        Retail,
        DATEDIFF(DAY, PrevPurchaseDate, PurchaseDate) AS DaysSincePrev
    FROM PurchasesWithLag
),
VendorSummary AS (
    SELECT
        Payee,
        COUNT(*)                        AS InvoiceCount,
        MIN(PurchaseDate)               AS FirstPurchase,
        MAX(PurchaseDate)               AS LastPurchase,
        SUM(Cost)                       AS TotalCost,
        AVG(Cost)                       AS AvgInvoiceCost,
        MAX(Cost)                       AS LargestInvoice,
        MIN(Cost)                       AS SmallestInvoice,
        AVG(CAST(DaysSincePrev AS DECIMAL(10,2))) AS AvgDaysBetweenOrders
    FROM DaysBetween
    GROUP BY Payee
)
SELECT
    Payee,
    InvoiceCount,
    FirstPurchase,
    LastPurchase,
    ROUND(TotalCost, 2)             AS TotalCost,
    ROUND(AvgInvoiceCost, 2)        AS AvgInvoiceCost,
    ROUND(LargestInvoice, 2)        AS LargestInvoice,
    ROUND(SmallestInvoice, 2)       AS SmallestInvoice,
    ROUND(AvgDaysBetweenOrders, 1)  AS AvgDaysBetweenOrders,
    RANK() OVER (
        ORDER BY TotalCost DESC
    )                               AS CostRank
FROM VendorSummary
ORDER BY TotalCost DESC;
