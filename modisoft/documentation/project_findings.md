# Retail Analytics Project — Key Findings
## Gas Station Analytics (Modisoft)
### Analysis Period: January 2024 - February 2026

---

## Executive Summary

End-to-end analysis of 26 months of operational data from an
independent BP gas station revealed twelve actionable findings
across two analytical domains: fuel sales and inside sales.
Total store revenue over the period was approximately $5.1M
($3.56M fuel + $1.47M inside sales).

Six fuel findings cover seasonal patterns, day-of-week behavior,
grade-level margin dynamics, and data quality. Six inside sales
findings cover department revenue concentration, year-over-year
trends, fuel-to-inside customer correlation, scratch-off ticket
mix, day-of-week patterns, and vendor purchasing behavior.

---

## FUEL ANALYTICS — Six Findings

### Finding F1 — Winter Is Peak Season

The five highest volume days in the 26-month period all
occurred in January or February. January 9 2025 was the
single highest day at 1,975 gallons across all grades — 67%
above the daily average of 1,184 gallons.

**Implication:** Delivery scheduling and inventory buffer
should be sized for winter demand spikes, not annual averages.

---

### Finding F2 — Thursday and Friday Are Peak Days

Every one of the top 5 highest volume days fell on a Thursday
or Friday. This suggests consistent consumer end-of-week
fill-up behavior — customers top off before weekend driving.

**Implication:** Staffing, pricing reviews, and promotional
timing should account for Thursday/Friday volume concentration.

---

### Finding F3 — Regular Margin Is Flat

Regular fuel — approximately 60% of total gallons sold —
showed essentially flat margin per gallon year over year.
Neither pricing changes nor cost fluctuations produced
meaningful margin movement for this grade.

**Implication:** Growing Regular fuel profit requires volume
growth (more customers), not margin management (pricing
adjustments). Marketing and competitive positioning matter
more than pricing strategy for this grade.

---

### Finding F4 — Diesel Is High Margin but Volatile

Diesel averages the highest profit per gallon of any grade
but shows a coefficient of variation of 79% in daily volume
(StdDev $44.99 against avg $56.88 gallons/day). Month-to-month
margin also shows the largest swings of any grade, driven by
wholesale cost fluctuations tied to heating oil markets.

**Implication:** Diesel requires larger buffer inventory
relative to its average daily volume compared to Regular.
Margin should be monitored monthly given wholesale cost
sensitivity.

---

### Finding F5 — $13,642 Gap Between Best and Worst Month

Monthly fuel profit ranged from $24,004 (January 2025) to
$37,646 (December 2025) — a gap of $13,642 on fuel alone.
Average monthly fuel profit was $29,170.

| Month          | Total Profit | Total Gallons |
|----------------|-------------|---------------|
| December 2025  | $37,646     | 38,604        |
| August 2024    | $35,339     | 37,886        |
| June 2024      | $33,228     | 36,213        |
| January 2025   | $24,004     | 32,666        |
| February 2024  | $24,448     | 34,557        |
| November 2024  | $24,649     | 32,895        |

**Implication:** The owner likely has intuition that some months
are better than others but no quantified range. This analysis
puts a $13,642 number on that variance for the first time.

---

### Finding F6 — Data Quality Issues Identified and Documented

Three categories of data quality issues were identified,
investigated, and documented:

1. **51 days of no Diesel sales** — mostly weekends, consistent
   with commercial traffic patterns. Legitimate not missing.

2. **9 consecutive Diesel zeros in November 2024** — tank issue.

3. **Store closed on January 25 2026** — ice storm and likely data import failure

**Implication:** Raw exports require cleaning and
contextual interpretation before use in reporting. This data
quality layer is documented and reproducible.

---

## INSIDE SALES ANALYTICS — Six Findings

### Finding I1 — Three Departments Drive 60% of Inside Revenue

Grocery & Beverages, Tobacco, and Cigarettes
account for 60% of all inside net sales. 
Lottery is the 4th largest category
at 14.3%. Finding like this not visible
in standard back office reports.

| Department      | Total Net Sales | % of Inside |
|-----------------|----------------|-------------|
| Grocery LOW TAX | $353,528        | 24.1%       |
| Tobacco         | $283,377        | 19.3%       |
| CIG PACK        | $240,699        | 16.4%       |
| SCRATCH OFF     | $209,277        | 14.3%       |
| Beer            | $135,585        | 9.2%        |
| HI TAX          | $114,315        | 7.8%        |

