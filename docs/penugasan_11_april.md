# Penugasan Tim Lumira (Update 11 April)

## 📅 Timeline Mobile
- **Target Minggu Depan:** Fitur iterasi terkait **CRUD API** sudah harus selesai dan terintegrasi di Mobile.
- **Target Dua Minggu Lagi:** Fungsionalitas **Chat System** dan **AI Integration** (MedGemma & Predict) sudah harus selesai.

---

## 👥 Pembagian Tugas Tim

### 🖥️ Tim Backend Server (BE)
Mayoritas beban operasional backend dialokasikan kepada Irgi, karena Gavin dan April sudah memegang peran spesifik di Core API dan AI.
- **Irgi:** Memegang mayoritas Endpoint API (Auth, Users, Patients, Medical Records, Statistics).
- **Gavin:** Fokus penuh pada pengembangan endpoint API back-end untuk **Chatroom** (`/chat`).
- **April:** Fokus penuh pada pengembangan yang berhubungan langsung dengan **AI API** (MedGemma Chatbot & Native AI Prediction API).

### 📱 Tim Frontend Mobile (FE) 
Fokus perbaikan utama di FE saat ini adalah memastikan halaman *detail* sesuai dengan rancangan referensi **Figma**, dan memastikan seluruh antarmuka **responsif secara mulus** di mobile.
- **Arfi:** Mengerjakan **Landing Page** (menambahkan animasi slide atau percantik transisi) dan merapikan halaman **Login**.
- **Jenny:** Fokus utama untuk mem-*fix* fitur **Chatroom** (yang sebelumnya sempat ada tapi menghilang/terkena masalah).
- **Bill:** Menutupi selisih sisa **fitur-fitur lain** yang belum ada di Frontend dan menyesuaikan UI dengan Figma.

---

## 🔌 Dokumentasi REST API Lumira
**Version:** 1.0.0 (OAS 3.0)
**Swagger/Docs API Lengkap:** [https://apilumiraai.vercel.app/api/docs#/](https://apilumiraai.vercel.app/api/docs#/)

**Available Servers:**
- **Local Development:** `http://localhost:3000` (Gunakan ini jika menjalankan BE di laptop sendiri)
- **Production:** `https://apilumiraai.vercel.app/` (Gunakan ini sebagai default di APK/Web Production)

**Base URL untuk Mobile:** `https://apilumiraai.vercel.app/` (Update variabel ini sesuai server yang digunakan)
**Authentication:** JWT Bearer Token via Response Body
**Actors:** User (Admin/Doctor via Web), Patient (via Mobile App)

> **💡 Catatan Integrasi Flutter (Koneksi API Frontend ke Backend):**
> URL *Production Server* di atas berfungsi sebagai **Base URL**. Disepakati untuk menggunakan file **`.env`** demi keamanan dan fleksibilitas:
> 
> - **Menggunakan file `.env`**: Buat file bernama `.env` di root folder aplikasi (sejajar dengan pubspec.yaml). Isi dengan:
>   ```env
>   BASE_URL=https://apilumiraai.vercel.app/
>   ```
> - Gunakan *package* `flutter_dotenv` untuk memuat variabel tersebut di dalam kode Dart. Hal ini memudahkan tim untuk mengganti URL (Local vs Production) tanpa menyentuh kode sumber.

Berikut referensi endpoint API yang akan digunakan dan diintegrasikan oleh Front-End:

---

## 🧪 Akun Dummy (Seed Data) untuk Testing
Untuk memudahkan pengetesan di Mobile/Web selama masa development, gunakan akun-akun *seed* berikut yang sudah tersedia di database:

### 1. Super Admin
- **Email:** `admin@lumira.ai`
- **Password:** `F1d,9OL2ri42`

### 2. Dokter (Actor: Doctor)
- **Email:** `doctor@test.com`
- **Password:** `Password123!`

### 3. Pasien (Actor: Patient)
- **Email:** `patient@test.com`
- **Password:** `Password123!`

> **Cara Pakai:**
> Masukkan email dan password di atas pada halaman Login Lumira. Pastikan koneksi internet aktif dan menunjuk ke *Base URL* yang benar (Production/Local) agar request login berhasil divalidasi.

---

### 1. Auth
Mencakup fungsi Login, Logout, dan Refresh Token untuk User dan Patient.

### 2. Users (Admin & Dokter)
- `POST /users` : Register / Create new user
- `GET /users` : Get list of users
- `GET /users/{id}` : Get user by ID
- `PATCH /users/{id}` : Update user profile
- `DELETE /users/{id}` : Delete user (soft delete)

### 3. Patients (Data Pasien Mobile)
- `GET /patients` : Get list of patients
- `POST /patients` : Add a new patient
- `GET /patients/{id}` : Get a specific patient by ID with their records
- `PUT /patients/{id}` : Update a patient
- `DELETE /patients/{id}` : Delete a patient

### 4. Medical Records
- `POST /medical-records/upload` : Upload a medical record image and trigger AI
- `POST /medical-records/{id}/review` : Submit Doctor Review for an AI diagnosis
- `POST /patients/{id}/reanalyze` : Re-run AI analysis on the latest patient image

### 5. Chatroom
Chat
Komunikasi antara dokter dan pasien



POST
/chat/firebase-token
Mint a short-lived Firebase Custom Token for the authenticated actor


Returns a Firebase custom token (UID = actor.id, claim actorType) that the client SDK must consume via signInWithCustomToken() before reading/writing Firestore messages or updating RTDB presence. The token expires in 3600 seconds (Firebase hard limit); the client should re-mint before that.

Parameters
Try it out
No parameters

Responses
Code	Description	Links
200	
Custom token minted.

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "customToken": "string",
  "expiresIn": 3600,
  "uid": "PAS-123456",
  "actorType": "patient"
}
No links
401	
Unauthorized.

