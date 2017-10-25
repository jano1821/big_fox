<?php

/**
 * @author acnunez
 * @since V1.0.0
 * @since 28.06.2017
 */
interface LoginInterfaceLocal {

    public function mostrarFormLogin();

    public function validarPassword($usuario, $password);
}
?>