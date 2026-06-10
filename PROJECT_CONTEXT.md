# Project Context - HealthPlate

Dokumen ini berfungsi sebagai acuan utama konteks proyek **HealthPlate** (Flutter Frontend) untuk developer baru. Dokumen ini menjelaskan tujuan aplikasi, arsitektur sistem, struktur modular, keputusan UX yang disepakati, dan ringkasan implementasi fitur.

---

## 1. Gambaran Umum Proyek
*   **Nama Aplikasi**: HealthPlate
*   **Tujuan Utama**: Aplikasi asisten kesehatan untuk memantau asupan kalori dan makro nutrisi harian, menyusun rencana makan (*Meal Plan*), mencatat konsumsi secara manual maupun berbasis barcode, memandu resep makanan sehat, serta melacak riwayat kesehatan dan berat badan pengguna secara berkala.
*   **Tech Stack**:
    *   **Framework**: Flutter (Dart) - mendukung Windows Desktop (untuk development) dan Android (Emulator & HP Fisik).
    *   **Penyimpanan Lokal**: `shared_preferences` untuk manajemen sesi autentikasi dan status onboarding.
    *   **HTTP Client**: Paket `http` standard untuk integrasi REST API backend.
    *   **State Management**: Berbasis local state (`setState`) dan repository layer terisolasi.
*   **Tema Desain & Estetika**:
    *   **Tema Utama**: Hijau Hutan (*Forest Green* `#095D40`) dan aksen Teal (`#14B8A6`).
    *   **Design System**: Pendekatan card-based modern bersudut melingkar (*large border radius* 24px), bayangan halus (*box shadow* dengan `Colors.black.withValues(alpha: 0.03)`), tipografi Inter/Outfit (menggunakan visual kustom berbobot seimbang), dan status visual adaptif (kartu warning berwarna merah premium `#FEF2F2` untuk konsumsi berlebih).

---

## 2. Struktur Aplikasi & Alur Halaman
Aplikasi HealthPlate dibagi menjadi modul-modul berikut:

*   **Welcome Screen (`/welcome`)**: Splash screen dinamis yang mendeteksi sesi masuk. Menampilkan logo piring sehat, judul premium, serta tombol pendaftaran/masuk.
*   **Register Screen (`/register`)**: Halaman pembuatan akun menggunakan Email dan Password. Mengirim nama default `"HealthPlate User"` ke backend. Token otomatis disimpan untuk memandu alur onboarding.
*   **Login Screen (`/login`)**: Autentikasi pengguna lama. Menyimpan access token dan langsung mengarahkan pengguna ke Dashboard jika onboarding sudah selesai.
*   **Onboarding Flow (3 Langkah)**:
    *   *Langkah 1: Profile Pic Setup (`/profile-pic-setup`)*: Mengunggah foto profil asli menggunakan `image_picker` secara opsional.
    *   *Langkah 2: Personal Data Setup (`/personal-data-setup`)*: Mengisi nama lengkap, jenis kelamin, tanggal lahir, tinggi badan, dan berat badan.
    *   *Langkah 3: Nutrient Target Setup (`/goals-setup`)*: Menentukan batas target kalori, karbohidrat, protein, lemak, dan gula harian. Menyelesaikan langkah ini mengubah status `onboarding_completed = true`.
*   **Dashboard / Home Tab**: Menu utama yang menampilkan ringkasan kalori harian (diagram lingkaran donat), progres bar makro nutrisi, kartu warning konsumsi berlebih, Water Tracking, Quick Access Grid, menu meal plan berikutnya, dan tips gizi harian.
*   **Meal Plan Tab**: Kalender horizontal mingguan interaktif (PageView per 7 hari), penampil paket makan aktif dinamis (Sarapan, Makan Siang, Makan Malam, Snack), opsi centang status konsumsi harian, dan pop-up resep masakan terpadu.
*   **Log Harian Tab**: Pemantauan asupan makan berdasarkan 4 segmentasi waktu makan harian (Sarapan, Makan Siang, Makan Malam, Snack) dengan opsi input manual maupun scan barcode.
*   **Resep Tab**: Galeri resep makanan sehat dengan filter kategori chips dan kolom pencarian real-time. Layar detail resep mencakup hero image, informasi durasi/porsi/kesulitan, nutrisi per porsi, checklist bahan interaktif, timeline langkah memasak, dan tips nutrisi dinamis.
*   **Riwayat Tab**: Grafik statistik nutrisi (bulanan, mingguan, 7 harian), skor pencapaian kalori, ringkasan hari konsisten, serta list harian dengan status terwarna (Hijau = Tercapai, Oranye = Terlampaui, Merah = Di Bawah Target).
*   **Profil Tab**: Tab profil pengguna dinamis yang menyajikan visualisasi indeks massa tubuh (BMI Slider 3-warna), target nutrisi, pencapaian bulanan, navigasi ke halaman edit profil, tombol ganti foto profil terintegrasi, dan konfirmasi dialog logout.

