<?php

/**
 *
 * @author acnunez
 * @since 02.08.2017
 */
interface MenuEntityInterface {

    public function obtenerMenuUsuarioSistema($codUsuario);

    public function obtenerMenuUsuarioConfiguracion($codUsuario);
}