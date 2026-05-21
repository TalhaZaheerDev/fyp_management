# FYP Management System

A **production-level Final Year Project Management System** built using **Flutter + Firebase**, designed to enable **real-time collaboration, tracking, and evaluation** between students and supervisors.

---

## 🎯 Overview

This system digitizes the entire FYP lifecycle by providing:

- 📡 Real-time communication
- 📊 Intelligent project tracking
- 👥 Role-based dashboards
- ⚡ Scalable Firebase architecture

---

## ✨ Core Features

---

### 🔐 Authentication System

- Firebase Authentication (Signup / Login)
- Login using **Email or Username (custom logic)**
- Role-based access control:
  - 👨‍🎓 Student
  - 👨‍🏫 Supervisor

---

### 👨‍🎓 Student Module

- Create and manage projects
- Select supervisor (username-based)
- Edit project details
- Submit project for evaluation
- Track weekly progress with percentage
- View structured supervisor feedback
- Access real-time chat

---

### 👨‍🏫 Supervisor Module

- View assigned student projects
- Approve / Reject submissions
- Provide structured feedback
- Monitor student progress
- Delete rejected projects (controlled action)
- Access chat with students

---

### 💬 Real-Time Chat System (Advanced)

- Project-based chat threads
- Real-time messaging (Firestore streams)
- Unread message badge
- Seen system (`seenBy` array)
- Last message preview
- Smart timestamp formatting
- Clean messaging UI (WhatsApp-inspired)

---

### 📊 Project Management

- Status lifecycle:
  - Pending
  - Submitted
  - Approved
  - Rejected
- Auto deadline calculation
- Weekly progress tracking
- Dynamic progress percentage

---

### 📈 Dashboard System

#### Student Dashboard
- Project overview cards
- Status-based filtering
- Deadline countdown
- Activity tracking

#### Supervisor Dashboard
- Analytics (Total / Pending / Approved)
- Smart filtering system
- Progress visualization
- Project review access

---

### 👤 Profile System

- View user information:
  - Username
  - Email
  - Role
- Dynamic stats (projects count)
- Secure logout

---

## 🧠 System Architecture

- **Frontend:** Flutter (Cross-platform)
- **Backend:** Firebase (Serverless)

  - Firebase Authentication
  - Cloud Firestore (real-time database)

- **Data Flow:**



Flutter UI → Firebase Auth → Firestore → Real-time Streams



---

## 🗄️ Firestore Data Model

```json
projects:
{
"title": "",
"description": "",
"technologies": "",
"supervisorId": "",
"supervisorName": "",
"userId": "",
"status": "",
"totalWeeks": 24,
"endDate": Timestamp
}
````

```json
messages:
{
  "senderId": "",
  "text": "",
  "timestamp": Timestamp,
  "seenBy": []
}
```

---

## 🎨 UI / UX Highlights

* Minimal & premium design system
* Consistent spacing & layout hierarchy
* Custom components (no default UI)
* Responsive across devices
* Google Fonts (Poppins)
* Clean dashboards & cards

---

## 🛠️ Tech Stack

* **Frontend:** Flutter
* **Backend:** Firebase

  * Firebase Auth
  * Cloud Firestore
* **State Management:** setState (lightweight & efficient)

---

## 📁 Project Structure

```
lib/
│── auth/
│── student/
│── supervisor/
│── chat/
│── models/
│── services/
│── core/
```

---

## ⚙️ Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/TalhaZaheerDev/fyp-management.git
cd fyp-management
```

---

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Firebase Setup

* Add `google-services.json` (Android)
* Add `GoogleService-Info.plist` (iOS)
* Run:

```bash
flutterfire configure
```

---

### 4. Run Application

```bash
flutter run
```

---

## 🌐 Platform Support

* ✅ Android
* ✅ Web (Chrome – Firebase configured)
* ⏳ iOS (extendable)

---

## 🚧 Challenges & Solutions

| Challenge                | Solution                     |
| ------------------------ | ---------------------------- |
| UID vs Username mismatch | Standardized data model      |
| Chat unread logic        | Implemented `seenBy` system  |
| Firebase web config      | Used `firebase_options.dart` |
| Performance issues       | Removed redundant queries    |

---

## 🚀 Future Improvements

* Push notifications
* Typing indicators in chat
* Online/offline status
* File sharing (docs/images)
* AI-based project recommendations

---

## 🧠 Key Engineering Decisions

* Used **UID-based relationships** for consistency
* Stored **username separately for UI performance**
* Leveraged **Firestore streams for real-time updates**
* Designed **modular architecture for scalability**

---

## 👨‍💻 Author

**Talha Zaheer**
Computer Science Student | Flutter Developer

---

## ⭐ Support

If you found this project useful:

👉 Give it a **⭐ on GitHub**
👉 Share with others

---
