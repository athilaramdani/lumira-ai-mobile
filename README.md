# Lumira AI Mobile

Aplikasi seluler (*mobile app*) untuk **Lumira AI** - Platform Pendeteksi Kanker Payudara yang terintegrasi dengan teknologi AI MedGemma dan fitur konsultasi *real-time*.

🔗 **Repository Link**: [https://github.com/athilaramdani/lumira-ai-mobile](https://github.com/athilaramdani/lumira-ai-mobile)

---

## 🏗 Arsitektur Aplikasi (Tech Stack)

Aplikasi ini dibangun menggunakan *framework* lintas-platform **Flutter** dengan mengusung pedoman keterbacaan kode **Feature-First Clean Architecture**.

Teknologi utama yang digunakan meliputi:
- **Framework Utama**: Flutter (Dart)
- **State Management**: Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Routing Navigasi**: GoRouter (`go_router`)
- **Network / HTTP Client**: Dio (`dio`)
- **Penyimpanan Lokal**: Hive (`hive_flutter`) & SharedPreferences

---

## 📁 Struktur Folder

Struktur kode utama berada di dalam folder `lib/`, yang terbagi menjadi `core` dan berbagai modul `features`:

```text
lib/
 ├── core/                       # Pengaturan Inti & Utilitas Global
 │    ├── constants/             # Kumpulan nilai konstan (URL, Teks, Warna)
 │    ├── network/               # Konfigurasi perantara API (Dio Interceptors)
 │    ├── router/                # Konfigurasi alur pindah halaman (GoRouter)
 │    ├── storage/               # Setup penyimpanan device (Hive & SP)
 │    ├── theme/                 # Tema dasar UI aplikasi
 │    └── utils/                 # Fungsi bantuan tambahan
 │
 ├── features/                   # Modul yang dipisah Spesifik Berdasarkan Fitur
 │    ├── auth/                  # Sistem Login Pasien & Dokter
 │    ├── dashboard/             # Beranda & Menu Navigasi Utama
 │    ├── medical_review/        # Fitur untuk USG (Diagnosis, Anotasi, Grad-CAM)
 │    ├── chat/                  # Sistem pesan real-time Dokter-Pasien
 │    └── ai_chatbot/            # Integrasi Chatbot Edukasi & Bantuan MedGemma
 │
 └── main.dart                   # Titik masuk / Entry point dari aplikasi
```

### Konsep Layering (Clean Architecture)

Jika Anda membongkar setiap folder yang ada di dalam `features/` (Misal: `features/ai_chatbot`), Anda akan melihat kode tersebut dipisah kembali dalam 3 lapisan atau *layer*, yaitu:

1. **`data/`** (Penyedia Data): Tempat untuk mengurus pengambilan data (*fetching API*) di `datasources/`, membentuk kelas *DTO* di `models/`, dan mengeksekusi abstraksi *repository*.
2. **`domain/`** (Aturan Bisnis): Tempat logic murni tanpa UI yang terdiri dari `entities/` (objek murni), kerangka `repositories/`, serta `usecases/` yang mendefinisikan kasus penggunaan fitur.
3. **`presentation/`** (Tampilan Antarmuka): Tempat yang hanya fokus pada pembuatan UI seperti `pages/`, potongan elemen `widgets/`, dan *state management* dengan menyiapkan `controllers/` Riverpod.

Dengan arsitektur yang terisolasi ini, pengembangan fitur yang dikerjakan oleh masing-masing orang di tim akan jauh lebih fokus, rapi, dan mengurangi risiko kode saling *crash*.
