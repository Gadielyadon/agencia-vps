#!/usr/bin/env node
// server.js
const path = require('path');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bcrypt = require('bcrypt');
const { getPool } = require('./db');
const multer = require('multer');
const fs = require('fs');

const isPkg = typeof process.pkg !== 'undefined';
const projectRoot = isPkg ? path.dirname(process.execPath) : path.join(__dirname, '..');

dotenv.config({ path: path.join(projectRoot, '.env') });

const app = express();

// ---- Configuración subida de imágenes ----
const publicDir = isPkg ? path.join(projectRoot, 'public') : path.join(__dirname, '..', 'public');
const imagesDir = path.join(publicDir, 'images');

if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, imagesDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    const name = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, name + ext);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      cb(new Error('Solo se permiten imágenes'));
    } else {
      cb(null, true);
    }
  }
});

// ---- Middlewares ----
app.use(cors());
app.use(express.json({ limit: '1mb' }));

// ---- Rutas API (SIN ÓRDENES NI CARRITO) ----
const productsRouter = require('./routes/products');
const authRouter = require('./routes/auth');
const categoriesRouter = require('./routes/categories');
const adminRouter = require('./routes/admin');

app.use('/api/productos', productsRouter);
app.use('/api/auth', authRouter);
app.use('/api/categorias', categoriesRouter);
app.use('/api/admin', adminRouter);

// ---- Subida de imágenes ----
app.post('/api/upload-imagen', (req, res) => {
  upload.single('imagen')(req, res, function (err) {
    if (err) {
      return res.status(500).json({ message: err.message });
    }
    if (!req.file) {
      return res.status(400).json({ message: 'No se subió ninguna imagen' });
    }
    res.json({ imagen_url: `/images/${req.file.filename}` });
  });
});

// ---- Usuario admin bootstrap ----
(async function ensureAdminUser() {
  try {
    const pool = getPool();
    const correo = 'admin@modanova.local';
    const [rows] = await pool.query(
      'SELECT id, password_hash, rol FROM clientes WHERE correo = ? LIMIT 1',
      [correo]
    );

    const needFix = !rows.length || rows[0].rol !== 'admin';

    if (needFix) {
      const hash = await bcrypt.hash('admin123', 10);
      if (rows.length) {
        await pool.query(
          'UPDATE clientes SET password_hash=?, rol="admin" WHERE id=?',
          [hash, rows[0].id]
        );
      } else {
        await pool.query(
          'INSERT INTO clientes (nombre, apellido, correo, password_hash, rol) VALUES (?,?,?,?,?)',
          ['Admin', 'Principal', correo, hash, 'admin']
        );
      }
      console.log('Admin listo: admin@modanova.local / admin123');
    }
  } catch (err) {
    console.warn('Admin bootstrap error:', err.message);
  }
})();

// ---- Archivos estáticos ----
const publicDirDev = path.join(__dirname, '..', 'public');
app.use(express.static(publicDirDev));

app.get('*', (_req, res) => {
  res.sendFile(path.join(publicDirDev, 'index.html'));
});

const PORT = Number(process.env.PORT || 3000);
app.listen(PORT, () => console.log(`Servidor iniciado en http://localhost:${PORT}`));




