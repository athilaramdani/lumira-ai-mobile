# API & Dokumentasi Platform Lumira AI Enhanced

## Ringkasan (Overview)
**Lumira AI** adalah platform deteksi kanker payudara berbasis *Artificial Intelligence* (AI) menggunakan pencitraan Ultrasound (USG). Memanfaatkan teknologi Deep Learning & Radiomics, sistem ini membantu dokter dalam melakukan deteksi dini dan diagnosis. Versi *Enhanced* (diperbarui) dari platform ini mengintegrasikan fungsi **Chat** langsung antara dokter dan pasien, serta chatbot konsultasi medis **MedGemma** yang dibangun berdasarkan teknologi Gemma 3 dari Google DeepMind.

*(Dikembangkan oleh PT Dutormasi Membangun Indonesia)*

---

## Fitur-Fitur

### Fitur yang Sudah Ada (Existing)
- **Akses Aman (RBAC)**: Kontrol akses berbasis peran (Role-Based Access Control) untuk akun `Admin` dan `Dokter`.
- **Dashboard Admin**: Manajemen akun dokter, pasien, unggahan citra USG, serta pemantauan antrean secara real-time.
- **Worklist Dokter**: Antrean penanganan pasien yang berurut berdasarkan prioritas (*Waiting for Review*, *Need Attention*, *Done*).
- **Review Medis (Medical Review)**: Tampilan visual berdampingan (side-by-side) antara citra USG asli pasien dan peta panas (Heatmap / Grad-CAM) hasil analisis AI.
- **Alat Anotasi (Annotation Tools)**: Toolkit interaktif untuk menandai area penting (*Region of Interest / ROI*).
- **AI Engine & GradCAM**: Deteksi dan klasifikasi otomatis kasus menjadi *Normal*, *Benign*, atau *Malignant*, yang dilengkapi *Confidence Score* dan visualisasi Heatmap.
- **Audit Logging**: Riwayat pencatatan seluruh aktivitas log dalam sistem.

### Fitur Baru (Enhanced)
- **Chat Dokter - Pasien**: Fitur pesan instan (real-time) yang memungkinkan komunikasi langsung antara dokter dengan pasien untuk membahas ringkasan klinis, diagnosis, maupun rekomendasi medis.
- **MedGemma Chatbot**: 
  - **Bagi Dokter**: Meminta opini kedua (*second opinion*), pendalaman analisis pada citra secara multimodal, dan diskusi logika analisis medis (clinical reasoning).
  - **Bagi Pasien**: Berperan sebagai pusat edukasi kesehatan, memberikan konsultasi pra-layanan (pre-consultation), dan sistem tanya-jawab (Q&A) terintegrasi.

---

## Alur Pengguna (User Flow)

### 1. Alur Admin
1. **Masuk (Login)**: Mengakses sistem menggunakan kredensial Admin.
2. **Dashboard**: Melihat ringkasan dan statistik berjalan (Jumlah Pasien, Dokter, Gambar Medis, dan Antrean Kasus).
3. **Kelola Dokter**: Menambahkan, mengedit, mengubah status, atau menghapus daftar dokter.
4. **Kelola Pasien**: Mendaftarkan identitas pasien baru lalu mengunggah gambar USG mereka di tempat untuk diproses AI secara otomatis.
5. **Lihat Hasil (View AI Results)**: Memantau hasil skor kepercayaan AI (*Confidence Score*) dari prediksi terkait citra USG tersebut.

### 2. Alur Dokter *(Diperbarui/Enhanced)*
1. **Masuk (Login)**: Mengakses sistem mengandalkan kredensial milik dokter bersangkutan.
2. **Dashboard/Worklist**: Meninjau dan memilah pasien dalam antrean periksa hariannya.
3. **Review Citra**: Verifikasi hasil proyeksi prediksi AI pada citra USG dengan GradCAM *heatmaps*.
4. **Diagnosis**: Memvalidasi klasifikasi prediksi secara medis, memberikan opini keputusan akhir (Misal: *Normal* / *Benign* / *Malignant*), serta mengisi lembar rekam medis pasien (Doctor Notes). **Penting**: Saat dokter men-submit *review*, data *medical record* pasien yang sebelumnya tidak akan di-edit/ditimpa, melainkan sistem akan **membuat rekam medis baru (new record)** dengan tag/status ter-update (misal tag: `VALIDATED`).
5. **Chat & Konsultasi**: Melakukan ruang obrolan langsung (Chat) dengan pasien terkait penemuannya atau bisa mengecek ulang opsi/proyeksi lanjutan dengan berkonsultasi via platform AI dari MedGemma.

### 3. Alur Pasien *(Fitur Baru)*
1. **Masuk/Akses**: Pasien mengunjungi alamat portal yang dibagikan dari pihak Rumah Sakit/Admin.
2. **Lihat Status**: Memantau progres diagnosis berkasnya (Misal status *Pending* / *In Review* / *Done*).
3. **Chat Dokter**: Konsultasi langsung mendiskusikan hasil medisnya dengan dokter yang menanganinya (Real-time discussion).
4. **Konsultasi AI (MedGemma)**: Mengajukan pertanyaan edukasi berbasis topik medis / *disease awareness* kepada chatbot MedGemma.
5. **Riwayat**: Fitur riwayat lengkap untuk arsip kesehatan dan dokumentasi percakapan di masa lalu.

---

## Arsitektur & Teknologi (Tech Stack)
- **Frontend**: Vue 3 (Composition API), Vue Router (RBAC protection), Tailwind CSS, Vue-Konva (Canvas Annotation), Vite (Build tooling), Vue-Chartjs (Data viz).
- **Backend & Database**: Supabase (PostgreSQL Database, Manajemen Role & Autentikasi, Cloud Storage).
- **AI Server**: Python (FastAPI).
- **Web Socket / Realtime Connectivity**: Pertukaran data interaktif menggunakan WebSocket untuk sistem Chat.
- **Model-Model AI Terintegrasi**: 
  - Breast Cancer Classifier
  - Grad-CAM Heatmap Visualization
  - MedGemma 4B (Multimodal Teks & Gambar)
  - MedGemma 27B (Text-only / Analisis Klinis)
