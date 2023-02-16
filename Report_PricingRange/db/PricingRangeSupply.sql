USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeSupply]    Script Date: 2/7/2023 1:47:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Burroughs
-- Create date: Dec 2022
-- Description:	supply of cars (cars sold last 30 days/cars we have now) math done in code
-- =============================================
ALTER PROCEDURE [dbo].[PricingRangeSupply]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT [loc] AS [LocationCode]
      ,COUNT([deal_no]) AS Cars
      ,CAST([yr] AS int) AS [ModelYear]
      ,CAST([yr] AS varchar(4)) AS [ModelYearString]
      ,UPPER(RTRIM([make])) AS [MakeName]
      ,UPPER(RTRIM([mk])) AS [MakeCode]
      ,UPPER(RTRIM([carline])) AS [ModelName]
       ,UPPER(RTRIM([mdl_no])) + RTRIM(yr) AS [ModelCode]
      ,[mdl_desc] AS [StyleName]
 INTO #SoldTempData
 FROM [10.254.162.196].[FOXPROTABLES].[dbo].[RCI_fimaster]  where deal_date > DATEADD(day, -30, GETDATE()) 
  and nuo = 'N' and (Category = 'R' or Category= 'L') and (status = 'F' or Status = 'C')
  AND COALESCE(mdl_no, '') != ''
  GROUP BY   [loc]
      ,[yr]
      ,[make]
      ,[mk]
      ,[carline]
       ,[mdl_no]
      ,[mdl_desc]

	    -- Move items re brand to different parts of a location
  UPDATE #SoldTempData SET LocationCode = 'FTO' WHERE LocationCode = 'FTN' 

  UPDATE #SoldTempData SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'XG' 
  UPDATE #SoldTempData SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'HY' 
  UPDATE #SoldTempData SET LocationCode = 'CSS' WHERE LocationCode = 'CJE' AND MakeCode = 'SU' 

  UPDATE #SoldTempData SET LocationCode = 'FCG' WHERE LocationCode = 'FAM' 

  UPDATE #SoldTempData SET MakeName = REPLACE(MakeName,' ','') WHERE MakeName LIKE '%truck%' 
  UPDATE #SoldTempData SET MakeName = REPLACE(MakeName,'TRUCK','') WHERE MakeName LIKE '%truck%' 

    UPDATE #SoldTempData SET ModelName = 'IONIQ 5' WHERE ModelName = 'IONIQ' 

  SELECT LocationCode, Cars, ModelYear, ModelYearString, MakeName, ModelName, ModelCode,
	StyleName FROM #SoldTempData
	ORDER BY   LocationCode, Cars, ModelYear, ModelYearString, MakeName, ModelName, ModelCode,
	StyleName

  DROP TABLE #SoldTempData

END
