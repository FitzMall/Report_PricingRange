USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeSum]    Script Date: 1/5/2023 8:40:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[PricingRangeSum]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/****** Object:  StoredProcedure [dbo].[PricingRange]    Script Date: 11/17/2022 11:38:25 AM ******/

--start by getting raw data with consumer rebates ZEROED if expiration has taken place
-- this makes bucketing them easier later ie InStock3 etc

SELECT [Id]
      ,[StyleId]
      ,[XrefId]
      ,[UseOptions]
      ,[StockNumber]
      ,[VehicleCondition]
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
      ,[ModelCode]
      ,[ModelYear]
      ,CAST([ModelYear] AS VARCHAR(4)) AS ModelYearString
      ,[Vin]
      ,[VehicleStatus]
      ,[InternetPrice]
      ,[DeliveredPrice]
      ,[InvoicePrice]
      ,[MSRPPrice]
      ,[KBBPrice]
      ,[KBBEdition]
      ,[CRAmount]
      ,[CRAmount] AS EffectiveCRAmount
      ,[FDAmount]
      ,[Holdback]
      ,[S_MARKET]
      ,[S_STORENAME]
      ,[S_DEPARTMENT]
      ,[S_SHOWROOM]
      ,[S_MALLCODE]
      ,[S_LOCCODE]
      ,[S_MAKECODE]
      ,[S_MAKENAME]
      ,[CRStartDate]
      ,[CREndDate]
      ,[FDStartDate]
      ,[FDEndDate]
      ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
      ,[MAPPrice]
      ,[LowestMAAPPrice]
      ,[FuelType]
      ,[HasInspection]
      ,[DaysInInventory],
    [VideoCount]
    INTO #PricingCRAdjusted
  FROM [FITZWAY].[dbo].[FM_VehicleResults] WHERE VehicleCondition = 'NEW'
  
  UPDATE #PricingCRAdjusted SET EffectiveCRAmount = 0 WHERE (datediff(day,[CREndDate],getdate()) > 0)


  
SELECT COUNT([Id]) AS Id
      ,[LocationCode]
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

-- code here to fix missing brands/models under each location


SELECT a.[V_ID] AS Id
      ,a.[V_styleid] AS StyleId
      ,a.[V_xrefid] AS XrefId
      ,a.[V_useoptions] AS UseOptions
      ,a.[V_stock] AS StockNumber
      ,a.[V_nu] AS VehicleCondition
      ,a.[V_loc] AS LocationCode
      ,a.[V_mall] AS MallCode
      ,a.[V_Year] AS ModelYearString
      ,CAST(a.[V_Year] AS Int) AS ModelYear
      ,a.[V_MakeCode] AS MakeCode
      ,LTRIM(a.[V_MakeName]) As MakeName
      ,LTRIM(a.[V_ModelName]) AS ModelName
      ,a.[V_StyleCode] as ModelCode
      ,'' as StyleName
      ,a.[V_daysinv] as DaysInInventory
      ,a.[V_Vin] as Vin
        ,0 as CRAmount
		,0 as FDAmount
      ,'N' as MatrixPricing
      ,a.[V_Status] as VehicleStatus
      ,a.[v_cramt] AS EffectiveCRAmount
    INTO #CarHistoryRecent
  FROM [FITZWAY].[dbo].[AllInventory_history] a 
  WHERE a.[V_nu] = 'NEW' and DATEDIFF(DAY, a.[V_SAVEID],GETDATE()) <= 190
 

    --add possible missing models/makes
	
SELECT COUNT([Id]) AS CountOf
	 ,0 AS Id
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
	  ,[ModelCode]
	  ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
	  ,[VehicleStatus]
	  ,[CRAmount]
	  ,[EffectiveCRAmount]
	  ,[DaysInInventory]
      , PricingStatus = '  '
    , BucketDaysInInventory = '  '
	, CRExpired = 'Expired'
	INTO #ModelsAvailable
  FROM #CarHistoryRecent GROUP BY [LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
 	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
      ,[MatrixPricing]
      ,[StyleName]
 	  ,[VehicleStatus]
	  ,[CRAmount]
	  ,[EffectiveCRAmount]
	, [DaysInInventory]
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
	  	  ,[VehicleStatus]
	  ,[CRAmount]
	  ,[EffectiveCRAmount]
	  ,[DaysInInventory]

	  INSERT INTO #PricingRange1 (Id
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
  	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired )
	    SELECT SUM([Id]) AS Id
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
  	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired 
	FROM #ModelsAvailable
	  GROUP BY [LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,[MakeName]
      ,[ModelName]
  	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired 
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
      , PricingStatus 
	 ,BucketDaysInInventory
	 

	DROP TABLE #CarHistoryRecent
	DROP TABLE #ModelsAvailable

	  UPDATE #PricingRange1 SET MakeName = REPLACE(MakeName,' ','') WHERE MakeName LIKE '%truck%' 
  UPDATE #PricingRange1 SET MakeName = REPLACE(MakeName,'TRUCK','') WHERE MakeName LIKE '%truck%' 

	  UPDATE #PricingRange1 SET MakeName = REPLACE(MakeName,'   ','')
	  UPDATE #PricingRange1 SET MakeName = REPLACE(MakeName,'  ','')
	  UPDATE #PricingRange1 SET MakeName = 'Cadillac' WHERE MakeCode = 'TK'
	     
  SELECT SUM([Id]) AS Id
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,LTRIM([MakeName]) as MakeName
      ,LTRIM([ModelName]) as ModelName
  	  ,[ModelCode]
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
      ,[trim]
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired 
	FROM #PricingRange1
	  GROUP BY [LocationCode]
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
      , PricingStatus 
	 ,BucketDaysInInventory
	  ,CRExpired 
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

	
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingCRAdjusted' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingCRAdjusted;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingRange1' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingRange1;

