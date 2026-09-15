SELECT p.Category_Name,
       SUM(oi.Order_Profit_Per_Order) / SUM(oi.Order_Item_Quantity * oi.Order_Item_Product_Price) * 100 AS Margin_Percentage,
       CAST(SUM(CASE WHEN o.Late_delivery_risk = 1 THEN 1 ELSE 0 END) AS FLOAT) * 100 / COUNT(*) AS Late_Delivery_Rate,
       COUNT(*) AS Order_Count
FROM Order_Items oi
JOIN Orders o ON oi.Order_Id = o.Order_Id
JOIN Products p ON oi.Order_Item_Cardprod_Id = p.Product_Card_Id
GROUP BY p.Category_Name
HAVING COUNT(*) >= 1000
ORDER BY Margin_Percentage DESC;