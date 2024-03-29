USE [VINSolutions_API]
GO
/****** Object:  StoredProcedure [dbo].[usp_BuildLeadTotalsByVIN]    Script Date: 2/23/2023 9:52:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Burroughs
-- Create date: 2/23/23
-- Description:	builds a table of lead totals by vin for last 2 years for Pricing Range Report
-- =============================================
ALTER PROCEDURE [dbo].[usp_BuildLeadTotalsByVIN] 
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	TRUNCATE TABLE LeadTotalsByVIN

    -- Insert statements for procedure here
	INSERT INTO LeadTotalsByVIN
	SELECT 
		COUNT(case when DATEDIFF(d,a.leadcreated,getdate()) < 31 THEN 1 END) AS Leads30, 
		COUNT(1) AS Leads, 
		a.VOfInterest_VIN AS VIN
		FROM 
		[VINSolutions_API].[dbo].[Vin_LeadInfo] a 
		WHERE 
		DATEDIFF(YY,a.leadcreated,getdate()) <= 2
		AND	a.LeadStatusTypeName != 'Bad' 
		AND	a.LeadStatusTypeName != 'Sold' 
		AND	a.LeadStatusName != 'Duplicate lead'
		AND RIGHT(a.VOfInterest_StockNumber,2) != '*O'
		and a.VOfInterest_VIN IS NOT NULL
		GROUP BY VOfInterest_VIN

		END
