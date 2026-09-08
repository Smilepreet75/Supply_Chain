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

## Next Steps
- [ ] Write analytical SQL queries (late delivery rate, profit by category/region)
- [ ] Build Power BI dashboard
- [ ] Excel summary tables
- [ ] Final insights & recommendation