---

## 3. Keputusan UX yang Sudah Disepakati
*   **Autentikasi Cepat (Register Awal)**: Proses registrasi awal dibuat secepat mungkin dengan hanya meminta Email dan Password. Nama lengkap dipindahkan ke alur onboarding langkah kedua agar pengguna dapat langsung terdaftar terlebih dahulu.
*   **Unggah Foto Profil Bersifat Opsional**: Pengguna tidak boleh dipaksa mengunggah foto profil di awal. Disediakan tombol "Lewati untuk Sekarang" pada onboarding langkah pertama. Jika pengunggahan gagal karena masalah jaringan, dialog pop-up yang informatif akan muncul dengan pilihan untuk mencoba kembali atau melewati tanpa mengunci pengguna pada halaman setup tersebut.
*   **Fallback Inisial Avatar**: Apabila `avatar_url` yang dikirim dari backend bernilai `null` atau kosong, sistem secara otomatis merender avatar bulat berwarna mint dengan inisial nama pengguna (misal: "RF" untuk "Raditya Fansa") untuk menjaga estetika premium.
*   **Penetapan Target Onboarding Secara Parsial**: Langkah data diri dan target nutrisi dikirimkan ke backend melalui satu endpoint profil (`PUT /auth/me`) secara parsial secara berurutan, sehingga pengguna yang sempat keluar di tengah onboarding dapat melanjutkan onboarding yang tersisa saat membuka kembali aplikasi.
*   **Water Tracking Berbasis State Lokal**: Komponen habit air minum harian di dashboard saat ini diimplementasikan menggunakan interaksi state lokal (non-persistent) untuk validasi responsivitas UI/UX, dengan target visual 8 gelas air (2000 ml) dan badge pencapaian target.
*   **Navigasi Multi-Tab Bersih**: Dasbor utama menggunakan bottom navigation bar 5-tab yang konsisten, mempertahankan status filter lokal pada masing-masing tab saat pengguna bernavigasi antar halaman.

---

## 4. Ringkasan Modul Proyek
| Modul / Fitur | Tujuan Utama | Status | Keterangan Implementasi |
| :--- | :--- | :--- | :--- |
| **Autentikasi** | Mengelola register, login, logout terintegrasi backend. | ✅ Selesai (Stabil) | Dilengkapi token session management, timeout 10 detik, dan custom error handling. |
| **Onboarding** | Mengisi data profil pengguna & target nutrisi. | ✅ Selesai (Stabil) | Sesi setup terbagi 3 langkah dengan logic upload avatar & update data parsial backend. |
| **Dashboard** | Menampilkan kalori, makro progres, warning, & water tracking. | ✅ Selesai (UI/UX & Logika) | Progres dihitung dinamis dari profil. Logika warning & water tracking aktif penuh secara visual. |
| **Meal Plan** | Melacak rencana makan harian & kalender mingguan. | ✅ Selesai (UI/UX) | Terdiri dari status kosong, status aktif (berdasarkan paket data dummy terintegrasi), filter tanggal, checklist meal, dan detail popup resep. |
| **Log Harian** | Pencatatan makan manual & barcode. | ✅ Selesai (UI/UX) | Mendukung toggle data kosong/terisi untuk development, form input manual lengkap, & simulasi scan barcode sinematik. |
| **Resep** | Katalog resep sehat & detail masakan. | ✅ Selesai (UI/UX) | Terdiri dari 10+ resepdummy sehat, search filter, checklist bahan, timeline memasak, & favoriting. |
| **Riwayat** | Melacak statistik & konsumsi historis. | ✅ Selesai (UI/UX) | Dilengkapi filter periode, custom bar chart, indicator pencapaian, dan detail riwayat tanggal terpilih. |
| **Profil & Edit** | Ringkasan akun, visualisasi BMI, edit data. | ✅ Selesai (UI & Logika) | Menampilkan profil dinamis dari backend, edit profile data diri terhubung API, live update avatar, & BMI Slider. |
