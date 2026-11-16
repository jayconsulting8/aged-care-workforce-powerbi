/*
    05_exception_views.sql
    One view per check. Each row is one problem, with the home, date,
    staff member and the dollar value at stake where there is one.
    Payroll checks cover paid pay periods only (up to 28 Jun 2026).
    Roster checks cover shifts up to 30 Jun 2026.

    Run each view on its own first (SELECT * FROM ...) and count the rows.
    The last view, vw_ExceptionSummary, shows all the counts together.
*/

USE AgedCareWorkforce;
GO

/* 1. Worked but not rostered: a timesheet with no roster row for that person that day */
CREATE OR ALTER VIEW dbo.vw_WorkedNotRostered AS
SELECT t.TimesheetID, t.WorkDate, t.HomeID, t.ShiftCode, t.StaffID, s.Role,
       t.ShiftHours + t.OvertimeHours AS HoursWorked
FROM dbo.Timesheets t
JOIN dbo.Staff s ON s.StaffID = t.StaffID
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roster r
                  WHERE r.StaffID = t.StaffID AND r.ShiftDate = t.WorkDate);
GO

/* 2. No show: rostered, but no timesheet and no leave that day */
CREATE OR ALTER VIEW dbo.vw_NoShows AS
SELECT r.RosterID, r.ShiftDate, r.HomeID, r.ShiftCode, r.Role, r.StaffID
FROM dbo.Roster r
WHERE r.StaffID IS NOT NULL
  AND r.ShiftDate <= '20260630'
  AND NOT EXISTS (SELECT 1 FROM dbo.Timesheets t
                  WHERE t.StaffID = r.StaffID AND t.WorkDate = r.ShiftDate)
  AND NOT EXISTS (SELECT 1 FROM dbo.Leave l
                  WHERE l.StaffID = r.StaffID AND l.LeaveDate = r.ShiftDate);
GO

/* 3. Paid more ordinary hours than the shift worked */
CREATE OR ALTER VIEW dbo.vw_PaidMoreThanWorked AS
SELECT p.PayrollLineID, p.PayPeriodID, p.WorkDate, t.HomeID, p.StaffID,
       t.ShiftHours AS HoursWorked, p.Hours AS HoursPaid,
       CAST((p.Hours - t.ShiftHours) * p.BaseRate * p.Multiplier AS decimal(10,2)) AS AmountAtStake
FROM dbo.Payroll p
JOIN dbo.Timesheets t ON t.StaffID = p.StaffID AND t.WorkDate = p.WorkDate
WHERE p.PayType = 'Ordinary'
  AND p.Hours > t.ShiftHours;
GO

/* 4. Overtime paid but not approved */
CREATE OR ALTER VIEW dbo.vw_OvertimeNotApproved AS
SELECT t.TimesheetID, t.WorkDate, t.HomeID, t.ShiftCode, t.StaffID, t.OvertimeHours,
       CAST(t.OvertimeHours * s.HourlyRate * 1.5 AS decimal(10,2)) AS AmountAtStake
FROM dbo.Timesheets t
JOIN dbo.Staff s ON s.StaffID = t.StaffID
WHERE t.OvertimeHours > 0
  AND t.OvertimeApproved = 'N'
  AND EXISTS (SELECT 1 FROM dbo.Payroll p
              WHERE p.StaffID = t.StaffID AND p.WorkDate = t.WorkDate
                AND p.PayType = 'Overtime');
GO

/* 5. Paid with no timesheet */
CREATE OR ALTER VIEW dbo.vw_PaidNoTimesheet AS
SELECT p.PayrollLineID, p.PayPeriodID, p.WorkDate, s.HomeID, p.StaffID, p.PayType,
       p.Hours, p.Amount AS AmountAtStake
FROM dbo.Payroll p
JOIN dbo.Staff s ON s.StaffID = p.StaffID
WHERE p.PayType IN ('Ordinary', 'Overtime')
  AND NOT EXISTS (SELECT 1 FROM dbo.Timesheets t
                  WHERE t.StaffID = p.StaffID AND t.WorkDate = p.WorkDate);
GO

/* 6. Paid at the wrong rate */
CREATE OR ALTER VIEW dbo.vw_WrongPayRate AS
SELECT p.PayrollLineID, p.PayPeriodID, p.WorkDate, s.HomeID, p.StaffID,
       s.HourlyRate AS CorrectRate, p.BaseRate AS RatePaid,
       CAST((p.BaseRate - s.HourlyRate) * p.Hours * p.Multiplier AS decimal(10,2)) AS AmountAtStake
FROM dbo.Payroll p
JOIN dbo.Staff s ON s.StaffID = p.StaffID
WHERE p.BaseRate <> s.HourlyRate;
GO

/* 7. Duplicate pay lines (one row per group, ExtraLines = copies to remove) */
CREATE OR ALTER VIEW dbo.vw_DuplicatePayLines AS
SELECT p.PayPeriodID, p.WorkDate, s.HomeID, p.StaffID, p.PayType, p.Hours, p.BaseRate,
       COUNT(*) - 1 AS ExtraLines,
       CAST((COUNT(*) - 1) * MAX(p.Amount) AS decimal(10,2)) AS AmountAtStake
