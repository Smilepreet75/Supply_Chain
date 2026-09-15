USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[Late_Delivery_Analysis]    Script Date: 15-09-2026 19:51:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Late_Delivery_Analysis] @TableName nvarchar(100), @RiskColumn NVARCHAR(100),@GroupColumnName nvarchar(100)
as
begin
     SET NOCOUNT ON;
     declare @sql nvarchar(max);
     set @sql = 'select ' + @GroupColumnName +', cast(sum(case when ' + @RiskColumn + ' =1 then 1 else 0 end) as float) *100 / count( ' + @RiskColumn + ' ) as Percentage_LateDelivery 
     from ' + @TableName + ' group by ' + @GroupColumnName + ' order by Percentage_LateDelivery desc ';
exec sp_executesql @sql;
end
GO


