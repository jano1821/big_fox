-- phpMyAdmin SQL Dump
-- version 4.7.3
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 25-10-2017 a las 16:41:07
-- Versión del servidor: 5.6.37
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `cchcorre_big_fox`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`cchcorre`@`localhost` PROCEDURE `prc_actualizar_estado_usuario` (IN `PI_usuario` INT, IN `PI_estadoRegistro` VARCHAR(1), IN `PI_empresa` INT, OUT `PO_error` VARCHAR(200))  BEGIN
	declare V_descripcionError varchar(500);
	DECLARE V_respuestaError varchar(200); 
	
	DECLARE exit handler for sqlexception
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_error = 'error';

        call prc_registrar_error(concat('Error de tipo exception al ',V_descripcionError),'prc_actualizar_estado_usuario',PI_usuario,V_respuestaError);
        
        COMMIT;
	END;
    
    DECLARE exit handler for sqlwarning
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_error = 'error';

        call prc_registrar_error(concat('Error de tipo sqlwarning al ',V_descripcionError),'prc_actualizar_estado_usuario',PI_usuario,V_respuestaError);
        
        COMMIT;
	END;
    
	set autocommit = 0;

    START TRANSACTION;


		set V_descripcionError='Actualizar estado de usuario';
        
		update usuario
           set estadoRegistro = PI_estadoRegistro,
               fechaModificacion=now(),
               usuarioModificacion=PI_usuario
         where codUsuario = PI_usuario;

		set PO_error = '000';
	
    COMMIT;
    
	set autocommit = 1;

END$$

CREATE DEFINER=`cchcorre`@`localhost` PROCEDURE `prc_actualizar_intentos_usuario` (IN `PI_usuario` INT, IN `PI_intentos` INT, IN `PI_empresa` INT, OUT `PO_error` VARCHAR(200))  BEGIN
	declare V_descripcionError varchar(500);
    declare V_intentos int;
    declare V_respuestaError varchar(200);

	DECLARE exit handler for sqlexception
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_error = 'error';

		call prc_registrar_error(concat('Error de tipo exception al ',V_descripcionError),'prc_actualizar_estado_usuario',PI_usuario,V_respuestaError);
        
        COMMIT;
	END;
    
    DECLARE exit handler for sqlwarning
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_error = 'error';

		call prc_registrar_error(concat('Error de tipo sqlwarning al ',V_descripcionError),'prc_actualizar_estado_usuario',PI_usuario,V_respuestaError);
        
        COMMIT;
	END;
	set autocommit = 0;

    START TRANSACTION;

		set V_descripcionError='Actualizar intentos de usuario';
        if PI_intentos = 0 then
        	update usuario
			   set cantidadIntentos = 0,
				   fechaModificacion=now(),
				   usuarioModificacion=PI_usuario
			 where codUsuario = PI_usuario;

        else
			set V_intentos = 0;            
            
            select cantidadIntentos 
              into V_intentos 
              from usuario
             where codUsuario = PI_usuario;
             
            if V_intentos <= 2 then
				update usuario
				   set cantidadIntentos = ifnull(cantidadIntentos,0) + 1,
					   fechaModificacion=now(),
					   usuarioModificacion=PI_usuario
				 where codUsuario = PI_usuario;
                 
                 select cantidadIntentos 
				   into V_intentos 
				   from usuario
				  where codUsuario = PI_usuario;
            end if;

            if V_intentos>=3 then
				call prc_actualizar_estado_usuario(PI_usuario,'B',PI_empresa,V_respuestaError);
            end if;
		end if;
        
		set PO_error = '000';
		
    COMMIT;
    
	set autocommit = 1;
END$$

CREATE DEFINER=`cchcorre`@`localhost` PROCEDURE `prc_registrar_error` (IN `PI_descrionError` VARCHAR(500), IN `PI_objetoOcurrencia` VARCHAR(200), IN `PI_usuario` INT, OUT `PO_error` VARCHAR(200))  BEGIN
	declare V_codUsuario int;

    SET autocommit = 0;
    START TRANSACTION;

	if PI_usuario = 0 then
		set V_codUsuario = null;
	else
		set V_codUsuario = PI_usuario;
	end if;

	insert into errores_sistema(descripcionError,claseError,fechaInsercion,codUsuario)
	values(PI_descrionError,PI_objetoOcurrencia,now(),V_codUsuario);

	set PO_error = '000';
	
    COMMIT;
    set autocommit = 1;
