USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[duplicate_primarykey_Check]    Script Date: 15-09-2026 19:58:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[duplicate_primarykey_Check] @TableName nvarchar(100) , @ColumnName nvarchar(100)
as 
begin
     declare @key_Check nvarchar(max);
     set @key_Check = 'select ' + @ColumnName + ', count(*) from ' + @TableName + ' group by ' + @ColumnName + ' having count(*)>1 ';
exec sp_executesql @key_Check;
end
GO


