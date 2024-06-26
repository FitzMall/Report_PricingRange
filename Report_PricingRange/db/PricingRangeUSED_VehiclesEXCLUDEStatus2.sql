USE [fitzway]
GO
/****** Object:  StoredProcedure [dbo].[PricingRangeUSED_VehiclesEXCLUDEStatus2]    Script Date: 4/11/2024 8:55:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Dave Burroughs
-- Create date: 5/17/23
-- Description:	for drill down to specific cars- exclude status 2 5/17/23
-- =============================================
ALTER PROCEDURE [dbo].[PricingRangeUSED_VehiclesEXCLUDEStatus2]
	-- Add the parameters for the stored procedure here
	@parPricingStatus varchar(20) = ''
           ,@parLoc varchar(5) = ''
           ,@StockNumber varchar(25) = ''
           ,@MakeName varchar(25) = ''
           ,@ModelName varchar(25) = ''
           ,@MatrixStatus varchar(1) = ''
           ,@CRExpired varchar(15) = ''
           ,@StyleName varchar(30) = ''
           ,@TrimName varchar(30) = ''
           ,@BucketDaysInInventory varchar(6) = ''
           ,@parModelYear int = 0
           ,@ModelCode varchar(30) = ''
  			,@VehicleStatus int = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

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
				, V_MakeCode AS S_MAKECODE
		, V_MakeName AS S_MAKENAME
		, v_markup AS Markup
		, v_MSRPInvoiceFlag as MSRPInvoiceFlag 
    INTO #PricingCRAdjusted
  FROM [FITZWAY].[dbo].[AllInventory] WHERE V_NU = 'USED' AND V_Status NOT IN (2, 5)
  
  UPDATE #PricingCRAdjusted SET EffectiveCRAmount = 0 WHERE (datediff(day,[CREndDate],getdate()) > 0)
  UPDATE #PricingCRAdjusted SET ModelName = 'IONIQ 5' WHERE ModelName = 'IONIQ' 
  UPDATE #PricingCRAdjusted SET ModelName = REPLACE(ModelName,' WAGON','') WHERE ModelName like '%wagon%' 
    UPDATE  #PricingCRAdjusted SET LocationCode = 'CSS' WHERE MakeName = 'SUBARU' AND LocationCode = 'CJE'
  UPDATE  #PricingCRAdjusted SET LocationCode = 'CHY' WHERE MakeName = 'HYUNDAI' AND LocationCode = 'CJE'
  UPDATE  #PricingCRAdjusted SET LocationCode = 'CHY' WHERE MakeName = 'GENESIS' AND LocationCode = 'CJE'

    -- Insert statements for procedure here
/****** Script for SelectTopNRows command from SSMS  ******/
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
   ,[Vin]
      ,[VehicleStatus]
      ,[InternetPrice]
      ,[DeliveredPrice]
      ,[InvoicePrice]
      ,[MSRPPrice]
      ,[KBBPrice]
      ,[KBBEdition]
      ,[CRAmount]
      ,[EffectiveCRAmount]      
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
	  ,[StyleName]
	  ,[Trim] AS TrimName
	  ,[Trim]
      ,[CRStartDate]
      ,[CREndDate]
      ,[FDStartDate]
      ,[FDEndDate]
      ,[MatrixPricing]
      ,[MAPPrice]
      ,[LowestMAAPPrice]
      ,[FuelType]
      ,[HasInspection]
	  ,[DAYSININVENTORY]
	  , PercentageMSRP = 0
      , PricingStatus =
	  CASE 
	  WHEN ([InternetPrice] + [EffectiveCRAmount]) > [MSRPPrice] AND VehicleStatus = 1 THEN 'InStock1'
	  WHEN ([InternetPrice] + [EffectiveCRAmount]) = [MSRPPrice] AND VehicleStatus = 1 THEN 'InStock2'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice + 200)  and VehicleStatus = 1 THEN 'InStock3'
	  WHEN ((internetprice + [EffectiveCRAmount]) < msrpprice) 
		and ((internetprice + [EffectiveCRAmount]) < (invoiceprice + 200)
		and (internetprice + [EffectiveCRAmount]) >= (invoiceprice))   and VehicleStatus = 1 then 'InStock3'
		 when ((internetprice + [EffectiveCRAmount]) < msrpprice) 
	and ((internetprice + [EffectiveCRAmount]) < (invoiceprice))   and VehicleStatus = 1 then 'InStock5'
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
	  WHEN ([DAYSININVENTORY] <= 30) THEN '0-30'
	  WHEN ([DAYSININVENTORY] > 30 AND [DAYSININVENTORY] <= 60) THEN '30-60'
	  WHEN ([DAYSININVENTORY] > 60 AND [DAYSININVENTORY] <= 90) THEN '60-90'
	  WHEN ([DAYSININVENTORY] > 90) THEN '90+'
	  ELSE '  '
	 END,
         CRExpired =
	  CASE 
	  WHEN ([EffectiveCRAmount] = 0 and [CRAmount] > 0)THEN 'Expired'
	  WHEN ([EffectiveCRAmount] = 0 and [CRAmount] = 0)THEN 'None'
	  ELSE 'Current'
	 END,
	 (InternetPrice- MSRPPrice) AS UnderMSRP
	 ,(InternetPrice - InvoicePrice) AS OverInvoice,
    [VideoCount]
      ,[Markup]
      ,[MSRPInvoiceFlag]
	INTO #PricingRangeVehicles1 
  FROM #PricingCRAdjusted c WHERE VehicleCondition = 'USED' AND VehicleStatus !=2

  SELECT  a.[Id]
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
		,a.[Vin]
      ,a.[VehicleStatus]
      ,a.[InternetPrice]
      ,a.[DeliveredPrice]
      ,a.[InvoicePrice]
      ,a.[MSRPPrice]
      ,a.[KBBPrice]
      ,a.[KBBEdition]
      ,a.[CRAmount]
      ,a.[EffectiveCRAmount]      
      ,a.[FDAmount]
      ,a.[Holdback]
      ,a.[S_MARKET]
      ,a.[S_STORENAME]
      ,a.[S_DEPARTMENT]
      ,a.[S_SHOWROOM]
      ,a.[S_MALLCODE]
      ,a.[S_LOCCODE]
      ,a.[S_MAKECODE]
      ,a.[S_MAKENAME]
	  ,a.[StyleName]
	  ,a.TrimName
	  ,a.[Trim]
      ,a.[CRStartDate]
      ,a.[CREndDate]
      ,a.[FDStartDate]
      ,a.[FDEndDate]
      ,a.[MatrixPricing]
      ,a.[MAPPrice]
      ,a.[LowestMAAPPrice]
      ,a.[FuelType]
      ,a.[HasInspection]
	  ,a.[DAYSININVENTORY]
      ,a.PercentageMSRP
      ,a.PricingStatus
	  ,a.BucketDaysInInventory
	  ,a.CRExpired
	  ,a.UnderMSRP
	 ,a.OverInvoice
      ,a.[VideoCount]
      ,a.[Markup]
      ,a.[MSRPInvoiceFlag]
	  ,b.Leads
	  ,b.Leads30
	INTO #PricingRangeVehicles
	FROM #PricingRangeVehicles1 a LEFT JOIN [VINSolutions_API].[dbo].[LeadTotalsByVIN] b ON a.[Vin] = b.VIN 
	WHERE a.VehicleStatus != 2
	DROP TABLE #PricingRangeVehicles1

  SET @parPricingStatus = @parPricingStatus + '%'
  
    IF(@parPricingStatus != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE PricingStatus NOT LIKE @parPricingStatus
		END
	
    IF(@parLoc != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE LocationCode != @parLoc
		END
	
    IF(@StockNumber != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE StockNumber != @StockNumber
		END
	
    IF(@MakeName != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE MakeName != @MakeName
		END    
		
	IF(@ModelName != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE ModelName != @ModelName
		END    
	IF(@ModelCode != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE ModelCode != @ModelCode
		END    
		
	IF(@BucketDaysInInventory != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE BucketDaysInInventory != @BucketDaysInInventory
		END
		
	IF(@CRExpired != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE CRExpired != @CRExpired
		END
		
	IF(@StyleName != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE StyleName != @StyleName
		END
		
	IF(@TrimName != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE TrimName != @TrimName
		END
		
	
    IF(@MatrixStatus != '')
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE MatrixPricing != @MatrixStatus
		END    
		
	
    IF(@parModelYear != 0)
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE ModelYear != @parModelYear
		END    

	IF(@VehicleStatus != 0)
		BEGIN 
			DELETE FROM #PricingRangeVehicles WHERE VehicleStatus != @VehicleStatus
		END   
  END;

 
  --[LastPriceChangesByVIN]
     SELECT  a.[Id]
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
		,a.[Vin]
      ,a.[VehicleStatus]
      ,a.[InternetPrice]
      ,a.[DeliveredPrice]
      ,a.[InvoicePrice]
      ,a.[MSRPPrice]
      ,a.[KBBPrice]
      ,a.[KBBEdition]
      ,a.[CRAmount]
      ,a.[EffectiveCRAmount]      
      ,a.[FDAmount]
      ,a.[Holdback]
      ,a.[S_MARKET]
      ,a.[S_STORENAME]
      ,a.[S_DEPARTMENT]
      ,a.[S_SHOWROOM]
      ,a.[S_MALLCODE]
      ,a.[S_LOCCODE]
      ,a.[S_MAKECODE]
      ,a.[S_MAKENAME]
	  ,a.[StyleName]
	  ,a.TrimName
	  ,a.[Trim]
      ,a.[CRStartDate]
      ,a.[CREndDate]
      ,a.[FDStartDate]
      ,a.[FDEndDate]
      ,a.[MatrixPricing]
      ,a.[MAPPrice]
      ,a.[LowestMAAPPrice]
      ,a.[FuelType]
      ,a.[HasInspection]
	  ,a.[DAYSININVENTORY]
      ,a.PercentageMSRP
      ,a.PricingStatus
	  ,a.BucketDaysInInventory
	  ,a.CRExpired
	  ,a.UnderMSRP
  	  ,a.OverInvoice
      ,a.[VideoCount]
      ,a.[Markup]
      ,a.[MSRPInvoiceFlag]
	  ,a.Leads
	  ,a.Leads30 
	  ,b.webviews  FROM #PricingRangeVehicles a LEFT JOIN [Logging].[dbo].[WebViewsByVehicleRefID] b
	  ON a.[XrefId] = b.refid

DROP TABLE #PricingRangeVehicles