END$$

CREATE DEFINER=`cchcorre`@`localhost` PROCEDURE `prc_registrar_token` (IN `PI_usuarioGenerado` VARCHAR(200), IN `PI_estadoRegistro` VARCHAR(1), IN `PI_usuario` INT, IN `PI_empresa` INT, OUT `PO_error` VARCHAR(200))  BEGIN
	declare V_descripcionError varchar(200);
    declare V_ultimoRegistroToken int;
    declare V_token varchar(200);
    declare V_codUsuario int;
    declare V_respuestaError varchar(200);
    declare V_correlativo int;

	DECLARE exit handler for sqlexception
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_error = 'error';
        
        if PI_usuario = 0 then
			set V_codUsuario = null;
		else
			set V_codUsuario = PI_usuario;
        end if;
        
        call prc_registrar_error(concat('Error de tipo exception al ',V_descripcionError),'prc_registrar_token',V_codUsuario,V_respuestaError);
        
        COMMIT;
        set autocommit = 1;
	END;
    
    DECLARE exit handler for sqlwarning
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_error = 'error';
        
        if PI_usuario = 0 then
			set V_codUsuario = null;
		else
			set V_codUsuario = PI_usuario;
        end if;
        
        call prc_registrar_error(concat('Error de tipo sqlwarning al ',V_descripcionError),'prc_registrar_token',V_codUsuario,V_respuestaError);
        
        COMMIT;
        set autocommit = 1;
	END;
    set V_descripcionError='';
    
	set autocommit = 0;
    
    START TRANSACTION;

	if PI_estadoRegistro = 'S' then
		set V_descripcionError='Insertar token Usuario';
		
        select ifnull(max(correlativo),0)+1 into V_ultimoRegistroToken from token_usuario;  
        
        set V_token = concat(cast(V_ultimoRegistroToken as char),PI_usuarioGenerado);
        
        insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)
		values(V_token,PI_estadoRegistro,now(),now(),PI_usuarioGenerado,PI_empresa);
	elseif PI_estadoRegistro = 'N' then
		set V_descripcionError='Actualizar estado token Usuario';
        
        SELECT correlativo
          into V_correlativo
		  from token_usuario
		 where valorToken = PI_usuarioGenerado
         and estadoRegistro = 'S';
        
		update token_usuario
		set estadoRegistro = PI_estadoRegistro
		where correlativo = V_correlativo;
        
        set V_token = '000';
	else
		set V_descripcionError='Actualizar actividad del token Usuario';
        
        SELECT correlativo
          into V_correlativo
		  from token_usuario
		 where valorToken = PI_usuarioGenerado;
        
		update token_usuario
		set fechaUltMov = now()
		where correlativo = V_correlativo;
        
        set V_token = '000';
	end if;

	set PO_error = V_token;
	
    COMMIT;
    set autocommit = 1;
END$$

CREATE DEFINER=`cchcorre`@`localhost` PROCEDURE `prc_validar_token` (IN `P_codToken` VARCHAR(200), IN `P_codUsuario` INT, OUT `PO_validacion` VARCHAR(200))  BEGIN
DECLARE V_cantidad int;
DECLARE V_fecha1 DATETIME;
declare V_diferencia_minutos int;
declare V_descripcionError varchar(500);
declare V_tiempoSesion int;
declare V_resultadoActualizarToken varchar(200);
declare V_respuestaError varchar(200);
declare V_codUsuario int;

	DECLARE exit handler for sqlexception
	BEGIN
		ROLLBACK;

        START TRANSACTION;
        SET PO_validacion = 'error';


        if P_codUsuario=0 then
			set V_codUsuario = null;
        else
			set V_codUsuario = P_codUsuario;
        end if;

        call prc_registrar_error(concat('Error de tipo exception al validar Token'),'prc_validar_token',V_codUsuario,V_respuestaError);

        COMMIT;
	END;

    DECLARE exit handler for sqlwarning
	BEGIN
		ROLLBACK;

        START TRANSACTION;
        SET PO_validacion = 'error';

        if P_codUsuario=0 then
			set V_codUsuario = null;
        else
			set V_codUsuario = P_codUsuario;
        end if;

        call prc_registrar_error(concat('Error de tipo sqlwarning al validar Token'),'prc_validar_token',V_codUsuario,V_respuestaError);

        COMMIT;
	END;


