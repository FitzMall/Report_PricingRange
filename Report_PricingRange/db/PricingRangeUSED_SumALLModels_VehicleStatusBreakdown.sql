USE [fitzway]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeUSED_SumALLModels_VehicleStatusBreakdown]    Script Date: 4/11/2024 8:54:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Dave Burroughs
-- Create date: Dec 2022
-- Description:	Pricing Range Sum including in-stock, on-order and sold in last 30 days
-- =============================================
CREATE PROCEDURE [dbo].[PricingRangeUSED_SumALLModels_VehicleStatusBreakdown]
	-- Add the parameters for the stored procedure here

AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/****** Object:  StoredProcedure [dbo].[PricingRangeUSED_]    Script Date: 11/17/2022 11:38:25 AM ******/

--start by getting raw data with consumer rebates ZEROED if expiration has taken place
-- this makes bucketing them easier later ie InStock3 etc

SELECT V_ID AS [Id] 
      ,[V_styleid] AS StyleId
      ,[V_xrefid] AS XrefId
      ,[V_useoptions] AS UseOptions 
      ,[V_stock] AS StockNumber 
      ,[V_nu] AS VehicleCondition 
      ,[V_loc] AS LocationCode 
      , [V_mall] AS MallCode 
      ,[V_MakeCode] AS MakeCode 
      ,[V_MakeName] AS MakeName 
      ,[V_ModelName] AS ModelName 
      ,[V_StyleCode] AS ModelCode 
      ,[V_Year] AS ModelYearString
      ,CAST([V_Year] AS INT) AS ModelYear
      , [V_Vin] AS Vin
      ,[V_Status] AS VehicleStatus 
      ,[V_int_price] AS InternetPrice  
	  ,[V_del_price] AS DeliveredPrice   
	  ,[V_inv_price] AS InvoicePrice 
	  ,[V_msrp_price] AS MSRPPrice
      ,[V_kbb_price] AS KBBPrice
      ,[V_kbb_edition] AS KBBEdition
      ,[V_cramt] AS CRAmount
      ,[V_cramt] AS EffectiveCRAmount   
      ,[V_fdamt] AS FDAmount
      ,[V_holdback] AS Holdback
      ,[v_MarketClass] AS[S_MARKET] 
      ,'' AS [S_STORENAME]  
	  ,[V_DeptId] AS [S_DEPARTMENT] 
      ,'' AS [S_SHOWROOM]  
      ,[V_mall] AS [S_MALLCODE] 
	  ,v_loc AS [S_LOCCODE] 
	  ,[v_crstart] AS [CRStartDate]  
      ,[v_crend] AS [CREndDate]  
      ,[v_fdstart] AS [FDStartDate]  
      ,[v_fdend] AS [FDEndDate]  
      ,[v_matrix] AS [MatrixPricing]  
      ,[V_StyleName] AS [StyleName]  
      ,[V_intcolor] AS [trim] 
      ,0 AS [MAPPrice]  
      ,0 AS [LowestMAAPPrice]
      ,[v_fuel] AS [FuelType]
      ,0 AS [HasInspection] 
      ,v_daysinv AS [DaysInInventory],
		0 AS [VideoCount] 
    INTO #PricingCRAdjusted
  FROM [FITZWAY].[dbo].[AllInventory] WHERE V_NU = 'USED' AND V_Status != 5
  
  UPDATE #PricingCRAdjusted SET EffectiveCRAmount = 0 WHERE (datediff(day,[CREndDate],getdate()) > 0)
  UPDATE #PricingCRAdjusted SET ModelName = 'OUTBACK' WHERE ModelName = 'OUTBACK WAGON' 
    UPDATE #PricingCRAdjusted SET ModelName = 'IMPREZA' WHERE ModelName = 'IMPREZA WAGON' 
	   UPDATE #PricingCRAdjusted SET ModelName = 'TACOMA' WHERE ModelName LIKE '%tacoma%' AND ModelName NOT LIKE '%hybrid%'
  UPDATE #PricingCRAdjusted SET ModelName = 'TUNDRA' WHERE ModelName LIKE '%tundra%' AND ModelName NOT LIKE '%hybrid%'
  UPDATE  #PricingCRAdjusted SET LocationCode = 'CSS' WHERE MakeName = 'SUBARU' AND LocationCode = 'CJE'
  UPDATE  #PricingCRAdjusted SET LocationCode = 'CHY' WHERE MakeName = 'HYUNDAI' AND LocationCode = 'CJE'
  UPDATE  #PricingCRAdjusted SET LocationCode = 'CHY' WHERE MakeName = 'GENESIS' AND LocationCode = 'CJE'
  
