# Medication Reminder App 💊⏰

A mobile application built with **Flutter** to help users manage their medications, doses, and schedules. The app focuses on simplicity, offline-first storage, and clean architecture using MVVM with GetX.

## 📌 Overview

The app allows users to:
- Add medications with name, dosage, frequency, duration, notes, and an optional photo.
- Define custom dose times for each medication and store them in a `medication_schedule` table.
- View all active medications in a clean card-based UI.
- Edit or delete medications with confirmation dialogs.
- Keep medication data stored locally with optional sync support.

## ✨ Features

- User authentication (login / registration).
- Add / edit / delete medications.
- Custom dose time selection using a compact time picker.
- Active Medications screen with:
  - Name, dosage, frequency.
  - Next dose and duration info.
  - Optional note.
  - Edit / Delete actions with dialogs.
- Local database using Floor (SQLite) with `sync_status` flags.
- MVVM architecture + GetX for controllers, navigation, and reactivity.
- Image support for medications (camera / gallery).

## 🧱 Tech Stack

- **Framework:** Flutter  
- **Language:** Dart  
- **Architecture:** MVVM + GetX  
- **Local Storage:** Floor (SQLite)  
- **Backend / Auth:** Supabase (or similar)  
- **Other:** Path Provider, Image Picker, Connectivity, etc.

## 📂 Project Structure

lib/
├─ main.dart
├─ views/
│ ├─ login_page.dart
│ ├─ registration_page.dart
│ ├─ home_page.dart
│ ├─ add_medication_page.dart
│ ├─ medications_page.dart
│ └─ medication_log_page.dart
├─ controllers/
│ ├─ login_controller.dart
│ ├─ registration_controller.dart
│ ├─ home_controller.dart
│ ├─ add_medication_controller.dart
│ ├─ medications_controller.dart
│ └─ medication_log_controller.dart
├─ data/
│ ├─ entity/
│ │ ├─ users.dart
│ │ ├─ medications.dart
│ │ ├─ medication_schedule.dart
│ │ └─ intake_records.dart
│ └─ dao/
│ ├─ user_dao.dart
│ ├─ medications_dao.dart
│ ├─ medication_schedule_dao.dart
│ └─ intake_record_dao.dart
├─ core/
│ ├─ app_database.dart
│ └─ init_local_db.dart
└─ services/
├─ auth_service.dart
├─ medication_service.dart
└─ connectivity_service.dart

