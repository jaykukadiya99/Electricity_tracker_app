# Dashboard & Navigation

## Main Layout
The application structure is rooted in `MainLayout` which orchestrates a persistent `BottomNavigationBar` allowing instant switching between core tabs:
- **HOME:** The main Dashboard overview.
- **METERS:** The master list of all tracking meters.
- **REPORTS:** (Coming Soon) Detailed financial reporting.
- **SETTINGS:** Application configuration.

## Dashboard (Home Screen)
The Home Screen (`home_screen.dart`) is the centralized command center.

### Components
- **Top Summary Card:** Displays high-level account status, recent total bills, and general property health.
- **Consumption Analytics Module:** A dark naval-blue card mapping aggregate usage.
- **Active Meters List:** A dynamic feed of all currently tracked meters, showing their status and usage snapshots.
- **Smart Action Button (FAB):** The floating action button spawns a Bottom Sheet allowing the user to instantly select their preferred workflow: "Single Meter Entry" or "Bulk Entry".
