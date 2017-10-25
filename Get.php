<?php

session_start();
if (isset($_POST['fecha'])) {
    include('./controller/principal/LoginController.php');

    $loginInterfaceLocal = new LoginController(true);
    $loginInterfaceLocal->mostrarFormLogin();
}
?>

