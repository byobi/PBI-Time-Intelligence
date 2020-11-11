DROP VIEW IF EXISTS dbo.vFactCustomerSalesIndex;
GO

CREATE VIEW dbo.vFactCustomerSalesIndex
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
	SELECT	 fis.CustomerKey
			,fis.OrderDateKey
			,fis.ProductKey
			,fis.SalesOrderNumber
			,fis.SalesOrderLineNumber
			,fis.OrderQuantity
			,fis.UnitPrice
			,UnitCost = fis.TotalProductCost
	FROM	dbo.FactInternetSales fis
			INNER JOIN CTE_customers_with_multiple_orders cust
				ON	cust.CustomerKey = fis.CustomerKey
;
GO
SELECT	*
FROM	dbo.vFactCustomerSalesIndex