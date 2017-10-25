<?php
class DB_mysql {
	/* variables de conexión */
	var $BaseDatos;
	var $Servidor;
	var $Usuario;
	var $Clave;

	/* identificador de conexión y consulta */
	var $Conexion_ID = 0;
	var $Error;

	/* Método Constructor: Cada vez que creemos una variable
	de esta clase, se ejecutará esta función */
	function DB_mysql() {
		$this->BaseDatos = "cchcorre_big_fox";
		$this->Servidor = "cchcorredores.com";
		$this->Usuario = "cchcorre";
		$this->Clave = "7un81uh4SD";
	}

	/*Conexión a la base de datos*/
	function conectar(){
		// Conectamos al servidor
		$this->Conexion_ID = mysqli_connect($this->Servidor, $this->Usuario, $this->Clave,$this->BaseDatos);
		if (!$this->Conexion_ID) {
			$this->Error = "Ha fallado la conexión.";
			return 0;
		}else{
			$this->Error = "Conexion Exitosa";
			mysqli_query($this->Conexion_ID,'SET CHARACTER SET utf8');
		}

		/* Si hemos tenido éxito conectando devuelve
		el identificador de la conexión, sino devuelve 0 */
		return $this->Conexion_ID;
	}
};
?>