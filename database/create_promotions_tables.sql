-- Bảng promotions: Lưu các chương trình khuyến mãi
CREATE TABLE IF NOT EXISTS promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_code VARCHAR(50) UNIQUE NOT NULL,
    promotion_name VARCHAR(255) NOT NULL,
    promotion_type ENUM('product', 'category', 'flash_sale', 'coupon', 'minimum_order') NOT NULL,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    max_discount DECIMAL(10,2) DEFAULT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    usage_limit INT DEFAULT NULL,
    used_count INT DEFAULT 0,
    status ENUM('active', 'inactive', 'expired') DEFAULT 'active',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (promotion_code),
    INDEX idx_type (promotion_type),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng promotion_products: Liên kết khuyến mãi với sản phẩm cụ thể
CREATE TABLE IF NOT EXISTS promotion_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    UNIQUE KEY unique_promo_product (promotion_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng promotion_categories: Liên kết khuyến mãi với danh mục
CREATE TABLE IF NOT EXISTS promotion_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    UNIQUE KEY unique_promo_category (promotion_id, category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng promotion_usage: Theo dõi việc sử dụng mã giảm giá
CREATE TABLE IF NOT EXISTS promotion_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
