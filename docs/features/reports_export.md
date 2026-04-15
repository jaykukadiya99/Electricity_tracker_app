# Reports & Export

**Screen:** `reports_screen.dart`  
**Controller:** `ReportsController`

## Overview
The Reports screen provides an in-depth analytics ledger across all meters and all time, with rich filtering capabilities.

## Lifetime Summary Card (Dark Gradient)
Always visible at the top regardless of filters:
- **Total Billed** (Rs.) — lifetime sum across all records.
- **Total Consumption** (kWh) — lifetime sum across all records.

## Filter Bar
Four interactive filter controls:

| Filter | Description |
|---|---|
| **Meter** | Dropdown — filter to a specific meter or view all. |
| **Start Date** | Date picker — filter records on or after this date. |
| **End Date** | Date picker — filter records up to and including this date. |
| **Latest Only toggle** | When ON (default), shows only the most recent entry per meter. When OFF, shows full historical ledger. |
| **Clear Filters** | Resets all filters to default state. |

## Ledger Table
Below the summary, each filtered record appears as a table row showing:
- Billing date
- Meter name
- Previous → Current readings
- Consumption (kWh)
- Amount (Rs.)

## PDF Export

The **PDF icon** in the AppBar exports all **currently filtered records** as a PDF.

### `PdfService` (`lib/services/pdf_service.dart`)
A reusable static service used by both the Reports screen and the Meter History screen.

**`generateAndShareReport({title, headers, data})`**
1. Creates a `pw.Document` with a header block (title + generated date).
2. Builds a `TableHelper.fromTextArray` with a dark blue-grey header row and zebra-striped rows.
3. Saves the PDF to `getApplicationDocumentsDirectory()`.
4. Calls `Share.shareXFiles` to trigger the native share sheet.

> **Note:** All amount columns use `Rs. X.XX` prefix instead of `₹` — built-in PDF fonts (Helvetica) don't support the `₹` Unicode glyph. Embedding a custom TTF (e.g. Noto Sans) would resolve this if needed in future.

### Reports PDF Columns
`[Date, Meter, Prev, Current, Usage, Amount]`

### Meter History PDF Columns
`[Month/Year, Prev, Current, Usage, Amount]`
