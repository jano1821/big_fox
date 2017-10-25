<?php

class BeanMenuUsuario {
    private $etiqueta;
    private $url;
    private $icono;
    private $usuario;
    private $identificador;

    function getEtiqueta() {
        return $this->etiqueta;
    }

    function getUrl() {
        return $this->url;
    }

    function getIcono() {
        return $this->icono;
    }

    function getUsuario() {
        return $this->usuario;
    }

    function setEtiqueta($etiqueta) {
        $this->etiqueta = $etiqueta;
    }

    function setUrl($url) {
        $this->url = $url;
    }

    function setIcono($icono) {
        $this->icono = $icono;
    }

    function setUsuario($usuario) {
        $this->usuario = $usuario;
    }

    function getIdentificador() {
        return $this->identificador;
    }

    function setIdentificador($identificador) {
        $this->identificador = $identificador;
    }
}
?>

