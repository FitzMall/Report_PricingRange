USE [SalesCommission]
GO
/****** Object:  StoredProcedure [dbo].[sp_EmployeePerformanceMTD_ByDate]    Script Date: 2/3/2023 2:47:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DAVE BURROUGHS
-- Create date: 12/12/22
-- Description:	for employee scorecard/high scores display, often in past
-- =============================================
ALTER PROCEDURE [dbo].[sp_EmployeePerformanceMTD_ByDate]
	-- Add the parameters for the stored procedure here
	 @parDate date
AS
BEGIN

DECLARE	@return_value int

-- list of sales persons by sales team

SELECT 	b.FIRSTNAME, b.LASTNAME, a.emp_loc AS LOCATION, b.DMS_ID, c.dept_desc AS SalesTeam, c.dept_code
INTO #SalesPersonsIvory
FROM [ivory].[dbo].[employees2] a JOIN [FITZDB].[dbo].[users] b ON b.DMS_ID = a.emp_nameid
JOIN [ivory].[dbo].[dept] c ON c.dept_code = a.emp_deptcode
AND b.LASTNAME = a.emp_lname
AND b.FIRSTNAME = a.emp_fname
WHERE ((year(a.emp_termdate) = 1900) OR (datediff(d,a.emp_termdate, @parDate) < 31))
-- above: termination date must be empty or quite recent

-- list of sales persons 
SELECT b.FIRSTNAME, b.LASTNAME, b.DMS_ID , b.SalesTeam, b.dept_code
  INTO #SalesPersons
  FROM [SalesCommission].[dbo].[saleslog] a JOIN #SalesPersonsIvory b ON b.DMS_ID = a.sl_SalesAssociate1
    where COALESCE(DMS_ID,'') != '' AND   
	a.sl_VehicleCategory != 'T' and
 month(sl_VehicleDealDate) = month(@parDate) and
  year(sl_VehicleDealDate) = year(@parDate) and
  COALESCE(LOCATION, '') != ''
  GROUP by DMS_ID, FIRSTNAME, LASTNAME, SalesTeam, dept_code

  DROP TABLE #SalesPersonsIvory

-- one salesperson gets whole 1 sale (no sales assoc 2)
SELECT a.[sl_SalesAssociate1],  a.sl_VehicleMake AS VehicleMake, CAST(COUNT(a.sl_pkey) AS decimal(5,2)) as salescount, a.sl_VehicleNU
	, b.FIRSTNAME, b.LASTNAME, b.SalesTeam, b.dept_code
  INTO #TEMP_EmployeePerformanceMTD_ByDate1
  FROM [SalesCommission].[dbo].[saleslog] a JOIN #SalesPersons b ON b.DMS_ID = a.sl_SalesAssociate1
    where COALESCE(DMS_ID,'') != '' AND   
	a.sl_VehicleCategory != 'T' and
 month(sl_VehicleDealDate) = month(@parDate) and
  year(sl_VehicleDealDate) = year(@parDate) 
  and COALESCE([sl_SalesAssociate2],'') = ''
  GROUP by sl_SalesAssociate1, FIRSTNAME, LASTNAME, sl_VehicleNU, a.sl_VehicleMake, SalesTeam, dept_code
  
  -- half-sales where there is a 2nd sales associate

  --first associate gets half of sale
  INSERT INTO #TEMP_EmployeePerformanceMTD_ByDate1
  SELECT a.[sl_SalesAssociate1],  a.sl_VehicleMake AS VehicleMake, COUNT(a.sl_pkey) * .5 as salescount, a.sl_VehicleNU
	, b.FIRSTNAME, b.LASTNAME, b.SalesTeam, b.dept_code
  FROM [SalesCommission].[dbo].[saleslog] a JOIN #SalesPersons b ON b.DMS_ID = a.sl_SalesAssociate1
    where COALESCE(DMS_ID,'') != '' AND   
	a.sl_VehicleCategory != 'T' and
 month(sl_VehicleDealDate) = month(@parDate) and
  year(sl_VehicleDealDate) = year(@parDate) 
  and COALESCE([sl_SalesAssociate2],'') != ''
  GROUP by sl_SalesAssociate1, FIRSTNAME, LASTNAME, sl_VehicleNU, a.sl_VehicleMake, SalesTeam, dept_code

  --second associate gets half of sale
  INSERT INTO #TEMP_EmployeePerformanceMTD_ByDate1
  SELECT a.[sl_SalesAssociate2] AS sl_SalesAssociate1,  a.sl_VehicleMake AS VehicleMake, COUNT(a.sl_pkey) * .5 as salescount, a.sl_VehicleNU
	, b.FIRSTNAME, b.LASTNAME,  b.SalesTeam, b.dept_code
  FROM [SalesCommission].[dbo].[saleslog] a JOIN #SalesPersons b ON b.DMS_ID = a.sl_SalesAssociate2
    where COALESCE(DMS_ID,'') != '' AND   
	a.sl_VehicleCategory != 'T' and
 month(sl_VehicleDealDate) = month(@parDate) and
  year(sl_VehicleDealDate) = year(@parDate) 
  and COALESCE([sl_SalesAssociate2],'') != ''
  GROUP by sl_SalesAssociate2, FIRSTNAME, LASTNAME, sl_VehicleNU, a.sl_VehicleMake, SalesTeam, dept_code


  UPDATE #TEMP_EmployeePerformanceMTD_ByDate1 SET VehicleMake = REPLACE(VehicleMake,' TRUCK','') WHERE VehicleMake LIKE '%TRUCK%'
  UPDATE #TEMP_EmployeePerformanceMTD_ByDate1 SET VehicleMake = 'USED' WHERE sl_VehicleNU = 'USED'
  UPDATE #TEMP_EmployeePerformanceMTD_ByDate1 SET VehicleMake = 'USED' WHERE VehicleMake = ''
  UPDATE #TEMP_EmployeePerformanceMTD_ByDate1 SET sl_VehicleNU = 'USED' WHERE VehicleMake = 'USED' AND sl_VehicleNU = ''

  --only get ones that are sold at the CORRECT location and brand

SELECT a.[sl_SalesAssociate1],  b.Make AS VehicleMake, a.salescount, a.sl_VehicleNU
	, a.FIRSTNAME, a.LASTNAME,  a.SalesTeam, a.dept_code
  INTO #TEMP_EmployeePerformanceMTD_ByDate
  FROM #TEMP_EmployeePerformanceMTD_ByDate1 a JOIN [ivory].[dbo].[SalesTeamMakesLocations] b ON a.VehicleMake = b.Make AND
  a.dept_code = b.dept_code

  DROP TABLE #TEMP_EmployeePerformanceMTD_ByDate1
  -- ADD BLANKS SO THAT ALL BRANDS SHOW UP for each sales team
-- insert zero totals for all salesmen for all showrooms for all products relevant to them

  INSERT INTO #TEMP_EmployeePerformanceMTD_ByDate
  SELECT b.DMS_ID, a.[Make] AS VehicleMake, 0.00 AS salescount, sl_VehicleNU =
	  CASE 
	  WHEN a.[Make] = 'USED' THEN 'USED'
	  ELSE 'NEW'
      END
	  , b.FIRSTNAME, b.LASTNAME,  b.SalesTeam, b.dept_code
  FROM [ivory].[dbo].[SalesTeamMakesLocations] a JOIN #SalesPersons b on b.dept_code = a.dept_code
  WHERE COALESCE(b.DMS_ID,'') != '' AND COALESCE(b.LASTNAME,'') != ''

SELECT DISTINCT sl_SalesAssociate1, UPPER(VehicleMake) AS VehicleMake, salescount
	, FIRSTNAME, LASTNAME, SalesTeam, dept_code
  INTO #TEMP_EmployeePerformanceMTD_ByDate2  
  FROM #TEMP_EmployeePerformanceMTD_ByDate 
  GROUP by sl_SalesAssociate1, VehicleMake, FIRSTNAME, LASTNAME, SalesTeam, dept_code, salescount

SELECT IDENTITY(INT, 1,1) AS SalesID, 0 AS SalesRank, sl_SalesAssociate1, VehicleMake
	, FIRSTNAME, LASTNAME, SalesTeam, dept_code,
	CAST(SUM(salescount) AS decimal(5,2)) AS MTD
  INTO #EmployeePerformanceMTD_ByDate
  FROM #TEMP_EmployeePerformanceMTD_ByDate2 
   GROUP by sl_SalesAssociate1, VehicleMake, FIRSTNAME, LASTNAME, SalesTeam, dept_code

    DROP TABLE #TEMP_EmployeePerformanceMTD_ByDate
    DROP TABLE #TEMP_EmployeePerformanceMTD_ByDate2
	DROP TABLE #SalesPersons

UPDATE #EmployeePerformanceMTD_ByDate 
SET SalesRank = OtherTable.SalesRank
FROM (
    SELECT SUM(MTD * 2) AS SalesRank, sl_SalesAssociate1
    FROM #EmployeePerformanceMTD_ByDate GROUP BY sl_SalesAssociate1) AS OtherTable
WHERE 
    #EmployeePerformanceMTD_ByDate.sl_SalesAssociate1 = OtherTable.sl_SalesAssociate1

	-- IGNORE those who had NO sales (probably dismissed) 
	SELECT * FROM #EmployeePerformanceMTD_ByDate WHERE SalesRank > 0
		 ORDER by SalesRank, sl_SalesAssociate1, VehicleMake 

    DROP TABLE #EmployeePerformanceMTD_ByDate

END
