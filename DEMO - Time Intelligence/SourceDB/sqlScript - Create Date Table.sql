USE AdventureWorksDW2017;
GO
DROP VIEW IF EXISTS dbo.vDate;
GO
CREATE VIEW [dbo].[vDate]
AS
WITH
	cte_today AS (
		SELECT	today = CONVERT(DATE, CONVERT(VARCHAR(10), CONVERT(VARCHAR(2), MONTH(GETDATE())) + '/' + CONVERT(VARCHAR(2), DAY(GETDATE())) + '/2013'), 101)
	)
	,cte_dt_base AS (
		SELECT	dt.DateKey
			   ,Date = dt.FullDateAlternateKey
			   ,dt.CalendarYear
			   ,Month = dt.EnglishMonthName
			   ,dt.MonthNumberOfYear
			   ,YearMonthNumber = (dt.CalendarYear * 100) + dt.MonthNumberOfYear
			   ,YearMonthLabel = CONVERT(CHAR(4), dt.CalendarYear) + ' ' + 
					CASE dt.EnglishMonthName
						WHEN 'January' THEN 'Jan'
						WHEN 'Febuary' THEN	'Feb'
						WHEN 'March' THEN 'Mar'
						WHEN 'April' THEN 'Apr'
						WHEN 'May' THEN 'May'
						WHEN 'June' THEN 'Jun'
						WHEN 'July' THEN 'Jul'
						WHEN 'August' THEN 'Aug'
						WHEN 'September' THEN 'Sep'
						WHEN 'October' THEN 'Oct'
						WHEN 'November' THEN 'Nov'
						WHEN 'December' THEN 'Dec'
						ELSE dt.EnglishMonthName
					END
			   ,Quarter = 'Q' + CONVERT(CHAR(1), dt.CalendarQuarter)
			   ,QuarterNumberOfYear = dt.CalendarQuarter
			   ,YearQuarterNumber = (dt.CalendarYear * 100) + dt.CalendarQuarter
			   ,YearQuarterLabel = CONVERT(CHAR(4), dt.CalendarYear) + ' ' + 'Q' + CONVERT(CHAR(1), dt.CalendarQuarter)

			   ,CurrentDate = IIF( cte_today.today = dt.FullDateAlternateKey, 1, 0 )
			   ,CurrentMonth = IIF( YEAR(cte_today.today) = dt.CalendarYear AND MONTH(cte_today.today) =  dt.MonthNumberOfYear, 1, 0 )
			   ,CurrentQuarter = IIF( YEAR(cte_today.today) = dt.CalendarYear AND DATENAME(QUARTER, cte_today.today) =  dt.CalendarQuarter, 1, 0 )
			   ,CurrentYear = IIF( YEAR(cte_today.today) =  dt.CalendarYear, 1, 0 )
			   ,CurrentMTD = IIF( YEAR(cte_today.today) = dt.CalendarYear AND MONTH(cte_today.today) = dt.MonthNumberOfYear AND CONVERT(DATE,cte_today.today) >= dt.FullDateAlternateKey, 1, 0 )
			   ,CurrentYTD = IIF( YEAR(cte_today.today) = dt.CalendarYear AND CONVERT(DATE,cte_today.today) >= dt.FullDateAlternateKey, 1, 0 )
			   ,DateSeq = ROW_NUMBER() OVER( ORDER BY dt.DateKey )
			   ,DateSeqOfYear = ROW_NUMBER() OVER( PARTITION BY dt.CalendarYear ORDER BY dt.DateKey )
			   ,DateSeqOfMonth = ROW_NUMBER() OVER( PARTITION BY (dt.CalendarYear * 100) + dt.MonthNumberOfYear ORDER BY dt.DateKey )
			   ,MonthSeq = DENSE_RANK() OVER( ORDER BY dt.CalendarYear, dt.MonthNumberOfYear )
			   ,QuarterSeq = DENSE_RANK() OVER( ORDER BY dt.CalendarYear, dt.CalendarQuarter )
			   ,YearSeq = DENSE_RANK() OVER( ORDER BY dt.CalendarYear )
			   ,DayNumberOfWeek = DATEPART( WEEKDAY, dt.CalendarYear)
			   ,DayNameOfWeek = 
					CASE DATEPART( WEEKDAY, dt.FullDateAlternateKey)
						WHEN 1 THEN 'Sunday'
						WHEN 2 THEN 'Monday'
						WHEN 3 THEN 'Tuesday'
						WHEN 4 THEN 'Wedsnesday'
						WHEN 5 THEN 'Thursday'
						WHEN 6 THEN 'Friday'
						WHEN 7 THEN 'Saturday'
						ELSE 'Unknown'
					END
				,IsWeekDay = IIF( DATEPART( WEEKDAY, dt.FullDateAlternateKey) IN (1,7), 0, 1)
				,IsHoliday = 
					CASE
						WHEN dt.DayNumberOfYear = 1 THEN 1
						WHEN dt.MonthNumberOfYear = 12 AND dt.DayNumberOfMonth = 31 THEN 1
						ELSE 0
					END
				,DaysInMonth = 
					DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,dt.FullDateAlternateKey),0)))
				,DaysInQuarter = 
					DATEDIFF(DAY, DATEADD(qq, DATEDIFF(qq, 0, dt.FullDateAlternateKey), 0), DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, dt.FullDateAlternateKey) +1, 0)))
				,DaysInYear = 
					DATEDIFF(DAY, DATEADD(yy, DATEDIFF(yy, 0, dt.FullDateAlternateKey), 0), DATEADD (dd, 0, DATEADD(yy, DATEDIFF(yy, 0, dt.FullDateAlternateKey) +1, 0)))
				,Today = cte_today.today
		FROM	dbo.DimDate dt
				CROSS JOIN cte_today
	)
	,CTE_RelativePeriodIndex AS (
		SELECT	 CurrentDateSeq = cte_dt_base.DateSeq
				,CurrentMonthSeq = MonthSeq
				,CurrentQuarterSeq = QuarterSeq
				,CurrentYearSeq = YearSeq 
		FROM	cte_dt_base 
		WHERE	cte_dt_base.CurrentDate = 1
	)
