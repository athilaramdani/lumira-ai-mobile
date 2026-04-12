# 📘 Kumpulan Prompting AI untuk Tim Lumira AI Mobile
> Panduan ini berisi prompt siap pakai untuk membantu pekerjaanmu dengan AI Coding Assistant (Gemini, ChatGPT, Claude, dsb).
> Setiap prompt sudah disesuaikan dengan arsitektur aplikasi Lumira. Tinggal copy, tempel, dan modifikasi sesuai kebutuhan.

---

## 🏛️ Konteks Arsitektur Aplikasi (Wajib Disertakan di Setiap Prompt)

> Salin blok ini dan tempelkan di **awal setiap prompt** yang kamu kirim ke AI:

```
Saya sedang mengembangkan aplikasi Flutter bernama Lumira AI Mobile.
Arsitektur yang digunakan adalah Feature-First Clean Architecture dengan 3 layer:
- Layer Presentation: pages/, widgets/, controllers/ (menggunakan Riverpod StateNotifier/Provider)
- Layer Domain: entities/, repositories/ (interface), usecases/
- Layer Data: datasources/ (API calls via Dio), models/ (DTO), repositories/ (implementasi)

Tech stack:
- State Management: Flutter Riverpod (flutter_riverpod, riverpod_annotation)
- Routing: GoRouter (go_router)
- HTTP Client: Dio
- Local Storage: Hive & SharedPreferences
- Language: Dart/Flutter
- CI/CD: Codemagic
- API Testing: Postman
- Version Control: Git (GitHub)
- Push Notification & Crash Reporting: BELUM DITENTUKAN (jangan implementasikan dulu)

Alur Data (PENTING):
- Aplikasi Mobile TIDAK boleh terhubung langsung ke Supabase.
- Semua komunikasi data harus melalui Backend API (https://apilumiraai.vercel.app/).
- Backend-lah yang berinteraksi dengan Supabase. Mobile hanya perlu tahu endpoint REST API.

Aturan penulisan kode yang WAJIB diikuti:
1. TIDAK BOLEH hardcode URL, string, atau nilai sensitif langsung di kode. Gunakan konstanta di lib/core/constants/.
2. Semua widget harus reusable jika digunakan lebih dari satu kali.
3. Penamaan file dan folder harus konsisten snake_case.
4. Setiap fitur ada di folder lib/features/<feature_name>/ dengan sub-folder presentation/, domain/, dan data/.
5. API call hanya boleh ada di layer Data (datasources/), BUKAN di presentation.
6. Gunakan Riverpod untuk semua state management, TIDAK menggunakan setState kecuali state bersifat sangat lokal.
7. JANGAN gunakan Supabase SDK/package langsung di Flutter. Semua request melalui REST API via Dio.
```

---

---

## 👤 IRGI — Backend Core (Auth, Users, Patients, Records, Stats)

**Deadline: 17 April**

### Prompt 1: Membuat Endpoint Integration (Data Layer)

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya perlu mengintegrasikan endpoint API Lumira ke dalam aplikasi Flutter saya.
Referensi lengkap API ada di: https://apilumiraai.vercel.app/api/docs#/
Base URL: https://apilumiraai.vercel.app/

Tolong buatkan implementasi lengkap untuk fitur [NAMA FITUR, contoh: Manajemen Pasien] yang mencakup:
1. Model/DTO Dart di layer Data sesuai response JSON dari API. Contoh endpoint: GET /patients
   Response JSON:
   [TEMPEL CONTOH JSON RESPONSE DARI SWAGGER DOCS-NYA DISINI]

2. Datasource class (PatientRemoteDataSource) yang menggunakan Dio untuk memanggil endpoint:
   - GET /patients — List semua pasien
   - POST /patients — Tambah pasien baru (Request body: { name, email, phone, dob, ... })
   - GET /patients/{id} — Detail pasien + rekam medis
   - PUT /patients/{id} — Update data pasien
   - DELETE /patients/{id} — Hapus pasien

