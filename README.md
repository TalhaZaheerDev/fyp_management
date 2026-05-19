# FYP Management System

A modern and minimal **Final Year Project Management System** built with **Flutter + Firebase**, designed to streamline collaboration between **students and supervisors**.

---

## ✨ Features

### 🔐 Authentication

* Firebase Authentication (Signup / Login)
* Login using **Email or Username**
* Role-based access (**Student / Supervisor**)

### 👨‍🎓 Student Side

* Create and manage projects
* Select supervisor during project creation
* Edit project details
* Submit project for review
* Track weekly progress with percentage
* View supervisor feedback

### 👨‍🏫 Supervisor Side

* View assigned student projects
* Approve or reject submissions
* Add structured feedback
* Monitor project progress

### 💬 Communication

* Real-time chat (Student ↔ Supervisor)
* Project-based conversations
* Clean chat UI with message timestamps

### 📊 Project Management

* Status system:

  * Pending
  * Submitted
  * Approved
  * Rejected
* Progress tracking based on total weeks

### 👤 Profile

* View user details (username, email, role)
* Secure logout

---

## 🎨 UI / UX Highlights

* Minimal & premium design system
* Consistent spacing and alignment
* Custom dialogs (no default UI)
* Responsive layout
* Clean typography using Google Fonts

---

## 🛠️ Tech Stack

* **Frontend:** Flutter
* **Backend:** Firebase

  * Firebase Auth
  * Cloud Firestore
* **State Management:** setState (lightweight)

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
```

---

## ⚙️ Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/TalhaZaheerDev/fyp-management.git
cd fyp-management
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

* Add `google-services.json` (Android)
* Add `GoogleService-Info.plist` (iOS)

### 4. Run app

```bash
flutter run
```

---


## 📌 Future Improvements

* Push notifications
* File uploads (documents/images)
* Supervisor assignment automation
* Dark mode

---

## 👨‍💻 Author

Talha

---

## ⭐ Support

If you like this project, give it a ⭐ on GitHub!
