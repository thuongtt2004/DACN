<?php
require_once 'config/connect.php';

$promotion_id = $_GET['promotion_id'] ?? 0;

$query = $conn->prepare("SELECT product_id FROM promotion_products WHERE promotion_id = ?");
$query->bind_param("i", $promotion_id);
$query->execute();
$result = $query->query();

$product_ids = [];
while ($row = $result->fetch_assoc()) {
    $product_ids[] = $row['product_id'];
}

header('Content-Type: application/json');
echo json_encode($product_ids);

$query->close();
$conn->close();
?>
