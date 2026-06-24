# UJ-ISMS

## University of Jordan - Inter-Departmental Services & Equipment Management System

### Overview

UJ-ISMS is a Flutter-based mobile application designed to streamline inter-departmental service requests, maintenance operations, and equipment management across the University of Jordan.

The system provides a centralized platform that enhances communication, transparency, and coordination between university departments while improving service delivery efficiency and response times.

Built with Flutter and powered by Firebase, the application offers real-time data synchronization, secure authentication, cloud storage, and scalable cloud infrastructure.

---

## Objectives

- Centralize service and maintenance request management.
- Improve equipment tracking and lifecycle management.
- Enhance communication between university departments.
- Reduce service response and resolution times.
- Increase operational transparency and accountability.
- Provide real-time updates for requests and assets.

---

## Features

### Service Request Management

- Create and submit service requests.
- Track request status in real time.
- Assign requests to responsible departments.
- View request history and updates.

### Maintenance Management

- Schedule and monitor maintenance activities.
- Track maintenance progress and completion.
- Maintain service logs and maintenance records.
- Receive notifications for maintenance updates.

### Equipment Management

- Register and manage university assets.
- Track equipment availability and location.
- Monitor equipment condition and maintenance history.
- Maintain equipment usage records.

### User Management

- Secure authentication using Firebase Authentication.
- Role-based access control.
- Department-specific permissions and access levels.

### Notifications

- Real-time notifications for:
  - New service requests
  - Request status updates
  - Maintenance schedules
  - Equipment-related updates

---

## Technology Stack

### Frontend

- Flutter
- Dart
- Provider (State Management)

### Backend

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging (FCM)
- Firebase Storage

### Development Tools

- Android Studio
- VS Code
- Git & GitHub
- Firebase Console

---

## System Architecture

```text
┌─────────────────────┐
│     Flutter App     │
│   (Provider State   │
│     Management)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│      Firebase       │
├─────────────────────┤
│ Authentication      │
│ Cloud Firestore     │
│ Cloud Storage       │
│ Cloud Messaging     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ University Users &  │
│ Departments         │
└─────────────────────┘
```

---

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Firebase Project
- Android Studio or VS Code

### Installation

1. Clone the repository:

```bash
git clone https://github.com/Leen-Zulof/UJ-ISMS.git
```

2. Navigate to the project directory:

```bash
cd UJ-ISMS
```

3. Install dependencies:

```bash
flutter pub get
```

4. Configure Firebase:

- Create a Firebase project.
- Register Android and/or iOS applications.
- Download the Firebase configuration files:
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS
- Place the files in their respective directories.

5. Run the application:

```bash
flutter run
```

---

## Future Enhancements

- QR code-based equipment tracking.
- Equipment reservation and booking system.
- Advanced analytics and reporting dashboard.
- Web-based administration portal.
- AI-powered maintenance prediction.
- Integration with university ERP systems.

---

## Team Members

- **Leen Zulof**
- **Tolay Khamis**

---

## License

This project is intended for academic and educational purposes.
