<?php

include_once ('../entity/principal/MenuEntityInterface.php');
include_once ('../bean/BeanMenuUsuario.php');
include_once ('../bean/BeanMenuConfiguracion.php');
class MenuEntity implements MenuEntityInterface {
    private $conexion;

    public function MenuEntity($conexion) {
        $this->conexion = $conexion;
    }

    public function obtenerMenuUsuarioSistema($codUsuario) {
        $modulo = "MenuEntity.obtenerMenuUsuarioSistema";
        $array = array();
        try {

            $consulta = "SELECT etiqueta,url,icono, identificador ";
            $consulta .= "FROM view_lista_menu_principal ";
            $consulta .= "where usuario = " . $codUsuario . ";";

            $result = $this->conexion->query($consulta);
            if ($result) {
                while ($myrow = $result->fetch_assoc()) {
                    $beanMenuUsuario = new BeanMenuUsuario;
                    $beanMenuUsuario->setEtiqueta($myrow['etiqueta']);
                    $beanMenuUsuario->setIcono($myrow['icono']);
                    $beanMenuUsuario->setUrl($myrow['url']);
                    $beanMenuUsuario->setIdentificador($myrow['identificador']);
                    array_push($array,
                               $beanMenuUsuario);
                }
            }
            return $array;
        }catch (Exception $e) {
            echo 'Excepción capturada-' . $modulo . ': ', $e->getMessage();
            return '1';
        }
    }

    public function obtenerMenuUsuarioConfiguracion($codUsuario) {
        $modulo = "MenuEntity.obtenerMenuUsuarioConfiguracion";
        $array = array();
        try {

            $consulta = "SELECT etiqueta,url,icono, tipo ";
            $consulta .= "FROM view_lista_menu_configuracion ";
            $consulta .= "where usuario = " . $codUsuario . ";";

            $result = $this->conexion->query($consulta);
            if ($result) {
                while ($myrow = $result->fetch_assoc()) {
                    $beanMenuConfiguracion = new BeanMenuConfiguracion;
                    $beanMenuConfiguracion->setEtiqueta($myrow['etiqueta']);
                    $beanMenuConfiguracion->setIcono($myrow['icono']);
                    $beanMenuConfiguracion->setUrl($myrow['url']);
                    $beanMenuConfiguracion->setTipo($myrow['tipo']);
                    $beanMenuConfiguracion->setIdentificador($myrow['identificador']);
                    array_push($array,
                               $beanMenuConfiguracion);
                }
            }
            return $array;
        }catch (Exception $e) {
            echo 'Excepción capturada-' . $modulo . ': ', $e->getMessage();
            return '1';
        }
    }
}
?>