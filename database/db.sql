-- Database
CREATE DATABASE IF NOT EXISTS example_api;
USE example_api;
-- Table
CREATE TABLE IF NOT EXISTS users (
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(30) NOT NULL,
	lastname VARCHAR(30) NOT NULL,
	email VARCHAR(50)
);
-- User
CREATE USER IF NOT EXISTS '{{username}}' @'%' IDENTIFIED WITH mysql_native_password BY '{{username}}';
GRANT ALL on users TO '{{username}}' @'%';
FLUSH PRIVILEGES;