---

### Finding I2 — Lottery Revenue Is in Significant Decline

Lottery net sales were growing YOY in
early 2025 (+1.4% to +16.7%) but declined sharply from May
2025 onward, accelerating to -51.7% and -53.4% YOY in
January-February 2026. Merchandise held flat throughout 2025
with slight recovery in early 2026. The two categories are
diverging — merchandise stable, lottery collapsing.

Root cause unconfirmed. January-February 2026 coincided with
an unusually cold winter. Lottery customers tend to be older 
and more sensitive to weather, but a 50%+ decline is extreme 
for weather alone.

**Implication:** The lottery decline is operationally significant
and warrants investigation. The overall decline in Lottery 
commission income is consistent with these results.

---

### Finding I3 — Inside Revenue Is Stable at 27-31% of Total
### But Fuel and Inside Customers Appear to Be Separate Segments

Inside sales consistently represent 25-31% of total store
revenue. However high fuel volume months do not produce
proportionally higher inside revenue — the correlation is
weak or slightly inverted:

- May 2024: 39,167 gallons — inside = 26.9% of total
- November 2024: 32,895 gallons — inside = 30.1% of total

Note: The finding is a monthly correlation observation, not 
individual behavior tracking.

---

### Finding I4 — $30 Scratch-Off Tickets Generate the Most Revenue
### Despite Not Being the Highest Volume Tier

| Ticket Value | Tickets Sold | Total Revenue | % of Scratch |
|-------------|-------------|--------------|-------------|
| $30          | 6,557        | $196,710      | 22.4%       |
| $10          | 16,827       | $168,270      | 19.2%       |
| $50          | 3,237        | $161,850      | 18.5%       |
| $20          | 6,725        | $134,500      | 15.3%       |
| $5           | 21,054       | $105,270      | 12.0%       |

$20-$50 tickets are 56% of scratch revenue on 30% of volume.
The $1 ticket is essentially irrelevant at 0.44% of revenue.

**Implication:** Premium scratch-off tickets punch well above
their unit volume. Prioritizing pack activation and slot
allocation for the $30 and $50 tiers is more valuable than
stocking more $1-$2 tickets.

---

### Finding I5 — Friday Is Peak Day for Both Fuel and Inside.
### Thursday Fuel Traffic Is Not Converting Inside.

| Day       | Avg Fuel Rev | Avg Inside Rev | Fuel Rank | Inside Rank |
|-----------|-------------|---------------|-----------|-------------|
| Friday    | $1,236.59    | $382.10        | 1         | 1           |
| Wednesday | $1,206.13    | $363.10        | 2         | 2           |
| Thursday  | $1,191.98    | $354.34        | 3         | 5           |
| Saturday  | $1,080.13    | $357.00        | 6         | 4           |
| Sunday    | $883.84      | $237.50        | 7         | 7           |

Thursday ranks 3rd for fuel but only 5th for inside —
suggesting Thursday fuel customers skew toward fill-up-only
visits. Saturday ranks 4th for inside despite 6th for fuel,
pointing to a distinct weekend inside customer segment.

**Implication:** Friday is the most critical day operationally.
Thursday represents a conversion opportunity.

---

### Finding I6 — Coremark Is the Dominant Vendor
### Near-Weekly Delivery for 26 Months

| Vendor            | Invoices | Total Cost  | Avg Days Between |
|-------------------|----------|-------------|-----------------|
| Coremark          | 100      | $327,093.87 | 7.9 days        |
| Star Wholesale    | 23       | $124,077.82 | 30.2 days       |
| Coke              | 92       | $54,859.38  | 8.6 days        |
| General Wholesale | 55       | $47,117.14  | 14.5 days       |
| United Distrib.   | 50       | $32,317.57  | 16.0 days       |

Coremark accounts 2.5x the next vendor. Coke is also weekly. 
Together they form the core weekly supply chain.

**Implication:** Any disruption to Coremark or Coke has
immediate shelf impact.

---

## Methodology Notes

- All analysis performed in SQL Server against a
  relational database built from raw back office Excel exports
- Data verified against source files before analysis
- Fuel queries in modisoft/sql/04_fuel_analysis.sql
- Inside sales queries in modisoft/sql/08_inside_sales_analysis.sql
- Data quality limitations in
  modisoft/documentation/business_rules_and_context.md
- Tools used: SQL Server, VS Code, GitHub, Claude
  (query structure, schema design, and project guidance)
