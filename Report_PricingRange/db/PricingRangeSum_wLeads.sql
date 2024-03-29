USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeSum_wLeads]    Script Date: 2/21/2023 4:12:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Dave Burroughs
-- Create date: Dec 2022
-- Description:	Pricing Range Sum including in-stock, on-order and sold in last 30 days
-- =============================================
ALTER PROCEDURE [dbo].[PricingRangeSum_wLeads]
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
    INTO #PricingCRAdjusted1
  FROM [FITZWAY].[dbo].[FM_VehicleResults] WHERE VehicleCondition = 'NEW'
  
  UPDATE #PricingCRAdjusted1 SET EffectiveCRAmount = 0 WHERE (datediff(day,[CREndDate],getdate()) > 0)

    SELECT COUNT([LeadID]) AS Leads, VOfInterest_VIN AS VIN
  INTO #LeadTotalsByStockNumber
  FROM 
 [10.254.162.196].[VINSolutions_API].[dbo].[Vin_LeadInfo]  
  WHERE DATEDIFF(d,leadcreated,getdate()) < 31
  AND VOfInterest_StockNumber NOT LIKE '%*O%'
  GROUP BY VOfInterest_VIN
  
  SELECT a.[Id]
      ,a.[StyleId]
      ,a.[XrefId]
      ,a.[UseOptions]
      ,a.[StockNumber]
      ,a.[VehicleCondition]
      ,a.[LocationCode]
      ,a.[MallCode]
      ,a.[MakeCode]
      ,a.[MakeName]
      ,a.[ModelName]
      ,a.[ModelCode]
      ,a.[ModelYear]
      ,CAST(a.[ModelYear] AS VARCHAR(4)) AS ModelYearString
      ,a.[Vin]
      ,a.[VehicleStatus]
      ,a.[InternetPrice]
      ,a.[DeliveredPrice]
      ,a.[InvoicePrice]
      ,a.[MSRPPrice]
      ,a.[KBBPrice]
      ,a.[KBBEdition]
      ,a.[CRAmount]
      ,a.[CRAmount] AS EffectiveCRAmount
      ,a.[FDAmount]
      ,a.[Holdback]
      ,a.[S_MARKET]
      ,a.[S_STORENAME]
      ,a.[S_DEPARTMENT]
      ,a.[S_SHOWROOM]
      ,a.[S_MALLCODE]
      ,a.[S_LOCCODE]
      ,a.[CRStartDate]
      ,a.[CREndDate]
      ,a.[FDStartDate]
      ,a.[FDEndDate]
      ,a.[MatrixPricing]
      ,a.[StyleName]
      ,a.[trim]
      ,a.[MAPPrice]
      ,a.[LowestMAAPPrice]
      ,a.[FuelType]
      ,a.[HasInspection]
      ,a.[DaysInInventory]
      ,b.Leads
    ,a.[VideoCount] INTO #PricingCRAdjusted FROM #PricingCRAdjusted1 a LEFT JOIN #LeadTotalsByStockNumber b
    ON a.Vin = b.VIN
  
  DROP TABLE #PricingCRAdjusted1
  DROP TABLE #LeadTotalsByStockNumber
  
SELECT COUNT([Id]) AS Id
		,SUM(Leads) AS Leads
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

-- below: fix missing brands/models under each location
 
  SELECT a.[loc] AS [LocationCode]
      ,COUNT(a.[deal_no]) AS Cars
	  , 0 AS Id
	  , 0 AS Leads
      ,CAST(a.[yr] AS int) AS [ModelYear]
      ,CAST(a.[yr] AS varchar(4)) AS [ModelYearString]
      ,b.[v_MakeName] AS [MakeName]
      ,b.[v_MakeCode] AS [MakeCode]
      ,b.[v_Modelname] AS [ModelName]
       ,RTRIM(a.[mdl_no]) + RTRIM(a.[yr]) AS [ModelCode]
	         ,'' AS [StyleName]
   , '  ' AS BucketDaysInInventory 
	, 'Expired' AS CRExpired
        ,0 AS CRAmount
		,0 AS FDAmount
      ,'N' AS MatrixPricing
	  ,'' AS PricingStatus
	  ,'' AS trim
  INTO #CarSales
 FROM [10.254.162.196].[FOXPROTABLES].[dbo].[RCI_fimaster] a  
  JOIN AllInventory b ON a.mdl_no = b.V_StyleCode
 where deal_date > DATEADD(day, -31, GETDATE()) AND
  ( RTRIM(carline) + RTRIM([mdl_no]) + RTRIM(a.[yr]) + RTRIM(b.V_loc) ) NOT IN (SELECT RTRIM(ModelName) + RTRIM(ModelCode) + RTRIM(ModelYear) + RTRIM(LocationCode) FROM #PricingRange1)
  and nuo = 'N' and (Category = 'R' or Category= 'L') and (status = 'F' or Status = 'C')
  GROUP BY   a.[loc] 
      ,a.[yr] 
      ,b.[v_MakeName] 
      ,b.[v_MakeCode]
      ,b.[v_Modelname] 
       ,a.[mdl_no]  

	    -- Move items re brand to different parts of a location
  UPDATE #CarSales SET LocationCode = 'FTO' WHERE LocationCode = 'FTN' 

  UPDATE #CarSales SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'XG' 
  UPDATE #CarSales SET LocationCode = 'CHY' WHERE LocationCode = 'CJE' AND MakeCode = 'HY' 
  UPDATE #CarSales SET LocationCode = 'CSS' WHERE LocationCode = 'CJE' AND MakeCode = 'SU' 

  UPDATE #CarSales SET LocationCode = 'FCG' WHERE LocationCode = 'FAM' 

  UPDATE #CarSales SET MakeName = REPLACE(MakeName,' ','') WHERE MakeName LIKE '%truck%' 
  UPDATE #CarSales SET MakeName = REPLACE(MakeName,'TRUCK','') WHERE MakeName LIKE '%truck%' 
  

  INSERT INTO #PricingRange1 (Id, Leads
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
		, SUM(Leads) AS Leads
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

  SELECT SUM([Id]) AS Id, COALESCE(SUM(Leads),0) AS Leads
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
	FROM #PricingRange1
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

	
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#CarSales' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #CarSales;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingCRAdjusted' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingCRAdjusted;

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#PricingRange1' AND TABLE_SCHEMA = 'dbo')
DROP TABLE #PricingRange1;


