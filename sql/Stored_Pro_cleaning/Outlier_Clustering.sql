USE [SupplyChainDB]
GO

/****** Object:  StoredProcedure [dbo].[CheckOutlierClustering]    Script Date: 15-09-2026 19:57:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- 2. Outlier Clustering Check (4 parameters)
-- Finds which GroupByColumn has the most rows below/above a threshold
-- ============================================
CREATE PROCEDURE [dbo].[CheckOutlierClustering]
    @TableName NVARCHAR(100), @ValueColumn NVARCHAR(100),
    @GroupByColumn NVARCHAR(100), @Threshold FLOAT
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT ' + @GroupByColumn + ', COUNT(*) AS cnt
                FROM ' + @TableName + '
                WHERE ' + @ValueColumn + ' < ' + CAST(@Threshold AS NVARCHAR(50)) + '
                GROUP BY ' + @GroupByColumn + '
                ORDER BY cnt DESC';
    EXEC sp_executesql @sql;
END
GO


