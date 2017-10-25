<?php

include_once ('../controller/principal/MenuInterface.php');
include_once ('../controller/principal/ControlToken.php');
include_once ('../utilities/AbstractClass.php');
class MenuController extends AbstractClass implements MenuInterface {
    private $controlToken;

    public function MenuController() {
        $this->controlToken = new ControlToken;
    }

    public function MostrarMenuPrincipal() {
        if (isset($_SESSION['numberToken'])) {
            $respuestaValidacion = $this->controlToken->validarToken(base64_decode($_SESSION['numberToken']),
                                                                                   0);
        }else {
            $respuestaValidacion = false;
        }

        if ($respuestaValidacion) {
            $this->controlToken->registrarToken(base64_decode($_SESSION['numberToken']),
                                                              'R',
                                                              $_SESSION['codUsuario'],
                                                              $_SESSION['codigoEmpresa']);

            $array_menu = array();
            $array_menu_configuracion = array();

            include_once ('../entity/principal/MenuEntity.php');
            $menuEntity = new MenuEntity($this->controlToken->getConnection());
            $array_menu = $menuEntity->obtenerMenuUsuarioSistema($_SESSION['codUsuario']);

            $array_menu_configuracion = $menuEntity->obtenerMenuUsuarioConfiguracion($_SESSION['codUsuario']);

            $this->controlToken->cerrarConexion();

            include_once ('../view/principal/MenuPrincipal.php');
            $menuPrincipal = new MenuPrincipal;
            $menuPrincipal->mostrarMenuPrincipal($array_menu,
                                                 $array_menu_configuracion);
        }else {
            include_once('../errores/FormFinSession.php');

            $formFinSession = new FormFinSession();
            $formFinSession->mostrarFormFinSession();
        }
    }

    public function enrutador($identificador) {
        if (isset($_SESSION['numberToken'])) {
            $respuestaValidacion = $this->controlToken->validarToken(base64_decode($_SESSION['numberToken']),
                                                                                   0);
        }else {
            $respuestaValidacion = false;
        }

        if ($respuestaValidacion) {
            $this->controlToken->registrarToken(base64_decode($_SESSION['numberToken']),
                                                              'R',
                                                              $_SESSION['codUsuario'],
                                                              $_SESSION['codigoEmpresa']);
            
            if ($identificador == 'MEMOASIS'){
                include_once('../controller/mantenimiento/Empresacontroller.php');
                $empresaControllerInterface = new Empresacontroller;
                $empresaControllerInterface->mostrarTablaEmpresa('');
            }
        }else {
            include_once('../errores/FormFinSession.php');

            $formFinSession = new FormFinSession();
            $formFinSession->mostrarFormFinSession();
        }
    }
}
?>

