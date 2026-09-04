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

## Data Cleaning Notes
- Fixed `order_date` column: original import failed due to date format ambiguity; resolved using `TRY_CONVERT(..., 101)`
- Dropped `product_description` (100% NULL)
- Dropped `order_zipcode` (86% NULL, insufficient for reliable analysis)
- Widened `Product_Image` column after truncation error on long URLs
- Verified empirically that `Order_Profit_Per_Order` varies at the **item level**, not order level, despite its name — placed in Order_Items
- Verified empirically that shipping/delivery status does **not** vary within an order — shipping fields merged into Orders instead of a separate table
- Dropped derivable columns (`Sales`, `Benefit_per_order`, `Sales_per_customer`) — recalculated via SQL instead of stored

## Status
🔧 In progress — schema and cleaning complete, SQL analysis queries and Power BI dashboard in progress.

## Next Steps
- [ ] Write analytical SQL queries (late delivery rate, profit by category/region)
- [ ] Build Power BI dashboard
- [ ] Excel summary tables
- [ ] Final insights & recommendation
