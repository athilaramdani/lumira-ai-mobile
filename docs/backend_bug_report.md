# 🐛 Bug Report: PUT /patients/:id — 500 Internal Server Error

## Ringkasan
Endpoint `PUT /patients/:id` selalu mengembalikan **500 Internal Server Error** saat dipanggil dari mobile client. Bug ini memblokir fitur **Edit Profil Pasien** di aplikasi mobile.

---

## Detail Bug

| Item | Detail |
|------|--------|
| **Endpoint** | `PUT /patients/{id}` |
| **Base URL** | `https://apilumiraai.vercel.app` |
| **HTTP Method** | PUT |
| **Status Code** | `500 Internal Server Error` |
| **Response Body** | `{"statusCode":500,"message":"Internal server error"}` |
| **Tanggal Ditemukan** | 16 Mei 2026 |
| **Environment** | Production (Vercel) |
| **Prioritas** | 🔴 High — Fitur edit profil pasien tidak bisa digunakan sama sekali |

---

## Cara Reproduce

### 1. Login terlebih dahulu untuk mendapatkan token
```http
POST /auth/login
Content-Type: application/json

{
  "email": "patient@test.com",
  "password": "<password>"
}
```

### 2. Panggil endpoint update patient
```http
PUT /patients/PAS-859317
Content-Type: application/json
Accept: application/json
Authorization: Bearer <access_token_dari_langkah_1>

{
  "name": "Test Patient",
  "phone": "08080909",
  "address": "Jl. Test No. 1"
}
```

### 3. Response yang diterima (❌ Actual)
```json
HTTP/1.1 500 Internal Server Error

{
  "statusCode": 500,
  "message": "Internal server error"
}
```

### 4. Response yang diharapkan (✅ Expected)
```json
HTTP/1.1 200 OK

{
  "data": {
    "id": "PAS-859317",
    "name": "Test Patient",
    "phone": "08080909",
    "address": "Jl. Test No. 1"
  }
}
```

---

## Full Request Log dari Mobile Client

```
*** Request ***
uri: https://apilumiraai.vercel.app/patients/PAS-859317
method: PUT
headers:
  Content-Type: application/json
  Accept: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
data: {"name":"Test Patient","phone":"08080909","address":"asasa"}

*** Response ***
statusCode: 500
headers:
  x-powered-by: Express
  content-type: application/json; charset=utf-8
  server: Vercel
Response Text: {"statusCode":500,"message":"Internal server error"}
```

---

## Analisis dari Sisi Mobile (Frontend)

Kami sudah melakukan verifikasi sebagai berikut:

### ✅ Yang sudah kami pastikan benar:
1. **Payload sesuai OpenAPI spec** — Field yang dikirim (`name`, `phone`, `address`) sesuai dengan schema `PatientRequest` di `openapi.yaml`
2. **Token valid & belum expired** — Kami sudah test dengan token fresh (baru login), tetap error 500
3. **Content-Type benar** — `application/json` sudah di-set di header
4. **Endpoint path benar** — Sesuai dengan API spec: `PUT /patients/{id}`
5. **Test independen (tanpa app)** — Kami sudah test langsung pakai PowerShell/cURL, hasilnya tetap 500

### ❌ Yang perlu dicek di backend:
1. **Error handling di controller `updatePatient`** — Kemungkinan ada exception yang tidak ter-catch (unhandled error) sehingga langsung return generic 500
2. **Database query/Supabase** — Mungkin ada masalah saat query UPDATE ke database (column mismatch, constraint violation, dll)
3. **Middleware auth** — Apakah middleware JWT verification throw error alih-alih return 401? Kami lihat bahwa bahkan dengan token expired pun, server return 500 bukan 401
4. **Vercel Function Logs** — Tolong cek log di Vercel Dashboard → Functions → untuk melihat stack trace error sebenarnya

---

## Cara Cek Vercel Logs

1. Buka [Vercel Dashboard](https://vercel.com/dashboard)
2. Pilih project **apilumiraai**
3. Klik tab **Logs** atau **Functions**
4. Filter berdasarkan:
   - Method: `PUT`
   - Path: `/patients/`
   - Status: `500`
5. Lihat **stack trace** dari error untuk menemukan baris kode yang crash

---

## Saran Perbaikan di Backend

### 1. Tambahkan try-catch yang proper di route handler
```javascript
// routes/patients.js atau controller terkait
router.put('/patients/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone, address } = req.body;
    
    const result = await supabase
      .from('patients')
      .update({ name, email, phone, address })
      .eq('id', id)
      .select()
      .single();
    
    if (result.error) {
      console.error('Supabase error:', result.error);
      return res.status(400).json({ 
        statusCode: 400, 
        message: result.error.message 
      });
    }
    
    return res.json({ data: result.data });
  } catch (err) {
    // LOG ERROR INI AGAR BISA DI-DEBUG
    console.error('PUT /patients/:id error:', err);
    return res.status(500).json({ 
      statusCode: 500, 
      message: err.message || 'Internal server error' 
    });
  }
});
```

### 2. Pastikan middleware auth return 401, bukan throw
```javascript
// middleware/auth.js
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ message: 'No auth token' });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    // JANGAN throw error, HARUS return 401
    return res.status(401).json({ message: 'Token expired or invalid' });
  }
};
```

### 3. Cek apakah kolom database match
Pastikan tabel `patients` di Supabase memiliki kolom:
- `name` (text)
- `email` (text) 
- `phone` (text)
- `address` (text)

Dan pastikan tidak ada kolom yang `NOT NULL` tanpa default value yang tidak dikirim dalam request.

---

## Referensi API Spec

Dari file `openapi.yaml` yang sudah disepakati:

```yaml
/api/patients/{id}:
  put:
    tags: [Patients]
    summary: Update a patient
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/PatientRequest'

# PatientRequest schema:
PatientRequest:
  type: object
  properties:
    name: { type: string }
    email: { type: string }
    phone: { type: string }
    address: { type: string }
```

---

## Status

| Sisi | Status |
|------|--------|
| **Mobile (Frontend)** | ✅ Sudah benar — payload dan request sesuai spec |
| **Backend (API)** | ❌ Perlu diperbaiki — return 500 untuk semua request PUT patients |

> **Mohon bantuan tim backend untuk cek Vercel logs dan perbaiki endpoint ini. Terima kasih! 🙏**
