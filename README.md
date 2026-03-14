# Campus Lost & Found

Campus Lost & Found is a cross-platform application built with Flutter (frontend) and Node.js/Express (backend) to help users report, search, and claim lost items on campus.

---

## Project Structure

- `lib/` — Flutter app source code
- `backend/` — Node.js/Express backend server

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js & npm](https://nodejs.org/)
- [MongoDB](https://www.mongodb.com/try/download/community)

---

## Backend Setup (Node.js/Express)

1. **Install dependencies:**
	```bash
	cd backend
	npm install
	```
2. **Start MongoDB:**
	Ensure MongoDB is running locally on the default port (27017).
3. **Run the server:**
	```bash
	node server.js
	```
	The backend will be available at `http://localhost:3000`.

---

## Frontend Setup (Flutter)

1. **Install dependencies:**
	```bash
	flutter pub get
	```
2. **Run the app:**
	- For mobile:
	  ```bash
	  flutter run
	  ```
	- For web:
	  ```bash
	  flutter run -d chrome
	  ```

---

## Configuration

- The Flutter app expects the backend API to be running at `http://localhost:3000` (update API URLs in `lib/services/api_service.dart` if needed).
- MongoDB must be running locally, or update the connection string in `backend/server.js`.

---

## Features

- User authentication (login/signup)
- Report lost/found items
- Claim items
- Notifications
- Messaging between users

---

## Useful Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Express.js Documentation](https://expressjs.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
