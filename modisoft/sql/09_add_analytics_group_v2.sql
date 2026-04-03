-- ============================================================
-- Gas Station Analytics — dim_Department Add AnalyticsGroup
-- Fixed version: checks if column exists before adding
-- ============================================================

USE GasStationAnalytics;

-- Only add the column if it doesn't already exist
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'dim_Department'
    AND COLUMN_NAME = 'AnalyticsGroup'
)
BEGIN
    ALTER TABLE dim_Department
    ADD AnalyticsGroup VARCHAR(50) NULL;
END

-- Update all departments with their analytics groupings
UPDATE dim_Department SET AnalyticsGroup = 'Lotto Online'        WHERE DepartmentName = 'LOTTO';
UPDATE dim_Department SET AnalyticsGroup = 'Lotto Payouts'       WHERE DepartmentName = 'LOTTO PAYOUT';
UPDATE dim_Department SET AnalyticsGroup = 'Scratch Off'         WHERE DepartmentName = 'SCRATCH OFF';
UPDATE dim_Department SET AnalyticsGroup = 'Beer'                WHERE DepartmentName = 'Beer';
UPDATE dim_Department SET AnalyticsGroup = 'Cigarettes'          WHERE DepartmentName = 'CIG PACK';
UPDATE dim_Department SET AnalyticsGroup = 'Cigarettes'          WHERE DepartmentName = 'CIGCTN';
UPDATE dim_Department SET AnalyticsGroup = 'Deli'                WHERE DepartmentName = 'Deli';
UPDATE dim_Department SET AnalyticsGroup = 'Grocery & Beverages' WHERE DepartmentName = 'Grocery LOW TAX';
UPDATE dim_Department SET AnalyticsGroup = 'General Merchandise' WHERE DepartmentName = 'HI TAX';
UPDATE dim_Department SET AnalyticsGroup = 'Ice'                 WHERE DepartmentName = 'ICE BAG';
UPDATE dim_Department SET AnalyticsGroup = 'Phone Cards'         WHERE DepartmentName = 'PHONE CARD';
UPDATE dim_Department SET AnalyticsGroup = 'Propane'             WHERE DepartmentName = 'PROPANE';
UPDATE dim_Department SET AnalyticsGroup = 'Tobacco'             WHERE DepartmentName = 'Tobacco';
UPDATE dim_Department SET AnalyticsGroup = 'Money Order'         WHERE DepartmentName = 'Money Order';

-- Verify
SELECT
    DepartmentID,
    DepartmentName,
    DepartType,
    TaxRate,
    AnalyticsGroup,
    Notes
FROM dim_Department
ORDER BY DepartType, AnalyticsGroup;