FROM dbo.Payroll p
JOIN dbo.Staff s ON s.StaffID = p.StaffID
GROUP BY p.PayPeriodID, p.WorkDate, s.HomeID, p.StaffID, p.PayType, p.Hours, p.BaseRate, p.Multiplier
HAVING COUNT(*) > 1;
GO

/* 8. Agency charged more hours than worked */
CREATE OR ALTER VIEW dbo.vw_AgencyOvercharged AS
SELECT a.InvoiceLineID, a.InvoiceNo, a.AgencyName, a.WorkDate, a.HomeID, a.StaffID,
       t.ShiftHours + t.OvertimeHours AS HoursWorked, a.Hours AS HoursCharged,
       CAST((a.Hours - (t.ShiftHours + t.OvertimeHours)) * a.ChargeRate AS decimal(10,2)) AS AmountAtStake
FROM dbo.AgencyInvoices a
JOIN dbo.Timesheets t ON t.StaffID = a.StaffID AND t.WorkDate = a.WorkDate
WHERE a.Hours > t.ShiftHours + t.OvertimeHours;
GO

/* 9. Agency charged for a shift with no timesheet */
CREATE OR ALTER VIEW dbo.vw_AgencyNoTimesheet AS
SELECT a.InvoiceLineID, a.InvoiceNo, a.AgencyName, a.WorkDate, a.HomeID, a.StaffID,
       a.Hours, a.Amount AS AmountAtStake
FROM dbo.AgencyInvoices a
WHERE NOT EXISTS (SELECT 1 FROM dbo.Timesheets t
                  WHERE t.StaffID = a.StaffID AND t.WorkDate = a.WorkDate);
GO

/* 10. Shifts with no Registered Nurse at work */
CREATE OR ALTER VIEW dbo.vw_ShiftsWithoutRN AS
SELECT d.[Date] AS ShiftDate, h.HomeID, sh.ShiftCode
FROM dbo.[Date] d
CROSS JOIN dbo.Homes h
CROSS JOIN dbo.Shifts sh
WHERE d.[Date] BETWEEN '20250701' AND '20260630'
  AND NOT EXISTS (SELECT 1
                  FROM dbo.Timesheets t
                  JOIN dbo.Staff s ON s.StaffID = t.StaffID
                  WHERE t.WorkDate = d.[Date] AND t.HomeID = h.HomeID
                    AND t.ShiftCode = sh.ShiftCode AND s.Role = 'RN');
GO

/* 11. Unfilled shifts: planned, nobody rostered, not replaced */
CREATE OR ALTER VIEW dbo.vw_UnfilledShifts AS
SELECT r.RosterID, r.ShiftDate, r.HomeID, r.ShiftCode, r.Role
FROM dbo.Roster r
WHERE r.ShiftSource = 'Planned'
  AND r.StaffID IS NULL
  AND r.ShiftDate <= '20260630'
  AND NOT EXISTS (SELECT 1 FROM dbo.Roster x WHERE x.ReplacesRosterID = r.RosterID);
GO

/* Summary: all checks in one list */
CREATE OR ALTER VIEW dbo.vw_ExceptionSummary AS
SELECT 1 AS CheckNo, 'Worked but not rostered' AS CheckName, COUNT(*) AS Problems, CAST(NULL AS decimal(12,2)) AS AmountAtStake FROM dbo.vw_WorkedNotRostered
UNION ALL SELECT 2,  'No show',                         COUNT(*), NULL               FROM dbo.vw_NoShows
UNION ALL SELECT 3,  'Paid more than worked',           COUNT(*), SUM(AmountAtStake) FROM dbo.vw_PaidMoreThanWorked
UNION ALL SELECT 4,  'Overtime not approved',           COUNT(*), SUM(AmountAtStake) FROM dbo.vw_OvertimeNotApproved
UNION ALL SELECT 5,  'Paid with no timesheet',          COUNT(*), SUM(AmountAtStake) FROM dbo.vw_PaidNoTimesheet
UNION ALL SELECT 6,  'Wrong pay rate',                  COUNT(*), SUM(ABS(AmountAtStake)) FROM dbo.vw_WrongPayRate
UNION ALL SELECT 7,  'Duplicate pay lines',             SUM(ExtraLines), SUM(AmountAtStake) FROM dbo.vw_DuplicatePayLines
UNION ALL SELECT 8,  'Agency charged more than worked', COUNT(*), SUM(AmountAtStake) FROM dbo.vw_AgencyOvercharged
UNION ALL SELECT 9,  'Agency charged, no timesheet',    COUNT(*), SUM(AmountAtStake) FROM dbo.vw_AgencyNoTimesheet
UNION ALL SELECT 10, 'Shift with no RN',                COUNT(*), NULL               FROM dbo.vw_ShiftsWithoutRN
UNION ALL SELECT 11, 'Unfilled shift',                  COUNT(*), NULL               FROM dbo.vw_UnfilledShifts;
GO

SELECT * FROM dbo.vw_ExceptionSummary ORDER BY CheckNo;
GO
