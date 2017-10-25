<?php

session_start();
if (isset($_POST['pass'])) {
    include('../controller/principal/LoginController.php');

    $loginInterfaceLocal = new LoginController(true);
    $loginInterfaceLocal->validarPassword($_POST['usuario'],
                                          $_POST['pass']);
}

if (isset($_POST['barra'])) {
    include('../controller/principal/MenuController.php');

    $menuInterfaceLocal = new MenuController();
    $menuInterfaceLocal->MostrarMenuPrincipal();
}
?>