3. Repository implementation di layer Data.
4. UseCase class di layer Domain untuk setiap operasi CRUD.
5. Riverpod Provider di layer Presentation untuk memanggil UseCase.

Pastikan: error handling menggunakan try-catch, Dio Interceptor untuk JWT token header,
dan Base URL tidak di-hardcode (gunakan konstanta dari lib/core/constants/api_constants.dart).
```

---

### Prompt 2: Membuat Dio Client dengan JWT Auth Interceptor

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Buatkan Dio HTTP client terpusat untuk aplikasi Flutter saya dengan fitur berikut:
- Base URL diambil dari konstanta (lib/core/constants/api_constants.dart), BUKAN hardcode.
- JWT Bearer Token otomatis ditambahkan ke setiap request header dari SharedPreferences/Hive.
- Interceptor untuk menangani response error 401 (token expired) dan melakukan refresh token secara otomatis.
- Timeout handling (connectTimeout, receiveTimeout).
- Logging request & response untuk mode debug.

API Auth endpoint-nya:
- Login: POST /auth/login — Body: { email, password } — Returns: { token, refreshToken, user }
- Refresh: POST /auth/refresh — Body: { refreshToken } — Returns: { token }
- Logout: POST /auth/logout

Taruh implementasi Dio client ini di lib/core/network/dio_client.dart dan daftarkan sebagai Riverpod Provider.
```

---

### Prompt 3: Brainstorming Arsitektur & Keamanan

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya sedang membangun Flutter app dengan backend REST API di: https://apilumiraai.vercel.app/api/docs#/
App ini punya 2 aktor: Dokter (via web) dan Pasien (via mobile).
Autentikasi menggunakan JWT Bearer Token.

Tolong bantu saya brainstorm hal-hal berikut:
1. Bagaimana strategi terbaik untuk menyimpan JWT token dengan aman di Flutter (Hive vs SharedPreferences vs FlutterSecureStorage)?
2. Bagaimana pola paling bersih untuk menangani sesi login/logout secara global menggunakan Riverpod?
3. Bagaimana menghindari race condition saat banyak request API harus attach token yang sama?
4. Apa pola terbaik untuk error handling API yang konsisten di seluruh fitur?
5. Apa potensi kerentanan keamanan yang perlu diwaspadai di mobile app yang mengonsumsi API ini?
```

---

---

## 👤 GAVIN — Backend Chatroom (`/chat`)

**Deadline: 22 April**

### Prompt 1: Implementasi Real-time Chat Integration di Flutter

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya perlu mengintegrasikan fitur Chatroom antara Dokter dan Pasien.
Referensi API: https://apilumiraai.vercel.app/api/docs#/

Endpoint yang tersedia:
- GET /chat/{patient_id} — Mengambil riwayat chat antara dokter dan pasien tertentu.
  Response: [{ id, sender_id, sender_role, message, sent_at, ... }]
- POST /chat/{patient_id} — Mengirim pesan baru.
  Request body: { message: string }
  Response: { id, sender_id, message, sent_at }

Tolong buatkan:
1. Model ChatMessage (DTO) di Dart untuk response di atas.
2. ChatRemoteDataSource dengan Dio untuk kedua endpoint tersebut.
3. ChatRepository interface & implementation.
4. UseCase: GetChatHistoryUseCase dan SendMessageUseCase.
5. ChatNotifier (Riverpod StateNotifier) yang:
   - Memuat riwayat chat saat halaman dibuka.
   - Melakukan optimistic UI update (pesan langsung tampil sebelum response server kembali).
   - Menangani error jika POST gagal (rollback pesan dari list).
6. Komponen UI dasar: ChatBubble widget yang bisa dibedakan apakah pesan dari user atau lawan bicara.

Semua string label dan URL harus menggunakan konstanta. Tidak boleh ada hardcode.
```

---

