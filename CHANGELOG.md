# Changelog

Seluruh perubahan signifikan (*notable changes*) pada proyek aplikasi mobile Lumira AI ini akan didokumentasikan di file ini.

Format pencatatan berdasarkan pedoman dari [Keep a Changelog](https://keepachangelog.com/id/1.0.0/), 
dan proyek ini akan mengikuti sistem penomoran rilis [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
*Bagian ini berisi perubahan yang saat ini ada di branch main tapi belum dibuatkan tag rilis.*

### Added
- [Dev] Inisialisasi dasar menggunakan *framework* Flutter (`lumira_ai_mobile`).
- [Arch] Menerapkan struktur *Feature-First Clean Architecture* (Pemisahan `core` dan `features`).
- [Arch] *Scaffold* modul utama: `auth`, `dashboard`, `medical_review`, `chat`, dan `ai_chatbot`.
- [Deps] Integrasi referensi *library* utama: `flutter_riverpod`, `dio`, `go_router`, `hive`, dan `shared_preferences`.
- [Docs] Dokumentasi diskusi tim (Tech Stack & Notulensi 17 Maret) ke dalam *folder* `docs/`.

---

*(Template / Panduan Pengisian untuk Versi Selanjutnya)*
<!--
## [Versi Rilis] - YYYY-MM-DD
### Added
- Fitur baru XYZ.
### Changed
- Perubahan pada fungsi atau logika XYZ.
### Deprecated
- Fitur peringatan sebelum dihapus pada versi mendatang.
### Removed
- Fitur XYZ dihapus (deprecated) pada versi sebelumnya.
### Fixed
- Perbaikan bug XYZ.
### Security
- Perbaikan kerentanan / bug keamanan.
-->
