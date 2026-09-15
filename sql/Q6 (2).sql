select Late_delivery_risk, COUNT(DISTINCT o.Order_Id) AS Orders,
    AVG(oi.Order_Profit_Per_Order) AS Avg_Profit,
    avg(Order_Item_Discount) as Avg_Discount,
sum(Order_Item_Discount) as Discount, sum(Order_Profit_Per_Order) as Profit 
from Order_Items as oi left join Orders o on oi.Order_Id = o.Order_Id group by Late_delivery_risk;