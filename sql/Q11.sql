SELECT 
    CASE 
        WHEN Order_Item_Discount_Rate < 0.1 THEN '0-10%'
        WHEN Order_Item_Discount_Rate < 0.2 THEN '10-20%'
        WHEN Order_Item_Discount_Rate < 0.3 THEN '20-30%'
        ELSE '30%+'
    END AS Discount_Bucket,
    AVG(Days_for_shipping_real) AS Avg_Shipping_Real,
    COUNT(*) AS Row_Count
FROM Order_Items oi 
LEFT JOIN Orders o ON o.Order_Id = oi.Order_Id
GROUP BY 
    CASE 
        WHEN Order_Item_Discount_Rate < 0.1 THEN '0-10%'
        WHEN Order_Item_Discount_Rate < 0.2 THEN '10-20%'
        WHEN Order_Item_Discount_Rate < 0.3 THEN '20-30%'
        ELSE '30%+'
    END;