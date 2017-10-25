<?php
class FormLogin {

    public function mostrarFormLogin($keyboard,
                                     $indicadorCerrado) {
        ?>
        <!DOCTYPE html>
        <html>
            <head lang="en">
                <meta charset="UTF-8">
                <title>Validación</title>
                <script language='JavaScript' src='./js/design.js'></script> 
                <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
            </head>
            <body>
                <div class="container well">
                    <div class="row">
                        <div class="col-md-12">
                            <h3><p class="text-center">Validación de Credenciales</p></h3>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <form class="form-horizontal" id="formLogin" name="formLogin" autocomplete="off" action="./get/Get1.php" method="POST">
                            <div class="form-group">
                                <div class="col-md-5">
                                </div>
                                <div class="col-md-2">
                                    <input class="form-control" name="usuario" id="usuario" placeholder="Usuario" autocomplete=off maxlength="30">
                                </div>
                                <div class="col-md-5">
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-5">
                                </div>
                                <div class="col-md-2">
                                    <input class="form-control" type="password" placeholder="Password" name="pass" id="pass" autocomplete=off readonly maxlength="6">
                                </div>
                                <div class="col-md-5">
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-5">
                                </div>
                                <div class="col-md-2">
                                    <div class="row"> 
                                        <?php
                                        echo $keyboard;
                                        ?>
                                    </div>
                                </div>
                                <div class="col-md-5">
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-5">
                                </div>

                                <div class="col-md-2">
                                    <button type="button" class="form-control btn btn-default btn-success" onclick="escribir(10);">Ingresar</button>
                                </div>

                                <div class="col-md-5">
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="col-md-5">
                                </div>

                                <div class="col-md-2">
                                    <a href="javascript:olvido();" class="pull-right">Olvidé mi Password</a>
                                </div>

                                <div class="col-md-5">
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
                <script type="text/javascript">
                            function escribir(valor) {
                                var cantCaracteres;

                                if (valor === -1) {
                                    document.formLogin.pass.value = "";
                                } else if (valor === 10) {
                                    document.formLogin.submit();
                                } else {
                                    cantCaracteres = document.formLogin.pass.value.length;
                                    if (cantCaracteres < 6) {
                                        document.formLogin.pass.value = document.formLogin.pass.value + valor;
                                    }
                                }
                            }
                            
                            function olvido(){
                                document.formLogin.submit();
                            }
                </script>
            </body>
        </html>        
        <?php
    }
}
?>