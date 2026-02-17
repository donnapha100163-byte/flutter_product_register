<?php
include 'condb.php';

$result = $conn->query("SELECT * FROM users");

$users = array();

while($row = $result->fetch_assoc()){
    $users[] = $row;
}

echo json_encode($users);

$conn->close();
?>
