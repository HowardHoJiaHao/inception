-- set root password, else initial is empty, anyone can access
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';

CREATE DATABASE IF NOT EXISTS ${DB_NAME};
DROP USER IF EXISTS ${DB_USER}@'%';
CREATE USER ${DB_USER}@'%' IDENTIFIED BY '${DB_PWD}';
GRANT ALL PRIVILEGES ON *.* TO ${DB_USER}@'%';

-- reloads immediately
FLUSH PRIVILEGES;