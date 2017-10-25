<?php

/**
 * Esta entidad es para validar aspectos de seguridad y otros que necesite el sistema
 *
 * @author Alejandro
 * @since 1.0 - 02.07.2017
 */
if (file_exists('./entity/principal/GeneralesInterfaceLocal.php')) {
    include('./entity/principal/GeneralesInterfaceLocal.php');
}else {
    include('../entity/principal/GeneralesInterfaceLocal.php');
}
class GeneralesEntity implements GeneralesInterfaceLocal {
    private $conexion;

    public function GeneralesEntity($conexion) {
        $this->conexion = $conexion;
    }

    public function validarToken($token,
                                 $usuario) {
        $valorDevuelto = "";

        $consulta = "call prc_validar_token(?,?,@repuesta); ";

        $sentencia = mysqli_prepare($this->conexion,
                                    $consulta);
        if ($sentencia) {
            mysqli_stmt_bind_param($sentencia,
                                   'si',
                                   $token,
                                   $usuario);

            mysqli_stmt_execute($sentencia);

            $select = mysqli_query($this->conexion,
                                   'SELECT @repuesta');
            $result = mysqli_fetch_assoc($select);
            $valorDevuelto = $result['@repuesta'];

            mysqli_stmt_close($sentencia);
        }

        return $valorDevuelto;
    }

    public function registrarToken($usuarioGenerado,
                                   $estadoRegistro,
                                   $usuario,
                                   $empresa) {
        $modulo = "GeneralesEntity.registrarToken";

        $consulta = "call prc_registrar_token(?,?,?,?,@respuesta); ";
        try {
            $sentencia = mysqli_prepare($this->conexion,
                                        $consulta);
            if ($sentencia) {
                mysqli_stmt_bind_param($sentencia,
                                       'sssi',
                                       $usuarioGenerado,
                                       $estadoRegistro,
                                       $usuario,
                                       $empresa);

                mysqli_stmt_execute($sentencia);

                $select = mysqli_query($this->conexion,
                                       'SELECT @respuesta');
                $result = mysqli_fetch_assoc($select);
                $valorDevuelto = $result['@respuesta'];
                mysqli_stmt_close($sentencia);
            }
            return $valorDevuelto;
        }catch (Exception $e) {
            echo 'Excepción capturada: ', $e->getMessage();
            return '1';
        }
    }

    public function obtenerEmpresa($codEmpresa) {
        $modulo = "GeneralesEntity.obtenerEmpresa";
        $nombre = "";

        try {
            $consulta = "select nombre ";
            $consulta .= "from view_lista_empresa ";
            $consulta .= "where codigo =" . $codEmpresa . ";";

            $resultado = $this->conexion->query($consulta);

            while ($row = $resultado->fetch_assoc()) {
                $nombre = $row['nombre'];
            }

            return $nombre;
        }catch (Exception $e) {
            echo 'Excepción capturada: ', $e->getMessage();
            return '1';
        }
    }
    
    public function registrarError(){
        
    }
    
}