set autocommit = 0;

START TRANSACTION;
set PO_validacion = 'S';

SELECT
    COUNT(correlativo)
INTO V_cantidad
FROM
    token_usuario
WHERE
    valorToken = P_codToken
        AND estadoRegistro = 'N';

if V_cantidad = 0 then
	SELECT
		COUNT(correlativo)
	INTO V_cantidad FROM
		token_usuario
	WHERE
		valorToken = P_codToken
			AND estadoRegistro = 'S';

	if V_cantidad = 1 then
		SELECT
			fechaUltMov
		INTO V_fecha1 FROM
			token_usuario
		WHERE
			valorToken = P_codToken
				AND estadoRegistro = 'S';

		select cast(valorParametro AS UNSIGNED)
          into V_tiempoSesion
          from parametros_generales
		 where identificadorParametro = 'TIME_OUT_SESSION';

        set V_diferencia_minutos = TIMESTAMPDIFF(MINUTE, V_fecha1, now());

        if V_diferencia_minutos >= V_tiempoSesion then
			call prc_registrar_token(P_codToken,'N',P_codUsuario,0,V_resultadoActualizarToken);

            if V_resultadoActualizarToken = 'error' then
                call prc_registrar_error('Error al actualizar estado del token','prc_validar_token',P_codUsuario,V_respuestaError);
            end if;

            set PO_validacion = 'N';
        else
			call prc_registrar_token(P_codToken,'R',P_codUsuario,0,V_resultadoActualizarToken);

            if V_resultadoActualizarToken = 'error' then
                call prc_registrar_error('Error al actualizar fecha y hora de ultima actualizacion del token','prc_validar_token',P_codUsuario,V_respuestaError);

			end if;

            set PO_validacion = 'S';

        end if;
    else
		set PO_validacion = 'N';
    end if;
else
	set PO_validacion = 'N';
end if;

COMMIT;
set autocommit = 1;

END$$

CREATE DEFINER=`cchcorre`@`localhost` PROCEDURE `prc_validar_usuario_password` (IN `P_usuario` VARCHAR(200), IN `PI_numeroToken` VARCHAR(200), OUT `PO_validacion` VARCHAR(200), OUT `PO_codUsuario` INT, OUT `PO_password` VARCHAR(200), OUT `PO_codEmpresa` INT)  BEGIN
DECLARE V_cantidad int;
declare V_codEmpresa int;
declare V_codUsuario int;
declare V_password varchar(200);
declare V_descripcionError varchar(500);
declare V_validacionToken varchar(200);
DECLARE V_respuestaError varchar(200); 

	DECLARE exit handler for sqlexception
	BEGIN
		ROLLBACK;
        
        START TRANSACTION;
        SET PO_validacion = 'error';
        
        call prc_registrar_error(concat('Error de tipo exception al validar Usuario: ',P_usuario),'prc_validar_usuario_password',null,V_respuestaError);
        COMMIT;
	END;
    
    DECLARE exit handler for sqlwarning
	BEGIN
        ROLLBACK;
        
        START TRANSACTION;
        SET PO_validacion = 'error';
        
        call prc_registrar_error(concat('Error de tipo Sqlwarning al validar Usuario: ',P_usuario),'prc_validar_usuario_password',null,V_respuestaError);
        COMMIT;
	END;


set autocommit = 0;
    
START TRANSACTION;
set V_codEmpresa = 0;
set V_validacionToken = 'S';
set V_cantidad = 0;

select count(*) 
  into V_cantidad
  from usuario
 where nombreUsuario = P_usuario;
