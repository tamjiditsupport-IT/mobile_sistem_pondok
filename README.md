# Pondok Mobile 📱

Aplikasi Android untuk Sistem Manajemen Pondok Pesantren, terhubung ke dua backend:
- **SMPT** (Sistem Manajemen Pesantren Terpadu) — port 8000
- **Bank Santri** — port 8001

## Tech Stack

| Layer | Teknologi |
|---|---|
| Framework | Flutter 3.41.7 |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| HTTP Client | Dio |
| Storage | flutter_secure_storage |
| Charts | fl_chart |
| Font | Poppins |

## Struktur Folder

```
lib/
├── app/
│   ├── routes/          # GoRouter configuration
│   └── themes/          # App theme & colors
├── core/
│   ├── constants/       # API URLs, storage keys
│   ├── network/         # Dio HTTP clients (smpt & bank)
│   └── storage/         # Secure storage service
├── features/
│   ├── auth/            # Login, logout, profil
│   ├── dashboard/       # Halaman utama & bottom nav
│   ├── keuangan/        # Saldo, transaksi, top-up, tagihan
│   ├── santri/          # Data santri
│   ├── akademik/        # Nilai, jadwal, raport
│   ├── kamtib/          # Perizinan, pelanggaran
│   └── profil/          # Pengaturan akun
└── shared/
    ├── widgets/          # Komponen reusable
    └── models/           # Shared models
```

## Cara Menjalankan

### 1. Pastikan Backend Berjalan
```bash
# Terminal 1 — SMPT backend
cd smpt && php artisan serve --port=8000

# Terminal 2 — Bank Santri backend
cd bank-santri && php artisan serve --port=8001
```

### 2. Konfigurasi URL API (jika pakai device fisik)
Edit `lib/core/constants/app_constants.dart`:
```dart
// Ganti 10.0.2.2 dengan IP lokal komputer Anda
static const String smptBaseUrl = 'http://192.168.1.xxx:8000/api';
static const String bankBaseUrl = 'http://192.168.1.xxx:8001/api';
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Jalankan di Emulator/Device
```bash
# List perangkat yang tersedia
flutter devices

# Jalankan aplikasi
flutter run
```

### 5. Build APK (untuk testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

## Fitur yang Sudah Diimplementasikan

- ✅ Struktur proyek & folder
- ✅ Dependencies & pubspec.yaml
- ✅ API client untuk SMPT & Bank Santri (Dio + JWT auto-inject)
- ✅ Secure storage untuk JWT token
- ✅ App theme (light & dark mode)
- ✅ GoRouter dengan auth guard
- ✅ Login screen dengan animasi
- ✅ Auth state management (Riverpod)
- ✅ Bottom navigation bar adaptif (berdasarkan role)
- ✅ Data models (AuthUser, BankAccount, Transaction, PaymentRecord)
- ✅ Repository layer (Auth, Keuangan)

## Fitur yang Perlu Dikembangkan Selanjutnya

- [ ] Dashboard screen (saldo ringkasan)
- [ ] Halaman Keuangan lengkap (riwayat transaksi, top-up)
- [ ] Data Santri screen
- [ ] Perizinan & Kamtib screen
- [ ] Profil screen
- [ ] Push notification
- [ ] App icon & splash screen

## Role Pengguna

| Role | Akses |
|---|---|
| Wali Santri | Dashboard, Keuangan, Profil |
| Santri | Dashboard, Keuangan, Akademik, Profil |
| Staf/Admin | Semua fitur termasuk Santri & Kamtib |
