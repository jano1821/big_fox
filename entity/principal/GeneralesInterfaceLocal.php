<?php

/**
 *
 * @author acnunez
 * @since 04.07.2017
 */
interface GeneralesInterfaceLocal {

    public function GeneralesEntity($conexion);

    public function validarToken($token,$usuario);

    public function registrarToken($token,
                            $estadoRegistro,
                            $usuario,
                            $empresa);
    
    public function obtenerEmpresa($codEmpresa);
    
    public function registrarError();
}