### Prompt 2: Polling atau WebSocket untuk Pesan Baru

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Backend saya adalah REST API (bukan WebSocket). Untuk fitur chatroom di Flutter, saya perlu strategi agar pesan baru dari sisi lain bisa muncul secara real-time (atau mendekati real-time).

Tolong berikan:
1. Implementasi Polling menggunakan Riverpod + Timer yang secara periodik memanggil GET /chat/{patient_id} dan hanya menambahkan pesan yang belum ada (berdasarkan ID atau timestamp).
2. Optimalisasi polling agar tidak terjadi rebuild widget berlebihan (gunakan select() atau equality check pada state).
3. Kapan polling harus dihentikan (saat halaman ditutup, app masuk background, dll).

Pastikan implementasinya bersih, tidak ada memory leak, dan mengikuti pola Riverpod yang tepat.
```

---

### Prompt 3: Brainstorming UX Chatroom

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Aplikasi Lumira adalah alat diagnosa kanker payudara berbasis AI yang dipakai dokter dan pasien.
Saya sedang merancang fitur Chatroom (komunikasi Dokter-Pasien) untuk aplikasi mobile-nya.

Tolong bantu brainstorm:
1. Fitur apa saja yang paling penting di chatroom konteks medis yang perlu ada (selain kirim/terima pesan teks)?
2. Bagaimana cara mendesain UI chatroom yang terasa lebih profesional dan tidak terasa seperti WhatsApp biasa?
3. Apakah perlu ada fitur pengiriman gambar/attachment untuk konteks ini? Apa pro & kontranya?
4. Bagaimana pengelolaan notifikasi pesan baru jika pengguna tidak sedang membuka halaman chat?
5. Apa saja edge case yang perlu dipersiapkan (dokter offline, pesan gagal terkirim, dll)?
```

---

---

## 👤 APRIL — AI Integration (MedGemma & Native AI Prediction)

**Deadline: 22 April**

### Prompt 1: Integrasi AI Chatbot MedGemma

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya perlu mengintegrasikan endpoint AI Chatbot MedGemma ke dalam halaman Consult AI di aplikasi Flutter.
Referensi API: https://apilumiraai.vercel.app/api/docs#/

Endpoint:
- POST /medgemma/consult
  Request body: { prompt: string, history?: [{ role: "user"|"model", parts: [{ text: string }] }] }
  Response: { response: string }

Tolong buatkan:
1. Model MedGemmaRequest & MedGemmaResponse Dart-nya.
2. MedGemmaRemoteDataSource menggunakan Dio.
3. MedGemmaRepository & ConsultMedGemmaUseCase.
4. MedGemmaNotifier (Riverpod) yang:
   - Menyimpan riwayat percakapan di memori (untuk multi-turn conversation).
   - Memiliki loading state saat menunggu respons AI.
   - Menangani error timeout atau respons kosong dari AI.
5. Tidak ada API key atau URL yang di-hardcode. Semua di api_constants.dart.

Tampilkan juga logika bagaimana menyusun format `history` yang benar untuk context percakapan multi-turn.
```

---

### Prompt 2: Integrasi Upload Gambar USG & Prediksi AI

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya perlu fitur upload citra USG/mammogram dan mendapatkan hasil prediksi AI.
Referensi API: https://apilumiraai.vercel.app/api/docs#/

Endpoint yang relevan:
- POST /medical-records/upload — Upload gambar USG dan trigger analisis AI.
  Request: multipart/form-data { patient_id, image: File, ... }
  Response: { record_id, prediction: { label, confidence, ... }, ... }
- POST /predict — Direct AI prediction (tanpa disimpan ke rekam medis).
  Request: multipart/form-data { image: File }
  Response: { label, confidence, heatmap_url?, ... }
- POST /patients/{id}/reanalyze — Re-run AI pada gambar terakhir pasien.

Tolong buatkan:
1. Logika pemilihan gambar dari galeri menggunakan image_picker.
2. Implementasi upload multipart/form-data dengan Dio (ProgressCallback untuk progress bar upload).
3. Model PredictionResult Dart untuk response AI.
4. Riverpod state yang mengelola: idle | uploading (dengan progress 0.0-1.0) | success | error.
5. Widget komponen untuk menampilkan hasil prediksi (label, confidence percentage, rekomendasi).

Pastikan ukuran gambar dikompresi sebelum upload jika melebihi batas tertentu.
```

