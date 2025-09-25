-- app/mysql.sql
CREATE DATABASE IF NOT EXISTS employees;
USE employees;

CREATE TABLE IF NOT EXISTS staff (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  role VARCHAR(100)
);

INSERT INTO staff (name, role) VALUES ('Alice','Dev'),('Bob','Ops');

