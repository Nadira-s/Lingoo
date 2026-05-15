# 📱 Android Tenant Booking Management App

# 📌 Project Overview

This project is an Android mobile application for managing tenant booking data via a provided REST API.

- **Project type:** Android client application  
- **Tenant:** `beauty-salon`  
- **Base context:** http://127.0.0.1:8000/business/beauty-salon/dashboard/  
- **Purpose:** Connect Android app to backend API (no backend development required)

The application is designed for internal staff only (admin, manager, employees). Customers do not use this app.

---

# 🎯 Goal

To build an Android client that:
- Connects to a provided API  
- Displays and manages tenant data  
- Handles role-based access (TENANT_ADMIN, MANAGER)  
- Ensures proper data isolation per tenant  

---

# 🔐 Authentication

- Login with username + password  
- Token-based authentication (JWT / session depending on API)  
- Save session locally (SharedPreferences / Secure Storage)  
- Auto logout on token expiration  

---

# 👥 User Roles

# 🟢 TENANT_ADMIN

Full access to tenant data:
- Branches (CRUD)  
- Services (CRUD)  
- Employees (CRUD)  
- All bookings  
- Change booking status  
- Edit comments/notes  

---

# 🟡 MANAGER

Limited access:
- Can view only their own bookings  
- Can open only assigned booking details  
- Can update status (if allowed by API)  
- Can edit comment (if allowed by API)  

❌ Cannot:
- View other employees' bookings  
- Access other tenants’ data  
- Manage staff  
- Open unauthorized booking by ID  

---

# 📲 App Screens

- Login Screen  
- Dashboard (summary stats)  
- Bookings List (filters supported)  
- Booking Details  
- Branches (CRUD)  
- Services (CRUD)  
- Staff (restricted by role)  
- Profile (logout)  

---

# ⚙️ Flutter Code Requirements

# 📦 Recommended Stack

- Dart  
- Flutter SDK  
- Android Studio / VS Code  
- State Management: Riverpod / BLoC (preferred)  
- Dio or http for API requests  
- Freezed / json_serializable for models  
- Async/Await (Future, Stream)  
- Clean Architecture (mandatory)  
- GoRouter or Navigator 2.0  
- SharedPreferences / Hive / Secure Storage  

---

# 🧠 Code Structure Rules

❌ Not allowed:
- Business logic inside UI  
- Direct API calls from UI  
- Mixing layers  

✔️ Required:
- Clean Architecture  
- Repository + UseCase pattern  
- State management (Riverpod/BLoC)  
- Proper error handling  

---

# 📁 Project Structure

lib/
  data/
    api/
      dio_client.dart
      endpoints.dart
    models/
      dto/
    repositories/
      impl/

  domain/
    models/
    repositories/
    usecases/

  presentation/
    auth/
      screens/
      widgets/
      state/
    dashboard/
      screens/
      widgets/
      state/
    bookings/
    branches/
    services/
    staff/
    profile/
  core/
    navigation/
      app_router.dart
    utils/
    constants/
    errors/
    theme/

  main.dart
# 🏗 Architecture Rules

UI layer only displays data  
Domain layer contains business logic  
Data layer handles API/local storage  
Flow: UI → Domain → Data  
Dependency Injection required  

---

# 🔌 API Integration

- Authentication  
- Current user info  
- Branches  
- Services  
- Employees  
- Bookings  
- Status updates  

⚠️ Backend handles tenant filtering (no bypass allowed)

---

# ❗ Error Handling

- No internet  
- 401 Unauthorized  
- 403 Forbidden  
- 404 Not found  
- 500 Server error  
- Empty states  
- Invalid login  

json
{
  "message": "Access denied",
  "code": "permission_denied",
  "status": 403
}
# 👤 Login Screen Requirements

- Username field  
- Password field  
- Login button  
- Loading indicator  
- Error messages  
- Validation  

On success:
- Fetch user data (ID, role, tenant)  
- Open dashboard  

---

# 📊 Key Features

- Role-based UI  
- Tenant-scoped data  
- Booking management  
- Branch & service management  
- Staff management  
- Secure auth  
- Safe error handling  

---

# 🧪 Testing Scenarios

## Authentication
- valid login  
- invalid login  
- empty fields  
- logout  

## TENANT_ADMIN
- full CRUD access  
- all bookings  

## MANAGER
- only own bookings  
- no access to others  
- correct error handling  

---

# 📌 Requirements

- No crashes  
- Role restrictions enforced  
- Clean architecture  
- API-driven app  

---

# 📄 README Must Include

- API base URL  
- Auth method  
- Test accounts  
- Endpoints list  
- Role permissions  
- Known issues  
- Run instructions  

---

# 🚀 Optional Features

- Search  
- Pagination  
- Pull-to-refresh  
- Dark mode  
- Calendar view  
- Push notifications  

---

# ✅ Final Result

- Working Android app  
- Connected to API  
- Role-based access working  
- Clean UI structure  
- Stable and production-ready architecture  