---

### Prompt 3: Brainstorming Pengalaman AI di Aplikasi Medis

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Aplikasi Lumira AI adalah alat bantu diagnosis kanker payudara. Saya bertanggung jawab pada fitur AI (chatbot medis dan prediksi gambar).

Tolong bantu brainstorm:
1. Bagaimana cara menyampaikan hasil prediksi AI (misal "Malignant 87%") secara bertanggung jawab di UI, supaya tidak menimbulkan kepanikan pada pasien?
2. Apakah ada best practice untuk medical AI chatbot dalam hal "disclaimer" dan batasan pertanyaan yang boleh dijawab?
3. Bagaimana mendesain UX halaman prediksi gambar yang intuitif (alur: pilih foto → preview → upload → loading → hasil)?
4. Apa yang harus ditampilkan jika confidence AI rendah (di bawah 60%)?
5. Bagaimana cara mendesain sistem feedback (validasi dokter vs hasil AI) yang berguna untuk evaluasi model kedepannya?
```

---

---

## 👤 BILL — Fitur Frontend yang Belum Ada & Penyesuaian Figma

**Deadline: 14 April**

### Prompt 1: Mengidentifikasi & Membangun Fitur yang Belum Ada

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Berikut ini adalah struktur file fitur yang sudah ada di aplikasi Flutter saya:
[TEMPEL OUTPUT DARI: find lib/features -name "*.dart" | head -50]

Saya punya referensi desain di Figma (minta link ke project lead) yang mencakup:
- Halaman [SEBUTKAN NAMA HALAMAN YANG BELUM ADA DIBANDING FIGMA]

Tolong bantu saya:
1. Mengidentifikasi komponen UI apa saja yang belum ada.
2. Membuat skeleton/boilerplate halaman baru tersebut dengan struktur Feature-First yang benar.
3. Memastikan halaman baru mengikuti design system yang sudah ada: AppColors dari app_colors.dart, komponen reusable dari lib/core/widgets/.

Jangan buat logika bisnis dulu, fokus ke struktur widget dan UI-nya terlebih dahulu.
```

---

### Prompt 2: Audit dan Perbaikan Responsivitas UI

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya perlu memastikan semua halaman di aplikasi Flutter saya responsif di berbagai ukuran layar (terutama HP kecil, HP besar, dan tablet).

Tolong review kode halaman ini:
[TEMPEL KODE DART HALAMAN YANG INGIN DIPERIKSA]

Dan identifikasi:
1. Pixel/ukuran yang di-hardcode (misalnya SizedBox(height: 300)) yang harus menggunakan MediaQuery.
2. Widget yang akan overflow di layar kecil.
3. Teks yang tidak mengikuti scaling (harus menggunakan textScaleFactor atau flexible font size).
4. Bagaimana cara memperbaikinya agar responsif, dengan menggunakan LayoutBuilder atau MediaQuery.of(context).size.

Berikan kode yang sudah diperbaiki.
```

---

### Prompt 3: Brainstorming Kelengkapan Fitur FE

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Aplikasi Lumira AI adalah mobile app untuk Pasien dan Dokter dalam konteks diagnosa kanker payudara.
Fitur yang sudah ada: Dashboard Pasien, Dashboard Dokter, Riwayat Diagnosa, Konsultasi AI (MedGemma), Chat Dokter-Pasien, Landing Page, dan Login.

Tolong bantu brainstorm:
1. Fitur apa saja yang menurut kamu penting namun kemungkinan belum ada di aplikasi jenis ini?
2. Dari perspektif UX/UI, bagian mana yang paling kritis untuk diperhatikan di aplikasi medis mobile?
3. Bagaimana cara terbaik menampilkan statistik/data medis (grafik, tabel) yang mudah dipahami pasien awam?
4. Apakah ada micro-interaction atau animasi kecil yang bisa membuat pengalaman pengguna lebih baik tanpa mengorbankan performa?
5. Bagaimana cara mendesain empty state dan error state yang informatif dan tidak membuat pengguna bingung?
```

