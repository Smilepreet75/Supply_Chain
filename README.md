# Supply Chain Late-Delivery & Profit Loss Analysis

## Problem
Investigating which shipping modes, regions, and product categories cause the most late deliveries and profit loss for a global supply chain company, using SQL Server, Excel, and Power BI.

## Dataset
DataCo Smart Supply Chain Dataset (Kaggle) — ~180,500 order records, single flat CSV, normalized into a relational schema for this project.

## Tools
- **SQL Server** — data cleaning, normalization, analytical queries (joins, window functions)
- **Power BI** — dashboard, DAX measures, some tables loaded via direct SQL query
- **Excel** — summary pivot tables on smaller, pre-aggregated data

## Schema
Normalized the original flat file into 4 tables:
- **Customers** — customer demographics/location
- **Products** — product name, price, category, department
- **Orders** — one row per order; includes shipping/location fields (merged in after verifying shipping outcome doesn't vary by item within an order)
- **Order_Items** — one row per product line per order (quantity, discount, price, profit ratio)

## Data Cleaning & Verification

To keep this process consistent and reusable, verification was done using custom **stored procedures** (rather than repeating manual queries for each table/column):

| Procedure | Purpose |
| `profiling_data` | Returns column names, data types, nullability, and sample rows for a given table |
| `GetColumnData` | Returns MIN/MAX/AVG for a given numeric column |
| `NullDataCheck` | Returns count and percentage of NULLs for a given column |
| `Check_duplicate_primarykey` | Checks a given column for duplicate values |
| `CheckFullRowDuplicates` | Checks a table for fully duplicated rows across all columns |
| `CheckReferentialIntegrity` | Checks that every foreign key value in a child table exists in its parent table |
| `CheckOutlierClustering` | Groups rows below/above a threshold by a chosen column, to see if outliers cluster around a specific value |

Each of the four normalized tables (Customers, Products, Orders, Order_Items) was run through the same verification sequence: data type check → NULL check → primary key + full-row duplicate check → outlier/range check → referential integrity check.

### Findings by table

**Customers**
- 8 NULLs in `Last_Name`, 3 in `Zipcode` — both negligible (<0.1%), left as-is
- No duplicate primary keys or full-row duplicates
- Dropped `Customer_Email` and `Customer_Password` — not relevant to the analysis

**Products**
- Product price range: ₹9.99–₹1999.99, avg ₹166.41 — no outliers
- No NULLs or duplicates
- Dropped `product_description` — 100% NULL
- Referential integrity confirmed against `Order_Items`

**Orders**
- Latitude/Longitude NULLs — negligible (3 and 32 rows), left as-is
- Dropped `order_zipcode` — 86% NULL (155,679 of 180,519 rows)
- `Days_for_shipping_real` / `Days_for_shipment_scheduled` range 0–6 / 0–4 days — 0-day entries (1,844 rows) confirmed to be legitimate "Same Day" shipping orders, not a data error
- Fixed `order_date_DateOrders` import failure (date format ambiguity) using `TRY_CONVERT(..., 101)`
- No duplicate primary keys or full-row duplicates
- Referential integrity confirmed against `Customer`
- Shipping fields (`Delivery_Status`, `Days_for_shipping_real`, etc.) verified empirically to not vary within a single order — merged into Orders rather than kept as a separate table

**Order_Items**
- Product price range consistent with Products table — no outliers
- `Order_Item_Profit_Ratio`: found a cluster of values at -2.75 (6,301 rows, ~3.5%). Investigated by checking whether extreme values were random or clustered — found the same handful of ratio values repeating thousands of times across many different products, but not perfectly fixed per product either. Concluded this reflects a genuine assigned margin pattern (likely tied to category/promotion) rather than a data error, and kept the column as-is rather than recalculating it
- Verified `Order_Profit_Per_Order` varies at the item level (not the order level, despite its name) — placed in Order_Items accordingly
- No duplicate primary keys or full-row duplicates
- Referential integrity confirmed against both `Orders` and `Products`
- Dropped derivable columns (`Sales`, `Benefit_per_order`, `Sales_per_customer`) — recalculated via SQL query instead of stored redundantly

## Status
🔧 In progress — schema and cleaning complete, SQL analysis queries and Power BI dashboard in progress.

## SQL Analysis Queries

All 12 business questions were answered directly in SQL first, then reproduced in Power BI (via DAX or query-loaded tables). Full queries saved in `/sql/analysis_queries.sql`.

| # | Question | Key Finding |
|---|---|---|
| Q1 | Late delivery trend by quarter | Stable ~54-55% all year — not seasonal |
| Q2 | Late rate by shipping mode | First Class 95%, Second Class 76%, Same Day 46%, Standard Class 38% (best, despite highest volume) |
| Q3 | Late rate by region | Flat, 54-58% across all regions |
| Q4 | Scheduled vs actual shipping gap | First Class: fixed 1-day delay on every order (Min=Max=Avg=1) — suggests over-promised delivery window, not inconsistent fulfillment |
| Q5 | Profit margin by category | Accessories highest among reliable categories (12.5%, n≥1000); low-volume categories (Golf Bags & Carts, Strength Training) excluded as unreliable |
| Q6 | Late delivery vs profit | On-time avg profit ₹22.40 vs late ₹21.62 (~3.5% gap) — small per order, but ~₹77,000+ across 98,977 late orders |
| Q7 | Profit by region | Western Europe & Central America highest (driven by sales volume, not efficiency — margins similar ~10-12% everywhere) |
| Q8 | Discount rate vs profit margin | Flat ~11.8-12.6% across all discount bands — discounting isn't a major profit leak |
| Q9 | Late rate by customer segment | Flat, 54.7-55.2% — segment has no meaningful effect |
| Q10 | Late rate by category | Flat, 54.5-57% (n≥1000 filter applied) — category has minimal effect |
| Q11 | Discount vs shipping speed | Flat ~3 days across all discount bands — no correlation |
| Q12 | Final recommendation | See `Q12_final_recommendation.md` — First Class's fixed 1-day gap is the core, fixable issue |

**Note on sample size:** Q5 and Q10 exclude categories with fewer than 1,000 transactions; smaller categories showed misleadingly extreme rates (e.g. Golf Bags & Carts at n=61) that don't hold up at scale.

## Power BI Dashboard

3-page dashboard built on the same 4-table schema, connected directly to SQL Server (Import mode).

**Page 1 — Overview:** KPI cards (Total Orders, Late Delivery Rate, Total Profit, Total Sales), late rate trend by quarter (Q1), late rate by shipping mode (Q2), late rate by region (Q3).

**Page 2 — Delivery Deep-Dive:** shipping gap analysis by mode (Q4), and a combined "factor comparison" table showing customer segment and discount level have negligible impact on delivery (Q9, Q11).

**Page 3 — Profit Analysis & Recommendation:** category margin vs late-rate combo chart (Q5+Q10 merged into one query, since both share the Category dimension), on-time vs late profit comparison via KPI cards (Q6), profit by region (Q7), discount vs margin (Q8), and the final written recommendation.

**Key DAX measures:**
```dax
Late Delivery Rate = DIVIDE(SUMX(Orders, IF(Orders[Late_delivery_risk] = TRUE(), 1, 0)), COUNTROWS(Orders))
Avg Profit = AVERAGEX(Order_Items, Order_Items[Order_Profit_Per_Order])
Total Profit = SUM(Order_Items[Order_Profit_Per_Order])
Total Sales = SUMX(Order_Items, Order_Items[Order_Item_Product_Price] * Order_Items[Order_Item_Quantity])
```

**Notable technical fixes along the way:**
- `Late_delivery_risk` imported as Boolean (not numeric) from SQL Server's `bit` type — `SUM()` fails on Boolean, fixed using `SUMX` + `IF` to convert True/False to 1/0
- Discount bucketing (`SWITCH(TRUE(), ...)`) must be a **calculated column**, not a measure, since it's row-level logic
- Some complex aggregations (category margin/late-rate with sample-size filtering) were loaded via Power BI's "SQL statement" advanced option rather than rebuilt in DAX, to preserve the actual SQL logic and avoid duplicating filtering that's easier to express in SQL
