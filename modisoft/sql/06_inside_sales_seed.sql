-- ============================================================
-- Gas Station Analytics — Inside Sales Seed Data
-- Populates dim_Department reference table
-- Run after 05_inside_sales_schema.sql
-- ============================================================

USE GasStationAnalytics;

-- ------------------------------------------------------------
-- dim_Department
-- Sourced from Modisoft department groupings across all reports
-- ------------------------------------------------------------
INSERT INTO dim_Department
    (DepartmentName, DepartType, TaxRate, Notes)
VALUES
    -- Lottery departments (from DeptWiseDetails only)
    ('LOTTO',           'Lottery',      0,    'Printed lotto ticket sales — Cash3, Cash4, Powerball, Mega Millions etc.'),
    ('LOTTO PAYOUT',    'Lottery',      0,    'Winning lotto ticket redemptions — values are negative'),
    ('SCRATCH OFF',     'Lottery',      0,    'Scratch-off instant ticket sales at POS'),

    -- Merchandise departments (from DailyMerchandiseSales)
    ('Beer',            'Merchandise',  8,    'Beer and malt beverages — taxable'),
    ('CIG PACK',        'Merchandise',  8,    'Single pack cigarette sales'),
    ('CIGCTN',          'Merchandise',  8,    'Carton cigarette sales'),
    ('Deli',            'Merchandise',  8,    'Deli / prepared food items'),
    ('Grocery LOW TAX', 'Merchandise',  4,    'Grocery items at reduced tax rate'),
    ('HI TAX',          'Merchandise',  8,    'High-tax merchandise category'),
    ('ICE BAG',         'Merchandise',  0,    'Bagged ice — non-taxable in GA'),
    ('PHONE CARD',      'Merchandise',  0,    'Prepaid phone cards — non-taxable'),
    ('PROPANE',         'Merchandise',  0,    'Propane tank exchange — non-taxable'),
    ('Tobacco',         'Merchandise',  8,    'Tobacco products excl. cigarette packs'),

    -- Services
    ('Money Order',     'Services',     0,    'Money order sales — non-taxable financial service');
