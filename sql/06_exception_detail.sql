/*
    06_exception_detail.sql
    Stacks all 11 checks into one view with the same columns.
    Power BI uses this view for the Payroll Exceptions page.
    The AI agent (version 2 of this project) will also read it.
*/

USE AgedCareWorkforce;
GO
CREATE OR ALTER VIEW dbo.vw_ExceptionDetail AS
SELECT 1 AS CheckNo, 'Worked but not rostered' AS CheckName, 'Roster' AS Area,
       HomeID, WorkDate AS EventDate, StaffID, CAST(NULL AS decimal(10,2)) AS AmountAtStake,
       CONCAT('Worked ', HoursWorked, ' hours with no roster') AS Details
FROM dbo.vw_WorkedNotRostered
UNION ALL
SELECT 2, 'No show', 'Roster', HomeID, ShiftDate, StaffID, NULL,
       CONCAT('Rostered on ', ShiftCode, ' shift, no timesheet or leave')
FROM dbo.vw_NoShows
UNION ALL
SELECT 3, 'Paid more than worked', 'Payroll', HomeID, WorkDate, StaffID, AmountAtStake,
       CONCAT('Paid ', HoursPaid, ' hours, worked ', HoursWorked)
FROM dbo.vw_PaidMoreThanWorked
UNION ALL
SELECT 4, 'Overtime not approved', 'Payroll', HomeID, WorkDate, StaffID, AmountAtStake,
       CONCAT(OvertimeHours, ' overtime hours paid without approval')
FROM dbo.vw_OvertimeNotApproved
UNION ALL
SELECT 5, 'Paid with no timesheet', 'Payroll', HomeID, WorkDate, StaffID, AmountAtStake,
       CONCAT('Paid ', Hours, ' ', PayType, ' hours with no timesheet')
FROM dbo.vw_PaidNoTimesheet
UNION ALL
SELECT 6, 'Wrong pay rate', 'Payroll', HomeID, WorkDate, StaffID, ABS(AmountAtStake),
       CONCAT('Paid $', RatePaid, ' an hour, correct rate is $', CorrectRate)
FROM dbo.vw_WrongPayRate
UNION ALL
SELECT 7, 'Duplicate pay lines', 'Payroll', HomeID, WorkDate, StaffID, AmountAtStake,
       CONCAT(ExtraLines, ' duplicate ', PayType, ' line')
FROM dbo.vw_DuplicatePayLines
UNION ALL
SELECT 8, 'Agency charged more than worked', 'Agency', HomeID, WorkDate, StaffID, AmountAtStake,
       CONCAT(AgencyName, ' charged ', HoursCharged, ' hours, worked ', HoursWorked)
FROM dbo.vw_AgencyOvercharged
UNION ALL
SELECT 9, 'Agency charged, no timesheet', 'Agency', HomeID, WorkDate, StaffID, AmountAtStake,
       CONCAT(AgencyName, ' charged ', Hours, ' hours with no timesheet')
FROM dbo.vw_AgencyNoTimesheet
UNION ALL
SELECT 10, 'Shift with no RN', 'Safety', HomeID, ShiftDate, NULL, NULL,
       CONCAT('No Registered Nurse on ', ShiftCode, ' shift')
FROM dbo.vw_ShiftsWithoutRN
UNION ALL
SELECT 11, 'Unfilled shift', 'Roster', HomeID, ShiftDate, NULL, NULL,
       CONCAT(Role, ' ', ShiftCode, ' shift not filled')
FROM dbo.vw_UnfilledShifts;
GO

-- Check: counts should match vw_ExceptionSummary
SELECT CheckNo, CheckName, COUNT(*) AS Problems, SUM(AmountAtStake) AS AmountAtStake
FROM dbo.vw_ExceptionDetail
GROUP BY CheckNo, CheckName
ORDER BY CheckNo;
GO
