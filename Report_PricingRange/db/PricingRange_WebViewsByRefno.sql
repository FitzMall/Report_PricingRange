USE [FITZWAY]
GO
/****** Object:  StoredProcedure [dbo].[PricingRange_WebViewsByRefno]    Script Date: 12/6/2023 11:56:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[PricingRange_WebViewsByRefno]
	-- Add the parameters for the stored procedure here
@refId  varchar(35) = ''
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT [Session]
                          ,[session_id]
                          ,[time_stamp]
                        , CONVERT(date,time_stamp) as ViewDate
                          ,[url]
                          ,[Refid]
                          ,[inside_firewall]
                          ,[logger]
                      FROM [10.254.186.197].[Logging].[dbo].[FM_VehicleDetailPages] where refid=@refId and inside_firewall = 'False'
                      order by time_stamp
					  
END
