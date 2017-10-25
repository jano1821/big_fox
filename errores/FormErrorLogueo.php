<?php
class FormErrorLogueo {

    public function mostrarFormErrorLogueo() {
        ?>
        <!DOCTYPE html>
        <html >
            <head>
                <meta charset="UTF-8">
                <title>OUTAFOX</title>
                <script language='JavaScript' src='./js/design.js'></script> 

            </head>
            <body>
                <form id="formLogin" name="formError" autocomplete="off" action="../Get.php" method="POST">
                    <input type="hidden" id="fecha" name="fecha" value="07/07/2017">
                    <label>Error de Validación de Credenciales</label>
                    <input type="button" name="enviarErrorLoguin" id="enviarErrorLoguin" onclick="cargar();" value="Volver a la Validación de Credenciales">
                </form>
                <script type="text/javascript">
                    function cargar() {
                        document.formError.submit();
                    }
                </script>
            </body>
        </html>
        <?php
    }
}
?>