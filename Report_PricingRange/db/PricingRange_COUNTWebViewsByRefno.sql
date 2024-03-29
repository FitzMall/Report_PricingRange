USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRange_COUNTWebViewsByRefno]    Script Date: 12/6/2023 11:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Dave Burroughs
-- Create date: 3/7/2023
-- Description:	Count the Web Views by Inventory Reference Number
-- =============================================
CREATE PROCEDURE [dbo].[PricingRange_COUNTWebViewsByRefno]
	-- Add the parameters for the stored procedure here
@refId  varchar(35) = ''
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT COUNT(1) AS ViewCount
      FROM [Logging].[dbo].[FM_VehicleDetailPages] where refid=@refId and inside_firewall = 'False'
       group by refid				   

END

