<?php

if (file_exists('./controller/principal/ControlToken.php')) {
    include_once('./controller/principal/ControlToken.php');
}else {
    include_once('../controller/principal/ControlToken.php');
}

if (file_exists('./controller/principal/LoginInterfaceLocal.php')) {
    include_once('./controller/principal/LoginInterfaceLocal.php');
}else {
    include_once('../controller/principal/LoginInterfaceLocal.php');
}

if (file_exists('./utilities/AbstractClass.php')) {
    include_once('./utilities/AbstractClass.php');
}else {
    include_once('../utilities/AbstractClass.php');
}
class LoginController extends AbstractClass implements LoginInterfaceLocal {
    private $controlToken;

    public function LoginController($conecta) {
        if ($conecta) {
            $this->controlToken = new ControlToken;
        }
    }

    public function validarPassword($usuario,
                                    $password) {

        $respuesta = parent::$NO_ERROR;

        $usuario = strtoupper($usuario);

        if (strlen($usuario) > 200) {
            $respuesta = parent::$ERROR_NO_CONTROLADO;
        }

        if (strlen($password) > 6 || strlen($password) < 6) {
            $respuesta = parent::$ERROR_NO_CONTROLADO;
        }

        if (!parent::_validarCaracteresEspeciales($usuario)) {
            $respuesta = parent::$ERROR_NO_CONTROLADO;
        }

        if (!parent::_validarSoloNumeros($password)) {
            $respuesta = parent::$ERROR_NO_CONTROLADO;
        }

        include_once('../entity/principal/LoginEntity.php');
        $loginEntity = new LoginEntity($this->controlToken->getConnection());
        $beanValidacionUsuario = $loginEntity->validarUsuarioPassword($usuario,
                                                                      base64_decode($_SESSION['numberToken']));

        include_once('../entity/principal/GeneralesEntity.php');
        $generalesInterfaceLocal = new GeneralesEntity($this->controlToken->getConnection());

        if ($beanValidacionUsuario->getRespuesta() == parent::$NO_ERROR) {
            if (password_verify($password,
                                $beanValidacionUsuario->getPassword())) {
                //Aqui se esta anulando el token que se uso para la validacion de usuario,
                //estos token solo tendran una vigencia de 5 min, sin posibilidad de refrescar su estado por actividad
                $respuesta = $this->controlToken->registrarToken(base64_decode($_SESSION['numberToken']),
                                                                               'N',
                                                                               $beanValidacionUsuario->getCodUsuario(),
                                                                               $beanValidacionUsuario->getCodEmpresa());

                $_SESSION['codigoEmpresa'] = $beanValidacionUsuario->getCodEmpresa();
                $_SESSION['nombreEmpresa'] = $generalesInterfaceLocal->obtenerEmpresa($beanValidacionUsuario->getCodEmpresa());
                $_SESSION['codUsuario'] = $beanValidacionUsuario->getCodUsuario();
                $_SESSION['usuario'] = $usuario;

                if ($respuesta === parent::$NO_ERROR) {
                    $usuarioGenerado = $this->controlToken->generarKey(false,
                                                                       $usuario);
                    //Aqui se está generando un nuevo token que le servirá para validar sus transaccion dentro del sistema.
                    $token = '';
                    $token = $this->controlToken->registrarToken($usuarioGenerado,
                                                                 'S',
                                                                 $beanValidacionUsuario->getCodUsuario(),
                                                                 $beanValidacionUsuario->getCodEmpresa());
                    //$token = $generalesInterfaceLocal->registrarToken();

                    if ($token != parent::$ERROR_NO_CONTROLADO) {
                        $_SESSION['numberToken'] = base64_encode($token);

                        $loginEntity->registrarIntento($beanValidacionUsuario->getCodUsuario(),
                                                       0,
                                                       $beanValidacionUsuario->getCodEmpresa());
                    }else {
                        $respuesta = parent::$ERROR_NO_CONTROLADO;
                    }
                }else {
                    $respuesta = parent::$ERROR_NO_CONTROLADO;
                }
            }else {
                $this->controlToken->registrarToken(base64_decode($_SESSION['numberToken']),
                                                                  'N',
                                                                  $beanValidacionUsuario->getCodUsuario(),
                                                                  $beanValidacionUsuario->getCodEmpresa());

                $loginEntity->registrarIntento($beanValidacionUsuario->getCodUsuario(),
                                               1,
                                               $beanValidacionUsuario->getCodEmpresa());

                $respuesta = parent::$ERROR_NO_CONTROLADO;
            }
        }else {
            $this->controlToken->registrarToken(base64_decode($_SESSION['numberToken']),
                                                              'N',
                                                              0,
                                                              0);
            $respuesta = parent::$ERROR_NO_CONTROLADO;
        }

        $this->controlToken->cerrarConexion();

        if ($respuesta == parent::$ERROR_NO_CONTROLADO) {
            if (file_exists('./errores/FormErrorLogueo.php')) {
                include_once('./errores/FormErrorLogueo.php');
            }else {
                include_once('../errores/FormErrorLogueo.php');
            }

            $formErrorLogueo = new FormErrorLogueo;
            $formErrorLogueo->mostrarFormErrorLogueo();
        }else {
            if (file_exists('./view/principal/BarraProgreso.php')) {
                include_once('./view/principal/BarraProgreso.php');
            }else {
                include_once('../view/principal/BarraProgreso.php');
            }
            $barraProgreso = new BarraProgreso;
            $barraProgreso->mostrarBarraProgreso();
        }
    }

    public function mostrarFormLogin() {
        $token = '0';

        if (isset($_SESSION['numberToken'])) {
            $respuestaValidacion = $this->controlToken->validarToken(base64_decode($_SESSION['numberToken']),
                                                                                   0);
        }else {
            $respuestaValidacion = false;
        }

        if (!$respuestaValidacion) {
            $usuarioGenerado = $this->controlToken->generarKey(true,
                                                               '');
            $token = $this->controlToken->registrarToken($usuarioGenerado,
                                                         'S',
                                                         0,
                                                         0);
        }

        $this->controlToken->cerrarConexion();

        if ($token != 'error') {
            if ($token != '0') {
                $_SESSION['numberToken'] = base64_encode($token);
            }

            if (file_exists('./view/principal/FormLogin.php')) {
                include_once('./view/principal/FormLogin.php');
            }else {
                include_once('../view/principal/FormLogin.php');
            }
            $formLogin = new FormLogin;
            $formLogin->mostrarFormLogin($this->_generarKeyboard(),
                                         'N');
        }else {
            header('http://localhost:81/big_fox');
        }
    }
}
?>