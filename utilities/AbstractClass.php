<?php

abstract class AbstractClass {
    static protected $NO_ERROR = '000';
    static protected $ERROR_NO_CONTROLADO = 'error';

    protected function _generarKeyboard() {
        $contador = 0;
        $rand = range(0,
                      9);
        shuffle($rand);

        $keyboard = "";

        $keyboard .= "";
        foreach ($rand as $val) {
            if ($contador % 3 == 0 && $contador <= 9) {
                
            }
            $contador++;
            if ($contador == 10) {
                
            }else {
                
            }
            $keyboard .= "<input type='button' class='btn btn-primary btn-md' onclick='escribir(" . $val . ");' value='" . $val . "'>";
            if ($contador % 3 == 0 && $contador <= 9 || $contador == 10) {
                
            }
        }
        $keyboard .= "<button type='button' class='btn btn-info  btn-md' onclick='escribir(-1);'>Limpiar</button>";

        return $keyboard;
    }

    protected function _validarSoloNumeros($cadena) {
        $permitidos = "0123456789";
        for ($i = 0; $i < strlen($cadena); $i++) {
            if (strpos($permitidos,
                       substr($cadena,
                              $i,
                              1)) === false) {
                return false;
            }
        }
        return true;
    }

    protected function _validarCaracteresEspeciales($cadena) {
        $permitidos = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for ($i = 0; $i < strlen($cadena); $i++) {
            if (strpos($permitidos,
                       substr($cadena,
                              $i,
                              1)) === false) {
                return false;
            }
        }
        return true;
    }
    
    
}
?>