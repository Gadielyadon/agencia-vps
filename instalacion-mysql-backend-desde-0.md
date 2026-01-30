### Paso 1: Instalación de MySQL en el VPS
Primero instalamos el motor de la base de datos:

```bash
sudo apt update
sudo apt install mysql-server -y
# Iniciar y asegurar que arranque con el sistema
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Paso 2: Creación de la Estructura (Esquema)
Usamos tu script ecommerce_setup.sql para crear las tablas, el usuario admin y los productos de ejemplo.

```Bash
# Ejecutar el script SQL
sudo mysql < ecommerce_setup.sql
```

### Paso 3: Configuración de Acceso Remoto (Red)
Por defecto, MySQL solo habla con el mismo servidor. Tuvimos que abrirlo al mundo:

Editar el archivo de configuración: sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

Cambiar la línea: bind-address = 127.0.0.1 ➜ bind-address = 0.0.0.0

Reiniciar el servicio: sudo systemctl restart mysql

Abrir el puerto en el firewall del VPS: sudo ufw allow 3306/tcp

### 👤 Paso 4: Creación del Usuario Universal (gadiel)
Entramos a MySQL (sudo mysql) y ejecutamos el bloque maestro para saltar las restricciones de seguridad:

```bash

-- Bajamos la seguridad de contraseñas temporalmente
SET GLOBAL validate_password.policy = LOW;
SET GLOBAL validate_password.length = 4;

-- Creamos el usuario para cualquier IP (%) con el plugin compatible
CREATE USER 'gadiel'@'%' IDENTIFIED WITH mysql_native_password BY 'password123';

-- Damos permisos totales sobre tu tienda
GRANT ALL PRIVILEGES ON ecommerce.* TO 'gadiel'@'%';


-- Aplicamos cambios
FLUSH PRIVILEGES;
```

### 💻 Paso 5: Conexión desde el Backend (Node.js)
Finalmente, configuramos el archivo .env en tu proyecto para usar la IP pública de tu VPS:

Fragmento de código

DB_HOST=148.x.x.x  (La IP de tu servidor)
DB_USER=gadiel
DB_PASSWORD=password123
DB_NAME=ecommerce
Y en tu código db.js, el pool de conexiones utiliza estas variables:

JavaScript

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});
Resumen de Seguridad:
Usuario root: Solo se usa localmente en el VPS (por seguridad).

Usuario gadiel: Es tu llave para trabajar remotamente.

Base de datos: Se llama ecommerce.