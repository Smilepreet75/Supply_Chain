USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[CheckFullRowDuplicates]    Script Date: 15-09-2026 19:57:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ============================================
-- 3. Full Row Duplicate Check (2 parameters, auto-pulls column list)
-- ============================================
CREATE PROCEDURE [dbo].[CheckFullRowDuplicates] @TableName NVARCHAR(100)
AS
BEGIN
    DECLARE @columns NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);

    -- Build a comma-separated column list automatically from INFORMATION_SCHEMA
    SELECT @columns = STRING_AGG(COLUMN_NAME, ', ')
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName;

    SET @sql = 'SELECT ' + @columns + ', COUNT(*) AS cnt
                FROM ' + @TableName + '
                GROUP BY ' + @columns + '
                HAVING COUNT(*) > 1';
    EXEC sp_executesql @sql;
END
GO


