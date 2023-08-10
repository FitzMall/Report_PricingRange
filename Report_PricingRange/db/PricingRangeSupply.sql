USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeSupply]    Script Date: 8/1/2023 4:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Burroughs
-- Create date: Dec 2022
-- Description:	supply of cars (cars sold last 30 days/cars we have now) math done in code
-- =============================================
CREATE PROCEDURE [dbo].[PricingRangeSupply_CHROME]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	-- Correcting model name by vin for models still in stock

SELECT DISTINCT [V_styleid]
	  ,[V_DeptId]
      ,[V_Year]
      ,[V_MakeCode]
      ,[V_MakeName]
      ,[V_ModelName]
      ,[V_StyleCode]
      ,[V_StyleName]
      ,[V_Vin]
	  INTO #ModelCodeAndName
  FROM [FITZWAY].[dbo].[AllInventory]
  
   SELECT [loc] AS [LocationCode]
      ,1 AS Cars
      ,CAST([yr] AS int) AS [ModelYear]
      ,CAST([yr] AS varchar(4)) AS [ModelYearString]
      ,UPPER(RTRIM([make])) AS [MakeName]
      ,UPPER(RTRIM([mk])) AS [MakeCode]
      ,UPPER(RTRIM([carline])) AS [ModelName]
      ,UPPER(RTRIM([carline])) AS [ModelName_Original]
       ,UPPER(RTRIM([mdl_no])) + RTRIM(yr) AS [ModelCode]
       ,UPPER(RTRIM([mdl_no])) + RTRIM(yr) AS [ModelCode_Original]
      ,[mdl_desc] AS [StyleName]
	  ,serial_no AS Vin
 INTO #SoldTempData
 FROM [10.254.162.196].[FOXPROTABLES].[dbo].[RCI_fimaster]  where deal_date > DATEADD(day, -31, GETDATE()) 
  and nuo = 'N' and (Category = 'R' or Category= 'L') and (status = 'F' or Status = 'C')
  AND COALESCE(mdl_no, '') != ''

 UPDATE #SoldTempData SET [ModelName] = (
 SELECT TOP 1 UPPER(LTRIM(RTRIM(B.[V_ModelName]))) AS [ModelName]
 FROM #SoldTempData A JOIN  
 #ModelCodeAndName B ON A.[Vin] = b.V_Vin
  WHERE #SoldTempData.Vin = b.V_Vin and b.V_ModelName IS NOT NULL 
)  

UPDATE #SoldTempData SET [ModelName] = [ModelName_Original] WHERE ModelName IS NULL

 UPDATE #SoldTempData SET [ModelCode] = (
 SELECT TOP 1 UPPER(LTRIM(RTRIM(B.[V_StyleCode]))) AS [ModelCode]
 FROM #SoldTempData A JOIN  
 #ModelCodeAndName B ON A.[Vin] = b.V_Vin
  WHERE #SoldTempData.Vin = b.V_Vin and b.[V_StyleCode] IS NOT NULL 
)  

UPDATE #SoldTempData SET [ModelCode] = [ModelCode_Original] WHERE ModelCode IS NULL

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
	ORDER BY    MakeName, ModelCode, ModelName,LocationCode, Cars, ModelYear, ModelYearString,
	StyleName

  DROP TABLE #SoldTempData
  DROP TABLE #ModelCodeAndName

END

