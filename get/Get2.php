<?php
session_start();
if (isset($_POST['param'])){
    include_once('../controller/principal/MenuController.php');
    $menuController = new MenuController;
    $menuController->enrutador($_POST['param']);
}
?>

