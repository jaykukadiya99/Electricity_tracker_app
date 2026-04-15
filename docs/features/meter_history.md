# Meter History & Delete Readings

**Screen:** `meter_history_screen.dart`  
**Controller:** `MeterHistoryController`

## Access
Tap any individual meter in the **Meters** tab to navigate here. The screen receives the `meter_id` and `meter_name` via `Get.arguments`.

## Components

### Lifetime Summary Cards
Three compact stat cards at the top showing for this specific meter:
- **Total Consumption** (kWh) — sum of all billed cycles.
- **Total Cost** (Rs.) — sum of all amounts billed.
- **Latest Reading** — the current registered meter value.

### History Ledger
A chronological list of every billing record for this meter, showing:
- Month/Year label
- Amount billed (Rs.)
- Previous Reading
- Current Reading
- Consumption (kWh)

---

## Delete a Reading

Each history card has a **red trash icon** in the top-right corner.

### Confirmation
Tapping the icon opens a `Get.defaultDialog` confirmation prompt before any deletion occurs.

### What happens on deletion (`DatabaseHelper.deleteBillingRecord`)
The deletion triggers a 3-step cascade to preserve data integrity:

1. **Delete the record:** Removes the specific `billingRecords` document from Firestore.
2. **Recalculate meter's latest reading:**
   - Fetches remaining history for that meter sorted by most recent.
   - Sets `latest_reading` to the `current_reading` of the most recent remaining record.
   - If no history remains, falls back to the meter's original `opening_reading`.
3. **Update the parent bill totals:**
   - Subtracts the deleted record's `amount` and `consumption` from the parent `billingHistory` document's totals.
   - If no records remain for that bill, the entire `billingHistory` document is also deleted.

This ensures the next bill entry will use the correct previous reading automatically.

---

## PDF Export
The AppBar contains a **PDF icon button** that calls `controller.exportToPdf()`.  
- Generates a paginated PDF table: `[Month/Year, Prev, Current, Usage, Amount]`.
- Note: Amounts are displayed as `Rs. X.XX` (the Rs. prefix) because standard PDF fonts don't support the `₹` Unicode symbol.
- The file is saved to the app's documents directory and shared via the native share sheet.
