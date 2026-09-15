SELECT Shipping_Mode, 
       MIN(Days_for_shipping_real - Days_for_shipment_scheduled) AS Min_Gap,
       MAX(Days_for_shipping_real - Days_for_shipment_scheduled) AS Max_Gap,
       AVG(Days_for_shipping_real - Days_for_shipment_scheduled) AS Avg_Gap
FROM Orders
GROUP BY Shipping_Mode;