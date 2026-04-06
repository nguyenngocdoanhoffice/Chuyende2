CREATE DATABASE IF NOT EXISTS my_app_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE my_app_db;

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'user') NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS products (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  image_url TEXT NOT NULL,
  on_sale TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS coupons (
  id VARCHAR(36) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  percent DECIMAL(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  customer_name VARCHAR(255) NOT NULL,
  customer_phone VARCHAR(50) NOT NULL,
  customer_address TEXT NOT NULL,
  created_at DATETIME NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  discount_percent DECIMAL(5,2) NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  status ENUM('processing', 'delivered') NOT NULL DEFAULT 'processing',
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_items (
  id VARCHAR(36) PRIMARY KEY,
  order_id VARCHAR(36) NOT NULL,
  product_id VARCHAR(36) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  product_category VARCHAR(100) NOT NULL,
  product_description TEXT NOT NULL,
  product_price DECIMAL(12,2) NOT NULL,
  product_image_url TEXT NOT NULL,
  product_on_sale TINYINT(1) NOT NULL DEFAULT 0,
  ram VARCHAR(20) NOT NULL,
  storage VARCHAR(20) NOT NULL,
  quantity INT NOT NULL,
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO users (id, name, email, password, role)
VALUES ('admin-1', 'Administrator', 'admin@gmail.com', '123456', 'admin');

INSERT IGNORE INTO coupons (id, code, percent)
VALUES ('cp-1', 'SALE10', 10.0);

INSERT IGNORE INTO products (id, name, category, description, price, image_url, on_sale)
VALUES
('p1', 'Phone A1', 'Điện thoại', 'Smartphone nhẹ, pin tốt, màn hình sắc nét.', 799.00, 'https://images.unsplash.com/photo-1510557880182-3b5f8a5a6b6f?w=800', 1),
('p2', 'Laptop Pro 14', 'Laptop', 'Laptop hiệu năng cao, phù hợp học tập và công việc.', 1499.00, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800', 0),
('p3', 'Wireless Headphones', 'Phụ kiện', 'Tai nghe không dây chống ồn, chất âm tốt.', 199.00, 'https://images.unsplash.com/photo-1518444020327-9c4c409e6d4f?w=800', 0),
('p4', 'Phone B2', 'Điện thoại', 'Điện thoại tầm trung, camera đẹp.', 599.00, 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=800', 0),
('p5', 'Gaming Laptop X', 'Laptop', 'Máy chơi game với GPU mạnh mẽ.', 1899.00, 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800', 1);
