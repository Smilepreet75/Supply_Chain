SELECT 
    CASE 
        WHEN Order_Item_Discount_Rate < 0.1 THEN '0-10%'
        WHEN Order_Item_Discount_Rate < 0.2 THEN '10-20%'
        WHEN Order_Item_Discount_Rate < 0.3 THEN '20-30%'
        ELSE '30%+'
    END AS Discount_Bucket,
    AVG(Order_Item_Profit_Ratio) AS Avg_Profit_Ratio
FROM Order_Items
GROUP BY 
    CASE 
        WHEN Order_Item_Discount_Rate < 0.1 THEN '0-10%'
        WHEN Order_Item_Discount_Rate < 0.2 THEN '10-20%'
        WHEN Order_Item_Discount_Rate < 0.3 THEN '20-30%'
        ELSE '30%+'
    END;