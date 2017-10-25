<?php
class BarraProgreso {

    public function mostrarBarraProgreso() {
        ?>
        <!DOCTYPE html>
        <html lang="es">
            <head>
                <title><?php echo $_SESSION['nombreEmpresa']; ?></title>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
            </head>
            <body onload="demo();">
                <form name="envio" id="envio" action="Get1.php" method="POST">
                    <input type="hidden" name="barra" id="barra" value="intermedio">
                    <div class="container">
                        <div class="progress">
                            <a id="progreso">
                                <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%">
                                    (Cargando) 0%
                                </div>
                            </a>
                        </div>
                    </div>
                </form>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
                <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

                <script type="text/javascript">
                        var tiempo = 1;
                        function avanzar() {
                            if (tiempo <= 5) {
                                document.getElementById("progreso").innerHTML = '<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:' + (tiempo * 20) + '%">(Cargando) ' + (tiempo * 20) + '%</div>';
                                tiempo++;
                                demo();
                            } else {
                                document.envio.submit();
                            }
                        }

                        function demo() {
                            setTimeout("avanzar()", 1000);
                        }

                </script> 
            </body>
        </html>
        <?php
    }
}
;
?>
