# Supply Chain Late-Delivery & Profit Loss Analysis

## Problem
Investigating which shipping modes, regions, and product categories cause the most late deliveries and profit loss for a global supply chain company, using SQL Server and Power BI.

## Dataset
DataCo Smart Supply Chain Dataset (Kaggle) — ~180,500 order records, single flat CSV, normalized into a relational schema for this project. URL: https://www.kaggle.com/datasets/saicharankomati/dataco-supply-chain-dataset

## Tools
- **SQL Server** — data cleaning, normalization, analytical queries (joins, window functions, stored procedures)
- **Power BI** — 3-page interactive dashboard, DAX measures, some tables loaded via direct SQL query

## Schema
Normalized the original flat file into 4 tables:
- **Customer** — demographics/location
- **Products** — name, price, category, department
- **Orders** — one row per order; includes shipping/location fields (merged in after verifying shipping outcome doesn't vary by item within an order)
- **Order_Items** — one row per product line per order (quantity, discount, price, profit)

## Data Cleaning & Verification

Verification was done using reusable custom **stored procedures** rather than repeating manual queries per table/column:

| Procedure | Purpose |
|---|---|
| `profiling_data` | Column names, data types, nullability, sample rows for a given table |
| `GetColumnData` | MIN/MAX/AVG for a given numeric column |
| `NullDataCheck` | Count and % of NULLs for a given column |
| `Check_duplicate_primarykey` | Checks a column for duplicate values |
| `CheckFullRowDuplicates` | Checks a table for fully duplicated rows |
| `CheckReferentialIntegrity` | Confirms every foreign key value exists in its parent table |
| `CheckOutlierClustering` | Groups rows below/above a threshold to see if outliers cluster |

Every table went through the same sequence: data type check → NULL check → primary key + full-row duplicate check → outlier/range check → referential integrity check.

### Findings by table

**Customer** — 8 NULLs in Last_Name, 3 in Zipcode (both negligible, <0.1%, left as-is). No duplicates. Dropped `Customer_Email` and `Customer_Password` (not relevant to analysis).

**Products** — price range ₹9.99–₹1999.99, avg ₹166.41, no outliers. No NULLs or duplicates. Dropped `product_description` (100% NULL). Referential integrity confirmed against Order_Items.

**Orders** — Latitude/Longitude NULLs negligible (3 and 32 rows). Dropped `order_zipcode` (86% NULL). Shipping day fields range 0–6 / 0–4 days; 0-day entries (1,844 rows) confirmed as legitimate "Same Day" orders, not an error. Fixed `order_date` import failure (date format ambiguity) via `TRY_CONVERT(..., 101)`. No duplicates. Referential integrity confirmed against Customer. Shipping fields verified empirically to not vary within a single order — merged into Orders instead of a separate table.

**Order_Items** — price range consistent with Products, no outliers. `Order_Item_Profit_Ratio` showed a cluster at -2.75 (6,301 rows, ~3.5%); investigated and found the same handful of ratio values repeating across many different products — concluded this reflects a genuine assigned margin pattern, not a data error, and kept as-is. Verified `Order_Profit_Per_Order` varies at the item level despite its name. No duplicates. Referential integrity confirmed against both Orders and Products. Dropped derivable columns (`Sales`, `Benefit_per_order`, `Sales_per_customer`) — recalculated via SQL instead of stored redundantly.

## SQL Analysis Queries

All 12 business questions were answered directly in SQL, then reproduced in Power BI via DAX or query-loaded tables. Full queries in `/sql`.

| # | Question | Key Finding |
|---|---|---|
| Q1 | Late delivery trend by quarter | Stable ~54-55% all year — not seasonal |
| Q2 | Late rate by shipping mode | First Class 95%, Second Class 77%, Same Day 46%, Standard Class 38% (best, despite highest volume) |
| Q3 | Late rate by region | Flat, 54-58% across all 23 regions |
| Q4 | Scheduled vs actual shipping gap | First Class: fixed 1-day delay on every order (Min=Max=Avg=1) — suggests an over-promised delivery window, not inconsistent fulfillment |
| Q5 | Profit margin by category | Accessories highest among reliable categories (12.5%, n≥1000); low-volume categories excluded as unreliable |
| Q6 | Late delivery vs profit | On-time avg profit ₹22.40 vs late ₹21.62 (~3.5% gap) — small per order, but ~₹77,000+ across 98,977 late orders |
| Q7 | Profit by region | Western Europe & Central America highest — driven by sales volume, not efficiency (margins similar ~10-12% everywhere) |
| Q8 | Discount rate vs profit margin | Flat ~11.8-12.6% across all discount bands — discounting isn't a major profit leak |
| Q9 | Late rate by customer segment | Flat, 54.7-55.2% — segment has no meaningful effect |
| Q10 | Late rate by category | Flat, 54.5-57% (n≥1000 filter) — category has minimal effect |
| Q11 | Discount vs shipping speed | Flat ~3 days across all discount bands — no correlation |
| Q12 | Final recommendation | See below — First Class's fixed 1-day gap is the core, fixable issue |

**Note on sample size:** Q5 and Q10 exclude categories with fewer than 1,000 transactions — smaller categories showed misleadingly extreme rates (e.g. one category at n=61 topped the list) that didn't hold up at scale.

## Power BI Dashboard

3-page interactive dashboard on the same 4-table schema (SQL Server, Import mode), with page-to-page navigation buttons and a "Clear all slicers" reset button on every page.

### Page 1 — Overview
KPIs: Order Count · Late Delivery Rate · Total Sales · Total Profit
Slicers: Shipping Mode · Order Region · Order Date
- **Late Delivery Trend (Quarterly)** — confirms the rate is stable year-round (Q1)
- **Late Delivery Rate by Shipping Mode** — the headline finding (Q2)
- **Late Delivery Rate by Region** — sorted descending, confirms minimal regional impact (Q3)

### Page 2 — Delivery & Category Deep-Dive
KPIs: Order Count · Late Delivery Rate · Total Discount Given · Overall Profit Margin
Slicers: Shipping Mode · Product Category
- **Shipping Time Reliability by Mode** — error-bar chart (Min/Max/Avg gap); shows First Class's uniform 1-day delay vs. other modes' real spread (Q4)
- **Category Performance: Profit Margin vs. Late Delivery Rate** — scatter chart merging Q5 and Q10 into one query; Accessories stands out with both the highest margin and highest late rate among reliable categories
- **Late Delivery Rate & Margin by Customer Segment** — table confirming segment has negligible effect on either metric (Q9)
- **Average Shipping Days by Discount Level** — confirms discount rate has no effect on shipping speed (Q11)

*The category scatter chart and segment table are fixed SQL query snapshots and don't respond to the slicers above (labeled on the dashboard).*

### Page 3 — Profit Analysis & Recommendation
KPIs: Total Sales · Total Profit · Avg Profit (On-Time) · Avg Profit (Late)
Slicers: Shipping Mode · Order Region
- **Profit Margin by Discount Level** — confirms discounting doesn't meaningfully hurt margin (Q8)
- **Total Profit by Region** — Western Europe & Central America lead, driven by volume not efficiency (Q7)
- **Profit Split: Late vs. On-Time Orders** — pie chart; late orders are a larger share of profit by volume despite earning less per order on average (Q6)
- **Key Finding & Recommendation** — closing summary (Q12, full text below)

### Key DAX measures
```dax
Late Delivery Rate = DIVIDE(SUMX(Orders, IF(Orders[Late_delivery_risk] = TRUE(), 1, 0)), COUNTROWS(Orders))
Avg Profit = AVERAGEX(Order_Items, Order_Items[Order_Profit_Per_Order])
Avg Profit OnTime = CALCULATE([Avg Profit], Orders[Late_delivery_risk] = FALSE())
Avg Profit Late = CALCULATE([Avg Profit], Orders[Late_delivery_risk] = TRUE())
Total Profit = SUM(Order_Items[Order_Profit_Per_Order])
Total Sales = SUMX(Order_Items, Order_Items[Order_Item_Product_Price] * Order_Items[Order_Item_Quantity])
Gap Min / Gap Max / Gap Avg = MINX/MAXX/AVERAGEX(Orders, [Days_for_shipping_real] - [Days_for_shipment_scheduled])
Discount Bucket = SWITCH(TRUE(), [Order_Item_Discount_Rate] < 0.1, "0-10%", ..., "30%+")  -- calculated column
Delivery Status = IF(Orders[Late_delivery_risk] = TRUE(), "Late", "On-Time")  -- calculated column
```

### Notable technical fixes
- `Late_delivery_risk` imports as Boolean from SQL Server's `bit` type — `SUM()` fails on Boolean, fixed with `SUMX` + `IF` to convert to 1/0
- Row-level logic (bucketing, status labels) must be a **calculated column**, not a measure — several attempts failed with "single value cannot be determined" until corrected
- Category/segment aggregations with sample-size filtering (`HAVING COUNT(*) >= 1000`) were loaded via Power BI's "SQL statement" advanced option rather than rebuilt in DAX, preserving the filtering logic directly from SQL
- Two visuals (Page 2's scatter chart and segment table) are static SQL snapshots with no model relationship — intentionally excluded from slicer interactions and labeled accordingly

## Key Finding & Recommendation (Q12)

Late deliveries are driven almost entirely by **shipping mode** — not region, customer segment, product category, or discounting, all of which showed negligible variation (2-4 percentage points at most). **First Class orders are late 95% of the time**, with a consistent, predictable **1-day gap on every single order** — pointing to an over-promised delivery window, not inconsistent fulfillment.

**Recommendation:** Re-evaluate the First Class shipping promise — either extend it by 1 day to match actual fulfillment capability, or invest specifically in First Class fulfillment. Standard Class (38% late, highest order volume) offers an internal benchmark for what reliable fulfillment looks like at scale.

**Financial impact:** Late orders earn ~3.5% less profit on average (₹21.62 vs ₹22.40). With over 54% of all orders currently late, this adds up to an estimated **₹77,000+ in lost profit** — separate from any harder-to-quantify cost to customer trust and retention.
