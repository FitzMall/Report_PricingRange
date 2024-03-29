USE [VinSolution]
GO
/****** Object:  StoredProcedure [dbo].[LeadsbyStockNumber]    Script Date: 2/23/2023 11:31:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		DAVID BURROUGHS
-- Create date: 2/17/2023
-- Description:	Leads by Stock #
-- =============================================
ALTER PROCEDURE [dbo].[LeadsbyStockNumber]
	-- Add the parameters for the stored procedure here
		@parStockNumber varchar(20)
     AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT *
  FROM [VinSolutions_API].[dbo].[Vin_LeadInfo] WHERE [VOfInterest_StockNumber] =  @parStockNumber
  		AND 
		DATEDIFF(YY,leadcreated,getdate()) <= 2
		AND	LeadStatusTypeName != 'Bad' 
		AND	LeadStatusTypeName != 'Sold' 
		AND	LeadStatusName != 'Duplicate lead'
	

END
