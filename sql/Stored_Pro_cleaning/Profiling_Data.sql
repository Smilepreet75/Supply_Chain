USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[profiling_data]    Script Date: 15-09-2026 20:00:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[profiling_data] @TableName nvarchar(100), @Columnname nvarchar(100)
as 
begin
     declare @sql nvarchar(max);

     -- Row count
    set @sql= 'SELECT COUNT(*) FROM ' + @TableName;

-- Column list and types
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = @TableName;

-- Sample rows
    set @sql = 'SELECT TOP 20 * FROM ' + @TableName;
exec sp_executesql @sql;
end
GO


