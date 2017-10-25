<?php

class ConectarBD {

    public function conectar() {
        if (file_exists('./inc/DB_mysql.php')) {
            include_once('./inc/DB_mysql.php');
        }else {
            include_once('../inc/DB_mysql.php');
        }
        $db_mysql = new DB_mysql;
        $conexion = $db_mysql->conectar();

        return $conexion;
    }
}
;
?>