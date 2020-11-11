USE AdventureWorksDW2017;
GO

CREATE VIEW [dbo].[vFactInternetSalesRemoved2010]
AS
SELECT	fis.ProductKey,
        fis.OrderDateKey,
        fis.DueDateKey,
        fis.ShipDateKey,
        fis.CustomerKey,
        fis.PromotionKey,
        fis.CurrencyKey,
        fis.SalesTerritoryKey,
        fis.SalesOrderNumber,
        fis.SalesOrderLineNumber,
        fis.RevisionNumber,
        fis.OrderQuantity,
        fis.UnitPrice,
        fis.ExtendedAmount,
        fis.UnitPriceDiscountPct,
        fis.DiscountAmount,
        fis.ProductStandardCost,
        fis.TotalProductCost,
        fis.SalesAmount,
        fis.TaxAmt,
        fis.Freight,
        fis.CarrierTrackingNumber,
        fis.CustomerPONumber,
        fis.OrderDate,
        fis.DueDate,
        fis.ShipDate
FROM	dbo.FactInternetSales fis
WHERE	YEAR(fis.OrderDate) > 2010