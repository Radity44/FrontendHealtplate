# Project Status - HealthPlate

Dokumen ini berisi informasi mengenai progres pengerjaan proyek **HealthPlate** (Flutter Frontend) per Juni 2026. Data ini merinci fitur yang telah selesai, fitur yang sedang berjalan, rencana sprint mendatang, serta masalah-masalah teknis yang diketahui (*Known Issues*).

---

## 1. Completed (Selesai)

### **Sprint 1 – Authentication Backend Integration**
*   **Fitur Pendaftaran**: Terhubung ke endpoint `POST /auth/register` menggunakan nama default `"HealthPlate User"`.
*   **Fitur Masuk**: Terhubung ke endpoint `POST /auth/login` menggunakan Email dan Password.
*   **Penyimpanan Sesi (Session Manager)**: Penyimpanan `access_token` tunggal secara aman menggunakan `shared_preferences`.
*   **Logika Startup Routing**:
    *   Pengguna tanpa token diarahkan ke halaman Welcome (`/welcome`).
    *   Pengguna dengan token tetapi belum menyelesaikan onboarding diarahkan ke halaman setup foto profil (`/profile-pic-setup`).
    *   Pengguna dengan token dan onboarding selesai diarahkan langsung ke halaman Utama (`/home`).
*   **Fitur Keluar (Logout)**: Terhubung ke endpoint `POST /auth/logout` dengan sistem hibrida (sesi lokal di SharedPreferences tetap dihapus meskipun request API ke server gagal karena kendala jaringan).

### **Sprint 2 – Profile & Onboarding Integration**
*   **Onboarding setup (Langkah 1-3)**: Terhubung ke API. Foto profil, data diri dasar (pria/wanita dikonversi ke `'Male'`/`'Female'`, tanggal lahir diformat ke format ISO `'YYYY-MM-DD'`), dan batas target nutrisi dikirim secara parsial menggunakan `PUT /auth/me`.
*   **Upload Avatar**: Terhubung ke endpoint multipart `POST /upload/avatar` menggunakan berkas gambar asli via `image_picker`.
*   **Profil Dinamis**: Mengambil data profil rill dari `GET /auth/me` untuk ditampilkan pada dashboard utama dan tab profil.
*   **Fallback Inisial**: Otomatis menampilkan inisial huruf nama depan dan belakang berlatar hijau mint jika avatar pengguna bernilai null/kosong.
*   **Widget Test Offline Compatibility**: Menambahkan flag static `ProfileRepository.useMockDataForTests` agar pengujian widget UI dapat berjalan cepat dan luring tanpa memanggil API HTTP secara langsung.

### **Hotfix – API Config Multi-Device & Network Diagnostic**
*   **Platform-Aware Base URL**: Mendeteksi secara dinamis apakah aplikasi berjalan pada Windows Desktop (`localhost:3000`) atau Android Emulator (`10.0.2.2:3000`).
*   **Manual Override IP LAN**: Variabel `customBaseUrl` di `api_config.dart` memfasilitasi pengetesan cepat pada HP Android Fisik menggunakan IP lokal laptop/server (misal: `http://192.168.X.X:3000/api/v1`).
*   **Batas Waktu Request (Timeout)**: Membatasi maksimal waktu tunggu respons server selama 10 detik `.timeout(const Duration(seconds: 10))` pada semua endpoint `AuthService` dan `ProfileService`.
*   **Logging Diagnostik Jaringan**: Mencetak informasi `Platform : ...` dan `Base URL : ...` saat startup aplikasi serta mencetak URL API request, status response, dan error exception ke terminal console pada debug mode (`kDebugMode`).
*   **Pemetaan Exception (Error Handling)**:
    *   *SocketException (Connection Refused)*: *"Koneksi ditolak oleh server. Pastikan backend berjalan dan port yang digunakan benar."*
    *   *SocketException (Failed Host Lookup)*: *"Tidak dapat menemukan server. Periksa alamat API dan koneksi jaringan."*
    *   *SocketException (General Network Error)*: *"Tidak dapat terhubung ke server. Pastikan backend aktif dan perangkat berada pada jaringan yang sama."*
    *   *TimeoutException*: *"Server tidak merespons. Silakan coba lagi beberapa saat."*
    *   *Unknown Exception*: *"Terjadi kesalahan saat menghubungi server. Silakan coba kembali."*

