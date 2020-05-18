DROP VIEW IF EXISTS dbo.vDimCustomerCohort;
GO

CREATE VIEW dbo.vDimCustomerCohort
AS

	WITH
		CTE_customers_with_multiple_orders AS (
			SELECT fis.CustomerKey,
				   NumOrders = COUNT(DISTINCT fis.SalesOrderNumber),
				   DateOfFirstOrder = MIN(fis.OrderDateKey)
			FROM dbo.FactInternetSales fis
			WHERE fis.OrderDateKey > 20101231
			GROUP BY fis.CustomerKey
			HAVING COUNT(DISTINCT fis.SalesOrderNumber) > 1
		)
	SELECT	cust.CustomerKey,
			cust.GeographyKey,
			cust.CustomerAlternateKey,
			cust.FirstName,
			cust.MiddleName,
			cust.LastName,
			cust.MaritalStatus,
			cust.Gender,
			cust.YearlyIncome,
			cust.TotalChildren,
			cust.NumberChildrenAtHome,
			cust.EnglishEducation,
			cust.EnglishOccupation,
			cust.HouseOwnerFlag,
			cust.CommuteDistance,
			cust.NumberCarsOwned,
			cust_w_multiple.DateOfFirstOrder,
			Cohort_NewCustomer_YYYYQ =
				(dd.CalendarYear * 100) + dd.CalendarQuarter,
			Cohort_NewCustomer_Code =
				'Cohort - ' + RIGHT('00' + CAST(DENSE_RANK() OVER (ORDER BY (dd.CalendarYear * 100) + dd.CalendarQuarter ) AS VARCHAR(10)), 2)

	FROM	dbo.DimCustomer cust
			INNER JOIN CTE_customers_with_multiple_orders cust_w_multiple
				ON cust_w_multiple.CustomerKey = cust.CustomerKey
			INNER JOIN dbo.DimDate dd
				ON dd.DateKey = cust_w_multiple.DateOfFirstOrder
;
GO
SELECT	*
FROM	dbo.vDimCustomerCohort