if V_cantidad = 1 then
	select codEmpresa
	  into V_codEmpresa
	  from usuario
	 where nombreUsuario = P_usuario;

	set PO_codEmpresa = V_codEmpresa;
	set V_cantidad = 0;

	select count(*) 
	  into V_cantidad
	  from usuario
	 where nombreUsuario = P_usuario
	   and codEmpresa = V_codEmpresa
       and estadoRegistro = 'S';
	   
	if V_cantidad = 1 then
		select codUsuario,passwordUsuario
		  into V_codUsuario,V_password
		  from usuario
		 where nombreUsuario = P_usuario
		   and codEmpresa = V_codEmpresa;
		
		call prc_validar_token(PI_numeroToken,V_codUsuario,V_validacionToken);
		
		if V_validacionToken = 'N' or V_validacionToken = 'error' then
			call prc_registrar_error('Error al validar Token','prc_validar_usuario_password',V_codUsuario,PO_validacion);
            set PO_validacion = 'error';
		else
			set PO_validacion = '000';
			set PO_password = V_password;
			set PO_codUsuario = V_codUsuario;
            set autocommit = 1;
		end if;
	else
		call prc_registrar_error('Usuario Bloqueado y/o No Vigente','prc_validar_usuario_password',null,PO_validacion);
    
		set PO_password = '';
		set PO_codUsuario = 0;
		set PO_validacion = 'error';
	end if;
else
	call prc_registrar_error('Usuario No Encontrado','prc_validar_usuario_password',null,PO_validacion);
	
    set autocommit = 1;
    set PO_password = '';
	set PO_codUsuario = 0;
    set PO_codEmpresa = 0;
end if;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_empresa`
--

CREATE TABLE `datos_empresa` (
  `codEmpresa` int(11) NOT NULL,
  `razonSocial` varchar(200) NOT NULL,
  `LimiteUsuarios` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `codEmpresa` int(11) NOT NULL,
  `nombreEmpresa` varchar(500) NOT NULL,
  `estadoRegistro` varchar(1) NOT NULL COMMENT 'S:Activo/N:No Activo/B:Bloqueado',
  `fechaInsercion` datetime NOT NULL,
  `usuarioInsercion` int(11) NOT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `usuarioModificacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`codEmpresa`, `nombreEmpresa`, `estadoRegistro`, `fechaInsercion`, `usuarioInsercion`, `fechaModificacion`, `usuarioModificacion`) VALUES