---

---

## 👤 JENNY — Fix Chatroom Frontend

**Deadline: 14 April**

### Prompt 1: Debug & Restore Fitur Chatroom

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Fitur Chatroom di aplikasi Flutter saya sebelumnya ada, namun sekarang tidak berfungsi/hilang.
File yang terkait: lib/features/chat/presentation/pages/chat_page.dart

Berikut kode chat_page.dart yang sekarang:
[TEMPEL KODE DART CHAT_PAGE.DART]

Dan berikut adalah file yang mungkin terkait:
[TEMPEL KODE TERKAIT JIKA ADA, MISAL MODEL, PROVIDER, DSB]

Tolong bantu saya:
1. Identifikasi kenapa chat page ini tidak berfungsi atau terasa kosong/placeholder.
2. Rebuild implementasi ChatPage yang fungsional dengan fitur:
   - Menampilkan list pesan (gelembung chat kanan/kiri untuk user vs dokter).
   - Input text field di bagian bawah dengan tombol kirim.
   - Loading indicator saat mengirim pesan.
3. Pastikan ChatPage menerima parameter navigasi (doctorName, patientId) via GoRouter.
4. Sambungkan ke ChatNotifier (Riverpod) untuk state management.

Ikuti arsitektur Feature-First. File UI hanya bertugas menampilkan data dari Provider.
```

---

### Prompt 2: Membuat Widget ChatBubble yang Reusable

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Tolong buatkan widget ChatBubble yang reusable untuk fitur chat di aplikasi medical Flutter saya.

Spesifikasi:
- Widget menerima parameter: message (String), isFromUser (bool), time (String), status (enum: sent/delivered/read) — opsional.
- Jika isFromUser = true: bubble di kanan, warna primary (AppColors.primary), teks putih.
- Jika isFromUser = false: bubble di kiri, warna abu muda, teks gelap.
- Tampilkan waktu pengiriman di sudut bawah bubble.
- Ukuran bubble otomatis menyesuaikan panjang teks, tidak melebihi 75% lebar layar.
- Avatar pengirim (lingkaran kecil) muncul di sebelah kiri bubble untuk pesan dokter.

Taruh di: lib/core/widgets/chat_bubble.dart
Pastikan widget ini reusable, tidak ada hardcode warna (gunakan AppColors), dan tidak ada logika bisnis di sini.
```

---

### Prompt 3: Brainstorming UX Chat yang Nyaman

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya sedang Fix/Revamp halaman Chat antara Dokter dan Pasien di aplikasi medis Flutter.

Tolong bantu brainstorm:
1. Apa saja elemen UI yang wajib ada di halaman chat medis agar terasa profesional?
2. Bagaimana menangani keyboard yang muncul agar daftar pesan tidak tertutup?
3. Apa animasi/transisi yang tepat saat pesan baru masuk atau dikirim?
4. Bagaimana menampilkan state "dokter sedang mengetik..." yang smooth?
5. Bagaimana UI harus berperilaku saat koneksi internet buruk atau pesan gagal terkirim?
```

---

---

## 👤 ARFI — Landing Page Animasi & Login Page

**Deadline: 14 April**

### Prompt 1: Animasi Landing Page yang Menarik

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Saya perlu menambahkan animasi dan transisi yang menarik pada Landing Page aplikasi Flutter saya.

Berikut kode Landing Page saat ini:
[TEMPEL KODE DART LANDING_PAGE.DART]

Landing page menggunakan PageView dengan 3 halaman (slide). Saya ingin:
1. Animasi fade-in + slide-up untuk teks dan gambar saat setiap halaman pertama kali tampil.
2. Transisi antar halaman yang lebih smooth (parallax effect: gambar bergerak lebih lambat dari teks).
3. Indikator titik (dot indicator) di bagian bawah yang animasinya smooth saat berpindah halaman.
4. Tombol "Next" dengan animasi pulse/glow agar menarik perhatian.
5. Animasi pada halaman pertama: logo muncul dengan scale-in effect saat pertama kali dibuka.

Gunakan AnimationController, TweenAnimationBuilder, atau AnimatedBuilder. Pastikan animasi menggunakan Curve yang tepat (ease, elasticOut, dsb). Tidak menggunakan package animasi eksternal kecuali rive atau lottie.
```

