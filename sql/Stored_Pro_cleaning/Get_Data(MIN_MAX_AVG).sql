USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[GetColumnData]    Script Date: 15-09-2026 19:59:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[GetColumnData] @TableName nvarchar(100), @ColumnName nvarchar(100)
as
begin
     declare @sql nvarchar(max);
     set @sql = 'select min(' + @ColumnName +') as MinVal, max(' + @ColumnName +') as MaxVal, avg(' + @ColumnName +') as AvgVal from ' + @TableName;
     exec sp_executesql @sql;
end
GO


