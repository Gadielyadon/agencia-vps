-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 31-01-2026 a las 04:11:54
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ecommerce`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'PK categoría',
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre visible de la categoría',
  `slug` varchar(160) NOT NULL COMMENT 'Identificador URL/único',
  `descripcion` text DEFAULT NULL COMMENT 'Descripción opcional',
  `activo` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de activación',
  `descuento_pct` decimal(5,2) DEFAULT NULL COMMENT 'Porcentaje de descuento [0-100] a nivel categoría',
  `descuento_activo` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Si 1, aplica descuento_pct a los productos sin descuento propio',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha de creación',
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha de última actualización'
) ;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `nombre`, `slug`, `descripcion`, `activo`, `descuento_pct`, `descuento_activo`, `creado_en`, `actualizado_en`) VALUES
(1, 'Destacados', 'destacados', 'Categoría de ejemplo', 0, NULL, 0, '2026-01-12 22:40:40', '2026-01-19 15:19:47'),
(2, 'FORD', 'FO', 'Ropa para hombre', 1, NULL, 0, '2026-01-12 22:40:40', '2026-01-17 19:54:00'),
(3, 'MOTOS', 'MOTOSS', 'Ropa para mujer', 1, NULL, 0, '2026-01-12 22:40:40', '2026-01-17 19:54:14'),
(4, 'Niño', 'nino', 'Ropa para niños', 0, NULL, 0, '2026-01-12 22:40:40', '2026-01-17 19:55:05'),
(5, 'Niñas', 'ninas', 'Ropa para niñas', 0, NULL, 0, '2026-01-12 22:40:40', '2026-01-17 19:55:00'),
(6, 'CHEVROLET', 'CHE-VROLET ', '', 1, NULL, 0, '2026-01-12 22:40:40', '2026-01-17 19:52:06'),
(7, 'TOYOTA', 'TOYO', 'Accesorios para mujer', 1, NULL, 0, '2026-01-12 22:40:40', '2026-01-17 19:52:41'),
(11, 'VOLKSVAWEN', 'VOLK', '', 1, NULL, 0, '2026-01-16 20:12:43', '2026-01-17 19:53:15'),
(12, 'FIAT', 'FI', '', 1, NULL, 0, '2026-01-16 20:22:10', '2026-01-17 19:53:48'),
(16, 'pepe', 'e', 'ee', 0, NULL, 0, '2026-01-16 23:03:57', '2026-01-17 19:55:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'PK cliente',
  `nombre` varchar(100) NOT NULL COMMENT 'Nombre del cliente',
  `apellido` varchar(100) NOT NULL COMMENT 'Apellido del cliente',
  `correo` varchar(255) NOT NULL COMMENT 'Correo único',
  `telefono` varchar(30) DEFAULT NULL COMMENT 'Teléfono de contacto',
  `password_hash` varchar(255) DEFAULT NULL COMMENT 'Hash bcrypt de la contraseña',
  `rol` enum('cliente','admin') NOT NULL DEFAULT 'cliente' COMMENT 'Rol de usuario',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha de creación',
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha de última actualización'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Clientes; referenciada por ordenes.cliente_id';

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id`, `nombre`, `apellido`, `correo`, `telefono`, `password_hash`, `rol`, `creado_en`, `actualizado_en`) VALUES
(1, 'Admin', 'Principal', 'admin@modanova.local', NULL, '$2b$10$1KHs7KYtXLZPPVmES3/XrebpYpCWgY6C8etODTNxTOaQKR75yIIXe', 'admin', '2026-01-12 22:40:40', '2026-01-12 22:40:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `imagenes_productos`
--

CREATE TABLE `imagenes_productos` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'PK imagen de producto',
  `producto_id` bigint(20) UNSIGNED NOT NULL COMMENT 'FK a productos.id',
  `nombre_archivo` varchar(255) NOT NULL COMMENT 'Nombre de archivo original (sanitizado)',
  `tipo_mime` varchar(100) DEFAULT NULL COMMENT 'Tipo MIME detectado (p.ej. image/jpeg)',
  `tamano_bytes` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Tamaño del binario en bytes si aplica',
  `datos` longblob DEFAULT NULL COMMENT 'Contenido binario de la imagen (opcional si se usa url)',
  `url` varchar(1000) DEFAULT NULL COMMENT 'URL absoluta o relativa de la imagen (opcional si se usa datos)',
  `hash_sha256` char(64) DEFAULT NULL COMMENT 'Hash SHA-256 hex para deduplicación',
  `ancho` int(10) UNSIGNED DEFAULT NULL COMMENT 'Ancho en píxeles',
  `alto` int(10) UNSIGNED DEFAULT NULL COMMENT 'Alto en píxeles',
  `orden_visual` int(11) NOT NULL DEFAULT 0 COMMENT 'Orden sugerido de visualización',
  `es_principal` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indicador de imagen principal',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha de creación',
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha de última actualización',
  `principal_producto_id` bigint(20) UNSIGNED GENERATED ALWAYS AS (if(`es_principal`,`producto_id`,NULL)) STORED
) ;

--
-- Volcado de datos para la tabla `imagenes_productos`
--