---

### Prompt 2: Merapikan Login Page

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Tolong review dan rapikan halaman Login Flutter saya berikut ini:
[TEMPEL KODE LOGIN_PAGE.DART]

Yang perlu diperbaiki/ditingkatkan:
1. Pastikan tata letak menggunakan MediaQuery agar responsif di berbagai ukuran HP.
2. Tambahkan animasi masuk (hero animation dari logo landing → logo di login, atau slide-up form dari bawah).
3. Tombol login harus punya loading state yang jelas (CircularProgressIndicator) dan disabled saat proses berlangsung.
4. Validasi form inline: email harus format valid, password minimal 8 karakter — tampilkan error merah di bawah field.
5. Keyboard handling: form harus auto-scroll saat keyboard muncul dan tidak overflow.
6. Accessibility: semua input field harus punya label yang jelas (labelText), bukan hanya placeholder.

Jangan ubah logika navigasi yang sudah ada, fokus ke perbaikan UI/UX.
```

---

### Prompt 3: Brainstorming First Impression App

```
[Tempel Konteks Arsitektur di atas terlebih dahulu]

Aplikasi Lumira AI adalah aplikasi screening kanker payudara berbasis AI. Ini adalah aplikasi medis yang serius namun harus tetap ramah dan tidak menakutkan bagi pasien.

Saya bertanggung jawab pada Landing Page dan Login Page yang jadi kesan pertama pengguna.

Tolong bantu brainstorm:
1. Bagaimana menyampaikan nilai (value proposition) aplikasi medis AI secara visual hanya dalam 3 slide landing page?
2. Warna, tipografi, dan tone visual apa yang tepat untuk aplikasi medis yang ingin terasa modern, terpercaya, namun tetap hangat dan tidak dingin seperti rumah sakit?
3. Apakah animasi yang berlebihan bisa kontraproduktif di aplikasi medis? Bagaimana takarannya?
4. Apa yang harus ada di halaman Login agar pengguna pertama kali (pasien awam) tidak bingung?
5. Bagaimana cara onboarding yang baik untuk pasien yang baru pertama kali menggunakan aplikasi medis berbasis AI?
```

---

---

## 💡 Tips Umum Menggunakan Prompt Ini

1. **Selalu sertakan Konteks Arsitektur** (blok pertama di file ini) di AWAL setiap prompt.
2. **Sertakan kode yang relevan** — Semakin banyak konteks yang diberikan (kode file yang ada, JSON response API, dll), semakin akurat jawaban AI-nya.
3. **Tempel response dari Swagger** — Untuk endpoint spesifik, buka [https://apilumiraai.vercel.app/api/docs#/](https://apilumiraai.vercel.app/api/docs#/), coba endpoint, copy contoh response JSON-nya, dan tempel ke dalam prompt.
4. **Iterasi** — Jika jawaban AI belum tepat, lakukan follow-up seperti: *"Kodenya sudah bagus, tapi tolong sesuaikan dengan folder structure yang ada di [X]"*
5. **Brainstorming dulu, coding belakangan** — Gunakan prompt brainstorming untuk eksplorasi sebelum langsung minta kode, supaya hasilnya lebih terarah.
