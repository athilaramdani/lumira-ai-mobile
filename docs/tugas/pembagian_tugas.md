# **PEMBAGIAN TUGAS KELOMPOK 1 - LUMIRA AI MOBILE**

Dokumen ini berisi pembagian tugas yang adil dan merata bagi **7 anggota kelompok** untuk menyalin (*copy-paste*) konten dari hasil generate markdown/Word local (`ComPro-SRS.docx` & `ComPro-SDD.docx`) ke link Google Docs resmi yang ada di grup.

---

## 📊 **DOKUMEN 1: SOFTWARE REQUIREMENT SPECIFICATION (SRS)**
**Google Docs Link**: [Google Docs SRS](https://docs.google.com/document/d/14sT8ys4ydDVEzdyxeyvSt7wkXMqnxb7Tv0W9MVDsFXM/edit?usp=sharing)

| Anggota Tim | NIM | Porsi Pembagian Tugas (Halaman / Bab di SRS) | Detail Konten yang Harus Di-copy |
| :--- | :--- | :--- | :--- |
| **Athila** | 103012300132 | **Cover Page s.d. Bab 1** | Halaman Judul, Document Version, Table of Content, Bab 1. Introduction (1.1 Purpose, 1.2 Intended Readers, 1.3 Scope of the System) |
| **April** | 103012300025 | **Bab 2 (Bagian A)** | Bab 2. Overall Description (2.1 Product Perspective + Diagram Mermaid, 2.2 Product Functions) |
| **Irgi** | 103012300039 | **Bab 2 (Bagian B)** | Bab 2. Overall Description (2.3 User Classes, 2.4 Operating Environment, 2.5 Design Constraints, 2.6 Assumptions, 2.7 Business Rules / Aturan Bisnis) |
| **Arfian** | 103012300337 | **Bab 3 (Functional - Bagian A)** | Bab 3. System Requirements -> 3.1 Functional Requirements (Modul 1: RBAC, Modul 2: Doctor Dashboard, Modul 3: Medical Review) |
| **Jeany** | 103012300357 | **Bab 3 (Functional - Bagian B)** | Bab 3. System Requirements -> 3.1 Functional Requirements (Modul 4: Patient Portal, Modul 5: Consultation Chat, Modul 6: MedGemma Chatbot) |
| **Gavin** | 103012300452 | **Bab 3 (Non-Functional)** | Bab 3. System Requirements -> 3.2 Non-Functional Requirements (Performance, Security, Usability, Reliability, Maintainability) |
| **Bill** | 103012330197 | **Bab 4 & Bab 5 (UI & Appendix)** | Bab 4. External Interface Requirements (4.1 User Interface, 4.2 Hardware Interface, 4.3 Software Interface, 4.4 Communication Interface) + Bab 5. Appendix (Glossary & References) |

---

## 📐 **DOKUMEN 2: SOFTWARE DESIGN DOCUMENT (SDD)**
**Google Docs Link**: [Google Docs SDD](https://docs.google.com/document/d/1g581UjPbbpi6wLOGaYRYHHOf7Z8oon2UQyQBm-Fcoq8/edit?usp=sharing)

| Anggota Tim | NIM | Porsi Pembagian Tugas (Halaman / Bab di SDD) | Detail Konten yang Harus Di-copy |
| :--- | :--- | :--- | :--- |
| **Athila** | 103012300132 | **Cover Page, Bab 1, Bab 8, & Bab 9** | Halaman Judul, Document Version, Table of Content, Bab 1. Introduction (1.1, 1.2, 1.3), Bab 8. System Constraints, Bab 9. Appendix |
| **April** | 103012300025 | **Bab 2 (Arsitektur)** | Bab 2. System Architecture Design (2.1 Use Case + Diagram, 2.2 High-Level Architecture + Diagram, 2.3 Deployment Architecture) |
| **Irgi** | 103012300039 | **Bab 3 (Modul)** | Bab 3. Module Design (3.1 Module List, 3.2 Module Description: A. Auth, B. Medical Review, C. MedGemma AI Chatbot) |
| **Arfian** | 103012300337 | **Bab 4 (Class & Sequence)** | Bab 4. Class Diagram and Object Design (4.1 Class Diagram, 4.2 Sequence Diagrams: A. Inferensi & Review, B. Real-time Chat) |
| **Jeany** | 103012300357 | **Bab 5 (Database - Bagian A)** | Bab 5. Database Design (5.1 ERD Diagram + Relasi, 5.2 Schema Definitions: Tabel `users`, Tabel `patients`, Tabel `doctors`) |
| **Gavin** | 103012300452 | **Bab 5 (Bagian B) & Bab 7** | Bab 5. Database Design (5.2 Schema Definitions: Tabel `medical_records`, Firestore `rooms`, Firestore `messages`) + Bab 7. Data Flow and Process Flow (7.1 DFD Level 0, 7.2 Activity Diagram) |
| **Bill** | 103012330197 | **Bab 6 (UI/UX)* (Khusus Bidang UI)** | Bab 6. User Interface Design (6.1 Wireframes / Mockups Layar A s.d. F komplit, 6.2 Navigation Flow GoRouter Diagram) |

---

### 💡 **Tips dan Catatan Penting saat Salin-Tempel ke Google Docs**:
1. **Salin Tabel**: Saat menyalin tabel skema database atau functional requirements dari berkas `.docx` yang di-generate, Google Docs akan otomatis memformatnya sebagai tabel Word yang bersih. Pertahankan warna biru navy header untuk konsistensi.
2. **Salin Diagram (Mermaid)**: 
   - Karena Google Docs tidak merender teks kode Mermaid secara native, Anda dapat mengambil tangkapan layar (*screenshot*) diagram Mermaid yang indah yang ada di dalam berkas markdown/preview atau merendernya di editor online [Mermaid Live Editor](https://mermaid.live) dan menempelkannya sebagai Gambar di Google Docs.
3. **Format Judul & Bullet**: Pastikan style Heading 1, Heading 2, dan bullet points teraplikasi secara rapi di Google Docs setelah melakukan paste.
