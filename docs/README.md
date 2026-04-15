# Electricity Consumption Tracker — Documentation

Welcome to the project documentation. This folder covers the full current feature set, architecture, and database schema of the app as it stands today.

## Table of Contents

1. [Architecture & Tech Stack](features/architecture.md)
2. [Authentication](features/authentication.md)
3. [Dashboard & Navigation](features/dashboard_navigation.md)
4. [Data Entry (Single & Bulk)](features/data_entry.md)
5. [Invoice & Bill Details](features/invoice_history.md)
6. [Meter History & Delete](features/meter_history.md)
7. [Reports & Export](features/reports_export.md)
8. [Settings](features/settings.md)
9. [Firestore Database Schema](features/database_schema.md)

## Overview

This is a **Flutter** application designed for landlords and property managers to digitize electricity consumption tracking across multiple meters (shops, apartments, tenant units).

### Key Capabilities
- **Firebase Auth:** Secure login per account; all data is scoped to the authenticated user.
- **Cloud Firestore:** All data is stored in the cloud — no local SQLite.
- **Flexible Meter Names:** Manage unlimited meters and rename them at any time.
- **Dual Entry Modes:** Single-meter or lightning-fast bulk data entry.
- **Automated Calculations:** Usage and amounts auto-calculated from previous/current readings.
- **Bill Sharing:** Generate and share a receipt-style bill image via any platform.
- **PDF Export:** Export any meter's full history or the filtered analytics report as a PDF.
- **Delete Readings:** Remove incorrect entries from meter history with automatic data recalculation.
- **Dark / Light Mode:** Full theme support across all screens.
