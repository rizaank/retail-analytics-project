-- ============================================================
-- Gas Station Analytics — Inside Sales Schema
-- Source: Back Office
-- Date Range: January 1 2024 - February 28 2026
-- ============================================================
-- New tables added to existing GasStationAnalytics database
-- Run after fuel schema (01_schema.sql) is in place
-- ============================================================

USE GasStationAnalytics;

-- ------------------------------------------------------------
-- DIMENSION TABLES
-- ------------------------------------------------------------

-- Department reference table
-- DepartType: 'Lottery' | 'Merchandise' | 'Services'
-- Source: department groupings
CREATE TABLE dim_Department (
    DepartmentID    INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName  VARCHAR(50)  NOT NULL,
    DepartType      VARCHAR(20)  NOT NULL,
    TaxRate         DECIMAL(5,2) NULL,
    Notes           VARCHAR(200) NULL
);

-- Product reference table
-- Cost and Retail are reference values only — not tracked inventory
-- ScanCode is the barcode/PLU used at point of sale
-- Note: Cost Total / Retail Total footer rows excluded on load
CREATE TABLE dim_Product (
    ProductID       INT IDENTITY(1,1) PRIMARY KEY,
    ScanCode        VARCHAR(50)  NOT NULL,
    Description     VARCHAR(200) NULL,
    Cost            DECIMAL(10,4) NULL,
    Retail          DECIMAL(10,4) NULL,
    Margin          DECIMAL(8,4)  NULL
);

-- ------------------------------------------------------------
-- FACT TABLES
-- ------------------------------------------------------------

-- Daily department-level merchandise sales
-- Primary source for merchandise departments (excludes Lottery)
-- One row per day per department — clean, no duplicates
-- Lottery departments (LOTTO, LOTTO PAYOUT, SCRATCH OFF)
--   come from fact_DeptSalesLottery, not this table
-- Jan 25 2026 (ice storm) present with all zeros — consistent
--   with complete station zero in fuel tables
CREATE TABLE fact_DeptSales (
    DeptSalesID     INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate        DATE        NOT NULL,
    DepartmentID    INT         NOT NULL
                        REFERENCES dim_Department(DepartmentID),
    Tax             DECIMAL(12,2) NOT NULL DEFAULT 0,
    TaxRate         DECIMAL(5,2)  NULL,
    Amount          DECIMAL(12,2) NOT NULL
);

-- Daily lottery department sales
-- Covers LOTTO, LOTTO PAYOUT, SCRATCH OFF departments
-- 17 dates had duplicate date+department rows — aggregated by
--   summing both rows per investigation confirming split-day
--   reporting. Affected dates flagged in DataQualityNote.
-- Jan 25 2026 - store closed
-- Refund, Discount, Promotion included (not available in DailyMerchandiseSales)
CREATE TABLE fact_DeptSalesLottery (
    LotteryDeptSalesID  INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate            DATE          NOT NULL,
    DepartmentID        INT           NOT NULL
                            REFERENCES dim_Department(DepartmentID),
    Sales               DECIMAL(12,2) NOT NULL,
    Refund              DECIMAL(12,2) NOT NULL DEFAULT 0,
    Discount            DECIMAL(12,2) NOT NULL DEFAULT 0,
    Promotion           DECIMAL(12,2) NOT NULL DEFAULT 0,
    NetSales            DECIMAL(12,2) NOT NULL,
    DataQualityNote     VARCHAR(500)  NULL
);

-- Daily lotto online (printed ticket) activity
-- 791 rows covering full date range
-- NetOnlineSales: total printed lotto ticket sales
-- NetOnlineCashes: winning ticket redemptions paid out
-- InstantCashes: instant credit applied same day
-- Settlements: daily state lottery settlement drawn
-- Adjustments: corrections applied by lottery commission
-- Commissions: retailer commission earned
--     matches the Lottery Sales Commission in OtherIncome file
-- Balance: net position for the day
CREATE TABLE fact_LottoOnline (
    LottoOnlineID       INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate            DATE          NOT NULL,
    NetOnlineSales      DECIMAL(12,2) NOT NULL,
    NetOnlineCashes     DECIMAL(12,2) NOT NULL,
    InstantCashes       DECIMAL(12,2) NOT NULL DEFAULT 0,
    Settlements         DECIMAL(12,2) NOT NULL DEFAULT 0,
    Adjustments         DECIMAL(12,2) NOT NULL DEFAULT 0,
    Commissions         DECIMAL(12,2) NOT NULL,
    Balance             DECIMAL(12,2) NOT NULL
);

