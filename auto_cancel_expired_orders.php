<?php
/**
 * Script tự động hủy đơn hàng chuyển khoản quá hạn 24h
 * Chạy script này theo lịch (cron job) hoặc gọi từ các trang khác
 */

// Không require connect.php vì file gọi đã có rồi
// require_once 'config/connect.php';

// Kiểm tra xem có được gọi trực tiếp hay từ file khác
$is_direct_call = !isset($conn);

if ($is_direct_call) {
    require_once 'config/connect.php';
}

// Tìm các đơn hàng chờ thanh toán quá 24h
$sql = "SELECT order_id, full_name, created_at 
        FROM orders 
        WHERE order_status = 'Chờ thanh toán' 
        AND payment_method = 'bank_transfer'
        AND TIMESTAMPDIFF(HOUR, created_at, NOW()) >= 24";

$result = $conn->query($sql);

$cancelled_count = 0;

if ($result && $result->num_rows > 0) {
    while ($order = $result->fetch_assoc()) {
        $order_id = $order['order_id'];
        
        // Cập nhật trạng thái đơn hàng thành "Đã hủy"
        $cancel_note = "Tự động hủy: Quá thời gian thanh toán (24h)";
        $update_sql = "UPDATE orders 
                      SET order_status = 'Đã hủy', 
                          notes = CONCAT(COALESCE(notes, ''), '\n', ?) 
                      WHERE order_id = ?";
        
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param("si", $cancel_note, $order_id);
        
        if ($update_stmt->execute()) {
            $cancelled_count++;
            
            // Log (optional - có thể lưu vào bảng logs)
            error_log("Auto-cancelled order #$order_id - expired after 24h");
        }
        
        $update_stmt->close();
    }
}

// Chỉ echo JSON khi được gọi trực tiếp (qua API)
if ($is_direct_call) {
    header('Content-Type: application/json');
    if ($cancelled_count > 0) {
        echo json_encode([
            'success' => true,
            'message' => "Đã hủy $cancelled_count đơn hàng quá hạn",
            'cancelled_count' => $cancelled_count
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'message' => 'Không có đơn hàng nào quá hạn',
            'cancelled_count' => 0
        ]);
    }
    $conn->close();
}

// Khi được gọi từ file khác, không echo gì cả và không đóng connection
