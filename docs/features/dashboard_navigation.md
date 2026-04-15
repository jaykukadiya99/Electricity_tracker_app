# Dashboard & Navigation

## Main Layout (`MainLayout`)
A `BottomNavigationBar` with four persistent tabs:

| Tab | Screen | Purpose |
|---|---|---|
| Home | `HomeScreen` | Dashboard overview & stats |
| Meters | Grid of meters | List of all meters with quick access to history |
| Reports | `ReportsScreen` | Filterable analytics ledger |
| Settings | `SettingsScreen` | Theme, account info, and data management |

## Home Screen (`home_screen.dart`)
**Controller:** `HomeController`

### Components
- **Top Summary Card (Dark Gradient):** Displays total amount billed this month and total kWh consumed. Always renders in dark gradient style regardless of theme.
- **Active Meters Feed:** Lists all configured meters showing their name and latest reading.
- **FAB (Floating Action Button):** Opens a bottom sheet with two options:
  - **Record Monthly Entry** → navigates to `NewBillScreen` (single meter).
  - **Bulk Entry** → navigates to `BulkBillingScreen` (all meters at once).

## First-Time Setup Flow
1. If no meters exist for the user, `AppController` detects this and routes to `/setup`.
2. **Meter Setup Screen (`meter_setup_screen.dart`):** User enters how many meters exist.
3. **Initial Readings Screen (`meter_initial_readings_screen.dart`):** User enters the current physical reading for each meter as the baseline `opening_reading`.
4. On save, the app routes to `/main` and normal billing can begin.
