import '../database/database_helper.dart';

class SchemaRepository {
  Future<void> ensureCreated() async {
    await DatabaseHelper.createTable('users', const [
      'id INT AUTO_INCREMENT PRIMARY KEY',
      'full_name VARCHAR(120) NOT NULL',
      'username VARCHAR(80) NOT NULL UNIQUE',
      'phone VARCHAR(32) NOT NULL UNIQUE',
      'password_hash VARCHAR(128) NOT NULL',
      "role VARCHAR(20) NOT NULL DEFAULT 'customer'",
      'address VARCHAR(255) NULL',
      'is_active TINYINT(1) NOT NULL DEFAULT 1',
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP',
    ]);
    await DatabaseHelper.createTable('gas_cylinders', const [
      'id INT AUTO_INCREMENT PRIMARY KEY',
      'name VARCHAR(120) NOT NULL',
      'size_kg INT NOT NULL',
      'price DECIMAL(10,2) NOT NULL',
      'stock INT NOT NULL DEFAULT 0',
      "color_hex VARCHAR(16) NOT NULL DEFAULT '#ff4b14'",
      'description TEXT NULL',
      'image_url VARCHAR(500) NULL',
      'is_active TINYINT(1) NOT NULL DEFAULT 1',
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP',
    ]);
    await DatabaseHelper.createTable('orders', const [
      'id INT AUTO_INCREMENT PRIMARY KEY',
      'order_code VARCHAR(40) NOT NULL',
      'customer_id INT NOT NULL',
      'driver_id INT NULL',
      'cylinder_id INT NOT NULL',
      'quantity INT NOT NULL DEFAULT 1',
      'delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 2.00',
      'total DECIMAL(10,2) NOT NULL',
      "status VARCHAR(32) NOT NULL DEFAULT 'placed'",
      'delivery_address VARCHAR(255) NULL',
      'payment_method VARCHAR(80) NULL',
      "payment_status VARCHAR(24) NOT NULL DEFAULT 'pending'",
      'payment_reference VARCHAR(80) NULL',
      'payment_account VARCHAR(80) NULL',
      'payment_last4 VARCHAR(4) NULL',
      'payment_paid_at DATETIME NULL',
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP',
    ]);
    await DatabaseHelper.createTable('notifications', const [
      'id INT AUTO_INCREMENT PRIMARY KEY',
      'user_id INT NOT NULL',
      'order_id INT NULL',
      'title VARCHAR(120) NOT NULL',
      'message VARCHAR(255) NOT NULL',
      'is_read TINYINT(1) NOT NULL DEFAULT 0',
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP',
    ]);

    await DatabaseHelper.updateTableRow(
      'ALTER TABLE gas_cylinders ADD COLUMN IF NOT EXISTS image_url VARCHAR(500) NULL',
    );

    for (final column in const [
      "ADD COLUMN IF NOT EXISTS payment_status VARCHAR(24) NOT NULL DEFAULT 'pending'",
      'ADD COLUMN IF NOT EXISTS payment_reference VARCHAR(80) NULL',
      'ADD COLUMN IF NOT EXISTS payment_account VARCHAR(80) NULL',
      'ADD COLUMN IF NOT EXISTS payment_last4 VARCHAR(4) NULL',
      'ADD COLUMN IF NOT EXISTS payment_paid_at DATETIME NULL',
    ]) {
      await DatabaseHelper.updateTableRow('ALTER TABLE orders $column');
    }
  }
}
