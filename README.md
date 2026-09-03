# 📱 KAESET MESSAGE SYSTEM

**KAESET MESSAGE SYSTEM** is a production-ready, 100% offline Android mobile application built with Flutter and SQLite. It reads and parses M-Pesa SMS messages directly from the device's local SMS inbox, stores transaction records in an indexed SQLite database, and provides a powerful, sub-500ms real-time search interface for business owners to find customer transactions by name or transaction code.

---

## 🌟 Key Features

1. **Local M-Pesa SMS Ingestion & High-Precision Parsing**
   - Directly reads M-Pesa SMS messages from the device telephony database via Android ContentResolver.
   - Extracts customer name, amount (KES), transaction reference code, timestamp, and transaction type (`Received` / `Sent`).
   - Supports money received, direct money transfers, and Paybill/Buy Goods payments.

2. **Ultra-Fast Local SQLite Database**
   - Local database (`kaeset_transactions.db`) with case-insensitive indexing on the `name` column and unique constraint on `transaction_code`.
   - Batch insert with duplicate suppression to handle **10,000+ SMS records** smoothly.
   - Real-time aggregations (Transaction counter, Total KES Received, Total KES Sent).

3. **Sub-500ms Instant Search & Smart Filters**
   - Real-time search as the user types.
   - Search by customer name, phone number, or M-Pesa transaction code.
   - Filter by transaction type (`All`, `📥 Received`, `📤 Sent`).
   - Sort by Date (Newest/Oldest), Amount (Highest/Lowest), or Customer Name (A-Z).

4. **Dynamic Global Font Customization (1.0x - 2.0x)**
   - Settings slider to scale all typography across the app from 100% to 200%.
   - Instant real-time card preview before applying.
   - Persistent preference storage via `SharedPreferences`.
   - Single-tap reset to default.

5. **Data Management & Export**
   - Export all transaction records to CSV/Excel format for business accounting.
   - Clear all stored data with a confirmation modal.
   - Built-in sample data generator for instant testing in emulators without SIM cards.

6. **100% Offline & Private by Design**
   - **Zero internet permission** declared in `AndroidManifest.xml`.
   - No external APIs, trackers, or cloud servers. All financial data remains encrypted on the user's phone.

---

## 📁 Project Architecture

```
lib/
├── main.dart                      # App entry point, MultiProvider & global TextScaler
├── models/
│   └── transaction.dart           # Transaction data model & TransactionType enum
├── services/
│   ├── database_service.dart      # SQLite database helper, indexing, batching, queries
│   ├── sms_service.dart           # Android SMS reading & Safaricom regex parsing engine
│   └── preference_service.dart    # SharedPreferences persistence (font scale, sync time)
├── providers/
│   ├── font_size_provider.dart    # State manager for dynamic font scaling
│   └── transaction_provider.dart  # State manager for transactions, sync, search & exports
├── utils/
│   ├── constants.dart             # Colors, themes, keys, and typography specs
│   ├── helpers.dart               # Currency (KES), date/time, and CSV formatters
│   └── themes.dart                # Material 3 Royal Blue & Teal styling
├── widgets/
│   ├── transaction_card.dart      # Elevated transaction card (Green=Received, Red=Sent)
│   ├── search_bar.dart            # Real-time search input with filter chips
│   ├── font_slider.dart           # 1.0x to 2.0x font size slider with live preview
│   └── custom_button.dart         # Action buttons with loading states
└── screens/
    ├── home_screen.dart           # Dashboard: metrics, sync button, recent transactions
    ├── search_screen.dart         # Full search view with sorting and filters
    ├── settings_screen.dart       # Font sizing, CSV export, and clear data
    └── about_screen.dart          # Offline privacy guarantee and developer info
```

---

## 🚀 Getting Started & Build Instructions

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16 or higher)
- [Android SDK](https://developer.android.com/studio) (API level 21 minimum, API 33/34 target)
- Java Development Kit (JDK 17 or 11)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Unit Tests
Verify the M-Pesa SMS parsing engine:
```bash
flutter test
```

### 3. Run on Connected Android Device / Emulator
```bash
flutter run
```

### 4. Build Production Release APK
```bash
# Build standard release APK
flutter build apk --release

# Output path:
# build/app/outputs/flutter-apk/app-release.apk

# Or build split APKs per ABI (reduced size under 15MB):
flutter build apk --split-per-abi
```

---

## 📱 User Guide & Operating Instructions

1. **First Launch & Permissions**:
   - On opening the app, grant the **SMS Permission** prompt so KAESET can read incoming and stored M-Pesa receipts.
2. **Sync Messages**:
   - Tap **"Sync M-Pesa SMS"** on the home dashboard. The app will parse all M-Pesa SMS messages and save them locally.
   - If testing on an emulator without a SIM card, tap **"+ Sample Data"** to load realistic transactions immediately.
3. **Search Transactions**:
   - Navigate to the **Search** tab or tap the top search bar.
   - Type any customer name (e.g., "John") or transaction code.
   - Use the filter chips (`Received`, `Sent`) and sort dropdown to locate records instantly.
4. **Customize Font Size**:
   - Go to **Settings** and drag the **Font Size Scale** slider (1.0x to 2.0x). The UI and live preview update in real time and persist across app restarts.
5. **Export to CSV**:
   - Go to **Settings > Export Data as CSV** to generate a spreadsheet file with all transaction history.

---

## 📄 License & Ownership
Copyright © 2026 KAESET Enterprise Solutions. All rights reserved.
Developed for business owners managing M-Pesa transactions.
