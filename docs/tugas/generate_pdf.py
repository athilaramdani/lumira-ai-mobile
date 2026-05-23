import sys
from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        # Header text
        self.set_font('Helvetica', 'B', 8)
        self.set_text_color(100, 100, 100)
        self.cell(0, 5, 'PEMBAGIAN TUGAS KELOMPOK 1 - LUMIRA AI MOBILE', 0, 1, 'R')
        self.set_draw_color(200, 200, 200)
        self.line(10, 15, 200, 15)
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(150, 150, 150)
        self.cell(0, 10, f'Halaman {self.page_no()}', 0, 0, 'C')

def create_pembagian_tugas_pdf():
    pdf = PDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    
    # Title
    pdf.set_font('Helvetica', 'B', 16)
    pdf.set_text_color(12, 35, 64) # Navy Blue
    pdf.cell(0, 8, 'PEMBAGIAN TUGAS KELOMPOK 1', 0, 1, 'C')
    pdf.cell(0, 8, 'LUMIRA AI MOBILE - COMPRO PROJECT', 0, 1, 'C')
    pdf.ln(5)
    
    # Description
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(50, 50, 50)
    pdf.multi_cell(0, 5, 'Dokumen ini memuat pembagian tugas resmi yang adil dan seimbang bagi 7 anggota kelompok untuk menyalin (copy-paste) isi dari draf dokumen ComPro-SRS dan ComPro-SDD ke tautan Google Docs resmi yang tersedia di grup WA kelompok.')
    pdf.ln(6)
    
    # ------------------ SRS SECTION ------------------
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(24, 76, 120)
    pdf.cell(0, 8, '1. SOFTWARE REQUIREMENT SPECIFICATION (SRS)', 0, 1, 'L')
    pdf.set_font('Helvetica', 'I', 8)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 5, 'Google Docs Link: https://docs.google.com/document/d/14sT8ys4ydDVEzdyxeyvSt7wkXMqnxb7Tv0W9MVDsFXM/edit', 0, 1, 'L')
    pdf.ln(2)
    
    # Table Header
    pdf.set_font('Helvetica', 'B', 8)
    pdf.set_text_color(255, 255, 255)
    pdf.set_fill_color(12, 35, 64) # Navy Header
    
    # Column widths: Anggota (28), NIM (20), Porsi (42), Konten (100)
    cols = [28, 20, 42, 100]
    headers = ['Anggota Tim', 'NIM', 'Porsi Tugas', 'Detail Konten SRS']
    for idx, h in enumerate(headers):
        pdf.cell(cols[idx], 8, h, 1, 0, 'C', True)
    pdf.ln()
    
    srs_tasks = [
        ('Athila', '103012300132', 'Cover s.d. Bab 1', 'Halaman Judul, Versi Dokumen, Daftar Isi, Bab 1. Introduction (1.1, 1.2, 1.3)'),
        ('April', '103012300025', 'Bab 2 (Bagian A)', 'Bab 2. Overall Description (2.1 Product Perspective + Diagram, 2.2 Product Functions)'),
        ('Irgi', '103012300039', 'Bab 2 (Bagian B)', 'Bab 2 (2.3 User Classes, 2.4 Operating Env, 2.5 Constraints, 2.6 Assumptions, 2.7 Business Rules)'),
        ('Arfian', '103012300337', 'Bab 3 (FR - Bagian A)', 'Bab 3. System Requirements -> 3.1 Functional Requirements (Modul 1: RBAC, Modul 2: Dashboard, Modul 3: Review)'),
        ('Jeany', '103012300357', 'Bab 3 (FR - Bagian B)', 'Bab 3. System Requirements -> 3.1 Functional Requirements (Modul 4: Patient Portal, Modul 5: Chat, Modul 6: MedGemma)'),
        ('Gavin', '103012300452', 'Bab 3 (NFR)', 'Bab 3. System Requirements -> 3.2 Non-Functional Requirements (Performance, Security, Usability, Reliability, Maintainability)'),
        ('Bill', '103012330197', 'Bab 4 & Bab 5', 'Bab 4. External Interface Requirements (4.1, 4.2, 4.3, 4.4) + Bab 5. Appendix (Glossary & References)')
    ]
    
    pdf.set_font('Helvetica', '', 8)
    pdf.set_text_color(50, 50, 50)
    for idx, row in enumerate(srs_tasks):
        fill = idx % 2 == 1
        pdf.set_fill_color(242, 245, 248) # light shading
        
        h = 10
        x = pdf.get_x()
        y = pdf.get_y()
        pdf.rect(x, y, cols[0], h, 'F' if fill else '')
        pdf.cell(cols[0], h, row[0], 1, 0, 'C', fill)
        pdf.cell(cols[1], h, row[1], 1, 0, 'C', fill)
        pdf.cell(cols[2], h, row[2], 1, 0, 'L', fill)
        
        # Detail cell (multi line inside 100 width)
        pdf.rect(x + cols[0] + cols[1] + cols[2], y, cols[3], h, 'F' if fill else '')
        pdf.multi_cell(cols[3], 5, row[3], 1, 'L', fill)
        pdf.set_xy(x, y + h)
        
    pdf.ln(6)
    
    # ------------------ SDD SECTION ------------------
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(24, 76, 120)
    pdf.cell(0, 8, '2. SOFTWARE DESIGN DOCUMENT (SDD)', 0, 1, 'L')
    pdf.set_font('Helvetica', 'I', 8)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 5, 'Google Docs Link: https://docs.google.com/document/d/1g581UjPbbpi6wLOGaYRYHHOf7Z8oon2UQyQBm-Fcoq8/edit', 0, 1, 'L')
    pdf.ln(2)
    
    # Table Header
    pdf.set_font('Helvetica', 'B', 8)
    pdf.set_text_color(255, 255, 255)
    pdf.set_fill_color(12, 35, 64)
    for idx, h in enumerate(headers):
        pdf.cell(cols[idx], 8, h, 1, 0, 'C', True)
    pdf.ln()
    
    sdd_tasks = [
        ('Athila', '103012300132', 'Cover s.d. Bab 1, 8, 9', 'Halaman Judul, Versi Dokumen, Daftar Isi, Bab 1. Introduction, Bab 8. Constraints, Bab 9. Appendix'),
        ('April', '103012300025', 'Bab 2 (Arsitektur)', 'Bab 2. System Architecture Design (2.1 Use Case, 2.2 High-Level Architecture, 2.3 Deployment Architecture)'),
        ('Irgi', '103012300039', 'Bab 3 (Modul)', 'Bab 3. Module Design (3.1 Module List, 3.2 Module Description: A. Auth, B. Medical Review, C. MedGemma AI Chatbot)'),
        ('Arfian', '103012300337', 'Bab 4 (Class & Seq)', 'Bab 4. Class Diagram and Object Design (4.1 Class Diagram, 4.2 Sequence Diagrams: A. Inferensi, B. Real-time Chat)'),
        ('Jeany', '103012300357', 'Bab 5 (Database - A)', 'Bab 5. Database Design (5.1 ERD Diagram + Relasi, 5.2 Schema Definitions: Tabel users, Tabel patients, Tabel doctors)'),
        ('Gavin', '103012300452', 'Bab 5 (B) & Bab 7', 'Bab 5 (5.2 Schema: Tabel medical_records, Firestore rooms, Firestore messages) + Bab 7 (7.1 DFD 0, 7.2 Activity Diagram)'),
        ('Bill', '103012330197', 'Bab 6 (UI/UX) *Khusus UI*', 'Bab 6. User Interface Design (6.1 Wireframes / Mockups Layar A s.d. F Komplit, 6.2 Navigation Flow GoRouter Diagram)')
    ]
    
    pdf.set_font('Helvetica', '', 8)
    pdf.set_text_color(50, 50, 50)
    for idx, row in enumerate(sdd_tasks):
        fill = idx % 2 == 1
        pdf.set_fill_color(242, 245, 248)
        
        h = 10
        x = pdf.get_x()
        y = pdf.get_y()
        pdf.rect(x, y, cols[0], h, 'F' if fill else '')
        pdf.cell(cols[0], h, row[0], 1, 0, 'C', fill)
        pdf.cell(cols[1], h, row[1], 1, 0, 'C', fill)
        pdf.cell(cols[2], h, row[2], 1, 0, 'L', fill)
        
        # Detail cell (multi line inside 100 width)
        pdf.rect(x + cols[0] + cols[1] + cols[2], y, cols[3], h, 'F' if fill else '')
        pdf.multi_cell(cols[3], 5, row[3], 1, 'L', fill)
        pdf.set_xy(x, y + h)
        
    pdf.output('pembagian_tugas.pdf')
    print("Successfully created pembagian_tugas.pdf")

if __name__ == '__main__':
    create_pembagian_tugas_pdf()
