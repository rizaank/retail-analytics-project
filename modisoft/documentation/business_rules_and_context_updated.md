# Business Rules and Data Quality Context
## Gas Station Analytics Project

---

## Location
Independent gas station

---

## Data Source
Modisoft back office POS system. All data exported as Excel
files covering January 1 2024 through February 28 2026 (790 days).

---

## Fuel Grades

### Grade Overview
Four grades sold at this location:
- Regular (highest volume)
- Plus (blended grade)
- Super
- Diesel

### Plus Grade — Important Structural Note
Plus is a blended grade mixed at the dispenser pump.
This means:
- Plus reconcile data (stick readings, book inventory) is
  not meaningful and excluded from tank inventory analysis

### Cash vs Credit Pricing
Modisoft's Fuel Cash Credit report combines Debit and Credit
into a single column making true payment-type margin
calculation impossible without estimation. An algebraic split
methodology is documented in the fuel margin tool.

---

## Fuel Reconcile Data

### Book Inventory Gallons
Calculated by Modisoft as remaining gallons after each day's
sales. Represents the system's internal running inventory balance.

### Closing Stick Reading
Intended to reflect the physical tank reading from the
Veeder-Root inventory system — separate hardware with direct
tank probes.

Entry has NOT always been consistent. Known causes of
inaccurate or missing readings:
- Veeder-Root system downtime — Book Inventory Gallons copied
  in as substitute when unavailable
- Active fuel transactions at the time of the 2am printout
- Fuel delivery coinciding with printout time
- Inconsistent manual entry by staff

### Daily Over/Short Gallons
EXCLUDED from all analysis. Derived from stick reading
inconsistencies described above and is not reliable for
variance analysis.

---

## Fuel Profit Data

### Cost Accuracy
Fuel delivery invoices may occasionally have been missed when
entering purchases into Modisoft. Missed invoices would
understate cost and overstate profit for affected periods.
Believed to be rare but cannot be fully verified. Days showing
unusual profit per gallon should be cross-referenced
against delivery records where possible.

---

## Inside Sales Data

### Source Reports
Two Modisoft reports used for inside sales:

1. **DailyMerchandiseSales** — merchandise departments only
   (Beer, Tobacco, CIG PACK, Grocery LOW TAX, etc.). One row
   per day per department. Clean, no duplicate entries.
   Used as primary source for all merchandise departments.

2. **DeptWiseDetails** — all departments including Lottery
   (LOTTO, LOTTO PAYOUT, SCRATCH OFF) and Money Order.
   Contains Refund, Discount, and Promotion columns not
   available in DailyMerchandiseSales.

### CIG PACK vs CIGCTN — Same Category, Different Entry Method
Both departments represent cigarette sales. The split is due
to inconsistent SKU-to-department mapping in the Modisoft
pricebook.

For all analytical purposes CIG PACK and CIGCTN are combined
under AnalyticsGroup = 'Cigarettes' in dim_Department.

### Lottery Data Sources
Two separate lottery reports loaded:

1. **fact_DeptSalesLottery** — LOTTO, LOTTO PAYOUT, and
   SCRATCH OFF daily totals from DeptWiseDetails. LOTTO PAYOUT
   values are negative (payouts reduce net lottery revenue).

2. **fact_LottoOnline** — Daily printed ticket (online lottery)
   activity including Net Online Sales, Net Online Cashes,
   Instant Cashes, Settlements, Adjustments, Commissions,
   and Balance.

3. **fact_ScratchOffSales** — Pack-level scratch-off data
   aggregated to date + game + ticket value level. Covers
   ticket values from $1 to $50 across all active games.

---

## Known Data Quality Issues

### Zero Sales Days — Diesel (51 occurrences)
Diesel recorded zero gallons on 51 days. Pattern shows heavy
clustering on Sundays and Saturdays — consistent with absence
of commercial traffic on weekends. Treated as legitimate
zero-sale days not missing data.

Exception: November 20-29 2024 shows 9 consecutive Diesel
zero days including weekdays. Cause unknown — possible pump
issue or data gap.

### Complete Station Zero — January 25 2026
All four fuel grades recorded zero gallons on January 25 2026
(Sunday). Station was closed due to an ice storm.
Fuel pumps were operational but no sales recorded in Modisoft
— likely a data import failure during the storm. Treated as
missing data not a true zero-sale day. Excluded from daily
average calculations where appropriate.

This date also appears in DailyMerchandiseSales with all zeros
and is absent from DeptWiseDetails entirely. Consistent across
all data sources.

### Plus Grade — January 2025 Volume Anomaly
Plus grade recorded a 22% year-over-year decline in January
2025 — the largest single-month YOY drop in the dataset for
any grade. No operational explanation has been identified.
January 2025 was also the lowest total profit month in the
26-month dataset.

### DeptWiseDetails — 17 Split-Day Duplicate Entries
The DeptWiseDetails source file contains 17 dates where the
same department appears twice with different sales figures.
Both rows were summed for each affected
date/department combination. Confirmed valid by surrounding-day
comparison — the sum of duplicate rows falls within the normal
range of adjacent days for all but one case (SCRATCH OFF on
June 26 2024, which appears elevated).

Affected dates flagged in DataQualityNote column of
fact_DeptSalesLottery.

### Lottery Revenue Decline — Jan-Feb 2026
Lottery net sales show accelerating YOY decline in the second
half of 2025, reaching -51.7% (January 2026) and -53.4%
(February 2026).
Root cause unconfirmed — flagged for further investigation.

### Purchase Data — Missing Invoices
The Product-PurchaseDetails source file contains blank
Cash-Daily entries with zero cost and no invoice number.
These represent cash purchases where invoice details were
not entered into Modisoft. Excluded from fact_Purchases on
load. Believed to represent a small portion of total purchases.

---

## Operational Context

### Fuel Delivery Schedule
Deliveries are irregular and recorded in the GallonsDelivered
column of fact_FuelSales. Delivery days are flagged in the
vw_FuelDeliveries view. Cost per gallon reflects the most
recent delivery cost at time of sale.
