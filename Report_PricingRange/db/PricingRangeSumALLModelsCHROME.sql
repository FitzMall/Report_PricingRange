USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeSumALLModelsCHROME]    Script Date: 8/10/2023 11:17:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Dave Burroughs
-- Create date: Dec 2022
-- Description:	Pricing Range Sum including in-stock, on-order and sold in last 30 days
-- =============================================
ALTER PROCEDURE [dbo].[PricingRangeSumALLModelsCHROME]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/****** Object:  StoredProcedure [dbo].[PricingRange]    Script Date: 11/17/2022 11:38:25 AM ******/

--start by getting raw data with consumer rebates ZEROED if expiration has taken place
-- this makes bucketing them easier later ie InStock3 etc
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CHROMEData' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CHROMEData;

SELECT DISTINCT v.[VIN]
	  , UPPER(v.VehicleLocation) AS VehicleLocation
      ,v.[Year] AS [V_Year]
      ,v.[Make] AS [V_MakeName]
      ,v.[Model] 
      ,v.[ModelId]
	  ,v.Manufacturer
      ,v.[StyleId]
      ,v.[DateUpdated]
	  ,RTRIM(s.[MFRModelCode]) + RTRIM(v.[Year]) AS [V_StyleCode]
	  INTO #CHROMEData
  FROM [ChromeDataCVD].[dbo].[Vehicle] v
  JOIN [ChromeDataCVD].[dbo].[Styles] s
  ON v.StyleId = s.StyleId

SELECT DISTINCT f.[Id]
      ,f.[StyleId]
      ,f.[XrefId]
      ,f.[UseOptions]
      ,f.[StockNumber]
      ,f.[VehicleCondition]
      ,f.[LocationCode]
      ,f.[MallCode]

      ,f.[MakeCode]
      ,f.[MakeName]

      ,UPPER(RTRIM(v.[Model])) AS [ModelName]
       , RTRIM(v.V_StyleCode) AS [ModelCode]
       ,f.[ModelYear]
      ,CAST(f.[ModelYear] AS VARCHAR(4)) AS ModelYearString
      ,f.[Vin]
      ,f.[VehicleStatus]
      ,f.[InternetPrice]
      ,f.[DeliveredPrice]
      ,f.[InvoicePrice]
      ,f.[MSRPPrice]
      ,f.[KBBPrice]
      ,f.[KBBEdition]
      ,f.[CRAmount]
      ,f.[CRAmount] AS EffectiveCRAmount
      ,f.[FDAmount]
      ,f.[Holdback]
      ,f.[S_MARKET]
      ,f.[S_STORENAME]
      ,f.[S_DEPARTMENT]
      ,f.[S_SHOWROOM]
      ,f.[S_MALLCODE]
      ,f.[S_LOCCODE]
      ,f.[CRStartDate]
      ,f.[CREndDate]
      ,f.[FDStartDate]
      ,f.[FDEndDate]
      ,f.[MatrixPricing]
      ,f.[StyleName]
      ,f.[trim]
      ,f.[MAPPrice]
      ,f.[LowestMAAPPrice]
      ,f.[FuelType]
      ,f.[HasInspection]
      ,f.[DaysInInventory],
		f.[VideoCount]
    INTO #PricingCRAdjusted
  FROM [FITZWAY].[dbo].[FM_VehicleResults] f 
  	JOIN #CHROMEData v ON v.VIN = f.Vin
  WHERE f.VehicleCondition = 'NEW' AND f.ModelCode IS NOT NULL AND
  f.ModelName IS NOT NULL
	
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CHROMEData' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CHROMEData;

  UPDATE #PricingCRAdjusted SET EffectiveCRAmount = 0 WHERE (datediff(day,[CREndDate],getdate()) > 0)
  
