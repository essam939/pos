
# 🧾 Mini-POS Checkout Core (Logic-only)

A headless, fully unit-tested checkout engine written in Dart using BLoC.  
This project powers the core business logic for future POS and self-service systems — **without any UI or database**.

---

## ✅ Features

- 🧠 Pure BLoC state management
- 🛒 Add / remove items, change quantity & discount
- 💸 Real-time totals calculation (Subtotal, VAT, Grand Total)
- 🔄 Undo / Redo last cart actions
- 💾 State persistence with `hydrated_bloc`
- 🧾 Receipt builder (pure function)
- 🧪 Fully unit-tested with coverage

---

## 📦 Folder Structure

```markdown
. 📂 lib
├── 📄 main.dart
└── 📂 src/
│  └── 📂 cart/
│    └── 📂 bloc/
│      ├── 📄 cart_bloc.dart
│      ├── 📄 cart_event.dart
│      ├── 📄 cart_state.dart
│    ├── 📄 cart_line.dart
│  └── 📂 catalog/
│    └── 📂 bloc/
│      ├── 📄 catalog_bloc.dart
│      ├── 📄 catalog_event.dart
│      ├── 📄 catalog_state.dart
│    ├── 📄 receipt.dart
│  ├── 📄 item_model.dart
│  └── 📂 util/
│    ├── 📄 constants.dart
│    └── 📄 money.dart
```
---

## 🚀 How to Run

1. Get packages:
```bash
flutter pub get
```

2. Run tests with coverage:
```bash
flutter test --coverage
```

---

## 🔧 Flutter & Dart Versions

- Flutter: 3.32
- Dart: 3.8

---

## 🕒 Time Spent

Total: **8 hours**
- Logic, BLoC, Receipt, Undo/Redo, Hydration, Testing & Docs

---

## 📁 Notes

- `main.dart` acts as a logic demo (no UI)
- `assets/catalog.json` contains 20 items
- All state is immutable & uses value equality
- `asMoney` is a num extension to format currency

---
