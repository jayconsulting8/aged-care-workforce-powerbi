# Aged Care Workforce: Data Dictionary

All data is made up for a portfolio project. The homes, staff, agencies and figures are not real.

**Period:** 1 Jul 2025 to 30 Jun 2026 (timesheets, payroll and invoices). The roster also runs to 14 Jul 2026, so the report can show "today and tomorrow" as at 30 Jun 2026.

**Last paid pay period:** 15 Jun 2026 to 28 Jun 2026. Timesheets on 29 and 30 Jun 2026 are not paid yet.

## Homes (4 rows)

| Column | Meaning |
|---|---|
| HomeID | H01 to H04 |
| HomeName | Lilly Pilly Gardens, Ironbark Court, Bottlebrush Place, Saltbush Manor |
| Suburb | Suburb of the home |
| Beds | Number of beds |

## Roles (3 rows)

| Column | Meaning |
|---|---|
| Role | RN, EN, PCW |
| RoleDescription | Registered Nurse, Enrolled Nurse, Personal Care Worker |
| SortOrder | Display order |
| StandardHourlyRate | Standard hourly rate for the role (made up) |

## Shifts (3 rows)

| Column | Meaning |
|---|---|
| ShiftCode | AM (07:00 to 15:00), PM (15:00 to 23:00), ND night (23:00 to 07:00) |
| PaidHours | 8 hours per shift |
| PenaltyMultiplier | Shift loading: AM 1.00, PM 1.125, ND 1.15 (made up) |

## Staff (one row per person)

| Column | Meaning |
|---|---|
| StaffID | S.... for employees, A.... for agency staff |
| HomeID | The home an employee belongs to. Blank for agency staff |
| Role | RN, EN or PCW |
| EmploymentType | Full time, Part time, Casual or Agency |
| ContractedHoursPerFortnight | 80 full time, 48 part time, 0 casual and agency |
| HourlyRate | Pay rate for employees. Charge rate for agency staff |
| AgencyName | Agency name for agency staff. Blank for employees |

## PayPeriods

Fortnightly pay periods, Monday to Sunday, starting 30 Jun 2025. PayDate is the Friday after the period ends.

## Roster (one row per shift slot)

| Column | Meaning |
|---|---|
| RosterID | Unique ID |
| ShiftDate, HomeID, ShiftCode, Role | Which shift and which role |
| StaffID | Who is rostered. **Blank means the shift was not filled** |
| ShiftSource | Planned, Replacement - own staff, Replacement - overtime, Replacement - agency |
| ReplacesRosterID | For replacement shifts: the RosterID of the planned shift it replaces (because of sick leave or an unfilled shift) |

## Leave

Sick leave and carer's leave taken on a rostered day. Paid = N for casual staff (no paid sick leave).

## Timesheets (one row per shift actually worked)

| Column | Meaning |
|---|---|
| ClockIn, ClockOut | Clock times |
| ShiftHours | Normal shift hours (8) |
| OvertimeHours | Extra hours stayed after the shift |
| OvertimeApproved | Y or N when there is overtime. Blank when there is none |
| OvertimeShift | Y when the whole shift was worked as overtime (replacing a sick colleague) |

Agency staff also sign in, so they have timesheets too.

## Payroll (employees only, paid periods only)

| Column | Meaning |
|---|---|
| PayType | Ordinary, Overtime or Sick leave |
| Hours | Hours paid |
| BaseRate | Hourly rate used |
| Multiplier | Loading used (shift, weekend, casual, or 1.5 for overtime) |
| Amount | Hours x BaseRate x Multiplier |

Pay rules used (made up): PM x1.125, night x1.15, Saturday x1.5, Sunday x1.75, casual x1.25, overtime x1.5.

## AgencyInvoices (one row per agency shift charged)

Hours x ChargeRate = Amount. One invoice number per agency, per home, per month.

## LabourBudget

Budgeted labour hours and cost per home per month.

## DailyOccupancy

Occupied beds per home per day. Use it for labour cost per resident per day.
