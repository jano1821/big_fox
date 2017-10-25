<?php
class MenuPrincipal {

    public function mostrarMenuPrincipal($arrayModulosDisponibles,
                                         $arrayMenuPrincipal) {
        ?>
        <html>
            <head lang="en">
                <meta charset="UTF-8">
                <title>Menú Principal</title>
                <script language='JavaScript' src='./js/design.js'></script> 
                <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
            </head>
            <body>
                <div class="container well">
                    <div class="row">
                        <div class="col-md-12">
                            <h3><p class="text-center">Menu Principal</p></h3>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <form class="form-horizontal" id="formLogin" name="formLogin" autocomplete="off" action="../get/Get2.php" method="POST">
                            <input type="hidden" id="param" name="param" value="S">
                            <h3><p class="text-center">Modulos</p></h3>
                            <?php
                            for ($i = 0; $i < count($arrayModulosDisponibles); $i++) {
                                $beanMenuUsuario = new BeanMenuUsuario;
                                $beanMenuUsuario = $arrayModulosDisponibles[$i];
                                ?>
                                <!DOCTYPE html>


                                <a href="<?php echo "javascript:enviar('".$beanMenuUsuario->getIdentificador()."')";?>" class="pull-right"><?php echo $beanMenuUsuario->getEtiqueta(); ?></a>


                                <?php
                            }
                            ?>
                            <h3><p class="text-center">Menu Configuracion</p></h3>
                            <?php
                            for ($i = 0; $i < count($arrayMenuPrincipal); $i++) {
                                $beanMenuConfiguracion = new BeanMenuConfiguracion;
                                $beanMenuConfiguracion = $arrayMenuPrincipal[$i];
                                if ($beanMenuConfiguracion->getTipo() == 'C') {//tipo configuracion
                                    ?>
                                    <a href="<?php echo "javascript:enviar('".$beanMenuConfiguracion->getIdentificador()."')";?>" class="pull-right"><?php echo $beanMenuConfiguracion->getEtiqueta(); ?></a>
                                    <br>
                                    <?php
                                }
                            }
                            ?>

                            <h3><p class="text-center">Menu de Contacto</p></h3>
                            <?php
                            for ($i = 0; $i < count($arrayMenuPrincipal); $i++) {
                                $beanMenuConfiguracion = new BeanMenuConfiguracion;
                                $beanMenuConfiguracion = $arrayMenuPrincipal[$i];
                                if ($beanMenuConfiguracion->getTipo() == 'T') {//tipo contacto
                                    ?>
                                    <a href="<?php echo "javascript:enviar('".$beanMenuConfiguracion->getIdentificador()."')";?>" class="pull-right"><?php echo $beanMenuConfiguracion->getEtiqueta(); ?></a>
                                    <br>
                                    <?php
                                }
                            }
                            ?>
                        </form>
                    </div>
                </div>
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
                <script type="text/javascript">
                    function enviar(menu) {
                        document.formLogin.param.value = menu;
                        document.formLogin.submit();
                    }
                </script>
            </body>
        </html> 
        <?php
    }
}
;
?>

