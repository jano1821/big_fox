<?php

abstract class AbstractSession {
    private $conexion;

    protected function establishConnection() {
        if (file_exists('./inc/ConectarBD.php')) {
            include_once('./inc/ConectarBD.php');
        }else {
            include_once('../inc/ConectarBD.php');
        }
        $conectarBD = new ConectarBD;
        $conexion = $conectarBD->conectar();

        $this->conexion = $conexion;
    }

    protected function getConnection() {
        return $this->conexion;
    }

    protected function setConnection($conexion) {
        if ($conexion != null) {
            $this->conexion = $conexion;
        }
    }
    
    protected function cerrarConexion() {
        mysqli_close($this->conexion);
    }
}
?>

