USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[Null_data_Check]    Script Date: 15-09-2026 20:00:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[Null_data_Check] @TableName nvarchar(100), @ColumnName nvarchar(100)
as
begin
     declare @null_variable nvarchar(max);
     set @null_variable = 'select count(*) as Total_row, sum(case when ' + @ColumnName + ' is null then 1 else 0 end) as Null_Count,
                           CAST(SUM(CASE WHEN ' + @ColumnName +' IS NULL THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS null_percentage from ' + @TableName;
exec sp_executesql @null_variable;
end
GO


