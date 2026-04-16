# Hasil Brainstorming Tech Stack Mobile App

Berdasarkan diskusi tim pada tanggal 18 Maret, berikut adalah rangkuman keputusan dan rancangan terkait *tech stack* serta arsitektur yang akan digunakan untuk pengembangan aplikasi mobile:

## 1. Framework Utama
- **Flutter (Dart)**: Dipilih agar pengembangan dapat dilakukan secara *cross-platform* (iOS & Android) secara langsung. Menggunakan teknologi modern yang relevan untuk saat ini, serta cocok untuk proyek yang memiliki integrasi API AI dan fitur *real-time*.

## 2. Tools & Library Pendukung
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Routing**: GoRouter
- **Local Storage**: Hive + SharedPreferences
- **API Testing**: Postman
- **Version Control**: Git (GitHub)
- **CI/CD**: Codemagic
- **Push Notification & Crash Reporting**: *(Belum ditentukan, akan didiskusikan lebih lanjut)*

## 3. Arsitektur Aplikasi
- **Clean Architecture**: Dipilih agar struktur *codebase* lebih *scalable* (mudah dikembangkan) dan memudahkan proses integrasi dengan API eksternal maupun layanan AI.

## 4. Integrasi Database & Backend
- **Database**: Supabase
- **Alur Data**: Aplikasi mobile tidak akan berinteraksi langsung ke Supabase. Aplikasi mobile akan berkomunikasi dengan sistem Backend (BE), yang kemudian diteruskan oleh BE ke Supabase.
- **Status Saat Ini**: Tim *developer* sedang dalam proses memisahkan sistem Frontend (FE) dan Backend (BE) karena sebelumnya tergabung dalam satu proyek (*Fullstack*).
