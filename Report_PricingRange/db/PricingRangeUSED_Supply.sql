USE [fitzway]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeUSED_Supply]    Script Date: 4/11/2024 8:56:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Burroughs
-- Create date: Dec 2022
-- Description:	supply of cars (cars sold last 30 days/cars we have now) math done in code
-- =============================================
CREATE PROCEDURE [dbo].[PricingRangeUSED_Supply]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Correcting model name by vin for models still in stock

SELECT v.[VIN]
      ,v.[Year] AS [V_Year]
      ,v.[Make] AS [V_MakeName]
      ,v.[Model] AS [V_ModelName]
      ,v.[ModelId]
      ,v.[StyleId]
      ,v.[DateUpdated]
	  ,RTRIM(s.[MFRModelCode]) + RTRIM(v.[Year]) AS [V_StyleCode]
	  INTO #ModelCodeAndName
  FROM [ChromeDataCVD].[dbo].[Vehicle] v
  JOIN [ChromeDataCVD].[dbo].[Styles] s
  ON v.StyleId = s.StyleId WHERE Model != 'IONIQ'

   SELECT r.[loc] AS [LocationCode]
      ,1 AS Cars
      ,CAST(r.[yr] AS int) AS [ModelYear]
      ,CAST(r.[yr] AS varchar(4)) AS [ModelYearString]
      ,UPPER(RTRIM(r.[make])) AS [MakeName]
      ,UPPER(RTRIM(r.[mk])) AS [MakeCode]
      ,UPPER(RTRIM(m.V_ModelName)) AS [ORIG_ModelName]
       ,UPPER(RTRIM(m.V_StyleCode)) AS [ModelCode]
      ,UPPER(RTRIM(r.carline)) AS [ModelName]
       ,UPPER(RTRIM(r.mdl_no ) + RTRIM(r.[yr])) AS [ORIG_ModelCode]
      ,r.[mdl_desc] AS [StyleName]
	  ,r.serial_no AS Vin
 INTO #SoldTempData
 FROM [FOXPROTABLES].[dbo].[RCI_fimaster] r
  LEFT JOIN #ModelCodeAndName m ON r.serial_no = m.VIN
  where r.deal_date > DATEADD(day, -31, GETDATE()) 
  and r.nuo = 'U' and (Category = 'R' or Category= 'L') and (r.status = 'F' or r.Status = 'C')
  AND RTRIM(LTRIM(COALESCE(r.mdl_no, ''))) != ''
    group by  r.[loc] 
       ,r.[yr]  
      ,r.[yr] 
      ,r.[make] 
      ,r.[mk]
      ,m.V_ModelName 
       ,m.V_StyleCode 
      ,r.carline
       ,r.mdl_no
      ,r.[mdl_desc]
	  , r.serial_no

  UPDATE #SoldTempData SET ModelName = ORIG_ModelName WHERE ModelName IS NULL
  UPDATE #SoldTempData SET ModelCode = ORIG_ModelCode WHERE ModelCode IS NULL

	    -- Move items re brand to different parts of a location
  UPDATE #SoldTempData SET LocationCode = 'FTO' WHERE LocationCode = 'FTN' 

  UPDATE #SoldTempData SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'XG' 
  UPDATE #SoldTempData SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'HY' 
  UPDATE #SoldTempData SET LocationCode = 'CSS' WHERE LocationCode = 'CJE' AND MakeCode = 'SU' 

  UPDATE #SoldTempData SET LocationCode = 'FCG' WHERE LocationCode = 'FAM' 

  UPDATE #SoldTempData SET MakeName = REPLACE(MakeName,' ','') WHERE MakeName LIKE '%truck%' 
  UPDATE #SoldTempData SET MakeName = REPLACE(MakeName,'TRUCK','') WHERE MakeName LIKE '%truck%' 
  UPDATE #SoldTempData SET ModelName = REPLACE(ModelName,' WAGON','') WHERE ModelName LIKE '%wagon%' 

  UPDATE #SoldTempData SET ModelName = 'TACOMA' WHERE ModelName LIKE '%tacoma%' AND ModelName NOT LIKE '%hybrid%'
  UPDATE #SoldTempData SET ModelName = 'TUNDRA' WHERE ModelName LIKE '%tundra%' AND ModelName NOT LIKE '%hybrid%'

  SELECT LocationCode, Cars, ModelYear, ORIG_ModelCode, ORIG_ModelName, ModelYearString, MakeName, ModelName, ModelCode,
	StyleName FROM #SoldTempData	
	ORDER BY   LocationCode, MakeName, ModelCode, ModelName, ModelYear, 
	StyleName

  DROP TABLE #SoldTempData
  DROP TABLE #ModelCodeAndName

END

