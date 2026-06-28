
# StudyMate

A cross-platform student productivity app built with Flutter — combining notes, to-dos, and an AI study assistant in one place.

## Overview

StudyMate is a Firebase-backed Flutter app that helps students organize their academic life: jot down notes, track to-dos, and chat with an AI assistant for quick help — all synced in real-time across devices.

## Features

- **Authentication** — Email/password login & signup via Firebase Auth, with a splash screen that auto-routes logged-in users straight to the home screen
- **Navigation** — Bottom navigation bar + custom app bar across Home, Notes, To-Do, Profile, and Settings
- **To-Do List** — Create, complete, edit, and delete tasks, synced in real-time via Firestore
- **Notes** — Create, edit, and delete notes with optional image/PDF attachments via Cloudinary
- **Search, Sort & Filter** — Real-time search across notes/to-dos, sort by date or alphabetically, filter by status (To-Do) or attachment type (Notes)
- **AI Chatbot** — Ask questions and get help directly inside the app
- **State Management** — Built entirely on BLoC (AuthBloc, TodoBloc, NotesBloc, ChatBloc)
- **Cross-Platform** — Runs on Android, iOS, and Web

## Tech Stack

- **Framework:** Flutter / Dart
- **State Management:** flutter_bloc
- **Backend:** Firebase 
- **Media Storage:** Cloudinary

## Getting Started

### Prerequisites
- Flutter SDK installed
- A Firebase project with Auth and Firestore enabled
- A Cloudinary account for image/PDF uploads

### Setup

```bash
# Clone the repo
git clone <repo-url>
cd studymate

# Install dependencies
flutter pub get

# Add Firebase config files via flutterfire configure,
# or manually add google-services.json (Android) and
# GoogleService-Info.plist (iOS)

# Run the app
flutter run
```

### Running on Web

```bash
flutter config --enable-web
flutter run -d chrome
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Web (for Firebase Hosting)
flutter build web
firebase deploy --only hosting
```

## Project Structure

```
lib/
├── blocs/          # AuthBloc, TodoBloc, NotesBloc, ChatBloc
├── models/         # Data models
├── screens/        # UI screens (login, home, notes, todo, profile, settings)
├── widgets/        # Reusable UI components
├── services/       # Firebase, Cloudinary, API services
└── main.dart
```

