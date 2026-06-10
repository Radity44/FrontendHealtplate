# Backend API Mapping - HealthPlate

Dokumen ini mendokumentasikan pemetaan integrasi REST API backend yang telah diterapkan dalam kode aplikasi frontend **HealthPlate**.

---

## 1. Daftar Endpoint yang Terintegrasi

### **POST /auth/register**
*   **Method**: `POST`
*   **Headers**: `Content-Type: application/json`
*   **Body Request**:
    ```json
    {
      "name": "HealthPlate User",
      "email": "user@example.com",
      "password": "password123"
    }
    ```
*   **Respon Sukses (200 / 201)**: Mengembalikan profil user dan token sesi `access_token`.
*   **Screen Pengguna**: [register_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/register_screen.dart)
*   **Service Layer**: `AuthService.register()` di [auth_service.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/services/auth_service.dart)
*   **Status Implementasi**: **Selesai (Stabil)**

---

### **POST /auth/login**
*   **Method**: `POST`
*   **Headers**: `Content-Type: application/json`
*   **Body Request**:
    ```json
    {
      "email": "user@example.com",
      "password": "password123"
    }
    ```
*   **Respon Sukses (200)**: Mengembalikan user data dan `access_token` sesi.
*   **Screen Pengguna**: [login_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/login_screen.dart)
*   **Service Layer**: `AuthService.login()` di [auth_service.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/services/auth_service.dart)
*   **Status Implementasi**: **Selesai (Stabil)**

---

### **POST /auth/logout**
*   **Method**: `POST`
*   **Headers**:
    *   `Content-Type: application/json`
    *   `Authorization: Bearer <access_token>`
*   **Respon Sukses (200)**: Sesi dinonaktifkan di server.
*   **Screen Pengguna**: Dialog Konfirmasi Logout di [home_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/home_screen.dart) dan [profil_tab.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/profil_tab.dart)
*   **Service Layer**: `AuthService.logout()` di [auth_service.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/services/auth_service.dart)
*   **Status Implementasi**: **Selesai (Hibrida/Aman)**. Menjamin pembersihan preferensi lokal (`access_token` dan status `onboarding_completed` dihapus dari SharedPreferences) walaupun koneksi server bermasalah saat menekan tombol keluar.

---

### **GET /auth/me**
*   **Method**: `GET`
*   **Headers**:
    *   `Content-Type: application/json`
    *   `Authorization: Bearer <access_token>`
*   **Respon Sukses (200)**: Mengembalikan data profil pengguna lengkap (Nama, Email, Gender, Birth Date, Height, Weight, Avatar URL, target kalori, target makro nutrisi).
*   **Screen Pengguna**:
    *   Dasbor Utama [home_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/home_screen.dart)
    *   Tab Profil [profil_tab.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/profil_tab.dart)
    *   Form edit [edit_profil_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/edit_profil_screen.dart)
*   **Service Layer**: `ProfileService.fetchProfile()` di [profile_service.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/services/profile_service.dart)
*   **Status Implementasi**: **Selesai (Stabil)**

---

### **PUT /auth/me**
*   **Method**: `PUT`
*   **Headers**:
    *   `Content-Type: application/json`
    *   `Authorization: Bearer <access_token>`
*   **Pilihan Payload Body**:
    *   *Pembaruan Data Diri (Onboarding 2 & Edit Profil)*:
        ```json
        {
          "name": "Raditya Fansa",
          "gender": "Male",
          "birth_date": "2003-05-15",
          "height_cm": 172,
          "weight_kg": 68
        }
        ```
    *   *Pembaruan Target Nutrisi (Onboarding 3)*:
        ```json
        {
          "calories_kcal": 2200,
          "protein_g": 85,
          "carbohydrate_g": 280,
          "fat_g": 75,
          "sugar_g": 45
        }
        ```
*   **Respon Sukses (200)**: Mengembalikan profil pengguna terbaru yang diperbarui.
*   **Screen Pengguna**:
    *   [personal_data_setup_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/personal_data_setup_screen.dart)
    *   [goals_setup_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/goals_setup_screen.dart)
    *   [edit_profil_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/edit_profil_screen.dart)
*   **Service Layer**: `ProfileService.updateProfile()` di [profile_service.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/services/profile_service.dart)
*   **Status Implementasi**: **Selesai (Dinamis/Parsial)**. Endpoint ini fleksibel menerima properti parsial apa pun untuk diperbarui di database backend.

---

### **POST /upload/avatar**
*   **Method**: `POST` (Multipart / Form-Data)
*   **Headers**:
    *   `Authorization: Bearer <access_token>`
*   **Multipart Files**: Key file bernama `'image'` berisikan data byte gambar dari berkas lokal.
*   **Respon Sukses (200)**: Mengembalikan URL avatar gambar baru (`avatar_url`) yang disimpan di storage server.
*   **Screen Pengguna**:
    *   [profile_pic_setup_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/profile_pic_setup_screen.dart) (Onboarding)
    *   [edit_profil_screen.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/screens/edit_profil_screen.dart) (Ganti avatar langsung)
*   **Service Layer**: `ProfileService.uploadAvatar()` di [profile_service.dart](file:///c:/Users/radit/Utama%201/UNEJ/Semester%204/PBM/frontendhealtplate/frontendhealtplate/lib/services/profile_service.dart)
*   **Status Implementasi**: **Selesai (Stabil)**

---

## 2. Rencana Pemetaan Endpoint Masa Depan (Sprint Berikutnya)

| Endpoint Tentatif | Method | Screen / Tab | Keterangan Target |
| :--- | :--- | :--- | :--- |
| `/logs/daily/:date` | `GET` | Dashboard & Log Harian | Mendapatkan asupan aktual kalori, makro, dan list menu makan pada hari tertentu. |
| `/logs/consume` | `POST` | Input Manual & Barcode | Menyimpan catatan porsi makanan/minuman yang dikonsumsi pengguna ke database. |
| `/logs/consume/:id` | `DELETE` | Log Harian | Menghapus log konsumsi tertentu dari history harian. |
| `/hydration/logs` | `POST`/`GET` | Dashboard (Water Tracking) | Menyimpan dan melacak jumlah gelas air yang dikonsumsi secara persisten. |
| `/meal-plans/active` | `GET` | Meal Plan Tab | Mengambil paket meal plan aktif yang diikuti pengguna saat ini. |
| `/meal-plans/select` | `POST` | Pemilihan Paket | Mengaktifkan paket meal plan pilihan pengguna di backend. |
| `/recipes` | `GET` | Daftar Resep | Mengambil seluruh katalog resep masakan sehat dari database. |
| `/recipes/:id/favorite` | `POST` | Detail & Daftar Resep | Men-toggle status favorit resep untuk disimpan di akun pengguna. |
| `/logs/statistics` | `GET` | Riwayat Tab | Mengambil data agregat konsumsi historis untuk membuat grafik mingguan/bulanan. |
