# Data Entry Modules

Two workflows exist for entering monthly meter readings.

---

## 1. Single Meter Entry

**Screen:** `new_bill_screen.dart`  
**Controller:** `NewBillController`

### Flow
1. User selects a **billing date** from a date picker.
2. User selects one **specific meter** from a dropdown.
3. User enters the **new current reading** for that meter.
4. User enters the **cost per unit** (Rs./kWh) for this cycle.
5. On tap, the `Save` button disables immediately (`isLoading = true`) to prevent double-submission.
6. On success, the app navigates to `BillDetailsScreen` to show the generated invoice.

### Validation
- Current reading **must not be less** than the previous reading.
- Cost per unit **must be greater than 0**.
- Meter **must be selected**.

### What gets saved
- A `billingHistory` document (parent bill).
- A `billingRecords` document (line item for that meter).
- The meter's `latest_reading` is immediately updated to the new current value.
- The parent bill's `total_amount` and `total_consumption` are updated.

---

## 2. Bulk Data Entry

**Screen:** `bulk_billing_screen.dart`  
**Controller:** `BulkBillingController`

### Flow
1. User sets a **global billing date** and a **global cost per unit** for the entire cycle.
2. **All meters** are listed. User enters the new reading for each one (blank = skip that meter).
3. Keyboard advances to the next field automatically.
4. The `Save` button sits statically at the bottom outside the scroll area.
5. On tap, the `Save` button disables to prevent double-submission.
6. On success, navigates to `BillDetailsScreen` showing the combined multi-meter invoice.

### Validation
- At least **one meter** must have a new reading entered.
- Any entered reading **must not be less** than the previous reading for that meter.

### What gets saved
- One shared `billingHistory` parent document.
- One `billingRecords` document per meter that had a new reading entered.
- Each included meter's `latest_reading` is updated.
- The parent bill's aggregated `total_amount` and `total_consumption` are computed and stored.
