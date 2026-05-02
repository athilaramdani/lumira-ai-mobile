# Skenario End-to-End (E2E) Testing - Lumira AI

Dokumen ini berisi panduan komprehensif serta daftar tugas (task) untuk menguji seluruh fungsionalitas (E2E) dari aplikasi mobile Lumira AI, dipisahkan berdasarkan peran akun dummy (Pasien dan Dokter).

---

## 1. Persiapan Kredensial Dummy

Untuk menjalankan pengujian ini, Anda memerlukan setidaknya dua akun dummy yang telah terdaftar di database (sebagai rujukan default, Anda bisa menggunakan email test jika tersedia, atau mendaftarkan akun baru).

| Role | Email Dummy (Contoh) | Password | Keterangan |
| :--- | :--- | :--- | :--- |
| **Doctor** | `doctor@test.com` | `password123` | Memiliki akses ke Doctor Dashboard & Medical Review |
| **Patient** | `patient@test.com` | `password123` | Memiliki akses ke Patient Dashboard & Upload Scan |

*(Catatan: Sesuaikan kredensial di atas dengan data yang riil dari seeder/database backend Anda saat ini).*

---

## 2. E2E Task List: Alur Pasien (Patient Role)

Skenario ini mensimulasikan perjalanan seorang pasien mulai dari masuk ke aplikasi hingga mendapatkan laporan klinis final.

### Task 2.1: Autentikasi & Profil
- [ ] Buka aplikasi (Landing Page).
- [ ] Lakukan proses Login menggunakan akun Pasien.
- [ ] Navigasi ke halaman **Edit Profile**.
- [ ] Coba ubah nama atau data kontak, lalu simpan.
- [ ] Pastikan perubahan tersimpan dan tampil di Dashboard Pasien.

### Task 2.2: Fitur Komunikasi (Chat)
- [ ] Buka halaman **Chat List** dari navigasi bawah.
- [ ] Pilih percakapan dengan Dokter (atau mulai chat baru).
- [ ] Kirim pesan teks untuk berkonsultasi mengenai hasil scan.
- [ ] (Opsional jika ada) Gunakan bot **MedGemma** untuk menanyakan informasi umum seputar penyakit/diagnosis.

### Task 2.3: Melihat Laporan Klinis (Clinical Report)
- [ ] Jika status dari dokter sudah *Done*, masuk ke **Clinical Report Page**.
- [ ] Pastikan hasil yang ditampilkan mencerminkan diagnosis akhir dari dokter (bukan sekadar prediksi AI awal).
---

## 3. E2E Task List: Alur Dokter (Doctor Role)

Skenario ini berfokus pada alur kerja dokter dalam memberikan validasi dan opini medis atas scan pasien.

### Task 3.1: Autentikasi & Dashboard
- [ ] Login menggunakan akun Dokter.
- [ ] Masuk ke **Doctor Dashboard Page**.
- [ ] Perhatikan daftar antrean pasien. Pastikan pasien dengan rekam medis baru muncul di antrean dengan status **"Review Needed"**.
- [ ] Pastikan indikator "Image: Yes/Missing" sinkron dengan data asli dari pasien.

### Task 3.2: Medical Review & Visual Mode
- [ ] Klik salah satu *Card* pasien yang berstatus *Review Needed*. Aplikasi harus beralih ke **Medical Review Page**.
- [ ] Di bagian *Image Section*, klik kotak **AI RESULT**. Pastikan muncul pop-up *Image Viewer* yang memuat gambar *GradCam* tanpa akses ke *tools* annotasi (Mode *Read-only*).
- [ ] Tutup pop-up, lalu klik kotak **RAW VIEW**.
- [ ] Pastikan pop-up yang sama terbuka, namun kali ini menampilkan gambar mentah dan **fitur annotasi aktif** (Brush, Focus Area, Undo, Erase).
- [ ] Di dalam pop-up RAW VIEW, coba mainkan *toggle switch* antara **Raw** dan **Normalized** (jika menggunakan asset lokal, pastikan gambarnya berubah ke citra hitam putih/normalized).
- [ ] Lakukan coretan (*drawing*), lalu klik **Save Annotations**.

### Task 3.3: Submit Diagnosis
- [ ] Di menu *Classification Result By AI*, perhatikan klasifikasi yang diberikan (Normal/Benign/Malignant).
- [ ] Pada bagian *Doctor Diagnosis*, tentukan apakah Anda setuju (**Agree**) atau tidak setuju (**Disagree**) dengan hasil AI tersebut.
- [ ] Berikan catatan tambahan pada kolom *Doctor Note*.
- [ ] Klik tombol **Submit Diagnosis**.
- [ ] Pastikan aplikasi memunculkan dialog/snackbar "Berhasil" dan tidak ada *error* dari *backend* (`status 200 OK`).
- [ ] Setelah *submit*, periksa *Doctor Dashboard* lagi. Status pasien tersebut harus berubah menjadi **"Done"**.

### Task 3.4: Komunikasi dengan Pasien (Patient Chat)
- [ ] Buka pesan yang dikirim oleh pasien (dari Task 2.2).
- [ ] Jawab pesan tersebut sebagai dokter.
- [ ] Klik tombol **Ask AI** (jika butuh referensi tambahan), pastikan dokter diarahkan ke layar **MedGemma Chat Page** dan bisa berdiskusi dengan *chatbot* LLM tersebut.

---

## 4. Daftar Pertanyaan Validasi E2E

Selama menguji (atau setelah menyelesaikan task di atas), tim QA atau developer perlu menjawab daftar pertanyaan ini untuk memvalidasi kualitas sistem:

**Autentikasi & Navigasi:**
1. Apakah *state* dari user (Token, Role) tersimpan dengan aman? (Jika aplikasi ditutup paksa lalu dibuka lagi, apakah ia langsung masuk atau harus login ulang?)
2. Saat *logout*, apakah *cache* chat dan *dashboard* terhapus sempurna?

**Logika Bisnis & Sinkronisasi Backend:**
3. Pada halaman Dokter, ketika gambar *Raw View* belum diunggah secara sempurna oleh pasien, apakah ditangani dengan baik (muncul *placeholder* atau error yang rapi)?
4. Saat Dokter mengklik *Submit Diagnosis*, apakah *payload* JSON (beserta *heatmapImage* binary) benar-benar terkirim ke *endpoint* `/medical-records/{id}/review`?
5. Apakah data `validation_status` dan `doctor_diagnosis` pasien langsung ter-*update* secara *real-time* di Dashboard Pasien setelah Dokter melakukan *Submit*?
6. Saat melakukan *chatting*, apakah terdapat *delay* yang tidak masuk akal atau adakah *error* ketika pasien belum memiliki *medical record*?

**User Interface & Experience (UI/UX):**
7. Apakah tampilan mode visual (*Raw* & *Normalized*) berfungsi mulus di dalam pop-up, tanpa men-tumpang-tindih teks atau layout di latar belakang layar yang lebih kecil?
8. Apakah coretan dokter (annotasi) tersimpan ke *state* secara konsisten, meskipun pop-up ditutup dan dibuka kembali?
9. Bagaimana responsivitas aplikasi ketika perangkat yang digunakan memiliki layar kecil, atau orientasi perangkat (landscape) diubah?

---
*Dokumen ini dapat digunakan sebagai lembar kendali (checklist) bagi Software Tester saat akan merilis aplikasi ke staging/production.*
