# Retail Analytics Project

End-to-end analytics project built on real operational data 
from two small businesses using SQL Server, Power BI, and 
Microsoft Fabric.

## Projects

### 1. Gas Station Analytics (Modisoft)
Real back office data from a gas station operation. Raw data 
extracted, cleaned, and modeled in SQL Server. Insights 
surfaced through Power BI dashboards published via Microsoft 
Fabric. Data quality was a significant challenge and is fully 
documented.

**Business questions answered:**
- Department-level sales trends and seasonality
- Fuel volume and margin analysis
- Lottery sales patterns
- Fuel vs inside sales correlation

### 2. Wholesale Business Analytics (QuickBooks)
Financial and sales data from a wholesale distributor serving 
c-stores and gas stations. Focused on customer profitability, 
product margin, and receivables analysis.

## Stack
- SQL Server 2022 (via Docker, local)
- Microsoft Fabric (cloud)
- Power BI
- VS Code
- GitHub

## AI Integration
This project deliberately documents where and how AI tools 
were used vs. where human domain knowledge and judgment drove 
decisions. That breakdown is documented in each project's 
individual README.
```

# Fuel Analytics — Key Findings
## Gas Station Analytics Project
### Analysis Period: January 2024 - February 2026

---

## Executive Summary

Analysis of 26 months of fuel sales and profit data 
revealed six actionable findings covering 
seasonal patterns, day-of-week behavior, grade-level margin 
dynamics, and data quality issues. Total fuel revenue over 
the period was $3,556,344 across 935,928 gallons sold.

---

## Finding 1 — Winter Is Peak Season

The five highest volume days in the 26-month period all 
occurred in January or February. January 9 2025 was the 
single highest day at 1,975 gallons across all grades — 
67% above the daily average of 1,184 gallons.

**Implication:** Delivery scheduling and inventory buffer 
should be sized for winter demand spikes, not annual averages.

---

## Finding 2 — Thursday and Friday Are Peak Days

Every one of the top 5 highest volume days fell on a Thursday 
or Friday. This suggests consistent consumer end-of-week 
fill-up behavior — customers top off before weekend driving.

**Implication:** Staffing, pricing reviews, and promotional 
timing should account for Thursday/Friday volume concentration.

---

## Finding 3 — Regular Margin Is Flat

Regular fuel — which accounts for approximately 60% of total 
gallons sold — showed essentially flat margin per gallon year 
over year. Neither pricing changes nor cost fluctuations 
produced meaningful margin movement for this grade.

**Implication:** Growing Regular fuel profit requires volume 
growth (more customers) not margin management (pricing 
adjustments). Marketing and competitive positioning matter 
more than pricing strategy for this grade.

---

## Finding 4 — Diesel Is High Margin but Volatile

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

## Finding 5 — $13,642 Gap Between Best and Worst Month

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

**Implication:** The owner likely has intuition that some 
months are better than others but no quantified range. This 
analysis puts a $13,642 number on that variance for the 
first time.

---

## Finding 6 — Data Quality Issues Identified and Documented

Three categories of data quality issues were identified, 
investigated, and documented:

1. **51 Diesel zero-sale days** — mostly weekends, consistent 
   with commercial traffic patterns. Legitimate not missing.

2. **9 consecutive Diesel zeros in November 2024** — 
   unexplained, possible pump issue during Thanksgiving week.

3. **Complete station zero on January 25 2026** — traced to 
   ice storm closure with likely data import failure. Treated 
   as missing data.

**Implication:** Raw Modisoft exports require cleaning and 
contextual interpretation before use in reporting. This data 
quality layer is documented and reproducible.

---

## Methodology Notes

- All analysis performed in SQL Server 2022 against a 
  relational database built from raw Modisoft Excel exports
- Data verified against source files before analysis
- All queries available in modisoft/sql/04_fuel_analysis.sql
- Data quality limitations documented in 
  modisoft/documentation/business_rules_and_context.md
- Tools used: SQL Server, VS Code, GitHub, Claude AI 
  (query review and project guidance)
```
