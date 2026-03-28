# Database Schema (`v2`)

The application is powered by a local, offline-first SQLite database managed by `DatabaseHelper`.

## Core Tables

### 1. `Meter`
Stores the actual entities being tracked.
- `id` (INTEGER PRIMARY KEY)
- `meter_name` (TEXT)
- `opening_reading` (REAL): The initial baseline reading.
- `latest_reading` (REAL): Constantly updated to match the highest billed reading, serving as the `Previous Reading` for the next cycle.

### 2. `BillingHistory`
Represents a generated "Invoice" event (groups records together).
- `id` (INTEGER PRIMARY KEY)
- `month_year` (TEXT): The billing cycle string.
- `total_cost_per_unit` (REAL): The rate applied during this bill.
- `date_added` (INTEGER): Timestamp.

### 3. `BillingRecords`
The line-items linking Meters to a specific Bill.
- `id` (INTEGER PRIMARY KEY)
- `bill_id` (FOREIGN KEY -> BillingHistory)
- `meter_id` (FOREIGN KEY -> Meter)
- `previous_reading` (REAL)
- `current_reading` (REAL)
- `consumption` (REAL)
- `amount` (REAL)

*Note: Foreign keys enforce `ON DELETE CASCADE`, ensuring no orphaned data if a Meter or Bill is deleted.*
