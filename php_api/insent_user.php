<?php
include 'condb.php';

$name  = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];

$imageName = "";

if(isset($_FILES['image'])){
    $imageName = time() . "_" . $_FILES['image']['name'];
    $target = "../images/" . $imageName;
    move_uploaded_file($_FILES['image']['tmp_name'], $target);
}

$sql = "INSERT INTO users (name, email, phone, image)
        VALUES ('$name', '$email', '$phone', '$imageName')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status"=>"success"]);
} else {
    echo json_encode(["status"=>"error"]);
}

$conn->close();
?>
