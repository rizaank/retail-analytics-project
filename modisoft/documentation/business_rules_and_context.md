# Business Rules and Data Quality Context
## Gas Station Analytics Project

---

## Location
Anonymized for portfolio purposes — independent gas station

---

## Data Source
Modisoft back office POS system. All data exported as Excel 
files covering January 1 2024 through February 28 2026 (790 days).

---

## Fuel Grades

### Grade Overview
Four grades sold at this location:
- Regular (highest volume — approximately 60% of total gallons)
- Plus (blended grade — see note below)
- Super
- Diesel (commercial grade, lowest volume)

### Plus Grade — Important Structural Note
Plus is a blended grade mixed at the dispenser pump. 
This means:
- Plus has no Veeder-Root tank probe data
- Plus reconcile data (stick readings, book inventory) is 
  not meaningful and excluded from tank inventory analysis
- Plus volume is indirectly a function of Regular and Super 
  tank levels

### Cash vs Credit Pricing
Cash and Debit transactions are priced identically at the pump.
Credit transactions carry a 10 cent per gallon premium over 
cash/debit price for all grades.

Modisoft's Fuel Cash Credit report combines Debit and Credit 
into a single column making true payment-type margin 
calculation impossible without estimation. An algebraic split 
methodology is documented in the fuel margin tool.

---

## Fuel Reconcile Data

### Book Inventory Gallons
Calculated by Modisoft as remaining gallons after each day's 
sales. Represents the system's internal running inventory 
balance.

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
unusually high profit per gallon should be cross-referenced 
against delivery records where possible.

---

## Known Data Quality Issues

### Zero Sales Days — Diesel (51 occurrences)
Diesel recorded zero gallons on 51 days. Pattern shows heavy 
clustering on Sundays and Saturdays — consistent with absence 
of commercial traffic on weekends. Treated as legitimate 
zero-sale days not missing data.

Exception: November 20-29 2024 shows 9 consecutive Diesel 
zero days including weekdays. Cause unknown — possible pump 
issue or data entry gap during Thanksgiving week.

### Complete Station Zero — January 25 2026
All four grades recorded zero gallons on January 25 2026 
(Sunday). Station was closed due to an ice storm. 
Fuel pumps were operational but no sales recorded in Modisoft 
— likely a data import failure during the storm. Treated as 
missing data not a true zero-sale day. Excluded from daily 
average calculations where appropriate.

### Plus Grade — January 2025 Volume Anomaly
Plus grade recorded a 22% year-over-year decline in January 
2025 — the largest single-month YOY drop in the dataset for 
any grade. No operational explanation has been identified. 
January 2025 was also the lowest total profit month in the 
26-month dataset.

### Drink Item Recategorization
During operational tenure (January-March 2026) certain drink 
items were recategorized into correct price groups to fix 
pricing errors. Department-level sales data prior to this 
correction may show different category mapping for affected 
beverage items.

### Lottery Data Entry
Scratch-off pack numbers, activation, and box counts are 
entered manually by staff. Data quality is dependent on staff entry 
consistency.

---

## Operational Context

### Date Range
Full data range: January 1 2024 - February 28 2026 (790 days)
Operational involvement at periods within range.

### Fuel Delivery Schedule
Deliveries are irregular and recorded in the GallonsDelivered 
column of fact_FuelSales. Delivery days are flagged in the 
vw_FuelDeliveries view. Cost per gallon reflects the most 
recent delivery cost at time of sale.