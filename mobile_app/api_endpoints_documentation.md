# SafetyWatch API Endpoints Documentation

All endpoints below are prefixed with `/api`.
For example, the login route is: `POST https://yourdomain.com/api/auth/login`

**Authentication requirement**:
All protected routes require an `Authorization` header with a Bearer Token:
`Authorization: Bearer <token>`

---

## 1. Authentication (Public)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/register` | Register a new user |
| `POST` | `/api/auth/login` | Login and get an access token |

---

## 2. Profile & Logout (Protected)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/logout` | Logout the current user and invalidate the token |
| `GET` | `/api/auth/me` | Get the authenticated user's profile info |

---

## 3. Admin Routes (Protected - Requires Admin Role)

### Dashboard
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/dashboard` | Get overall dashboard statistics |

### Employees
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/employees` | List all employees |
| `GET` | `/api/admin/employees/{id}` | Get details of a specific employee |
| `POST` | `/api/admin/employees` | Create a new employee |
| `PUT` | `/api/admin/employees/{id}` | Update an existing employee |
| `DELETE` | `/api/admin/employees/{id}` | Delete an employee |

### Attendance
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/attendance` | Get list of all attendances |
| `POST` | `/api/admin/attendance` | Record a new attendance entry |
| `GET` | `/api/admin/attendance/stats` | Get statistics about attendance |

### Violations
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/violations` | List all safety violations |
| `POST` | `/api/admin/violations/{id}/resolve` | Resolve a violation |
| `POST` | `/api/admin/violations/{id}/dismiss` | Dismiss a false alarm violation |
| `PUT` | `/api/admin/violations/{id}/status` | Update a violation status |

### Alerts
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/alerts` | List all security alerts |
| `POST` | `/api/admin/alerts/mark-all-read` | Mark all unread alerts as read |
| `POST` | `/api/admin/alerts/{id}/resolve` | Resolve an alert |
| `POST` | `/api/admin/alerts/{id}/dismiss` | Dismiss an alert |

### Cameras
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/cameras` | List all cameras |
| `POST` | `/api/admin/cameras` | Add a new camera |
| `PUT` | `/api/admin/cameras/{id}` | Update a camera's details |
| `DELETE` | `/api/admin/cameras/{id}` | Delete a camera |
| `POST` | `/api/admin/cameras/{id}/toggle-status` | Toggle camera status (online/offline) |

---

## 4. Employee Routes (Protected - Requires Employee Role)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/employee/dashboard` | Get employee's personal dashboard |
| `GET` | `/api/employee/attendance` | Get employee's own attendance history |

---

## 5. AI Service Webhook (Internal/Protected)
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/ai/detection` | Webhook used by the AI service to report a violation |