### **Peningkatan UI – Dashboard Water Tracking Card (UI Only)**
*   **Pencatatan Hidrasi**: Card habit tracking air minum terintegrasi di dashboard utama di bawah Nutrition Summary Card.
*   **Visual Progres**: 8 buah indikator lingkaran (dots) yang berubah warna secara beranimasi (`AnimatedContainer` berdurasi 250ms) menggunakan warna aksen teal utama.
*   **Simulasi Interaktif Tap**: Mengetuk lingkaran berikutnya mengaktifkan progres (+1 gelas / +250 ml), mengetuk lingkaran aktif terakhir menurunkan progres (-1 gelas / -250 ml).
*   **Badge Pencapaian**: Menampilkan badge `🎉 Target Tercapai` berwarna hijau lembut saat progress terisi penuh 8/8 gelas.

### **Sprint 3 – Dashboard Integration & Dynamic User Data**
*   **Integrasi Data Profil**: Menghubungkan dashboard dengan data profil riil dari endpoint `GET /auth/me` secara dinamis.
*   **Pengecekan Target Nutrisi yang Ketat**: Otomatis mendeteksi target nutrisi kosong/nol (`!hasNutritionTarget`) dan menampilkan empty state kustom yang mengarahkan pengguna untuk melengkapi profil.
*   **Visual Avatar Inisial**: Menggunakan `errorBuilder` untuk menangani network error/broken URL pada `avatar_url` dan otomatis menampilkan fallback inisial nama.
*   **Insight Card Baru**: Menambahkan "Insight Kesehatan & Target" card di dashboard yang menampilkan BMI terhitung riil (Kurus, Normal, Ideal/Normal, Overweight, Obesitas), Target Kalori, dan Target Protein.
*   **Pull-to-Refresh**: Menambahkan `RefreshIndicator` untuk memuat ulang data dasbor.
*   **Error Handling & Loading Spinner**: Menambahkan status spinner pemuatan dan kartu error penanganan kegagalan dengan tombol coba lagi.

---

## 2. In Progress (Sedang Dikerjakan)
*   **Persiapan Integrasi Sprint 4 (Meal Plan & Recipe Integration)**: Menyiapkan pemetaan API dan controller untuk daftar paket Meal Plan dan katalog resep sehat.

---

## 3. Planned (Rencana Berikutnya)
*   **Sprint 4 – Meal Plan & Recipe Integration**:
    *   Menghubungkan daftar paket Meal Plan dan menu harian yang dikonsumsi pengguna ke database backend.
    *   Mengintegrasikan katalog resep masakan, instruksi timeline, filter kategori, pencarian, dan favorit resep dengan backend.
*   **Sprint 5 – Riwayat & Analisis**:
    *   Menghubungkan statistik grafik riwayat (7 hari, 30 hari, bulanan) dengan data agregat backend.
    *   Mengintegrasikan modul Log Harian (tambah makan manual, upload gambar makanan, scan barcode produk) ke backend API.
    *   Mengintegrasikan fitur Water Tracking dengan endpoint backend hydration (jika backend telah merilis API hydration).

---

## 4. Known Issues (Masalah yang Diketahui)
*   **Kebutuhan Backend Aktif saat Development**: Aplikasi mobile akan menampilkan error *"Koneksi ditolak oleh server..."* jika server backend lokal di PC host belum dinyalakan atau port yang dikonfigurasi salah. Pastikan backend berjalan pada port `3000` sebelum menjalankan program.
*   **IP Wi-Fi Lokal Berubah**: Pada pengujian HP fisik, IP LAN laptop sering berubah saat berpindah koneksi Wi-Fi. Developer harus selalu memperbarui field `customBaseUrl` di `api_config.dart` sesuai IP IPv4 aktif laptop/server.
*   **Modul Lain Masih Dummy**: Halaman Meal Plan, Katalog Resep, Pencatatan Log Harian, dan Riwayat Grafik masih beroperasi menggunakan data dummy lokal yang disimulasikan secara premium. Skenario integrasi API untuk modul ini dijadwalkan pada sprint mendatang.
