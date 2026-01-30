-- ================================================================
-- Script de base de datos (ES) para un e-commerce - MySQL 8.0+
-- Base de datos: ecommerce
-- Tablas en español y moneda por defecto: COP
-- ================================================================

-- Guardar configuración actual de FOREIGN_KEY_CHECKS
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS=0;

SET NAMES utf8mb4;

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS ecommerce
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE ecommerce;

SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- ================================================================
-- Limpiar tablas existentes en orden inverso (primero las dependientes)
-- ================================================================
DROP TABLE IF EXISTS imagenes_productos;
DROP TABLE IF EXISTS items_orden;
DROP TABLE IF EXISTS ordenes;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

-- ================================================================
-- Tabla: categorias
-- Propósito: organización de productos y descuentos por categoría.
-- Referencias: padre de productos (productos.categoria_id).
-- ================================================================
CREATE TABLE categorias (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  slug VARCHAR(160) NOT NULL,
  descripcion TEXT,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  descuento_pct DECIMAL(5,2) DEFAULT NULL,
  descuento_activo TINYINT(1) NOT NULL DEFAULT 0,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_categorias_slug (slug),
  KEY idx_categorias_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================================
-- Tabla: clientes
-- Propósito: almacenar clientes.
-- Referencias: padre de ordenes (ordenes.cliente_id).
-- ================================================================
CREATE TABLE clientes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  correo VARCHAR(255) NOT NULL,
  telefono VARCHAR(30) DEFAULT NULL,
  password_hash VARCHAR(255) DEFAULT NULL,
  rol ENUM('cliente','admin') NOT NULL DEFAULT 'cliente',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_clientes_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================================
-- Tabla: productos
-- Propósito: catálogo de productos.
-- Referencias: padre de items_orden (items_orden.producto_id).
-- ================================================================
CREATE TABLE productos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(64) NOT NULL,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(12,2) NOT NULL,
  moneda CHAR(3) NOT NULL DEFAULT 'COP',
  existencias INT UNSIGNED NOT NULL DEFAULT 0,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  descuento_pct DECIMAL(5,2) DEFAULT NULL,
  descuento_activo TINYINT(1) NOT NULL DEFAULT 0,
  categoria_id BIGINT UNSIGNED DEFAULT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_productos_sku (sku),
  KEY idx_productos_nombre (nombre),
  KEY idx_productos_categoria (categoria_id),
  CONSTRAINT fk_productos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================================
-- Tabla: ordenes
-- Propósito: cabecera de pedido/orden.
-- Referencias: hija de clientes; padre de items_orden.
-- ================================================================
CREATE TABLE ordenes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id BIGINT UNSIGNED NOT NULL,
  estado ENUM('pendiente','pagada','enviada','entregada','cancelada','reembolsada') NOT NULL DEFAULT 'pendiente',
  total DECIMAL(12,2) NOT NULL DEFAULT 0,
  moneda CHAR(3) NOT NULL DEFAULT 'COP',
  realizada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ordenes_cliente_id (cliente_id),
  KEY idx_ordenes_estado_realizada (estado, realizada_en),
  CONSTRAINT fk_ordenes_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================================
-- Tabla: items_orden
-- Propósito: renglones de cada orden con cantidad y precio.
-- Referencias: puente entre ordenes y productos.
-- ================================================================
CREATE TABLE items_orden (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  orden_id BIGINT UNSIGNED NOT NULL,
  producto_id BIGINT UNSIGNED NOT NULL,
  sku VARCHAR(64) NOT NULL,
  nombre_producto VARCHAR(200) NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  cantidad INT UNSIGNED NOT NULL,
  total_renglon DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_items_orden_orden_id (orden_id),
  KEY idx_items_orden_producto_id (producto_id),
  CONSTRAINT fk_items_orden_orden FOREIGN KEY (orden_id) REFERENCES ordenes(id) ON DELETE CASCADE,
  CONSTRAINT fk_items_orden_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================================
-- Tabla: imagenes_productos
-- Propósito: almacenar imágenes asociadas a productos (BLOB o URL).
-- ================================================================
CREATE TABLE imagenes_productos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  producto_id BIGINT UNSIGNED NOT NULL,
  nombre_archivo VARCHAR(255) NOT NULL,
  tipo_mime VARCHAR(100) DEFAULT NULL,
  tamano_bytes BIGINT UNSIGNED DEFAULT NULL,
  datos LONGBLOB DEFAULT NULL,
  url VARCHAR(1000) DEFAULT NULL,
  hash_sha256 CHAR(64) DEFAULT NULL,
  ancho INT UNSIGNED DEFAULT NULL,
  alto INT UNSIGNED DEFAULT NULL,
  orden_visual INT NOT NULL DEFAULT 0,
  es_principal TINYINT(1) NOT NULL DEFAULT 0,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_imagenes_productos_producto_id (producto_id),
  KEY idx_imagenes_productos_hash (hash_sha256),
  CONSTRAINT fk_imagenes_productos_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================================
-- Vista: v_ordenes_con_totales
-- Propósito: calcular total real de cada orden
-- ================================================================
CREATE OR REPLACE VIEW v_ordenes_con_totales AS
SELECT
  o.id AS orden_id,
  o.cliente_id,
  o.estado,
  o.moneda,
  o.realizada_en,
  o.actualizada_en,
  COALESCE(SUM(io.total_renglon), 0) AS total_calculado
FROM ordenes o
LEFT JOIN items_orden io ON io.orden_id = o.id
GROUP BY o.id, o.cliente_id, o.estado, o.moneda, o.realizada_en, o.actualizada_en;

-- ================================================================
-- Datos iniciales
-- ================================================================

-- Categorías
INSERT INTO categorias (nombre, slug, descripcion, activo, descuento_pct, descuento_activo) VALUES
('Destacados', 'destacados', 'Categoría de ejemplo', 1, NULL, 0),
('Hombre', 'hombre', 'Ropa para hombre', 1, NULL, 0),
('Mujer', 'mujer', 'Ropa para mujer', 1, NULL, 0),
('Niño', 'nino', 'Ropa para niños', 1, NULL, 0),
('Niñas', 'ninas', 'Ropa para niñas', 1, NULL, 0),
('Accesorios Hombre', 'accesorios-hombre', 'Accesorios para hombre', 1, NULL, 0),
('Accesorios Mujer', 'accesorios-mujer', 'Accesorios para mujer', 1, NULL, 0);

-- Cliente admin
INSERT INTO clientes (nombre, apellido, correo, telefono, password_hash, rol) VALUES
('Admin', 'Principal', 'admin@modanova.local', NULL, '$2b$10$1KHs7KYtXLZPPVmES3/XrebpYpCWgY6C8etODTNxTOaQKR75yIIXe', 'admin');

-- Cliente demo
INSERT INTO clientes (nombre, apellido, correo, telefono) VALUES
('Cliente', 'Demo', 'cliente.demo@example.com', NULL);

-- Producto demo
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-ES-001', 'Producto Demo ES', 'Artículo de ejemplo en español', 19990, 'COP', 100, 1, 
  (SELECT id FROM categorias WHERE slug = 'destacados' LIMIT 1));

-- Productos Hombre
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-HOM-001', 'Camisa Formal Hombre', 'Camisa de manga larga en algodón 100%, ideal para ocasiones formales. Disponible en varios colores.', 89900, 'COP', 50, 1, (SELECT id FROM categorias WHERE slug = 'hombre' LIMIT 1)),
('SKU-HOM-002', 'Pantalón Jeans Clásico', 'Pantalón jeans de corte clásico, cómodo y resistente. Talla disponible desde 28 hasta 40.', 129900, 'COP', 75, 1, (SELECT id FROM categorias WHERE slug = 'hombre' LIMIT 1)),
('SKU-HOM-003', 'Chaqueta Deportiva', 'Chaqueta deportiva con capucha, perfecta para actividades al aire libre. Material transpirable.', 159900, 'COP', 40, 1, (SELECT id FROM categorias WHERE slug = 'hombre' LIMIT 1));

-- Productos Mujer
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-MUJ-001', 'Blusa Elegante', 'Blusa de corte elegante en poliéster y elastano. Perfecta para oficina o eventos casuales.', 79900, 'COP', 60, 1, (SELECT id FROM categorias WHERE slug = 'mujer' LIMIT 1)),
('SKU-MUJ-002', 'Vestido Casual', 'Vestido casual de algodón, cómodo y versátil. Ideal para el día a día. Disponible en varios estampados.', 119900, 'COP', 45, 1, (SELECT id FROM categorias WHERE slug = 'mujer' LIMIT 1)),
('SKU-MUJ-003', 'Pantalón Tiro Alto', 'Pantalón de tiro alto en tela elástica, cómodo y favorecedor. Perfecto para combinar con cualquier top.', 99900, 'COP', 55, 1, (SELECT id FROM categorias WHERE slug = 'mujer' LIMIT 1));

-- Productos Niño
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-NIN-001', 'Camiseta Estampada', 'Camiseta de algodón con estampados divertidos. Disponible en tallas desde 4 hasta 14 años.', 39900, 'COP', 80, 1, (SELECT id FROM categorias WHERE slug = 'nino' LIMIT 1)),
('SKU-NIN-002', 'Pantalón Corto Deportivo', 'Pantalón corto deportivo con cintura elástica. Ideal para jugar y hacer deporte.', 49900, 'COP', 70, 1, (SELECT id FROM categorias WHERE slug = 'nino' LIMIT 1)),
('SKU-NIN-003', 'Sudadera con Capucha', 'Sudadera cómoda con capucha y bolsillo delantero. Perfecta para días frescos.', 89900, 'COP', 50, 1, (SELECT id FROM categorias WHERE slug = 'nino' LIMIT 1));

-- Productos Niñas
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-NIA-001', 'Vestido Floral', 'Vestido con estampado floral, suave y cómodo. Perfecto para ocasiones especiales. Tallas 4-14 años.', 79900, 'COP', 65, 1, (SELECT id FROM categorias WHERE slug = 'ninas' LIMIT 1)),
('SKU-NIA-002', 'Falda Plisada', 'Falda plisada en colores vibrantes, ideal para el colegio o eventos casuales. Tallas disponibles.', 59900, 'COP', 55, 1, (SELECT id FROM categorias WHERE slug = 'ninas' LIMIT 1)),
('SKU-NIA-003', 'Blusa con Volantes', 'Blusa de algodón con detalles de volantes en los hombros. Diseño encantador y cómodo.', 69900, 'COP', 60, 1, (SELECT id FROM categorias WHERE slug = 'ninas' LIMIT 1));

-- Productos Accesorios Hombre
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-ACH-001', 'Cinturón de Cuero', 'Cinturón de cuero genuino con hebilla metálica. Disponible en varios colores y tallas.', 89900, 'COP', 100, 1, (SELECT id FROM categorias WHERE slug = 'accesorios-hombre' LIMIT 1)),
('SKU-ACH-002', 'Gorra Deportiva', 'Gorra ajustable con diseño moderno. Perfecta para proteger del sol durante actividades deportivas.', 49900, 'COP', 120, 1, (SELECT id FROM categorias WHERE slug = 'accesorios-hombre' LIMIT 1)),
('SKU-ACH-003', 'Billetera de Cuero', 'Billetera de cuero con múltiples compartimentos para tarjetas y billetes. Diseño elegante y funcional.', 129900, 'COP', 80, 1, (SELECT id FROM categorias WHERE slug = 'accesorios-hombre' LIMIT 1));

-- Productos Accesorios Mujer
INSERT INTO productos (sku, nombre, descripcion, precio, moneda, existencias, activo, categoria_id) VALUES
('SKU-ACM-001', 'Bolso Tote', 'Bolso tote espacioso en tela resistente. Perfecto para el día a día, con asas largas y bolsillo interior.', 149900, 'COP', 45, 1, (SELECT id FROM categorias WHERE slug = 'accesorios-mujer' LIMIT 1)),
('SKU-ACM-002', 'Collar de Perlas', 'Collar elegante con perlas naturales. Diseño clásico que complementa cualquier outfit formal o casual.', 199900, 'COP', 30, 1, (SELECT id FROM categorias WHERE slug = 'accesorios-mujer' LIMIT 1)),
('SKU-ACM-003', 'Gafas de Sol', 'Gafas de sol con protección UV400. Diseño moderno y elegante, disponibles en varios colores de montura.', 89900, 'COP', 60, 1, (SELECT id FROM categorias WHERE slug = 'accesorios-mujer' LIMIT 1));

-- Orden demo
INSERT INTO ordenes (cliente_id, estado, total, moneda) VALUES
(1, 'pendiente', 0, 'COP');

-- Items de orden demo
SET @orden_id = LAST_INSERT_ID();

INSERT INTO items_orden (orden_id, producto_id, sku, nombre_producto, precio_unitario, cantidad)
SELECT @orden_id, id, sku, nombre, precio, 2
FROM productos 
WHERE sku = 'SKU-ES-001'
LIMIT 1;

-- Actualizar total de la orden
UPDATE ordenes o
JOIN (
  SELECT orden_id, SUM(total_renglon) AS suma_total
  FROM items_orden
  WHERE orden_id = @orden_id
  GROUP BY orden_id
) x ON x.orden_id = o.id
SET o.total = x.suma_total
WHERE o.id = @orden_id;

-- Imagen para producto demo
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  'producto-demo-es.jpg',
  'image/jpeg',
  NULL,
  NULL,
  'https://www.planetkids.com.co/cdn/shop/products/21-03116-088-800-1.jpg?v=1631823859',
  NULL,
  600,
  400,
  0,
  1
FROM productos 
WHERE sku = 'SKU-ES-001'
LIMIT 1;

-- Imágenes para productos Hombre
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  CONCAT('hombre-', sku, '.jpg'),
  'image/jpeg',
  NULL,
  NULL,
  CASE sku
    WHEN 'SKU-HOM-001' THEN 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&h=800&fit=crop'
    WHEN 'SKU-HOM-002' THEN 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&h=800&fit=crop'
    WHEN 'SKU-HOM-003' THEN 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&h=800&fit=crop'
  END,
  NULL,
  600,
  800,
  0,
  1
FROM productos 
WHERE sku IN ('SKU-HOM-001', 'SKU-HOM-002', 'SKU-HOM-003');

-- Imágenes para productos Mujer
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  CONCAT('mujer-', sku, '.jpg'),
  'image/jpeg',
  NULL,
  NULL,
  CASE sku
    WHEN 'SKU-MUJ-001' THEN 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600&h=800&fit=crop'
    WHEN 'SKU-MUJ-002' THEN 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&h=800&fit=crop'
    WHEN 'SKU-MUJ-003' THEN 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=600&h=800&fit=crop'
  END,
  NULL,
  600,
  800,
  0,
  1
FROM productos 
WHERE sku IN ('SKU-MUJ-001', 'SKU-MUJ-002', 'SKU-MUJ-003');

-- Imágenes para productos Niño
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  CONCAT('nino-', sku, '.jpg'),
  'image/jpeg',
  NULL,
  NULL,
  CASE sku
    WHEN 'SKU-NIN-001' THEN 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=600&h=800&fit=crop'
    WHEN 'SKU-NIN-002' THEN 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=600&h=800&fit=crop'
    WHEN 'SKU-NIN-003' THEN 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=800&fit=crop'
  END,
  NULL,
  600,
  800,
  0,
  1
FROM productos 
WHERE sku IN ('SKU-NIN-001', 'SKU-NIN-002', 'SKU-NIN-003');

-- Imágenes para productos Niñas
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  CONCAT('ninas-', sku, '.jpg'),
  'image/jpeg',
  NULL,
  NULL,
  CASE sku
    WHEN 'SKU-NIA-001' THEN 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&h=800&fit=crop'
    WHEN 'SKU-NIA-002' THEN 'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=600&h=800&fit=crop'
    WHEN 'SKU-NIA-003' THEN 'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=600&h=800&fit=crop'
  END,
  NULL,
  600,
  800,
  0,
  1
FROM productos 
WHERE sku IN ('SKU-NIA-001', 'SKU-NIA-002', 'SKU-NIA-003');

-- Imágenes para accesorios Hombre
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  CONCAT('accesorios-hombre-', sku, '.jpg'),
  'image/jpeg',
  NULL,
  NULL,
  CASE sku
    WHEN 'SKU-ACH-001' THEN 'https://images.unsplash.com/photo-1624222247344-550fb60583fd?w=600&h=600&fit=crop'
    WHEN 'SKU-ACH-002' THEN 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=600&h=600&fit=crop'
    WHEN 'SKU-ACH-003' THEN 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600&h=600&fit=crop'
  END,
  NULL,
  600,
  600,
  0,
  1
FROM productos 
WHERE sku IN ('SKU-ACH-001', 'SKU-ACH-002', 'SKU-ACH-003');

-- Imágenes para accesorios Mujer
INSERT INTO imagenes_productos (producto_id, nombre_archivo, tipo_mime, tamano_bytes, datos, url, hash_sha256, ancho, alto, orden_visual, es_principal)
SELECT 
  id,
  CONCAT('accesorios-mujer-', sku, '.jpg'),
  'image/jpeg',
  NULL,
  NULL,
  CASE sku
    WHEN 'SKU-ACM-001' THEN 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=600&h=600&fit=crop'
    WHEN 'SKU-ACM-002' THEN 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600&h=600&fit=crop'
    WHEN 'SKU-ACM-003' THEN 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600&h=600&fit=crop'
  END,
  NULL,
  600,
  600,
  0,
  1
FROM productos 
WHERE sku IN ('SKU-ACM-001', 'SKU-ACM-002', 'SKU-ACM-003');

-- Restaurar configuración de FOREIGN_KEY_CHECKS
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

-- ================================================================
-- Script completado exitosamente
-- ================================================================