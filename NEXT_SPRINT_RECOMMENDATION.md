# Next Sprint Recommendation - HealthPlate

Dokumen ini memuat rekomendasi teknis dan panduan pengerjaan bagi developer baru untuk merencanakan sprint pengembangan berikutnya pada frontend aplikasi **HealthPlate**.

---

## 1. Rekomendasi Sprint Terdekat
Direkomendasikan untuk melanjutkan ke **Sprint 3 – Dashboard & Log Harian Integration**.

### **Alasan Teknis**
*   **Fondasi Kokoh**: Sprint 1 (Autentikasi) dan Sprint 2 (Profil & Onboarding) telah selesai, stabil, dan teruji secara offline.
*   **Fungsionalitas Utama**: Aplikasi saat ini menampilkan status gizi hari ini di dashboard menggunakan nilai tiruan statis. Menghubungkan dashboard dengan log asupan riil dari database backend adalah nilai guna utama (*core value proposition*) dari aplikasi HealthPlate.

---

## 2. Prasyarat Pengerjaan (Prerequisites)
Sebelum memulai Sprint 3, pastikan backend server telah siap dengan endpoint berikut:
1.  `GET /api/v1/logs/daily/:date`
    *   Mengembalikan total asupan kalori/makro aktual serta daftar makanan/minuman yang dikonsumsi pengguna pada tanggal tertentu.
2.  `POST /api/v1/logs/consume`
    *   Menyimpan entri makanan/minuman baru ke database. Menerima data nama makanan, porsi, waktu makan (sarapan/siang/malam/snack), serta nilai gizi (opsional jika backend memiliki kamus makanan sendiri).
3.  `GET /api/v1/food/barcode/:code` (Opsional - untuk Scan Barcode)
    *   Mencari informasi produk makanan kemasan berdasarkan kode barcode.
4.  `POST`/`GET` `/api/v1/hydration/logs` (Opsional - untuk Water Tracking)
    *   Menyimpan progress hidrasi harian pengguna secara persisten di database.

---

## 3. Estimasi Ruang Lingkup (Scope of Work)

*   **Integrasi Progress Dashboard Harian**:
    *   Mengganti nilai dummy di `_consumedCalories`, `_consumedProtein`, dll pada [home_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/home_screen.dart) agar mengambil data dari endpoint `/logs/daily/:date`.
    *   Memastikan diagram progres melingkar dan progress bar makro nutrisi ter-render dinamis mengikuti perubahan asupan aktual.
*   **Integrasi List Log Harian**:
    *   Menghubungkan tab [log_harian_tab.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/log_harian_tab.dart) untuk mengambil data dari backend.
    *   Merender kartu menu makanan dinamis per section waktu makan (Sarapan, Makan Siang, Makan Malam, Snack).
*   **Form Tambah Konsumsi Manual**:
    *   Menghubungkan form di [tambah_konsumsi_manual_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/tambah_konsumsi_manual_screen.dart) untuk mengirim data input ke endpoint `POST /logs/consume`.
    *   Mengintegrasikan pengiriman lampiran foto makanan menggunakan upload multipart (mirip logika upload avatar di ProfileService).
*   **Simulasi Scan Barcode Terintegrasi**:
    *   Memodifikasi [scan_barcode_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/scan_barcode_screen.dart). Setelah animasi scan selesai, panggil API pencarian barcode. Jika produk terdaftar, isi otomatis nilai gizi ke form input konsumsi.

---

## 4. Risiko & Strategi Mitigasi

*   **Risiko 1: Keterlambatan Sinkronisasi UI**
    *   *Deskripsi*: Setelah pengguna menyimpan makanan baru, dashboard tidak langsung terupdate karena cache atau data lama belum di-refresh.
    *   *Mitigasi*: Gunakan penantian asinkron (`await Navigator.pushNamed(...)`) pada tombol simpan konsumsi. Saat navigasi ditutup (pop), jalankan kembali fungsi `_fetchDailyData()` untuk memuat ulang data dasbor terbaru dari backend.
*   **Risiko 2: Kegagalan Jaringan Saat Simpan Data**
    *   *Deskripsi*: Pengguna kehilangan sinyal internet tepat saat menekan tombol "Simpan ke Log Harian".
    *   *Mitigasi*: Manfaatkan modularitas exception handling `_handleNetworkException(e)` yang telah diuji di `AuthService` dan `ProfileService`. Bungkus request dengan timeout 10 detik dan tampilkan pesan kegagalan ramah pengguna via SnackBar.
*   **Risiko 3: Endpoint Hydrasi Belum Siap**
    *   *Deskripsi*: Backend belum mengembangkan tabel atau API untuk tracking air minum.
    *   *Mitigasi*: Pertahankan water tracking di dasbor menggunakan state lokal tiruan saat ini. Pindahkan target persistence water tracking ke sprint pemeliharaan akhir.