No links
503	
Firebase is not configured (FIREBASE_ENABLED=false on server).

No links

POST
/chat/rooms
Create or resolve a chat room for a medical record


Each room is uniquely identified by medical_record_id. Backend persists the room in Postgres and mirrors the room metadata to Firestore so the client SDK can read & write messages within rooms/{roomId}/messages/*. If the room already exists for this medical record, the existing one is returned (idempotent).

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "patientId": "PAS-120394",
  "doctorId": "DOC-994122",
  "medicalRecordId": "MED-558712"
}
Responses
Code	Description	Links
201	
Room ready (created or resolved).

Media type

application/json
Controls Accept header.
Example Value
Schema
{
  "id": "CHR-123456",
  "patientId": "PAS-123456",
  "doctorId": "DOC-123456",
  "medicalRecordId": "MED-123456",
  "firstContactNotifiedAt": "2026-04-24T08:00:00.000Z",
  "createdAt": "2026-04-24T08:00:00.000Z",
  "updatedAt": "2026-04-24T08:00:00.000Z"
}
No links
400	
Validation error.

No links
403	
Forbidden.

No links
404	
Patient/Doctor/MedicalRecord not found.

No links

GET
/chat/rooms
List rooms for the authenticated actor


Returns slim room summaries (ID, participants, counterpart name, medical_record_id). Realtime fields like unreadCount, lastMessage, and counterpartPresence are computed CLIENT-SIDE via Firestore onSnapshot() and RTDB presence listeners — this endpoint does not touch Firestore (zero quota cost) so it stays fast on Vercel Hobby.

Parameters
Try it out
No parameters

Responses
Code	Description	Links
200	
Array of room summaries.

Media type

application/json
Controls Accept header.
Example Value
Schema
[
  {
    "id": "CHR-123456",
    "patientId": "PAS-123456",
    "doctorId": "DOC-123456",
    "medicalRecordId": "MED-123456",
    "counterpartId": "DOC-123456",
    "counterpartName": "Dr. Richard",
    "counterpartType": "doctor",
    "firstContactNotifiedAt": "2026-04-24T08:00:00.000Z",
    "createdAt": "2026-04-24T08:00:00.000Z",
    "updatedAt": "2026-04-24T08:00:00.000Z"
  }
]
No links

POST
/chat/rooms/{roomId}/notify
Dispatch FCM push for a just-written Firestore message


Call this AFTER the client SDK has successfully written the message document to Firestore. Backend re-reads the message from Firestore (anti-spoof), verifies the caller is the actual sender, and dispatches FCM to the receiver's active devices. Idempotent and best-effort — call as fire-and-forget.

Parameters
Try it out
Name	Description
roomId *
string
(path)
CHR-123456
Request body

application/json
Example Value
Schema
{
  "messageId": "CHM-aBc123XyZ789"
}
Responses
Code	Description	Links
200	
FCM dispatch attempted.

No links
403	
Caller is not the sender of that message.

No links
404	
Room or message not found.

No links

POST
/chat/device-tokens
Register or refresh FCM device token


Stores or refreshes the FCM registration token for the calling actor's device so push notifications can be delivered when the app is offline.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "fcmToken": "string",
  "platform": "android"
}
Responses
Code	Description	Links
201	
Token registered.

No links

POST
/chat/device-tokens/remove
Deactivate an FCM device token


Should be called on logout or when uninstalling. Marks the given FCM token as inactive for the current actor.

Parameters
Try it out
No parameters

Request body

application/json
Example Value
Schema
{
  "fcmToken": "string"
}
Responses
Code	Description	Links
200	
Token deactivated.

No links



### 6. Statistics / Dashboard
- Endpoint untuk meretrieve data KPI / chart statistik untuk ditampilkan di layar depan aplikasi.

### 7. MedGemma AI
- `POST /medgemma/consult` : Mengirim request prompt untuk konsultasi chatbot medis.

### 8. Native AI Service 
- `POST /predict` : Direct Native AI prediction from uploaded ultrasound image without writing to history yet.

### 9. Healthcheck
- `GET /health` : Cek uptime dan stabilitas Backend Server.
