# Invoice & Meter History

## Invoice Summary (`bill_details_screen.dart`)
When data is saved, the application produces a highly professional, itemized Invoice Summary.

- **Total Display:** Prominently flaunts the Total Amount Due `(₹)` and Total Usage `(kWh)`.
- **Meter-Wise Breakdown:** Filters out empty records and displays a specific white card for every meter included in the bill.
- **Card Details:** Each card lists the Meter Name, subtotal cost, Previous Reading, Current Reading, and the exact calculated Usage difference.

## Meter History (`meter_history_screen.dart`)
Accessible by tapping any individual meter directly from the "METERS" tab list.

- **Overview Summary:** Instantly computes the lifetime Total Cost `(₹)` and Total Usage `(kWh)` for that specific meter.
- **Ledger:** Provides a chronological scrollable list of every past billing cycle the meter was involved in, detailing the exact reading jumps and costs for historical auditing.
