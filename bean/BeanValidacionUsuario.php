<?php

class BeanValidacionUsuario {
    private $respuesta;
    private $codUsuario;
    private $codEmpresa;
    private $password;

    function getRespuesta() {
        return $this->respuesta;
    }

    function getCodUsuario() {
        return $this->codUsuario;
    }

    function getCodEmpresa() {
        return $this->codEmpresa;
    }

    function getPassword() {
        return $this->password;
    }

    function setRespuesta($respuesta) {
        $this->respuesta = $respuesta;
    }

    function setCodUsuario($codUsuario) {
        $this->codUsuario = $codUsuario;
    }

    function setCodEmpresa($codEmpresa) {
        $this->codEmpresa = $codEmpresa;
    }

    function setPassword($password) {
        $this->password = $password;
    }
}
?>