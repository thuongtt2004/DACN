-- Thêm cột phương thức thanh toán và ảnh chuyển khoản vào bảng orders
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_method ENUM('cod', 'bank_transfer') DEFAULT 'cod' AFTER total_amount,
ADD COLUMN IF NOT EXISTS payment_proof VARCHAR(255) DEFAULT NULL AFTER payment_method;

-- Tạo thư mục uploads nếu chưa có (chạy thủ công)
-- mkdir uploads/payment_proofs
