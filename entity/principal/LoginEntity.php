<?php

include_once('../entity/principal/LoginEntityInterfaceLocal.php');
class LoginEntity implements LoginEntityInterfaceLocal {
    private $conexion;
    
    public function LoginEntity($conexion) {
        $this->conexion = $conexion;
    }

    public function validarUsuarioPassword($usuario,
                            $token) {
        $valorDevuelto = "";
        $codUsuario = 0;
        $password = "";
        $codEmpresa = 0;

        $consulta = "call prc_validar_usuario_password(?,?,@repuesta,@codUsuario,@password,@codEmpresa); ";

        $sentencia = mysqli_prepare($this->conexion,
                                $consulta);
        if ($sentencia) {
            mysqli_stmt_bind_param($sentencia,
                                    'ss',
                                    $usuario,
                                    $token);

            mysqli_stmt_execute($sentencia);

            $select = mysqli_query($this->conexion,
                                    'SELECT @repuesta, @codUsuario, @password, @codEmpresa');
            $result = mysqli_fetch_assoc($select);
            $valorDevuelto = $result['@repuesta'];
            $codUsuario = $result['@codUsuario'];
            $password = $result['@password'];
            $codEmpresa = $result['@codEmpresa'];

            include('../bean/BeanValidacionUsuario.php');
            $beanValidacionUsuario = new BeanValidacionUsuario;
            $beanValidacionUsuario->setCodEmpresa($codEmpresa);
            $beanValidacionUsuario->setCodUsuario($codUsuario);
            $beanValidacionUsuario->setPassword($password);
            $beanValidacionUsuario->setRespuesta($valorDevuelto);

            mysqli_stmt_close($sentencia);
        }

        return $beanValidacionUsuario;
    }
    
    public function registrarIntento($usuario,
                            $intento,
                            $codEmpresa) {
        $valorDevuelto = "";

        $consulta = "call prc_actualizar_intentos_usuario(?,?,?,@repuesta); ";

        $sentencia = mysqli_prepare($this->conexion,
                                $consulta);
        if ($sentencia) {
            mysqli_stmt_bind_param($sentencia,
                                    'iii',
                                    $usuario,
                                    $intento,
                                    $codEmpresa);

            mysqli_stmt_execute($sentencia);

            $select = mysqli_query($this->conexion,
                                    'SELECT @repuesta');
            $result = mysqli_fetch_assoc($select);
            $valorDevuelto = $result['@repuesta'];

            mysqli_stmt_close($sentencia);
        }

        return $valorDevuelto;
    }
}
?>