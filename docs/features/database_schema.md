# Firestore Database Schema

The application uses **Cloud Firestore** (not SQLite). All data is scoped per-user under `/users/{uid}/`.

**`DatabaseHelper`** (`lib/db/database_helper.dart`) is the single access point — all controllers and screens use this singleton class.

---

## Collection: `meters`
Path: `/users/{uid}/meters/{meterId}`

Stores each physical meter being tracked.

| Field | Type | Description |
|---|---|---|
| `meter_name` | String | Display name (e.g. "Shop 1", "Meter 2") |
| `opening_reading` | Number | The initial baseline reading; used as fallback if all history is deleted |
| `latest_reading` | Number | Always kept up-to-date with the most recent billed `current_reading`; serves as `previous_reading` for the next bill |
| `created_at` | Number | Timestamp (ms) |

---

## Collection: `billingHistory`
Path: `/users/{uid}/billingHistory/{billId}`

Represents a single billing event (a "parent" record grouping one or more meter entries).

| Field | Type | Description |
|---|---|---|
| `month_year` | String | Billing cycle label (e.g. "15 Apr 2025") |
| `total_cost_per_unit` | Number | The Rs./kWh rate applied for this bill |
| `total_amount` | Number | Sum of all child record amounts |
| `total_consumption` | Number | Sum of all child record consumptions (kWh) |
| `date_added` | Number | Timestamp (ms) |

---

## Collection: `billingRecords`
Path: `/users/{uid}/billingRecords/{recordId}`

Stores individual meter line-items. Each record belongs to a parent `billingHistory`.

| Field | Type | Description |
|---|---|---|
| `bill_id` | String | Reference to parent `billingHistory` document ID |
| `meter_id` | String | Reference to `meters` document ID |
| `meter_name` | String | Denormalised name for display without joins |
| `month_year` | String | Billing cycle label (denormalised) |
| `previous_reading` | Number | The meter's reading at start of this cycle |
| `current_reading` | Number | The meter's reading at end of this cycle |
| `consumption` | Number | `current_reading - previous_reading` |
| `amount` | Number | `consumption × cost_per_unit` |
| `created_at` | Number | Timestamp (ms) |

---

## Key Relationships & Cascade Behaviour

- **Deleting a bill** (`DatabaseHelper.deleteBill`): Removes the parent `billingHistory` document AND all child `billingRecords` with that `bill_id`.
- **Deleting a reading** (`DatabaseHelper.deleteBillingRecord`):
  1. Removes the specific `billingRecords` document.
  2. Recalculates and updates the parent `billingHistory` totals.
  3. Updates the associated meter's `latest_reading` to the next most-recent `current_reading`, or falls back to `opening_reading` if no records remain.
- **Clearing all data** (`DatabaseHelper.clearAllData`): Batch-deletes all documents across `meters`, `billingHistory`, and `billingRecords` for the current user.

---

## Important Notes

- **No hard FK enforcement** in Firestore (unlike SQL). Referential integrity is maintained manually in `DatabaseHelper`.
- `meter_name` and `month_year` are intentionally **denormalised** onto `billingRecords` to allow efficient display without secondary lookups.
