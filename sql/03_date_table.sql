/*
    03_date_table.sql
    Builds the Date table: 30 Jun 2025 (start of the first pay period)
    to 31 Jul 2026 (covers the future roster). Weeks start on Monday.
*/

USE AgedCareWorkforce;
GO

CREATE TABLE dbo.[Date] (
    [Date]          date        NOT NULL PRIMARY KEY,
    [Year]          int         NOT NULL,
    [Month Number]  int         NOT NULL,
    [Month]         varchar(8)  NOT NULL,
    [Month Sort]    int         NOT NULL,
    [Week Start]    date        NOT NULL,
    [Day Name]      varchar(10) NOT NULL,
    [Is Weekend]    bit         NOT NULL
);
GO

INSERT INTO dbo.[Date]
SELECT
    d,
    YEAR(d),
    MONTH(d),
    FORMAT(d, 'MMM yyyy', 'en-US'),
    YEAR(d) * 100 + MONTH(d),
    DATEADD(day, -(DATEDIFF(day, '19000101', d) % 7), d),
    FORMAT(d, 'dddd', 'en-US'),
    CASE WHEN DATEDIFF(day, '19000101', d) % 7 IN (5, 6) THEN 1 ELSE 0 END
FROM (
    SELECT DATEADD(day, value, '20250630') AS d
    FROM GENERATE_SERIES(0, DATEDIFF(day, '20250630', '20260731'))
) AS days;
GO

SELECT TOP 7 * FROM dbo.[Date] ORDER BY [Date];
GO
