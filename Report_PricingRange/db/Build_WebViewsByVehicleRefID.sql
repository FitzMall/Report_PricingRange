USE [Logging]
GO

/****** Object:  StoredProcedure [dbo].[usp_RPT_GenerateFMEmailLogLeadSrc]    Script Date: 3/8/2023 10:17:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<david burroughs
-- Create date: 3/8/2023
-- Description:	<overnight? build of webviews by vehicle ref id>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Build_WebViewsByVehicleRefID]

AS
BEGIN

TRUNCATE TABLE WebViewsByVehicleRefID

INSERT INTO WebViewsByVehicleRefID
SELECT
      count(1) as webviews, refid
	 
      FROM [Logging].[dbo].[FM_VehicleDetailPages] 
	  where len(refid) = 11 and
	  datediff(MM,time_stamp, getdate()) <= 1
	  group by Refid 

END

GO


