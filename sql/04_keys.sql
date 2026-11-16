/*
    04_keys.sql
    Primary keys on every table, then foreign keys from the fact tables
    to the dimension tables. Run after 01, 02 and 03.
    If a foreign key fails, some rows do not match. Send the error message.
*/

USE AgedCareWorkforce;
GO

-- ---------- Primary keys ----------
ALTER TABLE dbo.Homes          ADD CONSTRAINT PK_Homes          PRIMARY KEY (HomeID);
ALTER TABLE dbo.Roles          ADD CONSTRAINT PK_Roles          PRIMARY KEY (Role);
ALTER TABLE dbo.Shifts         ADD CONSTRAINT PK_Shifts         PRIMARY KEY (ShiftCode);
ALTER TABLE dbo.Staff          ADD CONSTRAINT PK_Staff          PRIMARY KEY (StaffID);
ALTER TABLE dbo.PayPeriods     ADD CONSTRAINT PK_PayPeriods     PRIMARY KEY (PayPeriodID);
ALTER TABLE dbo.Roster         ADD CONSTRAINT PK_Roster         PRIMARY KEY (RosterID);
ALTER TABLE dbo.Leave          ADD CONSTRAINT PK_Leave          PRIMARY KEY (LeaveID);
ALTER TABLE dbo.Timesheets     ADD CONSTRAINT PK_Timesheets     PRIMARY KEY (TimesheetID);
ALTER TABLE dbo.Payroll        ADD CONSTRAINT PK_Payroll        PRIMARY KEY (PayrollLineID);
ALTER TABLE dbo.AgencyInvoices ADD CONSTRAINT PK_AgencyInvoices PRIMARY KEY (InvoiceLineID);
ALTER TABLE dbo.LabourBudget   ADD CONSTRAINT PK_LabourBudget   PRIMARY KEY (HomeID, MonthStart);
ALTER TABLE dbo.DailyOccupancy ADD CONSTRAINT PK_DailyOccupancy PRIMARY KEY (OccupancyDate, HomeID);
GO

-- ---------- Foreign keys ----------
ALTER TABLE dbo.Staff ADD
    CONSTRAINT FK_Staff_Homes FOREIGN KEY (HomeID) REFERENCES dbo.Homes (HomeID),
    CONSTRAINT FK_Staff_Roles FOREIGN KEY (Role)   REFERENCES dbo.Roles (Role);

ALTER TABLE dbo.Roster ADD
    CONSTRAINT FK_Roster_Homes    FOREIGN KEY (HomeID)           REFERENCES dbo.Homes (HomeID),
    CONSTRAINT FK_Roster_Shifts   FOREIGN KEY (ShiftCode)        REFERENCES dbo.Shifts (ShiftCode),
    CONSTRAINT FK_Roster_Roles    FOREIGN KEY (Role)             REFERENCES dbo.Roles (Role),
    CONSTRAINT FK_Roster_Staff    FOREIGN KEY (StaffID)          REFERENCES dbo.Staff (StaffID),
    CONSTRAINT FK_Roster_Date     FOREIGN KEY (ShiftDate)        REFERENCES dbo.[Date] ([Date]),
    CONSTRAINT FK_Roster_Replaces FOREIGN KEY (ReplacesRosterID) REFERENCES dbo.Roster (RosterID);

ALTER TABLE dbo.Leave ADD
    CONSTRAINT FK_Leave_Staff FOREIGN KEY (StaffID)   REFERENCES dbo.Staff (StaffID),
    CONSTRAINT FK_Leave_Date  FOREIGN KEY (LeaveDate) REFERENCES dbo.[Date] ([Date]);

ALTER TABLE dbo.Timesheets ADD
    CONSTRAINT FK_Timesheets_Staff  FOREIGN KEY (StaffID)   REFERENCES dbo.Staff (StaffID),
    CONSTRAINT FK_Timesheets_Homes  FOREIGN KEY (HomeID)    REFERENCES dbo.Homes (HomeID),
    CONSTRAINT FK_Timesheets_Shifts FOREIGN KEY (ShiftCode) REFERENCES dbo.Shifts (ShiftCode),
    CONSTRAINT FK_Timesheets_Date   FOREIGN KEY (WorkDate)  REFERENCES dbo.[Date] ([Date]);

ALTER TABLE dbo.Payroll ADD
    CONSTRAINT FK_Payroll_PayPeriods FOREIGN KEY (PayPeriodID) REFERENCES dbo.PayPeriods (PayPeriodID),
    CONSTRAINT FK_Payroll_Staff      FOREIGN KEY (StaffID)     REFERENCES dbo.Staff (StaffID),
    CONSTRAINT FK_Payroll_Date       FOREIGN KEY (WorkDate)    REFERENCES dbo.[Date] ([Date]);

ALTER TABLE dbo.AgencyInvoices ADD
    CONSTRAINT FK_AgencyInvoices_Staff  FOREIGN KEY (StaffID)   REFERENCES dbo.Staff (StaffID),
    CONSTRAINT FK_AgencyInvoices_Homes  FOREIGN KEY (HomeID)    REFERENCES dbo.Homes (HomeID),
    CONSTRAINT FK_AgencyInvoices_Shifts FOREIGN KEY (ShiftCode) REFERENCES dbo.Shifts (ShiftCode),
    CONSTRAINT FK_AgencyInvoices_Date   FOREIGN KEY (WorkDate)  REFERENCES dbo.[Date] ([Date]);

ALTER TABLE dbo.LabourBudget ADD
    CONSTRAINT FK_LabourBudget_Homes FOREIGN KEY (HomeID)     REFERENCES dbo.Homes (HomeID),
    CONSTRAINT FK_LabourBudget_Date  FOREIGN KEY (MonthStart) REFERENCES dbo.[Date] ([Date]);

ALTER TABLE dbo.DailyOccupancy ADD
    CONSTRAINT FK_DailyOccupancy_Homes FOREIGN KEY (HomeID)        REFERENCES dbo.Homes (HomeID),
    CONSTRAINT FK_DailyOccupancy_Date  FOREIGN KEY (OccupancyDate) REFERENCES dbo.[Date] ([Date]);
GO

-- Check: list every key that was created
SELECT OBJECT_NAME(parent_object_id) AS TableName, name AS KeyName, type_desc
FROM sys.objects
WHERE type IN ('PK', 'F')
ORDER BY TableName, type_desc DESC, KeyName;
GO
