# UtilityFlow (Electricity Consumption Tracker)

Welcome to the UtilityFlow Documentation! This folder contains detailed breakdowns of the core features and architecture of our Electricity Consumption Tracking application.

## Table of Contents

1. [Dashboard & Navigation](features/dashboard_navigation.md)
2. [Data Entry (Single & Bulk)](features/data_entry.md)
3. [Invoice & Meter History](features/invoice_history.md)
4. [Database Schema](features/database_schema.md)

## Overview

UtilityFlow is a specialized Flutter application designed for landlords and property managers to seamlessly track electricity consumption across multiple meters (e.g., shops, apartments). It replaces traditional paper tracking with a fully digitized, offline-first SQLite database.

## Key Capabilities

- **Flexible Meter Naming:** Manage unlimited meters and rename them on the fly (e.g., "Shop 1").
- **Smart Entry:** Choose between highly detailed single-meter entry or lightning-fast bulk data entry.
- **Automated Calculations:** Automatically calculates usage subtracting prior readings from current entries.
- **Full History:** Generates precise, itemized invoices and maintains a historical ledger for every individual meter.
