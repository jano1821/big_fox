<?php

session_start();

include_once('./controller/principal/LoginController.php');

$loginInterfaceLocal = new LoginController(true);
$loginInterfaceLocal->mostrarFormLogin();
?>