-- Daily scratch-off ticket sales — aggregated to day and game level
-- Raw source is pack-level (44,137 rows) — one row per pack per day
--   showing tickets sold out of that pack on that day
-- Aggregated here to date + game level for analytical usability
-- TicketValue: face value of each ticket ($1 - $50)
-- TicketsOut: count of tickets sold from that game on that day
-- AmountSold: TicketsOut * TicketValue
-- GameName: scratch-off game title
CREATE TABLE fact_ScratchOffSales (
    ScratchOffSalesID   INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate            DATE          NOT NULL,
    GameNo              INT           NOT NULL,
    GameName            VARCHAR(100)  NOT NULL,
    TicketValue         DECIMAL(8,2)  NOT NULL,
    TicketsOut          INT           NOT NULL,
    AmountSold          DECIMAL(12,2) NOT NULL
);

-- Vendor purchase invoices
-- One row per invoice delivery from a vendor
-- Payee: vendor name (Coke, Pepsi, Frito Lay, etc.)
-- Type: 'Cash - Daily' | 'Cash - Deli' | 'Check/EFT'
-- Total column excluded — was zero for all rows in source
-- Rows with no Payee and zero Cost excluded (blank entries)
-- Covers irregular delivery schedule across 26 months
CREATE TABLE fact_Purchases (
    PurchaseID      INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseDate    DATE          NOT NULL,
    Payee           VARCHAR(100)  NOT NULL,
    PurchaseType    VARCHAR(20)   NULL,
    InvoiceNo       VARCHAR(50)   NULL,
    Cost            DECIMAL(12,4) NOT NULL,
    Retail          DECIMAL(12,4) NULL,
    Margin          DECIMAL(8,4)  NULL
);

-- ------------------------------------------------------------
-- ANALYTICAL VIEWS
-- ------------------------------------------------------------

-- Combined daily inside sales — merchandise + lottery net
-- Joins fact_DeptSales and fact_DeptSalesLottery for full picture
-- Use for total inside revenue trending and fuel vs inside correlation
GO
CREATE VIEW vw_DailyInsideSales AS
SELECT
    s.SaleDate,
    d.DepartmentName,
    d.DepartType,
    s.Amount        AS Sales,
    0               AS Refund,
    0               AS Discount,
    0               AS Promotion,
    s.Amount        AS NetSales,
    'Merchandise'   AS SourceTable
FROM fact_DeptSales s
JOIN dim_Department d ON d.DepartmentID = s.DepartmentID

UNION ALL

SELECT
    l.SaleDate,
    d.DepartmentName,
    d.DepartType,
    l.Sales,
    l.Refund,
    l.Discount,
    l.Promotion,
    l.NetSales,
    'Lottery'       AS SourceTable
FROM fact_DeptSalesLottery l
JOIN dim_Department d ON d.DepartmentID = l.DepartmentID;


-- Monthly inside sales summary by department type
-- For Power BI trend reporting and fuel vs inside correlation
GO
CREATE VIEW vw_InsideMonthlySummary AS
SELECT
    YEAR(SaleDate)              AS SaleYear,
    MONTH(SaleDate)             AS SaleMonth,
    DATENAME(MONTH, SaleDate)   AS MonthName,
    DepartType,
    DepartmentName,
    SUM(Sales)                  AS TotalSales,
    SUM(NetSales)               AS TotalNetSales,
    SUM(Refund)                 AS TotalRefunds,
    SUM(Discount)               AS TotalDiscounts
FROM vw_DailyInsideSales
GROUP BY
    YEAR(SaleDate),
    MONTH(SaleDate),
    DATENAME(MONTH, SaleDate),
    DepartType,
    DepartmentName;


-- Scratch-off monthly summary by ticket value tier
-- Useful for understanding which price points drive revenue
GO
CREATE VIEW vw_ScratchOffMonthly AS
SELECT
    YEAR(SaleDate)              AS SaleYear,
    MONTH(SaleDate)             AS SaleMonth,
    DATENAME(MONTH, SaleDate)   AS MonthName,
    TicketValue,
    SUM(TicketsOut)             AS TotalTicketsSold,
    SUM(AmountSold)             AS TotalAmountSold
FROM fact_ScratchOffSales
GROUP BY
    YEAR(SaleDate),
    MONTH(SaleDate),
    DATENAME(MONTH, SaleDate),
    TicketValue;


-- Vendor purchase summary — monthly spend by vendor
GO
CREATE VIEW vw_PurchasesByVendor AS
SELECT
    YEAR(PurchaseDate)          AS PurchaseYear,
    MONTH(PurchaseDate)         AS PurchaseMonth,
    DATENAME(MONTH, PurchaseDate) AS MonthName,
    Payee,
    COUNT(*)                    AS InvoiceCount,
    SUM(Cost)                   AS TotalCost,
    SUM(Retail)                 AS TotalRetail
FROM fact_Purchases
GROUP BY
    YEAR(PurchaseDate),
    MONTH(PurchaseDate),
    DATENAME(MONTH, PurchaseDate),
    Payee;
