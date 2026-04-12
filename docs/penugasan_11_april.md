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
- `GET /chat/{patient_id}` : Get chat history between doctor and patient
- `POST /chat/{patient_id}` : Send a new chat message

### 6. Statistics / Dashboard
- Endpoint untuk meretrieve data KPI / chart statistik untuk ditampilkan di layar depan aplikasi.

### 7. MedGemma AI
- `POST /medgemma/consult` : Mengirim request prompt untuk konsultasi chatbot medis.

### 8. Native AI Service 
- `POST /predict` : Direct Native AI prediction from uploaded ultrasound image without writing to history yet.

### 9. Healthcheck
- `GET /health` : Cek uptime dan stabilitas Backend Server.
