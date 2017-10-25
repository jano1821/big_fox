<?php
if (file_exists('./utilities/AbstractSession.php')){
    include_once ('./utilities/AbstractSession.php');
}else{
    include_once ('../utilities/AbstractSession.php');
}
class ControlToken extends AbstractSession {
    public function ControlToken() {
        if (file_exists('./entity/principal/GeneralesEntity.php')) {
            include_once('./entity/principal/GeneralesEntity.php');
        }else {
            include_once('../entity/principal/GeneralesEntity.php');
        }
        
        parent::establishConnection();
    }

    public function generarKey($indicadorSinUsuario,
                               $usuario) {
        if ($indicadorSinUsuario) {
            $usuarioGenerado = 'usuarioTemporal' . rand(1,
                                                        9999);
        }else {
            $usuarioGenerado = $usuario . rand(1,
                                               9999);
        }

        return $usuarioGenerado;
    }

    public function validarToken($token,
                                 $codUsuario) {


        $generalesInterfaceLocal = new GeneralesEntity(parent::getConnection());
        $respuesta = $generalesInterfaceLocal->validarToken($token,
                                                            $codUsuario);

        if ($respuesta == 'S') {
            return true;
        }else {
            return false;
        }
    }

    public function registrarToken($usuarioGenerado,
                                   $estado,
                                   $usuario,
                                   $empresa) {

        $generalesInterfaceLocal = new GeneralesEntity(parent::getConnection());
        $respuesta = $generalesInterfaceLocal->registrarToken($usuarioGenerado,
                                                              $estado,
                                                              $usuario,
                                                              $empresa);

        return $respuesta;
    }
    
    public function getConnection(){
        return parent::getConnection();
    }
    
    public function cerrarConexion(){
        parent::cerrarConexion();
    }
}
;
?>