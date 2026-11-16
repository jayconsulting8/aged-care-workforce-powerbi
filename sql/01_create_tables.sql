/*
    01_create_tables.sql
    Creates the AgedCareWorkforce database and its tables.
    All data is made up for a portfolio project.
*/

CREATE DATABASE AgedCareWorkforce;
GO

USE AgedCareWorkforce;
GO

-- ---------- Dimension tables ----------

CREATE TABLE dbo.Homes (
    HomeID      varchar(10)   NOT NULL,
    HomeName    nvarchar(100) NOT NULL,
    Suburb      nvarchar(50)  NOT NULL,
    Beds        int           NOT NULL
);

CREATE TABLE dbo.Roles (
    Role                varchar(10)   NOT NULL,
    RoleDescription     nvarchar(50)  NOT NULL,
    SortOrder           int           NOT NULL,
    StandardHourlyRate  decimal(8,2)  NOT NULL
);

CREATE TABLE dbo.Shifts (
    ShiftCode          varchar(5)    NOT NULL,
    StartTime          time(0)       NOT NULL,
    EndTime            time(0)       NOT NULL,
    PaidHours          decimal(5,2)  NOT NULL,
    PenaltyMultiplier  decimal(6,4)  NOT NULL
);

CREATE TABLE dbo.Staff (
    StaffID                      varchar(10)   NOT NULL,
    FirstName                    nvarchar(50)  NOT NULL,
    LastName                     nvarchar(50)  NOT NULL,
    HomeID                       varchar(10)   NULL,      -- blank for agency staff
    Role                         varchar(10)   NOT NULL,
    EmploymentType               varchar(20)   NOT NULL,  -- Full time, Part time, Casual, Agency
    ContractedHoursPerFortnight  int           NOT NULL,
    HourlyRate                   decimal(8,2)  NOT NULL,  -- pay rate, or agency charge rate
    StartDate                    date          NULL,
    AgencyName                   nvarchar(100) NULL
);

CREATE TABLE dbo.PayPeriods (
    PayPeriodID  int   NOT NULL,
    StartDate    date  NOT NULL,
    EndDate      date  NOT NULL,
    PayDate      date  NOT NULL
);

-- ---------- Fact tables ----------

CREATE TABLE dbo.Roster (
    RosterID          int          NOT NULL,
    ShiftDate         date         NOT NULL,
    HomeID            varchar(10)  NOT NULL,
    ShiftCode         varchar(5)   NOT NULL,
    Role              varchar(10)  NOT NULL,
    StaffID           varchar(10)  NULL,      -- blank = unfilled shift
    ShiftSource       varchar(40)  NOT NULL,  -- Planned or Replacement - ...
    ReplacesRosterID  int          NULL       -- the planned shift this one replaces
);

CREATE TABLE dbo.Leave (
    LeaveID    int           NOT NULL,
    StaffID    varchar(10)   NOT NULL,
    LeaveDate  date          NOT NULL,
    LeaveType  nvarchar(30)  NOT NULL,
    Hours      decimal(5,2)  NOT NULL,
    Paid       char(1)       NOT NULL       -- Y or N (casual staff are not paid sick leave)
);

CREATE TABLE dbo.Timesheets (
    TimesheetID       int           NOT NULL,
    StaffID           varchar(10)   NOT NULL,
    WorkDate          date          NOT NULL,
    HomeID            varchar(10)   NOT NULL,
    ShiftCode         varchar(5)    NOT NULL,
    ClockIn           datetime2(0)  NOT NULL,
    ClockOut          datetime2(0)  NOT NULL,
    ShiftHours        decimal(5,2)  NOT NULL,
    OvertimeHours     decimal(5,2)  NOT NULL,
    OvertimeApproved  char(1)       NULL,     -- Y, N, or blank when no overtime
    OvertimeShift     char(1)       NOT NULL  -- Y when the whole shift was worked as overtime
);

CREATE TABLE dbo.Payroll (
    PayrollLineID  int           NOT NULL,
    PayPeriodID    int           NOT NULL,
    StaffID        varchar(10)   NOT NULL,
    WorkDate       date          NOT NULL,
    PayType        varchar(20)   NOT NULL,  -- Ordinary, Overtime, Sick leave
    Hours          decimal(5,2)  NOT NULL,
    BaseRate       decimal(8,2)  NOT NULL,
    Multiplier     decimal(6,4)  NOT NULL,
    Amount         decimal(10,2) NOT NULL
);

CREATE TABLE dbo.AgencyInvoices (
    InvoiceLineID  int           NOT NULL,
    InvoiceNo      varchar(20)   NOT NULL,
    AgencyName     nvarchar(100) NOT NULL,
    StaffID        varchar(10)   NOT NULL,
    WorkDate       date          NOT NULL,
    HomeID         varchar(10)   NOT NULL,
    ShiftCode      varchar(5)    NOT NULL,
    Hours          decimal(5,2)  NOT NULL,
    ChargeRate     decimal(8,2)  NOT NULL,
    Amount         decimal(10,2) NOT NULL
);

CREATE TABLE dbo.LabourBudget (
    HomeID       varchar(10)    NOT NULL,
    MonthStart   date           NOT NULL,
    BudgetHours  int            NOT NULL,
    BudgetCost   decimal(12,2)  NOT NULL
);

CREATE TABLE dbo.DailyOccupancy (
    OccupancyDate  date         NOT NULL,
    HomeID         varchar(10)  NOT NULL,
    OccupiedBeds   int          NOT NULL
);
GO