SELECT COUNT([Id]) AS Id
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,MakeName
      ,RTRIM(ModelName) AS ModelName
	  ,UPPER(RTRIM([ModelCode]))AS ModelCode
	  ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
	  ,[VehicleStatus]
	  ,[CRAmount]
	  ,[EffectiveCRAmount]
	  ,[Invoiceprice]
	  , [InternetPrice]
	  , [msrpprice]
	  ,[DaysInInventory]
	  ,[CREndDate]
      , PricingStatus =
	  CASE 
	  WHEN ([InternetPrice] + [EffectiveCRAmount]) > [MSRPPrice] AND VehicleStatus in (1,2) THEN 'InStock1'
	  WHEN ([InternetPrice] + [EffectiveCRAmount]) = [MSRPPrice] AND VehicleStatus in (1,2) THEN 'InStock2'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice + 200)  and VehicleStatus in (1,2) THEN 'InStock3'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and ((internetprice + [EffectiveCRAmount]) < (invoiceprice + 200)
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice))   and VehicleStatus in (1,2) then 'InStock3'
		 when ((internetprice + [EffectiveCRAmount]) < msrpprice) 
	and ((internetprice + [EffectiveCRAmount]) < (invoiceprice))   and VehicleStatus in (1,2) then 'InStock5'
		  WHEN ([InternetPrice] + [EffectiveCRAmount]) > [MSRPPrice] AND VehicleStatus  not in (1,2,3, 5, 6,7,8,15) THEN 'OnOrder1'
	  WHEN ([InternetPrice] + [EffectiveCRAmount]) = [MSRPPrice] AND VehicleStatus  not in (1,2,3, 5, 6,7,8,15) THEN 'OnOrder2'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice + 200)  and VehicleStatus  not in (1,2,3, 5, 6,7,8,15) THEN 'OnOrder3'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and ((internetprice + [EffectiveCRAmount]) < (invoiceprice + 200)
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice))   and VehicleStatus  not in (1,2,3, 5, 6,7,8,15) then 'OnOrder3'
		 when ((internetprice + [EffectiveCRAmount]) < msrpprice) 
	and ((internetprice + [EffectiveCRAmount]) < (invoiceprice))   and VehicleStatus  not in (1,2,3, 5, 6,7,8,15) then 'OnOrder5'
	END,
    	    BucketDaysInInventory =
	  CASE 
	  WHEN ([DaysInInventory] <= 30) THEN '0-30'
	  WHEN ([DaysInInventory] > 30 AND [DaysInInventory] <= 60) THEN '30-60'
	  WHEN ([DaysInInventory] > 60 AND [DaysInInventory] <= 90) THEN '60-90'
	  WHEN ([DaysInInventory] > 90) THEN '90+'
	  ELSE '  '
	 END,
	       CRExpired =
	  CASE 
	  WHEN ([EffectiveCRAmount] = 0 and [CRAmount] > 0)THEN 'Expired'
	  WHEN ([EffectiveCRAmount] = 0 and [CRAmount] = 0)THEN 'None'
	  ELSE 'Current'
	 END
	INTO #PricingRange1
  FROM #PricingCRAdjusted GROUP BY [LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
 	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
      ,[MatrixPricing]
      ,[StyleName]
      ,[trim] 	  ,[VehicleStatus]
	  ,[CRAmount]
	  ,[EffectiveCRAmount]
	  ,[Invoiceprice]
	  , [InternetPrice]
	  , [msrpprice] , [DaysInInventory], [CREndDate]
	  ORDER BY [LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
 	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
      ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
	  	  ,[VehicleStatus]
	  ,[CRAmount]
	  ,[EffectiveCRAmount]
	  ,[Invoiceprice]
	  , [InternetPrice]
	  , [msrpprice]
	  ,[DaysInInventory], [CREndDate]

  END;



  	
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CHROMEData' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CHROMEData;


-- below: fix missing brands/models under each location (so sales in last 30 are not lost)
 SELECT DISTINCT v.[VIN]
	  , UPPER(a.V_loc) AS VehicleLocation
     ,v.[Year] AS [V_Year]
      ,v.[Make] AS [V_MakeName]
      ,v.[Model] 
      ,v.[ModelId]
	  ,v.Manufacturer
      ,v.[StyleId]
      ,v.[DateUpdated]
	  ,RTRIM(s.[MFRModelCode]) + RTRIM(v.[Year]) AS [V_StyleCode]
	  ,a.V_MakeCode
	  INTO #CHROMEData2
  FROM [ChromeDataCVD].[dbo].[Vehicle] v
  JOIN [ChromeDataCVD].[dbo].[Styles] s
  ON v.StyleId = s.StyleId
  JOIN [FITZWAY].[dbo].AllInventory a
  ON v.Make = a.V_MakeName
  WHERE a.V_nu = 'NEW' AND v.VehicleLocation NOT LIKE '%*%' AND LEN(v.VehicleLocation) = 3
   AND v.VehicleLocation NOT IN ('COC','HAG','FBC','FSS','LFM','WDC','FBN')
 
SELECT COUNT(v.[VIN]) AS Cars
		,VehicleLocation AS [LocationCode]
   , 1 AS Id
        ,CAST([V_Year] AS int) AS [ModelYear]
      ,CAST([V_Year] AS varchar(4)) AS [ModelYearString]
      ,[V_MakeName] AS [MakeName]
      ,[V_MakeCode] AS [MakeCode]
      ,v.[Model]  AS [ModelName]
      ,v.[ModelId] AS [ModelCode]
	  ,[V_StyleCode]  AS [StyleName]
 , '  ' AS BucketDaysInInventory 
	, 'Expired' AS CRExpired
        ,0 AS CRAmount
		,0 AS FDAmount
      ,'N' AS MatrixPricing
	  ,'' AS PricingStatus
	  ,'' AS trim
INTO #CarSales
	  FROM #CHROMEData2 V
WHERE  (VIN) NOT IN (SELECT vin FROM #PricingCRAdjusted)
  GROUP BY  VehicleLocation
      ,[V_Year]
      ,[V_MakeName]
      ,[V_MakeCode]
      ,[Model]
       ,[ModelId]
      ,[V_StyleCode]

	    -- Move items re brand to different parts of a location
  UPDATE #CarSales SET LocationCode = 'FTO' WHERE LocationCode = 'FTN' 

  UPDATE #CarSales SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeName = 'GENESIS' 
  UPDATE #CarSales SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeName = 'HYUNDAI' 
  UPDATE #CarSales SET LocationCode = 'CSS' WHERE LocationCode = 'CJE' AND MakeName = 'SUBARU' 

  UPDATE #CarSales SET LocationCode = 'FCG' WHERE LocationCode = 'FAM' 

  UPDATE #CarSales SET MakeName = REPLACE(MakeName,' ','') WHERE MakeName LIKE '%truck%' 
  UPDATE #CarSales SET MakeName = REPLACE(MakeName,'TRUCK','') WHERE MakeName LIKE '%truck%' 
  

  INSERT INTO #PricingRange1 (Id
      ,[LocationCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
  	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
	 ,BucketDaysInInventory
	 ,PricingStatus
	  ,CRExpired )
	    SELECT SUM([Id]) AS Id
      ,[LocationCode]
      ,RTRIM([MakeCode]) AS [MakeCode] 
      ,RTRIM([MakeName]) AS [MakeName] 
      ,UPPER(RTRIM([ModelName])) AS [ModelName]
  	  ,RTRIM([ModelCode]) AS [ModelCode] 
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
	 ,BucketDaysInInventory
	 ,PricingStatus
	  ,CRExpired 
	FROM #CarSales
	  GROUP BY [LocationCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
  	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
	 ,BucketDaysInInventory
	 ,PricingStatus
	  ,CRExpired 
	  ORDER BY [LocationCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
 	  ,[ModelCode]
       ,[ModelYear]
       ,[ModelYearString]
    ,[MatrixPricing]
      ,[StyleName]
	 ,PricingStatus
	 ,BucketDaysInInventory
  ,CRExpired 
	 
	DROP TABLE #CarSales

	     UPDATE #PricingRange1 SET ModelName = 'IONIQ 5' WHERE ModelName = 'IONIQ' 

  SELECT SUM([Id]) AS Id
      ,[LocationCode]
      ,[MallCode]
      ,RTRIM([MakeCode]) AS [MakeCode]
      ,UPPER(RTRIM([MakeName])) as MakeName
      ,UPPER(RTRIM([ModelName])) as ModelName
  	  ,RTRIM([ModelCode]) AS [ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired 
  ,SUM(CASE WHEN PricingStatus LIKE 'InStock%' THEN [InvoicePrice] ELSE 0 END) AS InvoiceTotal	FROM #PricingRange1
	  GROUP BY [LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
  	  ,[ModelCode]
      ,[ModelName]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired 
	  ORDER BY [LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
 	  ,[ModelCode]
      ,[ModelName]
       ,[ModelYear]
       ,[ModelYearString]
    ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
	 
	
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CHROMEData2' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CHROMEData2;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CarSales' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CarSales;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingCRAdjusted' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingCRAdjusted;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingRange1' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingRange1;


