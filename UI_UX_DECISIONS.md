# UI/UX Decisions - HealthPlate

Dokumen ini mendokumentasikan keputusan antarmuka (*UI*) dan pengalaman pengguna (*UX*) yang telah disepakati dan diterapkan sepanjang pengembangan frontend **HealthPlate**. Keputusan ini diambil untuk menghadirkan nuansa aplikasi kesehatan premium, responsif, dan mudah digunakan.

---

## 1. Alur Masuk & Pendaftaran Pengguna (Autentikasi)
*   **Registrasi Minimalis**: 
    *   *Keputusan*: Pendaftaran awal hanya meminta **Email**, **Password**, dan **Konfirmasi Password**. Field *Nama Lengkap* dihilangkan dari halaman registrasi.
    *   *Alasan*: Meminimalkan friksi pengguna saat pertama kali membuat akun. Proses pengisian nama dipindahkan ke onboarding setelah akun berhasil dibuat.
*   **Logika Startup Routing**:
    *   *Keputusan*: Sistem startup di `main.dart` memeriksa token lokal. Jika ada token tetapi onboarding belum diselesaikan (`onboarding_completed == false`), aplikasi akan memaksa pengguna masuk kembali ke halaman onboarding awal, bukan dilempar ke Login/Register.
    *   *Alasan*: Menjaga kesinambungan alur setup agar pengguna tidak bingung atau memiliki profil kosong setelah register.

---

## 2. Alur Onboarding (Wizard 3 Langkah)
*   **Langkah Onboarding Terfragmentasi**:
    *   *Keputusan*: Proses setup profil dibagi menjadi 3 layar terpisah:
        1.  *Langkah 1*: Foto Profil (Opsional).
        2.  *Langkah 2*: Data Diri Dasar (Nama, Gender, Lahir, Tinggi, Berat).
        3.  *Langkah 3*: Target Batasan Nutrisi (Kalori, Karbohidrat, Protein, Lemak, Gula).
    *   *Alasan*: Mengurangi kelelahan kognitif pengguna (*cognitive load*) dibandingkan menampilkan seluruh isian dalam satu formulir panjang.
*   **Unggah Foto Profil Bersifat Opsional**:
    *   *Keputusan*: Pengguna dapat melewati langkah upload avatar dengan mengklik *"Lewati untuk Sekarang"*. Bila proses upload gambar asli gagal karena kendala server/jaringan, aplikasi menampilkan dialog modal *"Upload Foto Gagal"* yang menyediakan tombol **[Coba Lagi]** dan **[Lewati]**.
    *   *Alasan*: Kegagalan upload foto tidak boleh mengunci (*blocking*) pengguna dari menyelesaikan seluruh proses onboarding.

---

## 3. Dasbor Utama & Habit Tracking
*   **Visualisasi Progres Nutrisi Dinamis**:
    *   *Keputusan*: Dashboard menggunakan donut progress chart 75% terisi sebagai status kalori utama, serta progress bar berwarna berbeda untuk zat makro: Protein (Hijau Hutan), Lemak (Biru), Karbohidrat (Oranye), dan Gula (Merah).
    *   *Alasan*: Visualisasi berkode warna memudahkan pengguna membaca status gizi mereka secara cepat (*scannability*).
*   **Peringatan Konsumsi Berlebih (*Over-Consumption Warnings*)**:
    *   *Keputusan*: Menampilkan kartu warning berwarna merah premium (`#FEF2F2`) secara dinamis di bawah Nutrition Card apabila total asupan kalori/makro hari itu terdeteksi melampaui batas target harian pengguna.
    *   *Alasan*: Memberikan peringatan preventif langsung yang mencolok namun tetap elegan.
*   **Water Tracking (Pencatatan Air Minum)**:
    *   *Keputusan*: Menggunakan card visual air minum tepat di bawah Nutrition Card yang berisi 8 indikator lingkaran kecil (dots) yang beranimasi warna teal saat ditekan.
    *   *Alasan*: Menambahkan fitur habit tracking yang ringan dan interaktif secara lokal. Mengikuti aturan tap spesifik (ketuk index berikutnya untuk menambah progress, ketuk index aktif terakhir untuk mengurangi progress) serta menampilkan badge `🎉 Target Tercapai` secara kondisional.

---

## 4. Kalender & Jadwal Makan (Meal Plan)
*   **Kalender Horizontal Snapping**:
    *   *Keputusan*: Kalender mingguan (7 hari) pada layar Meal Plan menggunakan `PageView.builder` yang dapat digeser (swipe) langsung per minggu sekaligus dan melakukan snapping otomatis.
    *   *Alasan*: Mempermudah eksplorasi jadwal makan mingguan secara cepat tanpa memakan banyak tempat layar.
*   **Penandaan Tanggal Pilihan**:
    *   *Keputusan*:
        *   Hari Minggu dihiasi dengan teks berwarna merah.
        *   Tanggal terpilih menggunakan lingkaran latar belakang **biru solid** (`#0284C7`) dengan teks putih.
        *   Tanggal hari ini (Today) menggunakan lingkaran berbingkai **outline border biru** (`#0284C7`) ketika tidak terpilih, dan berubah menjadi biru solid saat terpilih.
    *   *Alasan*: Menghindari kebingungan visual antara hari ini dan hari yang sedang diinspeksi oleh pengguna.

---

## 5. Katalog & Visualisasi Detail
*   **Fallback Inisial Profil**:
    *   *Keputusan*: Menampilkan inisial huruf dari nama lengkap di dalam lingkaran berlatar mint sebagai avatar cadangan jika user tidak mengunggah foto.
    *   *Alasan*: Menghilangkan tampilan placeholder ikon default "orang" abu-abu yang terkesan murahan.
*   **Skor Kategori Riwayat**:
    *   *Keputusan*: Riwayat harian diklasifikasikan dengan badge warna status pencapaian target: **Hijau** (Tercapai), **Oranye** (Terlampaui/Over), dan **Merah** (Di Bawah Target).
    *   *Alasan*: Memberikan umpan balik psikologis visual yang kuat tentang kepatuhan diet harian pengguna.
*   **Dialog Konfirmasi Keluar (Logout) Beranimasi**:
    *   *Keputusan*: Tombol keluar memicu dialog konfirmasi yang muncul menggunakan animasi transisi zoom/scale yang halus.
    *   *Alasan*: Meningkatkan kualitas interaksi mikro (*micro-interactions*) agar selaras dengan nuansa aplikasi premium.
