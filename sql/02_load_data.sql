/*
    02_load_data.sql
    Loads the CSV files into the tables.

    Before you run it:
    1. Copy the csv folder to C:\AgedCareWorkforce\csv\
       (or change the path below with Find and Replace, Ctrl+H).
    2. If you get an "access denied" or "cannot be opened" error,
       SQL Server cannot read that folder. Move the files to C:\Temp\csv\
       and change the path, or load them with Import Flat File instead.
*/

USE AgedCareWorkforce;
GO

BULK INSERT dbo.Homes          FROM 'C:\AgedCareWorkforce\csv\Homes.csv'          WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Roles          FROM 'C:\AgedCareWorkforce\csv\Roles.csv'          WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Shifts         FROM 'C:\AgedCareWorkforce\csv\Shifts.csv'         WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Staff          FROM 'C:\AgedCareWorkforce\csv\Staff.csv'          WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.PayPeriods     FROM 'C:\AgedCareWorkforce\csv\PayPeriods.csv'     WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Roster         FROM 'C:\AgedCareWorkforce\csv\Roster.csv'         WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Leave          FROM 'C:\AgedCareWorkforce\csv\Leave.csv'          WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Timesheets     FROM 'C:\AgedCareWorkforce\csv\Timesheets.csv'     WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.Payroll        FROM 'C:\AgedCareWorkforce\csv\Payroll.csv'        WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.AgencyInvoices FROM 'C:\AgedCareWorkforce\csv\AgencyInvoices.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.LabourBudget   FROM 'C:\AgedCareWorkforce\csv\LabourBudget.csv'   WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
BULK INSERT dbo.DailyOccupancy FROM 'C:\AgedCareWorkforce\csv\DailyOccupancy.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2, KEEPNULLS);
GO

-- Check the row counts
SELECT 'Homes' AS TableName, COUNT(*) AS RowsLoaded FROM dbo.Homes
UNION ALL SELECT 'Roles', COUNT(*) FROM dbo.Roles
UNION ALL SELECT 'Shifts', COUNT(*) FROM dbo.Shifts
UNION ALL SELECT 'Staff', COUNT(*) FROM dbo.Staff
UNION ALL SELECT 'PayPeriods', COUNT(*) FROM dbo.PayPeriods
UNION ALL SELECT 'Roster', COUNT(*) FROM dbo.Roster
UNION ALL SELECT 'Leave', COUNT(*) FROM dbo.Leave
UNION ALL SELECT 'Timesheets', COUNT(*) FROM dbo.Timesheets
UNION ALL SELECT 'Payroll', COUNT(*) FROM dbo.Payroll
UNION ALL SELECT 'AgencyInvoices', COUNT(*) FROM dbo.AgencyInvoices
UNION ALL SELECT 'LabourBudget', COUNT(*) FROM dbo.LabourBudget
UNION ALL SELECT 'DailyOccupancy', COUNT(*) FROM dbo.DailyOccupancy;
GO