INSERT INTO `imagenes_productos` (`id`, `producto_id`, `nombre_archivo`, `tipo_mime`, `tamano_bytes`, `datos`, `url`, `hash_sha256`, `ancho`, `alto`, `orden_visual`, `es_principal`, `creado_en`, `actualizado_en`) VALUES
(23, 25, '0001.url', NULL, NULL, NULL, '/images/1768690572273-972285438.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 19:56:12', '2026-01-17 19:56:12'),
(24, 26, '0002.url', NULL, NULL, NULL, '/images/1768690827368-468914495.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:00:27', '2026-01-17 20:00:27'),
(25, 27, '0003.url', NULL, NULL, NULL, '/images/1768690944068-433727972.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:02:24', '2026-01-17 20:02:24'),
(26, 28, '0004.url', NULL, NULL, NULL, '/images/1768691052963-150164031.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:04:12', '2026-01-17 20:04:12'),
(27, 29, '0005.url', NULL, NULL, NULL, '/images/1768691124754-58157954.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:05:24', '2026-01-17 20:05:24'),
(28, 30, '0006.url', NULL, NULL, NULL, '/images/1768691196660-657686055.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:06:36', '2026-01-17 20:06:36'),
(29, 31, '0007.url', NULL, NULL, NULL, '/images/1768691271840-374174473.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:07:51', '2026-01-17 20:07:51'),
(30, 32, '0008.url', NULL, NULL, NULL, '/images/1768691356799-501158770.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:09:16', '2026-01-17 20:09:16'),
(31, 33, '00010.url', NULL, NULL, NULL, '/images/1768691475599-267693711.jpg', NULL, NULL, NULL, 0, 1, '2026-01-17 20:11:15', '2026-01-17 20:11:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'PK producto',
  `sku` varchar(64) NOT NULL COMMENT 'Código único de inventario',
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre visible del producto',
  `descripcion` text DEFAULT NULL COMMENT 'Descripción del producto',
  `precio` decimal(12,2) NOT NULL COMMENT 'Precio unitario',
  `moneda` char(3) NOT NULL DEFAULT 'COP' COMMENT 'Código ISO 4217, por defecto COP',
  `existencias` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Unidades disponibles',
  `activo` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Indicador de activación',
  `descuento_pct` decimal(5,2) DEFAULT NULL COMMENT 'Porcentaje de descuento [0-100] a nivel producto',
  `descuento_activo` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Si 1, aplica descuento_pct del producto',
  `categoria_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'FK a categorias.id (opcional)',
  `creado_en` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha de creación',
  `actualizado_en` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha de última actualización'
) ;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `sku`, `nombre`, `descripcion`, `precio`, `moneda`, `existencias`, `activo`, `descuento_pct`, `descuento_activo`, `categoria_id`, `creado_en`, `actualizado_en`) VALUES
(25, '0001', 'VW FOX COMFORTLINE 1.6 3 PUERTA', 'MODELO 2013/ 146.000 KM', 12500000.00, 'COP', 0, 1, NULL, 0, 11, '2026-01-17 19:56:12', '2026-01-17 19:56:12'),
(26, '0002', 'FORD FIESTA SE  5 PUERTA', 'MODELO 2014 / 129.000 KM', 15000000.00, 'COP', 0, 1, NULL, 0, 2, '2026-01-17 20:00:27', '2026-01-17 20:00:27'),
(27, '0003', 'VW SURAN HIGHLINE 1.6', 'MODELO 2018 / 103.000 KM ', 18600000.00, 'COP', 0, 1, NULL, 0, 11, '2026-01-17 20:02:24', '2026-01-17 20:02:24'),
(28, '0004', ' FIAT PALIO  ESSENCE 1.6 5 PUERTA', 'MODELO 2014 / 98.000 KM', 14500000.00, 'COP', 0, 1, NULL, 0, 12, '2026-01-17 20:04:12', '2026-01-19 15:42:31'),
(29, '0005', 'CHEVROLET AGILE 1.4 LT ', 'MODELO 2014 / 107.000 KM ', 12800000.00, 'COP', 0, 1, NULL, 0, 6, '2026-01-17 20:05:24', '2026-01-17 20:05:24'),
(30, '0006', 'TOYOTA C-HR HYBRIDO 1.8 ', 'MODELO 2020 / 128.000', 44000000.00, 'COP', 0, 1, NULL, 0, 7, '2026-01-17 20:06:36', '2026-01-17 20:06:36'),
(31, '0007', 'TOYOTA COROLLA 1.8 XEI CVT', 'MODELO 2017 / 84.000 KM', 26000000.00, 'COP', 0, 1, NULL, 0, 7, '2026-01-17 20:07:51', '2026-01-17 20:07:51'),
(32, '0008', 'CHEVROLET PRISMA LT ', 'MODELO 2015 / 220.000 KM', 12000000.00, 'COP', 0, 1, NULL, 0, 6, '2026-01-17 20:09:16', '2026-01-17 20:09:16'),
(33, '00010', 'VW SAVEIRO 1.6 C/ EXTENDIDA HINGLINE', 'MODELO 2014 / 116.000 KM ', 17000000.00, 'COP', 0, 1, NULL, 0, NULL, '2026-01-17 20:11:15', '2026-01-17 20:11:15');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_categorias_slug` (`slug`),
  ADD KEY `idx_categorias_nombre` (`nombre`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_clientes_correo` (`correo`);

--
-- Indices de la tabla `imagenes_productos`
--
ALTER TABLE `imagenes_productos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_imagenes_productos_principal` (`principal_producto_id`),
  ADD KEY `idx_imagenes_productos_producto_id` (`producto_id`),
  ADD KEY `idx_imagenes_productos_hash` (`hash_sha256`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_productos_sku` (`sku`),
  ADD KEY `idx_productos_nombre` (`nombre`),
  ADD KEY `idx_productos_categoria` (`categoria_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'PK categoría';

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'PK cliente', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `imagenes_productos`
--
ALTER TABLE `imagenes_productos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'PK imagen de producto';

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'PK producto';

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `imagenes_productos`
--
ALTER TABLE `imagenes_productos`
  ADD CONSTRAINT `fk_imagenes_productos_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `fk_productos_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
