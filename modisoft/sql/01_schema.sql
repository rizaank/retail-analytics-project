-- ============================================================
-- Gas Station Analytics — Database Schema
-- Source: Modisoft Back Office POS System
-- Date Range: January 1 2024 - February 28 2026
-- Location: Anonymized for portfolio purposes
-- ============================================================
-- Schema follows data warehouse conventions:
--   dim_ prefix = dimension/reference tables
--   fact_ prefix = transactional fact tables
--   vw_ prefix = analytical views
-- ============================================================

-- ------------------------------------------------------------
-- DIMENSION TABLES
-- ------------------------------------------------------------

-- Fuel grade reference table
CREATE TABLE dim_FuelType (
    FuelTypeID      INT IDENTITY(1,1) PRIMARY KEY,
    FuelTypeName    VARCHAR(20) NOT NULL,
    ColorCode       VARCHAR(10) NULL,
    CashDebitRetail DECIMAL(10,4) NULL,
    CreditRetail    DECIMAL(10,4) NULL
);

-- Date dimension for time intelligence in Power BI
-- IsWeekend: 1 = Saturday or Sunday
CREATE TABLE dim_Date (
    DateKey         INT PRIMARY KEY,
    FullDate        DATE NOT NULL,
    Year            INT NOT NULL,
    Quarter         INT NOT NULL,
    Month           INT NOT NULL,
    MonthName       VARCHAR(10) NOT NULL,
    Week            INT NOT NULL,
    DayOfWeek       INT NOT NULL,
    DayName         VARCHAR(10) NOT NULL,
    IsWeekend       BIT NOT NULL
);

-- ------------------------------------------------------------
-- FACT TABLES
-- ------------------------------------------------------------

-- Daily fuel sales by grade
-- Source: Modisoft Fuel Sales report
-- One row per day per fuel grade
CREATE TABLE fact_FuelSales (
    FuelSalesID         INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate            DATE NOT NULL,
    FuelTypeID          INT NOT NULL
                            REFERENCES dim_FuelType(FuelTypeID),
    GallonsSold         DECIMAL(12,4) NOT NULL,
    GallonsDelivered    DECIMAL(12,4) NOT NULL DEFAULT 0,
    AmountSold          DECIMAL(12,2) NOT NULL
);

-- Daily fuel cost and margin by grade
-- Source: Modisoft Fuel Profit DateWise Detail reports
-- One row per day per fuel grade
-- CostDataReliable = 0 flags days where invoice may have been missed
CREATE TABLE fact_FuelProfit (
    FuelProfitID        INT IDENTITY(1,1) PRIMARY KEY,
    ProfitDate          DATE NOT NULL,
    FuelTypeID          INT NOT NULL
                            REFERENCES dim_FuelType(FuelTypeID),
    GallonsSold         DECIMAL(12,4) NOT NULL,
    RetailPerGallon     DECIMAL(10,4) NOT NULL,
    CostPerGallon       DECIMAL(10,4) NOT NULL,
    ProfitPerGallon     DECIMAL(10,4) NOT NULL,
    ProfitAdj           DECIMAL(12,2) NOT NULL DEFAULT 0,
    TotalProfit         DECIMAL(12,2) NOT NULL,
    CostDataReliable    BIT NOT NULL DEFAULT 1,
    DataQualityNote     VARCHAR(500) NULL
);

-- Daily tank inventory reconciliation by grade
-- Source: Modisoft Fuel Reconcile reports
-- Note: Plus grade has no dedicated tank — it is blended at 
-- the dispenser (approx 1/3 Regular + 2/3 Super) so stick 
-- readings for Plus are not meaningful and excluded from analysis
-- Note: Daily Over/Short column excluded due to data reliability
-- issues with manual Veeder-Root stick reading entry
CREATE TABLE fact_FuelReconcile (
    ReconcileID             INT IDENTITY(1,1) PRIMARY KEY,
    ReconcileDate           DATE NOT NULL,
    FuelTypeID              INT NOT NULL
                                REFERENCES dim_FuelType(FuelTypeID),
    InitialStickInches      DECIMAL(10,4) NULL,
    InitialStickGallons     DECIMAL(12,4) NULL,
    GallonsDelivered        DECIMAL(12,4) NOT NULL DEFAULT 0,
    GallonsDispensed        DECIMAL(12,4) NOT NULL,
    BookInventoryGallons    DECIMAL(12,4) NULL,
    ClosingStickInches      DECIMAL(10,4) NULL,
    ClosingStickGallons     DECIMAL(12,4) NULL,
    StickReadingReliable    BIT NOT NULL DEFAULT 1,
    DataQualityNote         VARCHAR(500) NULL
);

