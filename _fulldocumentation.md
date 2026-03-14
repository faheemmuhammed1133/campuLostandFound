
# Campus Lost & Found — Full Documentation

## Table of Contents
1. [Overview](#overview)
2. [Requirements & Dependencies](#requirements--dependencies)
3. [Architecture & Workflow](#architecture--workflow)
4. [Backend (Node.js/Express)](#backend-nodejsexpress)
	- [Data Models & Schemas](#data-models--schemas)
	- [API Endpoints](#api-endpoints)
5. [Frontend (Flutter)](#frontend-flutter)
	- [State Management](#state-management)
	- [Theme & Design](#theme--design)
	- [Widgets & Screens](#widgets--screens)
	- [Library Functions](#library-functions)
6. [Application Workflow](#application-workflow)
7. [Appendix](#appendix)

---

## Overview

Campus Lost & Found is a cross-platform application for reporting, searching, and claiming lost items on campus. It consists of a Flutter frontend and a Node.js/Express backend with MongoDB for data storage.

---

## Requirements & Dependencies

### Prerequisites
- Flutter SDK (3.10.7+)
- Node.js & npm
- MongoDB (local or remote)

### Flutter Dependencies
- flutter
- cupertino_icons
- image_picker
- http

### Backend Dependencies
- express
- mongoose
- cors

---

## Architecture & Workflow

**Frontend:** Flutter app (mobile/web/desktop)

**Backend:** Node.js/Express REST API, MongoDB database

**Data Flow:**
1. User interacts with Flutter UI
2. Flutter app calls REST API endpoints via `ApiService`
3. Backend processes requests, interacts with MongoDB, returns JSON
4. Flutter updates UI based on API responses

---

## Backend (Node.js/Express)

### Data Models & Schemas

#### User
```js
username: String (unique, required)
password: String (required)
```

#### Item
```js
title: String (required)
description: String (required)
location: String (required)
imageBase64: String (optional)
type: 'lost' | 'found' (required)
postedBy: String (required)
foundBy: String (optional)
status: 'active' | 'resolved' (default: 'active')
date: Date (default: now)
```

#### Claim
```js
itemId: ObjectId (ref: Item, required)
claimerUsername: String (required)
description: String (required)
status: 'pending' | 'approved' | 'rejected' (default: 'pending')
date: Date (default: now)
```

#### Notification
```js
recipientUsername: String (required)
message: String (required)
itemId: ObjectId (ref: Item, optional)
type: 'item_found' | 'claim_submitted' | 'claim_approved' | 'claim_rejected' | 'new_message' (required)
isRead: Boolean (default: false)
date: Date (default: now)
```

#### Message
```js
itemId: ObjectId (ref: Item, required)
senderUsername: String (required)
text: String (required)
date: Date (default: now)
```

### API Endpoints

#### Auth
- `POST /api/auth/register` — Register new user
- `POST /api/auth/login` — Login user

#### Items
- `GET /api/items` — List all items
- `GET /api/items/:id` — Get item by ID
- `POST /api/items` — Create new item
- `PUT /api/items/:id/mark-found` — Mark item as found
- `DELETE /api/items/:id` — Delete item

#### Claims
- `GET /api/claims?itemId=...` — List claims for item
- `POST /api/claims` — Create claim
- `PUT /api/claims/:id/approve` — Approve claim
- `PUT /api/claims/:id/reject` — Reject claim

#### Notifications
- `GET /api/notifications?username=...` — List notifications for user
- `PUT /api/notifications/:id/read` — Mark notification as read
- `PUT /api/notifications/read-all?username=...` — Mark all as read

#### Messages
- `GET /api/messages?itemId=...` — List messages for item
- `GET /api/messages/conversations?username=...` — List conversations for user
- `POST /api/messages` — Send message

---

## Frontend (Flutter)

### State Management
- Uses `StatefulWidget` and `setState` for local state
- Navigation via `Navigator`

### Theme & Design
- Custom `AppTheme` with indigo/teal palette
- Material 3, rounded cards, modern UI
- Consistent use of color, typography, and spacing

### Widgets & Screens

- **LoginScreen**: User authentication (login/register)
- **HomeScreen**: Item list, search, filter, navigation tabs
- **ReportItemScreen**: Form to report lost/found item, image picker, location fetch
- **ItemDetailScreen**: Item details, claim submission, claim approval
- **NotificationsScreen**: List and manage notifications
- **MessagesScreen**: List conversations
- **ChatScreen**: Real-time chat for item
- **ItemCard**: Card widget for displaying item summary

#### Widget Example: ItemCard
Displays item image, title, location, type (Lost/Found), and status color.

### Library Functions

- **ApiService**: Handles all HTTP requests to backend (login, register, CRUD for items, claims, notifications, messages, location fetch)
- **Model Classes**: Dart models for Item, Claim, Notification, Message

---

## Application Workflow

1. **User Registration/Login**: User creates account or logs in
2. **Home Screen**: User sees list of lost/found items, can search/filter
3. **Report Item**: User reports a lost/found item (with optional image, location)
4. **Item Details**: View item, submit claim if found, approve/reject claims
5. **Notifications**: User receives notifications for claims, messages, status changes
6. **Messaging**: Users chat about items via Messages/Chat screens

---

## Appendix

- **Error Handling**: All API errors are surfaced to the user via SnackBar
- **Extensibility**: Add more item fields, user roles, admin panel, etc.
- **Security**: Passwords are stored in plaintext for demo; use hashing in production
- **Testing**: Add widget/unit tests in `test/`

---

For further details, see code comments and the README.md.
