-- ============================================================
-- Gas Station Analytics — Update AnalyticsGroup Labels
-- Corrects HI TAX and Grocery LOW TAX labels
-- ============================================================
-- Tax category breakdown confirmed by item analysis:
--
-- Grocery LOW TAX (4):
--   Beverages (soda, juice, water, energy drinks, coffee),
--   candy, snacks, protein bars, beer, general grocery.
--   Anything consumable food or beverage.
--
-- HI TAX (8):
--   Medicine, auto products, household items, other general merch.
--   Note: cigarettes, tobacco have their own departments
--   despite also being high-tax items.
-- ============================================================

USE GasStationAnalytics;

UPDATE dim_Department
SET AnalyticsGroup = 'Grocery & Beverages',
    Notes = '4% tax rate'
WHERE DepartmentName = 'Grocery LOW TAX';

UPDATE dim_Department
SET AnalyticsGroup = 'General Merchandise',
    Notes = '8% tax rate'
WHERE DepartmentName = 'HI TAX';

-- Verify final state of dim_Department
SELECT
    DepartmentID,
    DepartmentName,
    DepartType,
    TaxRate,
    AnalyticsGroup,
    Notes
FROM dim_Department
ORDER BY DepartType, AnalyticsGroup;