SELECT	cte_dt_base.DateKey
       ,cte_dt_base.Date
       ,cte_dt_base.CalendarYear
       ,cte_dt_base.Month
       ,cte_dt_base.MonthNumberOfYear
       ,cte_dt_base.YearMonthNumber
	   ,cte_dt_base.YearMonthLabel
       ,cte_dt_base.Quarter
       ,cte_dt_base.QuarterNumberOfYear
       ,cte_dt_base.YearQuarterNumber
	   ,cte_dt_base.YearQuarterLabel
       ,cte_dt_base.CurrentDate
       ,cte_dt_base.CurrentMonth
	   ,cte_dt_base.CurrentQuarter
       ,cte_dt_base.CurrentYear
       ,cte_dt_base.CurrentMTD
       ,cte_dt_base.CurrentYTD
       ,cte_dt_base.DateSeq
       ,cte_dt_base.DateSeqOfYear
       ,cte_dt_base.DateSeqOfMonth
       ,cte_dt_base.MonthSeq
	   ,cte_dt_base.QuarterSeq
       ,cte_dt_base.YearSeq
       ,cte_dt_base.DayNumberOfWeek
       ,cte_dt_base.DayNameOfWeek
       ,cte_dt_base.IsWeekDay
       ,cte_dt_base.IsHoliday
       ,IsWorkday = IIF(cte_dt_base.IsHoliday + cte_dt_base.IsWeekDay > 0, 1, 0)
	   ,WorkDayNumberOfMonth = SUM(IIF(cte_dt_base.IsHoliday + cte_dt_base.IsWeekDay > 0, 1, 0)) OVER(PARTITION BY cte_dt_base.CalendarYear, cte_dt_base.MonthNumberOfYear ORDER BY cte_dt_base.Date)
	   ,WorkDayNumberOfQuarter = SUM(IIF(cte_dt_base.IsHoliday + cte_dt_base.IsWeekDay > 0, 1, 0)) OVER(PARTITION BY cte_dt_base.CalendarYear, cte_dt_base.QuarterNumberOfYear ORDER BY cte_dt_base.Date)
	   ,WorkDayNumberOfYear = SUM(IIF(cte_dt_base.IsHoliday + cte_dt_base.IsWeekDay > 0, 1, 0)) OVER(PARTITION BY cte_dt_base.CalendarYear ORDER BY cte_dt_base.Date)
	   ,RelativeDayIndex =
			CASE
				WHEN cte_dt_base.CurrentDate = 1 THEN 0
				ELSE cte_dt_base.DateSeq - rpi.CurrentDateSeq
			END
	   ,RelativeMonthIndex =
			CASE
				WHEN cte_dt_base.CurrentMonth = 1 THEN 0
				ELSE cte_dt_base.MonthSeq - rpi.CurrentMonthSeq
			END
	   ,RelativeQuarterIndex = 
			CASE
				WHEN cte_dt_base.CurrentQuarter = 1 THEN 0
				ELSE cte_dt_base.QuarterSeq - rpi.CurrentQuarterSeq
			END
	   ,RelativeYearIndex = 
			CASE
				WHEN cte_dt_base.CurrentYear= 1 THEN 0
				ELSE cte_dt_base.YearSeq - rpi.CurrentYearSeq
			END
		,cte_dt_base.DaysInMonth
		,cte_dt_base.DaysInQuarter
		,cte_dt_base.DaysInYear
		,cte_dt_base.Today
FROM	cte_dt_base
		CROSS JOIN CTE_RelativePeriodIndex rpi
GO


SELECT * FROM dbo.vDate