SELECT COUNT([Id]) AS Id
      ,[LocationCode]
      ,[MallCode]
      ,[MakeCode]
      ,MakeName
      ,RTRIM(ModelName) AS ModelName
	  ,RTRIM([ModelCode]) + RTRIM(ModelYear) AS ModelCode
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
		  WHEN ([InternetPrice] + [EffectiveCRAmount]) > [MSRPPrice] AND VehicleStatus  not in (1,2,3, 5, 6,7,8) THEN 'OnOrder1'
	  WHEN ([InternetPrice] + [EffectiveCRAmount]) = [MSRPPrice] AND VehicleStatus  not in (1,2,3, 5, 6,7,8) THEN 'OnOrder2'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice + 200)  and VehicleStatus  not in (1,2,3, 5, 6,7,8) THEN 'OnOrder3'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and ((internetprice + [EffectiveCRAmount]) < (invoiceprice + 200)
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice))   and VehicleStatus  not in (1,2,3, 5, 6,7,8) then 'OnOrder3'
		 when ((internetprice + [EffectiveCRAmount]) < msrpprice) 
	and ((internetprice + [EffectiveCRAmount]) < (invoiceprice))   and VehicleStatus  not in (1,2,3, 5, 6,7,8) then 'OnOrder5'
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
  FROM #PricingCRAdjusted WHERE VehicleStatus != 5 GROUP BY [LocationCode]
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




-- below: fix missing brands/models under each location (so sales in last 30 are not lost)
 
SELECT DISTINCT 
      [yr]
      ,[make]
	  ,mk
      ,[carline]
      ,[mdl_no]
	INTO #TEMP_MakesModels	
  FROM  [FOXPROTABLES].[dbo].[RCI_fimaster] WHERE nuo = 'U'
  AND yr IS NOT NULL AND deal_date > DATEADD(day, -31, GETDATE())
    AND mdl_no IS NOT NULL



SELECT DISTINCT 
		loc
      ,[make]
	  , mk
	  INTO #TEMP_MakesLocs	
  FROM  [FOXPROTABLES].[dbo].[RCI_fimaster] WHERE nuo = 'U'
  AND yr IS NOT NULL AND deal_date > DATEADD(day, -31, GETDATE())
  AND loc IS NOT NULL

   SELECT a.[loc] AS [LocationCode]
      ,1 AS Cars
   , 1 AS Id
        ,CAST([yr] AS int) AS [ModelYear]
      ,CAST([yr] AS varchar(4)) AS [ModelYearString]
      ,UPPER(RTRIM(b.[make])) AS [MakeName]
      ,UPPER(RTRIM(b.[mk])) AS [MakeCode]
      ,UPPER(RTRIM(b.[carline])) AS [ModelName]
       ,UPPER(RTRIM(b.[mdl_no])) + RTRIM(b.yr) AS [ModelCode]
      ,'' AS [StyleName]
 , '  ' AS BucketDaysInInventory 
	, 'Expired' AS CRExpired
        ,0 AS CRAmount
		,0 AS FDAmount
      ,'U' AS MatrixPricing
	  ,'' AS PricingStatus
	  ,'' AS trim
INTO #CarSales FROM #TEMP_MakesLocs a RIGHT JOIN #TEMP_MakesModels b
  ON a.[make] = b.[make] ORDER BY a.loc, b.make, b.carline, b.mdl_no

DROP TABLE #TEMP_MakesModels	
DROP TABLE #TEMP_MakesLocs


	    -- Move items re brand to different parts of a location
  UPDATE #CarSales SET LocationCode = 'FTO' WHERE LocationCode = 'FTN' 

  UPDATE #CarSales SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'XG' 
  UPDATE #CarSales SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'HY' 
  UPDATE #CarSales SET LocationCode = 'CSS' WHERE LocationCode = 'CJE' AND MakeCode = 'SU' 

  UPDATE #CarSales SET LocationCode = 'FCG' WHERE LocationCode = 'FAM' 

  UPDATE #CarSales SET MakeName = REPLACE(MakeName,' ','') WHERE MakeName LIKE '%truck%' 
  UPDATE #CarSales SET MakeName = REPLACE(MakeName,'TRUCK','') WHERE MakeName LIKE '%truck%' 
  UPDATE #CarSales SET ModelName = 'OUTBACK' WHERE ModelName = 'OUTBACK WAGON' 
    UPDATE #CarSales SET ModelName = 'IMPREZA' WHERE ModelName = 'IMPREZA WAGON' 
   UPDATE #CarSales SET ModelName = 'TACOMA' WHERE ModelName LIKE '%tacoma%' AND ModelName NOT LIKE '%hybrid%'
  UPDATE #CarSales SET ModelName = 'TUNDRA' WHERE ModelName LIKE '%tundra%' AND ModelName NOT LIKE '%hybrid%'

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
	    SELECT Id
      ,[LocationCode]
      ,[MakeCode] 
      , [MakeName] 
      ,[ModelName]
  	  , [ModelCode] 
     ,[ModelYear]
       ,[ModelYearString]
     ,[MatrixPricing]
      ,[StyleName]
	 ,BucketDaysInInventory
	 ,PricingStatus
	  ,CRExpired 
	FROM #CarSales
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

 --   UPDATE #PricingRange1 SET ModelName = 'IONIQ 5' WHERE ModelName = 'IONIQ' 

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
	  ,VehicleStatus
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
	  ,VehicleStatus
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
	  ,VehicleStatus

	
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CarSales' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CarSales;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingCRAdjusted' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingCRAdjusted;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingRange1' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingRange1;



