<?php

/**
 *
 * @author acnunez
 * @since 05.07.2017
 */
interface LoginEntityInterfaceLocal {

    public function validarUsuarioPassword($usuario,
                            $token);

    public function registrarIntento($usuario,
                            $intento,
                            $codEmpresa);
}