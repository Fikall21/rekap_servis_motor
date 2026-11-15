const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Konfigurasi koneksi ke container MySQL
const dbConfig = {
  host: process.env.DB_HOST || 'mysql',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'rootpassword',
  database: process.env.DB_NAME || 'db_motocare',
};

let pool;

// Inisialisasi Database & Auto-Create Tabel
async function initDB() {
  let connected = false;
  while (!connected) {
    try {
      pool = mysql.createPool(dbConfig);
      await pool.query('SELECT 1');
      connected = true;
      console.log('Terhubung ke MySQL Docker!');

      // 1. Buat Tabel Users (Register & Login)
      await pool.query(`
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          nama VARCHAR(100) NOT NULL,
          email VARCHAR(100) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // 2. Buat Tabel Rekap Servis Motor (CRUD)
      await pool.query(`
        CREATE TABLE IF NOT EXISTS servis_motor (
          id INT AUTO_INCREMENT PRIMARY KEY,
          user_id INT NOT NULL,
          nama_motor VARCHAR(100) NOT NULL,
          plat_nomor VARCHAR(20) NOT NULL,
          jenis_servis VARCHAR(150) NOT NULL,
          biaya INT NOT NULL,
          tanggal_servis DATE NOT NULL,
          catatan TEXT,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      `);
      console.log('Tabel users & servis_motor siap digunakan!');
    } catch (err) {
      console.log('Menunggu MySQL siap... mencoba ulang dalam 3 detik');
      await new Promise((res) => setTimeout(res, 3000));
    }
  }
}

initDB();

// ============================================================================
// ENDPOINT AUTENTIKASI (REGISTER & LOGIN)
// ============================================================================

// 1. REGISTER USER BARU
app.post('/api/register', async (req, res) => {
  const { nama, email, password } = req.body;
  if (!nama || !email || !password) {
    return res.status(400).json({ status: 'error', message: 'Semua field wajib diisi!' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO users (nama, email, password) VALUES (?, ?, ?)',
      [nama, email, hashedPassword]
    );
    res.status(201).json({
      status: 'success',
      message: 'Registrasi berhasil!',
      data: { id: result.insertId, nama, email }
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ status: 'error', message: 'Email sudah terdaftar!' });
    }
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 2. LOGIN USER
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Email tidak ditemukan!' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ status: 'error', message: 'Password salah!' });
    }

    res.json({
      status: 'success',
      message: 'Login berhasil!',
      user: { id: user.id, nama: user.nama, email: user.email }
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// ============================================================================
// ENDPOINT CRUD REKAP SERVIS MOTOR
// ============================================================================

// 3. CREATE: Tambah Data Servis
app.post('/api/servis', async (req, res) => {
  const { user_id, nama_motor, plat_nomor, jenis_servis, biaya, tanggal_servis, catatan } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO servis_motor (user_id, nama_motor, plat_nomor, jenis_servis, biaya, tanggal_servis, catatan) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [user_id, nama_motor, plat_nomor, jenis_servis, biaya, tanggal_servis, catatan]
    );
    res.status(201).json({ status: 'success', message: 'Data servis ditambahkan', id: result.insertId });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 4. READ: Ambil Semua Data Servis per User
app.get('/api/servis/:user_id', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM servis_motor WHERE user_id = ? ORDER BY tanggal_servis DESC',
      [req.params.user_id]
    );
    res.json({ status: 'success', data: rows });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 5. UPDATE: Ubah Data Servis
app.put('/api/servis/:id', async (req, res) => {
  const { nama_motor, plat_nomor, jenis_servis, biaya, tanggal_servis, catatan } = req.body;
  try {
    await pool.query(
      'UPDATE servis_motor SET nama_motor=?, plat_nomor=?, jenis_servis=?, biaya=?, tanggal_servis=?, catatan=? WHERE id=?',
      [nama_motor, plat_nomor, jenis_servis, biaya, tanggal_servis, catatan, req.params.id]
    );
    res.json({ status: 'success', message: 'Data servis diperbarui' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 6. DELETE: Hapus Data Servis
app.delete('/api/servis/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM servis_motor WHERE id = ?', [req.params.id]);
    res.json({ status: 'success', message: 'Data servis dihapus' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.listen(3000, () => {
  console.log('Smart MotoCare API berjalan di http://localhost:3000');
});