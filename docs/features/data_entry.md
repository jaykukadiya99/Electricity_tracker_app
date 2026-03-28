# Data Entry Modules

The application supports two distinct workflows for inputting monthly readings, catering to different user preferences and scale.

## 1. Single Meter Entry (`new_bill_screen.dart`)
Designed for precision and detailed review of a single unit.

- **Billing Cycle Selection:** Users tap to select the exact `month_year` for the bill.
- **Meter Dropdown:** Select the specific meter. The system automatically fetches that meter's absolute `latest_reading` to use as the base `Previous Reading`.
- **Dynamic Cost:** Allows inputting a specific Cost per Unit `(₹)` for this entry.
- **Redirection:** Upon saving, the system creates an isolated invoice and immediately redirects the user to the `Bill Details` screen to view the generated breakdown.

## 2. Bulk Data Entry (`bulk_billing_screen.dart`)
Designed for speed and efficiency when processing an entire property at the end of the month.

- **Global Parameters:** The user sets a single global Billing Date and a global Cost per Unit `(₹)`.
- **List Input:** Every active meter is mapped into a vertical list. The user effortlessly scrolls down, typing the new reading into the right-aligned text fields for each meter.
- **Validation:** Safeguards prevent inputting a reading lower than a meter's previous reading.
- **Batch Processing:** On save, it updates every meter's `latest_reading` simultaneously and generates a unified multi-meter invoice, redirecting the user to the master `Bill Details` screen.