(1, 'OUTAFOX', 'S', '2017-07-04 00:00:00', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa_sistema`
--

CREATE TABLE `empresa_sistema` (
  `codEmpresa` int(11) NOT NULL,
  `codSistema` int(11) NOT NULL,
  `estadoRegistro` varchar(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `errores_sistema`
--

CREATE TABLE `errores_sistema` (
  `codError` int(11) NOT NULL,
  `codUsuario` int(11) DEFAULT NULL,
  `descripcionError` varchar(500) NOT NULL COMMENT 'Descripcion del error',
  `claseError` varchar(200) NOT NULL COMMENT 'clase y metoido donde ocurrio el error',
  `fechaInsercion` datetime NOT NULL COMMENT 'fecha y hora donde ocurrio el error'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `errores_sistema`
--

INSERT INTO `errores_sistema` (`codError`, `codUsuario`, `descripcionError`, `claseError`, `fechaInsercion`) VALUES
(296, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-08-02 15:05:25'),
(297, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-08-02 15:07:59'),
(298, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-08-02 17:10:28'),
(299, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-08-02 18:31:01'),
(300, NULL, 'Error de tipo sqlwarning al Insertar token Usuario---insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)	values(1usuarioTemporal4199,S,2017-08-02 18:32:28,2017-08-02 18:32:28,usuarioTemporal4199,0);', 'prc_registrar_token', '2017-08-02 18:32:28'),
(301, NULL, 'Error de tipo sqlwarning al Insertar token Usuario---insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)	values(1usuarioTemporal9117,S,2017-08-02 18:32:58,2017-08-02 18:32:58,usuarioTemporal9117,0);', 'prc_registrar_token', '2017-08-02 18:32:58'),
(302, NULL, 'Error Insertar token Usuario-insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)	values(1usuarioTemporal5649,S,2017-08-02 18:35:30,2017-08-02 18:35:30,usuarioTemporal5649,0);', 'prc_registrar_token', '2017-08-02 18:35:30'),
(303, NULL, 'Error Insertar token Usuario-insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)	values(1usuarioTemporal6139,S,2017-08-02 18:35:45,2017-08-02 18:35:45,usuarioTemporal6139,0);', 'prc_registrar_token', '2017-08-02 18:35:45'),
(304, NULL, 'Error Insertar token Usuario-insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)	values(1usuarioTemporal2470,S,2017-08-02 18:36:09,2017-08-02 18:36:09,usuarioTemporal2470,0);', 'prc_registrar_token', '2017-08-02 18:36:09'),
(305, NULL, 'Error Insertar token Usuario-insert into token_usuario(valorToken,estadoRegistro,fechaInsercion,fechaUltMov,usuario,codEmpresa)	values(1usuarioTemporal706,S,2017-08-02 18:39:37,2017-08-02 18:39:37,usuarioTemporal706,0);', 'prc_registrar_token', '2017-08-02 18:39:37'),
(306, NULL, 'Error de tipo exception al Insertar token Usuario', 'prc_registrar_token', '2017-08-02 18:47:00'),
(307, NULL, 'Usuario No Encontrado', 'prc_validar_usuario_password', '2017-08-02 20:30:27'),
(308, NULL, 'Error de tipo sqlwarning al Actualizar intentos de usuario', 'prc_actualizar_estado_usuario', '2017-08-02 20:30:27'),
(309, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:44:32'),
(310, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:44:32'),
(311, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:46:10'),
(312, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:46:10'),
(313, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:46:55'),
(314, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:46:55'),
(315, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:47:49'),
(316, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:47:49'),
(317, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:49:14'),
(318, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:49:14'),
(319, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:56:05'),
(320, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:56:05'),
(321, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:57:44'),
(322, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:57:44'),
(323, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:58:19'),
(324, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:58:19'),
(325, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 15:58:52'),
(326, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 15:58:52'),
(327, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 16:01:07'),
(328, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 16:01:07'),
(329, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-03 16:06:19'),
(330, NULL, 'Error de tipo sqlwarning al Actualizar estado token Usuario', 'prc_registrar_token', '2017-08-03 16:06:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parametros_generales`
--

CREATE TABLE `parametros_generales` (
  `codParametro` int(11) NOT NULL,
  `codEmpresa` int(11) NOT NULL,
  `identificadorParametro` varchar(100) NOT NULL,
  `descipcionParametro` varchar(200) DEFAULT NULL,
  `valorParametro` varchar(200) DEFAULT NULL,
  `estadoRegistro` varchar(1) NOT NULL,
  `fechaInsercion` datetime NOT NULL,
  `usuarioInsercion` int(11) NOT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `usuarioModificacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `parametros_generales`
--

INSERT INTO `parametros_generales` (`codParametro`, `codEmpresa`, `identificadorParametro`, `descipcionParametro`, `valorParametro`, `estadoRegistro`, `fechaInsercion`, `usuarioInsercion`, `fechaModificacion`, `usuarioModificacion`) VALUES
(1, 1, 'TIME_OUT_SESSION', 'Tiempo limite de Sesion Activa', '5', 'S', '2017-07-05 00:00:00', 1, NULL, NULL),
(2, 1, 'LLAVE_HASH', 'Llave de encriptacion Hash para datos Sensibles', 'VmFtb3NfcG9yX21hc19wdWxwaW4=', 'S', '2017-07-05 00:00:00', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sistema`
--

CREATE TABLE `sistema` (
  `codSistema` int(11) NOT NULL,
  `etiquetaSistema` varchar(300) DEFAULT NULL,
  `urlSistema` varchar(300) DEFAULT NULL,
  `urlIcono` varchar(300) DEFAULT NULL,
  `estadoRegistro` varchar(1) DEFAULT NULL,
  `fechaInsercion` datetime DEFAULT NULL,
  `usuarioInsercion` int(11) DEFAULT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `usuarioModificacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `sistema`
--

INSERT INTO `sistema` (`codSistema`, `etiquetaSistema`, `urlSistema`, `urlIcono`, `estadoRegistro`, `fechaInsercion`, `usuarioInsercion`, `fechaModificacion`, `usuarioModificacion`) VALUES
(1, 'Asistencia', NULL, NULL, 'S', '2017-07-31 00:00:00', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `token_usuario`
--

CREATE TABLE `token_usuario` (
  `correlativo` int(11) NOT NULL COMMENT 'Esta correlativo servirá para generar el token y no realizar busquedas constantes para validar existencias de token.',
  `valorToken` varchar(200) NOT NULL,
  `estadoRegistro` varchar(1) NOT NULL COMMENT '''S=activo/N:no activo''',
  `fechaInsercion` datetime NOT NULL COMMENT 'Fecha y hora de registro de token',
  `fechaUltMov` datetime DEFAULT NULL COMMENT 'fecha y hora de ultima transaccion',
  `usuario` varchar(200) DEFAULT NULL,
  `codEmpresa` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `token_usuario`
--

INSERT INTO `token_usuario` (`correlativo`, `valorToken`, `estadoRegistro`, `fechaInsercion`, `fechaUltMov`, `usuario`, `codEmpresa`) VALUES
(1, '1usuarioTemporal1461', 'N', '2017-08-02 18:53:10', '2017-08-02 18:53:36', 'usuarioTemporal1461', 0),
(2, '2ACNUNEZ2566', 'N', '2017-08-02 18:53:37', '2017-08-02 19:12:12', 'ACNUNEZ2566', 1),
(3, '3usuarioTemporal1166', 'N', '2017-08-02 19:24:15', '2017-08-02 19:24:23', 'usuarioTemporal1166', 0),
(4, '4ACNUNEZ3247', 'N', '2017-08-02 19:24:23', '2017-08-02 19:29:43', 'ACNUNEZ3247', 1),
(5, '5usuarioTemporal7029', 'N', '2017-08-02 19:35:12', '2017-08-02 19:35:19', 'usuarioTemporal7029', 0),
(6, '6ACNUNEZ9602', 'S', '2017-08-02 19:35:19', '2017-08-02 19:39:41', 'ACNUNEZ9602', 1),
(7, '7usuarioTemporal9706', 'N', '2017-08-02 19:57:31', '2017-08-02 19:57:39', 'usuarioTemporal9706', 0),
(8, '8ACNUNEZ3088', 'S', '2017-08-02 19:57:39', '2017-08-02 19:57:45', 'ACNUNEZ3088', 1),
(9, '9usuarioTemporal9694', 'N', '2017-08-02 20:29:43', '2017-08-02 20:29:43', 'usuarioTemporal9694', 0),
(10, '10usuarioTemporal7108', 'N', '2017-08-02 20:30:31', '2017-08-02 20:31:12', 'usuarioTemporal7108', 0),
(11, '11ACNUNEZ4567', 'N', '2017-08-02 20:31:12', '2017-08-02 20:31:47', 'ACNUNEZ4567', 1),
(12, '12usuarioTemporal6384', 'S', '2017-08-02 20:38:29', '2017-08-02 20:40:34', 'usuarioTemporal6384', 0),
(13, '13usuarioTemporal768', 'N', '2017-08-02 23:09:05', '2017-08-02 23:09:43', 'usuarioTemporal768', 0),
(14, '14ACNUNEZ1620', 'S', '2017-08-02 23:09:43', '2017-08-02 23:09:51', 'ACNUNEZ1620', 1),
(15, '15usuarioTemporal4573', 'N', '2017-08-03 15:33:13', '2017-08-03 15:33:22', 'usuarioTemporal4573', 0),
(16, '16usuarioTemporal1070', 'N', '2017-08-03 15:40:25', '2017-08-03 15:40:35', 'usuarioTemporal1070', 0),
(17, '17usuarioTemporal5722', 'N', '2017-08-03 15:42:01', '2017-08-03 15:44:04', 'usuarioTemporal5722', 0),
(18, '18usuarioTemporal219', 'N', '2017-08-03 15:44:39', '2017-08-03 15:44:48', 'usuarioTemporal219', 0),
(19, '19usuarioTemporal4244', 'N', '2017-08-03 15:46:11', '2017-08-03 15:46:20', 'usuarioTemporal4244', 0),
(20, '20usuarioTemporal2396', 'N', '2017-08-03 15:46:57', '2017-08-03 15:47:04', 'usuarioTemporal2396', 0),
(21, '21usuarioTemporal7041', 'N', '2017-08-03 15:47:51', '2017-08-03 15:47:59', 'usuarioTemporal7041', 0),
(22, '22usuarioTemporal7271', 'N', '2017-08-03 15:49:14', '2017-08-03 15:49:23', 'usuarioTemporal7271', 0),
(23, '23usuarioTemporal867', 'N', '2017-08-03 15:56:06', '2017-08-03 15:56:16', 'usuarioTemporal867', 0),
(24, '24usuarioTemporal1', 'N', '2017-08-03 15:57:46', '2017-08-03 15:57:54', 'usuarioTemporal1', 0),
(25, '25usuarioTemporal5033', 'N', '2017-08-03 15:58:20', '2017-08-03 15:58:28', 'usuarioTemporal5033', 0),
(26, '26usuarioTemporal4223', 'N', '2017-08-03 15:58:53', '2017-08-03 15:59:01', 'usuarioTemporal4223', 0),
(27, '27usuarioTemporal369', 'N', '2017-08-03 16:01:08', '2017-08-03 16:05:20', 'usuarioTemporal369', 0),
(28, '28usuarioTemporal2686', 'N', '2017-08-03 16:06:20', '2017-08-03 16:06:29', 'usuarioTemporal2686', 0),
(29, '29ACNUNEZ4656', 'S', '2017-08-03 16:06:29', '2017-08-03 16:06:35', 'ACNUNEZ4656', 1),
(30, '30usuarioTemporal8189', 'N', '2017-08-03 18:01:42', '2017-08-03 18:01:49', 'usuarioTemporal8189', 0),
(31, '31ACNUNEZ6026', 'S', '2017-08-03 18:01:50', '2017-08-03 18:01:56', 'ACNUNEZ6026', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `codUsuario` int(11) NOT NULL,
  `codEmpresa` int(11) NOT NULL,
  `nombreUsuario` varchar(200) NOT NULL,
  `passwordUsuario` varchar(200) NOT NULL,
  `cantidadIntentos` int(11) NOT NULL,
  `indicadorUsuarioAdministrador` varchar(1) NOT NULL,
  `estadoRegistro` varchar(1) NOT NULL COMMENT 'S:Vigente/N:No Vigente/Z:Super Admin',
  `fechaInsercion` datetime NOT NULL,
  `usuarioInsercion` int(11) NOT NULL,
  `fechaModificacion` datetime DEFAULT NULL,
  `usuarioModificacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`codUsuario`, `codEmpresa`, `nombreUsuario`, `passwordUsuario`, `cantidadIntentos`, `indicadorUsuarioAdministrador`, `estadoRegistro`, `fechaInsercion`, `usuarioInsercion`, `fechaModificacion`, `usuarioModificacion`) VALUES
(1, 1, 'ACNUNEZ', '$2y$12$Vm1GdGIzTmZjRzl5WDIxa.2gQYe0cMPidgMxR7sEAYU17oD2RZHte', 0, 'Z', 'S', '2017-07-04 00:00:00', 1, '2017-08-03 18:01:50', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_sistema`
--

CREATE TABLE `usuario_sistema` (
  `codUsuario` int(11) NOT NULL,
  `codSistema` int(11) NOT NULL,
  `estadoRegistro` varchar(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario_sistema`
--

INSERT INTO `usuario_sistema` (`codUsuario`, `codSistema`, `estadoRegistro`) VALUES
(1, 1, 'S');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_lista_empresa`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `view_lista_empresa` (
`codigo` int(11)
,`nombre` varchar(500)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_lista_menu_principal`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `view_lista_menu_principal` (
`etiqueta` varchar(300)
,`url` varchar(300)
,`icono` varchar(300)
,`usuario` int(11)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `view_lista_empresa`
--
DROP TABLE IF EXISTS `view_lista_empresa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`cchcorre`@`localhost` SQL SECURITY DEFINER VIEW `view_lista_empresa`  AS  select `em`.`codEmpresa` AS `codigo`,`em`.`nombreEmpresa` AS `nombre` from `empresa` `em` where (`em`.`estadoRegistro` = 'S') ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_lista_menu_principal`
--
DROP TABLE IF EXISTS `view_lista_menu_principal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`cchcorre`@`localhost` SQL SECURITY DEFINER VIEW `view_lista_menu_principal`  AS  select `si`.`etiquetaSistema` AS `etiqueta`,ifnull(`si`.`urlSistema`,'') AS `url`,ifnull(`si`.`urlIcono`,'') AS `icono`,`us`.`codUsuario` AS `usuario` from (`sistema` `si` join `usuario_sistema` `us` on((`si`.`codSistema` = `us`.`codSistema`))) where (`us`.`estadoRegistro` = 'S') ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `datos_empresa`
--
ALTER TABLE `datos_empresa`
  ADD PRIMARY KEY (`codEmpresa`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`codEmpresa`);

--
-- Indices de la tabla `empresa_sistema`
--
ALTER TABLE `empresa_sistema`
  ADD PRIMARY KEY (`codEmpresa`,`codSistema`),
  ADD KEY `fk_empresa_has_sistemas_sistemas1_idx` (`codSistema`),
  ADD KEY `fk_empresa_sistema_empresa1_idx` (`codEmpresa`);

--
-- Indices de la tabla `errores_sistema`
--
ALTER TABLE `errores_sistema`
  ADD PRIMARY KEY (`codError`),
  ADD KEY `fk_errores_sistema_usuario_sistema1_idx` (`codUsuario`);

--
-- Indices de la tabla `parametros_generales`
--
ALTER TABLE `parametros_generales`
  ADD PRIMARY KEY (`codParametro`),
  ADD KEY `fk_parametros_generales_empresa1_idx` (`codEmpresa`);

--
-- Indices de la tabla `sistema`
--
ALTER TABLE `sistema`
  ADD PRIMARY KEY (`codSistema`);

--
-- Indices de la tabla `token_usuario`
--
ALTER TABLE `token_usuario`
  ADD PRIMARY KEY (`correlativo`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`codUsuario`,`codEmpresa`),
  ADD UNIQUE KEY `nombre_usuario_UNIQUE` (`nombreUsuario`),
  ADD UNIQUE KEY `cod_usuario_UNIQUE` (`codUsuario`),
  ADD KEY `fk_usuario_empresa1_idx` (`codEmpresa`);

--
-- Indices de la tabla `usuario_sistema`
--
ALTER TABLE `usuario_sistema`
  ADD PRIMARY KEY (`codUsuario`,`codSistema`),
  ADD KEY `fk_usuario_has_sistema_sistema1_idx` (`codSistema`),
  ADD KEY `fk_usuario_has_sistema_usuario1_idx` (`codUsuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `codEmpresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `errores_sistema`
--
ALTER TABLE `errores_sistema`
  MODIFY `codError` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=331;
--
-- AUTO_INCREMENT de la tabla `parametros_generales`
--
ALTER TABLE `parametros_generales`
  MODIFY `codParametro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `sistema`
--
ALTER TABLE `sistema`
  MODIFY `codSistema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `token_usuario`
--
ALTER TABLE `token_usuario`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Esta correlativo servirá para generar el token y no realizar busquedas constantes para validar existencias de token.', AUTO_INCREMENT=32;
DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`cchcorre`@`localhost` EVENT `evn_caducar_token` ON SCHEDULE EVERY 1 MINUTE STARTS '2017-08-02 10:14:42' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
		declare V_tiempoSesion int;
	
		select cast(valorParametro as unsigned) 
          into V_tiempoSesion 
          from parametros_generales 
		 where identificadorParametro = 'TIME_OUT_SESSION';
    
		update token_usuario
        set estadoRegistro = 'N'
        where TIMESTAMPDIFF(MINUTE, fechaUltMov, now())>=V_tiempoSesion;
	    
	END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