-- Fuel payment mix summary — cash vs credit/debit
-- Source: Modisoft Fuel Cash Credit report
-- Note: Period summary only, not daily granularity
-- Note: Debit and Credit are combined in source data
-- Cash and Debit are priced identically at this location
-- Credit carries a 10 cent per gallon premium
CREATE TABLE fact_FuelPaymentMix (
    PaymentMixID            INT IDENTITY(1,1) PRIMARY KEY,
    ReportPeriodStart       DATE NOT NULL,
    ReportPeriodEnd         DATE NOT NULL,
    FuelTypeID              INT NOT NULL
                                REFERENCES dim_FuelType(FuelTypeID),
    GallonsCash             DECIMAL(12,4) NOT NULL,
    GallonsCreditDebit      DECIMAL(12,4) NOT NULL,
    TotalGallons            DECIMAL(12,4) NOT NULL,
    AmountCash              DECIMAL(12,2) NOT NULL,
    AmountCreditDebit       DECIMAL(12,2) NOT NULL,
    TotalAmount             DECIMAL(12,2) NOT NULL,
    AvgRetailPerGallon      DECIMAL(10,4) NOT NULL,
    CreditRetailAtTime      DECIMAL(10,4) NOT NULL
);

-- ------------------------------------------------------------
-- ANALYTICAL VIEWS
-- ------------------------------------------------------------

-- Monthly fuel performance — primary analytical view
-- Used by Power BI for trend and comparison reporting
CREATE VIEW vw_FuelMonthlyPerformance AS
SELECT
    YEAR(fs.SaleDate)               AS SaleYear,
    MONTH(fs.SaleDate)              AS SaleMonth,
    DATENAME(MONTH, fs.SaleDate)    AS MonthName,
    ft.FuelTypeName,
    SUM(fs.GallonsSold)             AS TotalGallons,
    SUM(fs.AmountSold)              AS TotalRevenue,
    SUM(fs.GallonsDelivered)        AS TotalDelivered,
    AVG(fp.RetailPerGallon)         AS AvgRetail,
    AVG(fp.CostPerGallon)           AS AvgCost,
    AVG(fp.ProfitPerGallon)         AS AvgMarginPerGallon,
    SUM(fp.TotalProfit)             AS TotalProfit
FROM fact_FuelSales fs
JOIN fact_FuelProfit fp
    ON fp.ProfitDate = fs.SaleDate
    AND fp.FuelTypeID = fs.FuelTypeID
JOIN dim_FuelType ft
    ON ft.FuelTypeID = fs.FuelTypeID
GROUP BY
    YEAR(fs.SaleDate),
    MONTH(fs.SaleDate),
    DATENAME(MONTH, fs.SaleDate),
    ft.FuelTypeName;

-- Fuel delivery tracking view
CREATE VIEW vw_FuelDeliveries AS
SELECT
    fs.SaleDate             AS DeliveryDate,
    ft.FuelTypeName,
    fs.GallonsDelivered,
    fp.CostPerGallon        AS CostAtDelivery,
    fs.GallonsDelivered * fp.CostPerGallon AS EstDeliveryCost
FROM fact_FuelSales fs
JOIN fact_FuelProfit fp
    ON fp.ProfitDate = fs.SaleDate
    AND fp.FuelTypeID = fs.FuelTypeID
JOIN dim_FuelType ft
    ON ft.FuelTypeID = fs.FuelTypeID
WHERE fs.GallonsDelivered > 0;