# 🏍️ Smart MotoCare — Aplikasi Rekap Servis Motor

**Smart MotoCare** adalah aplikasi pencatatan riwayat perawatan dan servis motor berbasis **Flutter** yang terintegrasi dengan **Node.js (Express) REST API** dan database **MySQL** di dalam **Docker**. 

Aplikasi ini dirancang untuk memudahkan pemilik kendaraan menyimpan catatan servis rutin (tanggal, jenis perbaikan, biaya, dan catatan mekanik) secara terpusat dan *real-time* di berbagai perangkat.

---

## 👨‍💻 Identitas Pengembang
* **Nama:** Rafie Haikal Iskandar
* **NIM:** 240102103
* **Program Studi:** Teknik Informatika — Universitas Muhammadiyah Bandung
* **Mata Kuliah:** Pengantar Cloud Computing (UTS)

---

## ✨ Fitur Utama
* **Autentikasi Pengguna:** Registrasi akun baru dan Login dengan manajemen sesi lokal (`SharedPreferences`).
* **Manajemen Riwayat Servis (CRUD):** Tambah, lihat, ubah, dan hapus data servis motor secara langsung (*real-time* tanpa perlu *refresh* manual).
* **Deteksi Koneksi Otomatis:** Aplikasi otomatis menyesuaikan alamat server saat dijalankan di **Browser Laptop**, **Browser HP**, **HP Fisik (USB Debugging)**, maupun **Emulator Android** tanpa perlu mengubah kode.
* **Infrastruktur Terkontainerisasi:** Backend API, database MySQL, dan phpMyAdmin berjalan otomatis menggunakan satu perintah Docker Compose.

---

## 🛠️ Arsitektur & Daftar Port

Semua layanan backend sudah dibungkus dalam Docker sehingga tidak perlu instalasi manual MySQL atau Node.js di komputer penguji:

| Layanan | Nama Container | Port | Alamat Akses | Fungsi |
| :--- | :--- | :--- | :--- | :--- |
| **Backend REST API** | `motocare_api` | `3000` | `http://localhost:3000/api` | Server API penghubung Flutter & MySQL |
| **phpMyAdmin** | `motocare_phpmyadmin` | `8080` | `http://localhost:8080` | Antarmuka web untuk cek database `db_motocare` |
| **Database MySQL** | `motocare_mysql` | `3308` | `localhost:3308` | Penyimpanan tabel `users` dan `servis_motor` |

> **Kredensial Login phpMyAdmin:**
> * **Username:** `root`
> * **Password:** `rootpassword`
> * **Database:** `db_motocare`

---

## 🚀 Cara Menjalankan Proyek

### 1. Clone Repository
```bash
git clone [https://github.com/Fikall21/rekap_servis_motor.git](https://github.com/Fikall21/rekap_servis_motor.git)
cd rekap_servis_motor