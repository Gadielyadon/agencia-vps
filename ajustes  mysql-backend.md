-- 1. Bajar la seguridad de contraseñas para que acepte 'password123'
SET GLOBAL validate_password.policy = LOW;
SET GLOBAL validate_password.check_user_name = OFF;
SET GLOBAL validate_password.length = 4;

-- 2. Limpiar rastros de intentos fallidos
DROP USER IF EXISTS 'gadiel'@'%';
DROP USER IF EXISTS 'gadiel'@'localhost';
DROP USER IF EXISTS 'gadiel'@'148.227.75.67';

-- 3. Crear el usuario universal con el plugin compatible para Node.js
CREATE USER 'gadiel'@'%' IDENTIFIED WITH mysql_native_password BY 'password123';

-- 4. Dar permisos sobre la base de datos
GRANT ALL PRIVILEGES ON ecommerce.* TO 'gadiel'@'%';

-- 5. Aplicar cambios y verificar
FLUSH PRIVILEGES;
SELECT user, host, plugin FROM mysql.user WHERE user = 'gadiel';















# Cambiar bind-address a 0.0.0.0 automáticamente
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciar el servicio para que surta efecto
sudo systemctl restart mysql

# Abrir el puerto en el firewall (por si acaso)
sudo ufw allow 3306/tcp