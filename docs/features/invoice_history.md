# Invoice & Bill Details

**Screen:** `bill_details_screen.dart`  
**Controller:** `BillDetailsController`

## Overview
After saving any bill (single or bulk), the user is automatically taken to the Bill Details screen, which displays a full breakdown of the generated invoice.

## Components

### Summary Card (Dark Gradient)
- **Total Amount Due** (Rs.)
- **Total Consumption** (kWh)
- **Billing Date / Month**
- Always renders in the dark navy gradient — not affected by light/dark theme toggle.

### Meter-Wise Breakdown Cards
For each meter included in the bill:
- Meter name
- Previous Reading
- Current Reading
- Consumption (kWh)
- Subtotal Amount (Rs.)

Empty meters (no consumption) are automatically filtered out.

## Share Bill as Image

A **Share** icon in the AppBar allows the user to export the bill as an image.

### How it works
1. A hidden off-screen `_buildShareWidget` captures the bill layout via `screenshotController`.
2. The widget is **always rendered in light mode** (`Theme(data: ThemeData.light(...))` wrapper) regardless of the user's current app theme — ensuring text is always dark on a white receipt background.
3. Critical text and table data explicitly use `color: Colors.black` for maximum contrast.
4. The captured image is shared via the platform's native share sheet using `share_plus`.

## Bill Deletion
- Individual bills can be deleted from the home screen bill history list.
- Deleting a bill removes the `billingHistory` document and all child `billingRecords` via `DatabaseHelper.deleteBill`.
