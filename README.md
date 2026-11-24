# PINKLEDGER – Every Rupee, Under Control.

A premium, production-ready personal finance and expense management application built with Flutter and Dart.

---

## 📱 Direct Download (Release APK)

Download and install the latest release directly on your Android device:

[![Download APK](https://img.shields.io/badge/Download_APK-PinkLedger_v1.0.0-10B981?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Thuyavan28/Expense_tracker/raw/main/releases/PinkLedger-release.apk)
[![Platform](https://img.shields.io/badge/Platform-Android_7.0+-000000?style=for-the-badge&logo=android)](https://github.com/Thuyavan28/Expense_tracker/raw/main/releases/PinkLedger-release.apk)
[![Status](https://img.shields.io/badge/Build-Passing-10B981?style=for-the-badge)](https://github.com/Thuyavan28/Expense_tracker)

| Package | Direct Download Link | Size | Architecture | Sideload Ready |
|---|---|---|---|---|
| **PinkLedger v1.0.0 (Release)** | [📥 **Download PinkLedger-release.apk**](https://github.com/Thuyavan28/Expense_tracker/raw/main/releases/PinkLedger-release.apk) | ~51.6 MB | universal (arm64-v8a, armeabi-v7a, x86_64) | ✅ Yes (Signed) |
| **Direct Raw Mirror** | [📥 **Raw GitHub Link**](https://raw.githubusercontent.com/Thuyavan28/Expense_tracker/main/releases/PinkLedger-release.apk) | ~51.6 MB | universal | ✅ Yes |

### 📲 Quick Installation Guide:
1. Tap the **[Download PinkLedger-release.apk](https://github.com/Thuyavan28/Expense_tracker/raw/main/releases/PinkLedger-release.apk)** link above from your Android phone browser.
2. Once downloaded, open your **Downloads** notification or file manager and tap `PinkLedger-release.apk`.
3. If prompted with *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings** and toggle **"Allow from this source"**.
4. Tap **Install** and launch **PinkLedger**!

---

## Overview

PINKLEDGER is a comprehensive financial management application that helps users take control of their money. It enables tracking of income, expenses, budgets, savings, recurring payments, financial goals, and spending analytics — all with a modern, high-contrast light interface.

## Brand Identity & Design System

- **App Name:** PINKLEDGER
- **Tagline:** Every Rupee, Under Control.
- **Theme:** High-Contrast Modern Light Theme
- **Primary Accent:** `#10B981` (Lite Green / Emerald)
- **Background:** `#FFFFFF` (Pure White)
- **Text & Solid Borders:** `#000000` (Crisp Solid Black)
- **Card Background:** `#F8FAF9` / `#FFFFFF` with bold `2px` black borders

## Features

### Core Finance Management
- **Income & Expense Tracking** – Add, edit, delete, and categorize transactions
- **Transfer Management** – Move money between accounts (not counted as income/expense)
- **Transaction Timeline** – View transactions grouped by date
- **Search, Filter, Sort** – Find transactions by date, type, category, payment method
- **Duplicate Detection** – Prevent accidental double entries

### Dashboard
- **Balance Overview** – Total balance, income, expenses, net savings with animated numbers
- **Privacy Toggle** – Hide/show balance for security
- **Spending Overview** – Interactive charts and visualizations
- **Income vs Expenses** – Comparative analysis
- **Recent Transactions** – Quick access to latest activity
- **Top Spending Categories** – Category-wise breakdown
- **Budget Progress** – Track budget consumption
- **Upcoming Bills** – Recurring payment reminders
- **Savings Goal Progress** – Track goal achievements

### Budget Management
- Monthly, weekly, category-wise, and custom budgets
- Budget progress bars with percentage consumed
- Alerts at 50%, 75%, 90%, and 100% thresholds
- Budget exceeded warnings with actionable suggestions

### Analytics & Insights
- Daily, weekly, monthly, and yearly spending charts
- Income vs expense comparison
- Category and payment method distribution
- Spending and savings trends
- Smart financial insights (e.g., "You spent 18% more on food this month")
- Predicted end-of-month spending (labelled as estimates)

### Recurring Transactions & Bill Reminders
- Daily, weekly, monthly, yearly, and custom schedules
- Next payment date tracking
- Pause, resume, edit, cancel recurrences
- Configurable reminders (1, 3, 7 days before due)
- Local notifications for upcoming bills

### Savings Goals
- Create goals (emergency fund, travel, laptop, etc.)
- Track target amount, current amount, progress percentage
- Add contributions and view history
- Estimated completion date

### Accounts & Payment Methods
- Multiple accounts (Cash, Savings, Current, Wallet, Credit Card)
- Account balances and transaction history
- Account transfers
- Balance reconciliation

### Receipt Scanner
- Capture receipts via camera or gallery
- Review extracted details before creating transactions
- Manual entry with confirmation

### Export & Reports
- **CSV Export** – Export transactions to CSV format
- **PDF Export** – Generate professional financial reports
- Monthly expense, income, category, and budget reports
- Share and save exported files

### Security & Privacy
- App PIN lock with optional biometric authentication
- Privacy balance toggle
- Automatic app lock after configurable inactivity
- Secure local storage for authentication secrets
- Data export and deletion
- Never stores card CVV or banking passwords

### Offline-First
- All data stored locally using Hive (NoSQL) and SharedPreferences
- Full functionality without internet access
- Transaction-safe balance updates
- Database migrations support
- Local notifications
- Backup and restore capability

### Themes
- Light mode and Dark mode support
- System theme following
- Premium deep purple and pink brand colors throughout

## Technical Stack

- **Framework:** Flutter 3.50+, Dart 3.14+
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Local Database:** Hive (NoSQL, offline-first)
- **Local Preferences:** SharedPreferences
- **Secure Storage:** Flutter Secure Storage
- **Biometric Auth:** local_auth
- **Charts:** fl_chart
- **Camera & Images:** image_picker, camera
- **Notifications:** flutter_local_notifications
- **PDF Export:** pdf package
- **CSV Export:** csv package
- **Animations:** AnimationController, TweenAnimationBuilder, CustomPainter

## Project Structure

```
lib/
  app/              # App configuration and routing
  core/             # Core services, theme, database, security
  features/         # Feature-based modules (dashboard, transactions, budgets, etc.)
  shared/           # Reusable widgets, popups, animations
```

## Getting Started

### Prerequisites
- Flutter SDK 3.50 or higher
- Dart SDK 3.14 or higher
- Android Studio or VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/Thuyavan28/Expense_tracker.git
cd Expense_tracker

# Get dependencies
flutter pub get

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

### Android Setup
The app targets Android API level 21+ (minSdkVersion) and compiles against API level 34.

## Screenshots

*(Add screenshots here after building the APK)*

## License

This project is proprietary software.

## Support

For support, contact the PINKLEDGER development team.

---

**PINKLEDGER – Every Rupee, Under Control.**
