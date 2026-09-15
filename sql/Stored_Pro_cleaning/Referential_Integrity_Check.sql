USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[CheckReferentialIntegrity]    Script Date: 15-09-2026 19:58:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================
-- 1. Referential Integrity Check (4 parameters)
-- ============================================
CREATE PROCEDURE [dbo].[CheckReferentialIntegrity]
    @ChildTable NVARCHAR(100), @ChildColumn NVARCHAR(100),
    @ParentTable NVARCHAR(100), @ParentColumn NVARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT c.' + @ChildColumn + ' FROM ' + @ChildTable + ' c
                LEFT JOIN ' + @ParentTable + ' p ON c.' + @ChildColumn + ' = p.' + @ParentColumn + '
                WHERE p.' + @ParentColumn + ' IS NULL';
    EXEC sp_executesql @sql;
END
GO


