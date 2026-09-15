USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[Check_dataType_Length]    Script Date: 15-09-2026 19:54:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[Check_dataType_Length] @TableName nvarchar(100) , @ColumnName nvarchar(100)
as
begin
    SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = @TableName AND COLUMN_NAME = @ColumnName;
end 
GO


