-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 02-08-2017 a las 02:54:11
-- Versión del servidor: 10.1.13-MariaDB
-- Versión de PHP: 5.6.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `big_fox`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`jano`@`localhost` PROCEDURE `prc_actualizar_estado_usuario` (IN `PI_usuario` INT, IN `PI_estadoRegistro` VARCHAR(1), IN `PI_empresa` INT, OUT `PO_error` VARCHAR(200))  BEGIN
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

CREATE DEFINER=`jano`@`localhost` PROCEDURE `prc_actualizar_intentos_usuario` (IN `PI_usuario` INT, IN `PI_intentos` INT, IN `PI_empresa` INT, OUT `PO_error` VARCHAR(200))  BEGIN
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

CREATE DEFINER=`jano`@`localhost` PROCEDURE `prc_registrar_error` (IN `PI_descrionError` VARCHAR(500), IN `PI_objetoOcurrencia` VARCHAR(200), IN `PI_usuario` INT, OUT `PO_error` VARCHAR(200))  BEGIN
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

CREATE DEFINER=`jano`@`localhost` PROCEDURE `prc_registrar_token` (IN `PI_usuarioGenerado` VARCHAR(200), IN `PI_estadoRegistro` VARCHAR(1), IN `PI_usuario` INT, IN `PI_empresa` INT, OUT `PO_error` VARCHAR(200))  BEGIN
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
		set fechaModificacion = now()
		where correlativo = V_correlativo;
        
        set V_token = '000';
	end if;

	set PO_error = V_token;
	
    COMMIT;
    set autocommit = 1;
END$$

CREATE DEFINER=`jano`@`localhost` PROCEDURE `prc_validar_token` (IN `P_codToken` VARCHAR(200), IN `P_codUsuario` INT, OUT `PO_validacion` VARCHAR(200))  BEGIN
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

/********************Aqui inicia la logica de validacion************************/
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
			fechaInsercion
		INTO V_fecha1 FROM
			token_usuario
		WHERE
			valorToken = P_codToken
				AND estadoRegistro = 'S';
	
		select cast(valorParametro as int) 
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

CREATE DEFINER=`jano`@`localhost` PROCEDURE `prc_validar_usuario_password` (IN `P_usuario` VARCHAR(200), IN `PI_numeroToken` VARCHAR(200), OUT `PO_validacion` VARCHAR(200), OUT `PO_codUsuario` INT, OUT `PO_password` VARCHAR(200), OUT `PO_codEmpresa` INT)  BEGIN
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

/*******************Aqui empieza el bloque de validacion********************/
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
(10, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-07-04 18:56:56'),
(11, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-07-04 18:57:47'),
(12, NULL, 'Error de tipo sqlwarning al Insertar token Usuario', 'prc_registrar_token', '2017-07-04 18:58:14'),
(13, NULL, 'Error de tipo exception al Insertar token Usuario', 'prc_registrar_token', '2017-07-04 19:04:14'),
(14, NULL, 'Error de tipo exception al Insertar token Usuario', 'prc_registrar_token', '2017-07-04 19:04:24'),
(15, NULL, 'Error de tipo exception al Insertar token Usuario', 'prc_registrar_token', '2017-07-04 19:05:57'),
(16, 1, 'Error de tipo exception al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 09:14:32'),
(17, 1, 'Error de tipo sqlwarning al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 09:20:40'),
(18, 1, 'Error de tipo sqlwarning al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 09:27:04'),
(19, 1, 'Sqlwarning al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 09:46:06'),
(20, 1, 'Sqlwarning al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 09:46:49'),
(21, 1, 'Error de tipo exception al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 10:38:09'),
(22, 1, 'Sqlwarning al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 10:39:05'),
(23, 1, 'Sqlwarning al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 10:39:44'),
(24, 1, 'Error de tipo exception al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 11:01:48'),
(25, 1, 'Error de tipo exception al validar Usuario: ACNUNEZ', 'prc_validar_usuario_password', '2017-07-06 11:02:24'),
(26, 1, 'Error de tipo exception al validar Token', 'prc_registrar_token', '2017-07-06 11:11:54'),
(27, 1, 'Error de tipo exception al validar Token', 'prc_registrar_token', '2017-07-06 11:12:52'),
(28, 1, 'Error de tipo exception al validar Token', 'prc_registrar_token', '2017-07-06 11:13:17'),
(29, 1, 'Error de tipo exception al validar Token', 'prc_registrar_token', '2017-07-06 11:13:58'),
(30, 1, 'Error de tipo exception al validar Token', 'prc_registrar_token', '2017-07-06 11:14:22'),
(31, 1, 'Error de tipo exception al validar Token', 'prc_registrar_token', '2017-07-06 11:15:04'),
(32, 1, 'Error de tipo sqlwarning al validar Token', 'prc_validar_token', '2017-07-06 11:18:47'),
(33, 1, 'Error de tipo sqlwarning al validar Token', 'prc_validar_token', '2017-07-06 11:19:42'),
(34, 1, 'Error de tipo sqlwarning al validar Token', 'prc_validar_token', '2017-07-06 11:21:02'),
(35, 1, 'Error de tipo sqlwarning al validar Token', 'prc_validar_token', '2017-07-06 11:21:50'),
(36, 1, 'prueba', 'editor', '2017-07-07 12:00:42'),
(37, 1, 'prueba', 'editor', '2017-07-07 12:00:44'),
(39, 1, 'prueba', 'editor', '2017-07-07 12:27:13'),
(43, 1, 'prueba', 'editor', '2017-07-07 12:48:59'),
(47, NULL, 'Error de tipo exception al ', 'prc_registrar_token', '2017-07-07 14:24:59'),
(48, NULL, 'Error de tipo exception al ', 'prc_registrar_token', '2017-07-07 14:30:11'),
(55, NULL, 'prueba', 'editor', '2017-07-07 14:50:31'),
(56, NULL, 'Usuario Bloqueado y/o No Vigente', 'prc_actualizar_estado_usuario', '2017-07-07 14:54:49'),
(57, NULL, 'Usuario Bloqueado y/o No Vigente', 'prc_validar_usuario_password', '2017-07-07 14:56:55'),
(58, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 15:02:16'),
(59, NULL, 'prueba', 'editor', '2017-07-07 15:02:16'),
(60, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 15:28:56'),
(61, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 15:29:38'),
(62, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 15:53:31'),
(63, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 15:54:17'),
(64, 1, 'Error de tipo exception al Actualizar estado token Usuario', 'prc_registrar_token', '2017-07-07 15:55:48'),
(65, 1, 'Error de tipo exception al Actualizar estado token Usuario', 'prc_registrar_token', '2017-07-07 15:57:25'),
(66, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:06:05'),
(67, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:06:24'),
(68, NULL, 'Usuario Bloqueado y/o No Vigente', 'prc_validar_usuario_password', '2017-07-07 16:08:52'),
(69, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:12:35'),
(70, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:13:13'),
(71, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:13:57'),
(72, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:21:43'),
(73, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:23:10'),
(74, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:39:25'),
(75, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:48:01'),
(76, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-07-07 16:55:18'),
(77, NULL, 'Usuario No Encontrado', 'prc_validar_usuario_password', '2017-07-19 18:53:32'),
(78, NULL, 'Error de tipo sqlwarning al Actualizar intentos de usuario', 'prc_actualizar_estado_usuario', '2017-07-19 18:53:32'),
(79, NULL, 'Usuario No Encontrado', 'prc_validar_usuario_password', '2017-07-19 18:54:01'),
(80, NULL, 'Error de tipo sqlwarning al Actualizar intentos de usuario', 'prc_actualizar_estado_usuario', '2017-07-19 18:54:02'),
(81, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 12:54:16'),
(82, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 12:54:17'),
(83, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:20:59'),
(84, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:20:59'),
(85, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:21:02'),
(86, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:21:02'),
(87, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:22:07'),
(88, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:22:07'),
(89, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:23:05'),
(90, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:23:05'),
(91, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:23:25'),
(92, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:23:25'),
(93, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:27:22'),
(94, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:27:22'),
(95, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:28:49'),
(96, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:28:49'),
(97, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-27 14:29:55'),
(98, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-27 14:29:55'),
(99, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 09:03:36'),
(100, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 09:03:36'),
(101, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 09:04:55'),
(102, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 09:04:55'),
(103, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 09:05:11'),
(104, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 09:05:11'),
(105, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 10:07:55'),
(106, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 10:07:55'),
(107, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 10:09:18'),
(108, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 10:09:19'),
(109, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 10:10:59'),
(110, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 10:10:59'),
(111, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 10:15:11'),
(112, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 10:15:11'),
(113, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 10:15:34'),
(114, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 10:15:34'),
(115, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 11:03:27'),
(116, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 11:03:27'),
(117, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 11:46:56'),
(118, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 11:46:56'),
(119, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 12:40:36'),
(120, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 12:40:36'),
(121, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 12:42:48'),
(122, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 12:42:48'),
(123, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 12:42:49'),
(124, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 12:42:49'),
(125, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 12:42:50'),
(126, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 12:42:50'),
(127, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 12:42:51'),
(128, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 12:42:51'),
(129, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:40'),
(130, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:40'),
(131, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:42'),
(132, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:42'),
(133, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:43'),
(134, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:44'),
(135, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:44'),
(136, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:44'),
(137, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:45'),
(138, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:45'),
(139, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:45'),
(140, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:45'),
(141, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:54'),
(142, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:54'),
(143, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:54'),
(144, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:54'),
(145, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:54'),
(146, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:54'),
(147, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:55'),
(148, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:55'),
(149, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:55'),
(150, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:55'),
(151, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:55'),
(152, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:55'),
(153, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:55'),
(154, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:55'),
(155, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:55'),
(156, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:55'),
(157, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:55'),
(158, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:56'),
(159, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:56'),
(160, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:56'),
(161, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:56'),
(162, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:56'),
(163, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:56'),
(164, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:56'),
(165, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:56'),
(166, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:56'),
(167, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:56'),
(168, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:56'),
(169, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:56'),
(170, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:57'),
(171, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:57'),
(172, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:57'),
(173, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:57'),
(174, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:57'),
(175, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:57'),
(176, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:57'),
(177, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 14:31:57'),
(178, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 14:31:57'),
(179, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 18:04:44'),
(180, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 18:04:44'),
(181, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 18:36:40'),
(182, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 18:36:40'),
(183, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 18:55:09'),
(184, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 18:55:09'),
(185, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 19:01:31'),
(186, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 19:01:32'),
(187, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 19:03:34'),
(188, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 19:03:34'),
(189, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 19:09:34'),
(190, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 19:09:35'),
(191, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 19:10:43'),
(192, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 19:10:43'),
(193, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 19:17:34'),
(194, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 19:17:34'),
(195, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-07-31 20:01:47'),
(196, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-07-31 20:01:47'),
(197, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:04'),
(198, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:05'),
(199, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:09'),
(200, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:09'),
(201, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:09'),
(202, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:09'),
(203, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:10'),
(204, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:10'),
(205, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:11'),
(206, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:11'),
(207, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:11'),
(208, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:11'),
(209, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:12'),
(210, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:12'),
(211, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:01:12'),
(212, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:01:13'),
(213, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:50:27'),
(214, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:50:27'),
(215, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 10:50:41'),
(216, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 10:50:41'),
(217, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 11:54:13'),
(218, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 11:54:13'),
(219, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:16:03'),
(220, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:16:03'),
(221, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:18:00'),
(222, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:18:00'),
(223, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:18:07'),
(224, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:18:07'),
(225, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:28:28'),
(226, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:28:28'),
(227, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:45:38'),
(228, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:45:38'),
(229, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:50:59'),
(230, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:50:59'),
(231, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 12:51:30'),
(232, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 12:51:30'),
(233, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:28:12'),
(234, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:28:12'),
(235, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:32:08'),
(236, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:32:08'),
(237, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:32:17'),
(238, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:32:17'),
(239, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:33:23'),
(240, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:33:23'),
(241, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:33:39'),
(242, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:33:39'),
(243, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:33:48'),
(244, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:33:48'),
(245, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:34:47'),
(246, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:34:47'),
(247, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:35:07'),
(248, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:35:07'),
(249, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:36:10'),
(250, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:36:10'),
(251, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:36:32'),
(252, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:36:32'),
(253, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:37:18'),
(254, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:37:18'),
(255, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:38:09'),
(256, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:38:09'),
(257, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:42:22'),
(258, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:42:22'),
(259, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 14:42:31'),
(260, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 14:42:31'),
(261, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 15:51:18'),
(262, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 15:51:18'),
(263, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 15:51:34'),
(264, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 15:51:34'),
(265, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 15:51:44'),
(266, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 15:51:44'),
(267, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 17:58:18'),
(268, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 17:58:18'),
(269, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-01 17:58:18'),
(270, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 17:58:31'),
(271, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 17:58:31'),
(272, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-01 17:58:31'),
(273, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 17:59:01'),
(274, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 17:59:01'),
(275, 1, 'Error al validar Token', 'prc_validar_usuario_password', '2017-08-01 17:59:01'),
(276, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 18:01:38'),
(277, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 18:01:38'),
(278, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 18:10:27'),
(279, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 18:10:27'),
(280, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 18:10:31'),
(281, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 18:10:31'),
(282, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 19:16:15'),
(283, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 19:16:15'),
(284, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 19:16:22'),
(285, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 19:16:22'),
(286, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 19:17:37'),
(287, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 19:17:37'),
(288, NULL, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 19:19:47'),
(289, NULL, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 19:19:47'),
(290, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 19:24:03'),
(291, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 19:24:03'),
(292, 1, 'Error de tipo exception al Actualizar actividad del token Usuario', 'prc_registrar_token', '2017-08-01 19:37:43'),
(293, 1, 'Error al actualizar fecha y hora de ultima actualizacion del token', 'prc_validar_token', '2017-08-01 19:37:43');

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
-- Estructura de tabla para la tabla `pruebas`
--

CREATE TABLE `pruebas` (
  `id` int(11) NOT NULL,
  `valor` varchar(50) NOT NULL,
  `fechayhora` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `pruebas`
--

INSERT INTO `pruebas` (`id`, `valor`, `fechayhora`) VALUES
(1, '123', '2017-07-05 12:22:25'),
(2, 'prueba', '2017-07-05 12:22:37'),
(3, 'prueba', '2017-07-07 12:27:12'),
(4, 'prueba', '2017-07-07 15:02:15');

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
(1, '1usuarioTemporal6766', 'N', '2017-07-04 19:09:44', '2017-07-04 19:09:44', 'usuarioTemporal6766', 1),
(2, '2usuarioTemporal5960', 'N', '2017-07-04 19:09:57', '2017-07-04 19:09:57', 'usuarioTemporal5960', 0),
(3, '3usuarioTemporal4354', 'N', '2017-07-05 08:52:43', '2017-07-05 08:52:43', 'usuarioTemporal4354', 0),
(4, '4usuarioTemporal5171', 'N', '2017-07-05 09:13:28', '2017-07-05 09:13:28', 'usuarioTemporal5171', 0),
(5, '5usuarioTemporal5007', 'N', '2017-07-05 09:15:47', '2017-07-05 09:15:47', 'usuarioTemporal5007', 0),
(6, '6usuarioTemporal7878', 'N', '2017-07-05 09:27:12', '2017-07-05 09:27:12', 'usuarioTemporal7878', 0),
(7, '7usuarioTemporal4916', 'N', '2017-07-05 09:27:33', '2017-07-05 09:27:33', 'usuarioTemporal4916', 0),
(8, '8usuarioTemporal2642', 'N', '2017-07-05 12:27:47', '2017-07-05 12:27:47', 'usuarioTemporal2642', 0),
(9, '9usuarioTemporal1599', 'N', '2017-07-05 12:48:52', '2017-07-05 12:48:52', 'usuarioTemporal1599', 0),
(10, '10usuarioTemporal680', 'N', '2017-07-05 18:38:12', '2017-07-05 18:38:12', 'usuarioTemporal680', 0),
(11, '11usuarioTemporal4349', 'N', '2017-07-06 09:11:23', '2017-07-06 09:11:23', 'usuarioTemporal4349', 0),
(12, '12usuarioTemporal3818', 'N', '2017-07-06 09:20:32', '2017-07-06 09:20:32', 'usuarioTemporal3818', 0),
(13, '13usuarioTemporal3540', 'N', '2017-07-06 09:26:52', '2017-07-06 09:26:52', 'usuarioTemporal3540', 0),
(14, '14usuarioTemporal7438', 'N', '2017-07-06 11:02:01', '2017-07-06 11:02:01', 'usuarioTemporal7438', 0),
(15, '15usuarioTemporal1809', 'N', '2017-07-06 11:10:26', '2017-07-06 11:10:26', 'usuarioTemporal1809', 0),
(16, '16usuarioTemporal4940', 'N', '2017-07-06 11:41:04', '2017-07-06 11:41:04', 'usuarioTemporal4940', 0),
(17, '17usuarioTemporal6146', 'N', '2017-07-06 12:05:06', '2017-07-06 12:05:06', 'usuarioTemporal6146', 0),
(18, '18usuarioTemporal3494', 'N', '2017-07-06 17:16:20', '2017-07-06 17:16:20', 'usuarioTemporal3494', 0),
(19, '19usuarioTemporal9203', 'N', '2017-07-06 17:17:01', '2017-07-06 17:17:01', 'usuarioTemporal9203', 0),
(20, '20usuarioTemporal3014', 'N', '2017-07-06 17:17:46', '2017-07-06 17:17:46', 'usuarioTemporal3014', 0),
(21, '21usuarioTemporal9104', 'N', '2017-07-06 17:19:37', '2017-07-06 17:19:37', 'usuarioTemporal9104', 0),
(22, '22usuarioTemporal93', 'N', '2017-07-06 17:28:40', '2017-07-06 17:28:40', 'usuarioTemporal93', 0),
(23, '23usuarioTemporal4533', 'N', '2017-07-06 17:33:52', '2017-07-06 17:33:52', 'usuarioTemporal4533', 0),
(24, '24usuarioTemporal4418', 'N', '2017-07-06 17:34:59', '2017-07-06 17:34:59', 'usuarioTemporal4418', 0),
(25, '25usuarioTemporal2677', 'N', '2017-07-06 17:35:25', '2017-07-06 17:35:25', 'usuarioTemporal2677', 0),
(26, '26usuarioTemporal677', 'N', '2017-07-06 17:36:01', '2017-07-06 17:36:01', 'usuarioTemporal677', 0),
(27, '27usuarioTemporal5722', 'N', '2017-07-06 17:36:18', '2017-07-06 17:36:18', 'usuarioTemporal5722', 0),
(28, '28usuarioTemporal8556', 'N', '2017-07-06 17:46:44', '2017-07-06 17:46:44', 'usuarioTemporal8556', 0),
(29, '29usuarioTemporal858', 'N', '2017-07-06 17:47:30', '2017-07-06 17:47:30', 'usuarioTemporal858', 0),
(30, '30usuarioTemporal2744', 'N', '2017-07-06 17:49:48', '2017-07-06 17:49:48', 'usuarioTemporal2744', 0),
(31, '31usuarioTemporal271', 'N', '2017-07-06 17:49:51', '2017-07-06 17:49:51', 'usuarioTemporal271', 0),
(32, '32usuarioTemporal2929', 'N', '2017-07-06 17:51:03', '2017-07-06 17:51:03', 'usuarioTemporal2929', 0),
(33, '33usuarioTemporal1148', 'N', '2017-07-06 17:51:06', '2017-07-06 17:51:06', 'usuarioTemporal1148', 0),
(34, '34usuarioTemporal3797', 'N', '2017-07-06 17:52:00', '2017-07-06 17:52:00', 'usuarioTemporal3797', 0),
(35, '35usuarioTemporal5678', 'N', '2017-07-06 17:52:36', '2017-07-06 17:52:36', 'usuarioTemporal5678', 0),
(36, '36usuarioTemporal5035', 'N', '2017-07-06 17:53:17', '2017-07-06 17:53:17', 'usuarioTemporal5035', 0),
(37, '37usuarioTemporal1048', 'N', '2017-07-06 18:00:14', '2017-07-06 18:00:14', 'usuarioTemporal1048', 0),
(38, '38usuarioTemporal1333', 'N', '2017-07-06 18:00:29', '2017-07-06 18:00:29', 'usuarioTemporal1333', 0),
(39, '39usuarioTemporal9445', 'N', '2017-07-06 18:02:58', '2017-07-06 18:02:58', 'usuarioTemporal9445', 0),
(40, '40usuarioTemporal2377', 'N', '2017-07-06 18:03:09', '2017-07-06 18:03:09', 'usuarioTemporal2377', 0),
(41, '41usuarioTemporal8057', 'N', '2017-07-06 18:03:11', '2017-07-06 18:03:11', 'usuarioTemporal8057', 0),
(42, '42usuarioTemporal2854', 'N', '2017-07-06 18:09:00', '2017-07-06 18:09:00', 'usuarioTemporal2854', 0),
(43, '43usuarioTemporal9071', 'N', '2017-07-06 18:12:35', '2017-07-06 18:12:35', 'usuarioTemporal9071', 0),
(44, '44usuarioTemporal2453', 'N', '2017-07-06 18:13:45', '2017-07-06 18:13:45', 'usuarioTemporal2453', 0),
(45, '45usuarioTemporal9675', 'N', '2017-07-06 18:17:54', '2017-07-06 18:17:54', 'usuarioTemporal9675', 0),
(46, '46usuarioTemporal5859', 'N', '2017-07-06 18:19:03', '2017-07-06 18:19:03', 'usuarioTemporal5859', 0),
(47, '47\0#T4Fvӟ', 'N', '2017-07-06 18:19:13', '2017-07-06 18:19:13', '\0#T4Fvӟ', 1),
(48, '48usuarioTemporal2763', 'N', '2017-07-07 09:42:24', '2017-07-07 09:42:24', 'usuarioTemporal2763', 0),
(49, '49usuarioTemporal3404', 'N', '2017-07-07 09:47:15', '2017-07-07 09:47:15', 'usuarioTemporal3404', 0),
(50, '50\0#T4F{??', 'N', '2017-07-07 09:47:24', '2017-07-07 09:47:24', '\0#T4F{??', 1),
(51, '51usuarioTemporal5903', 'N', '2017-07-07 09:47:39', '2017-07-07 09:47:39', 'usuarioTemporal5903', 0),
(52, '52usuarioTemporal807', 'N', '2017-07-07 09:53:21', '2017-07-07 09:53:21', 'usuarioTemporal807', 0),
(53, '53usuarioTemporal6741', 'N', '2017-07-07 09:54:03', '2017-07-07 09:54:03', 'usuarioTemporal6741', 0),
(54, '54usuarioTemporal6323', 'N', '2017-07-07 09:56:39', '2017-07-07 09:56:39', 'usuarioTemporal6323', 0),
(55, '55usuarioTemporal8107', 'N', '2017-07-07 09:56:50', '2017-07-07 09:56:50', 'usuarioTemporal8107', 0),
(56, '56usuarioTemporal4483', 'N', '2017-07-07 11:45:26', '2017-07-07 11:45:26', 'usuarioTemporal4483', 0),
(57, '57usuarioTemporal3186', 'N', '2017-07-07 11:45:42', '2017-07-07 11:45:42', 'usuarioTemporal3186', 0),
(58, '58usuarioTemporal4560', 'N', '2017-07-07 11:45:55', '2017-07-07 11:45:55', 'usuarioTemporal4560', 0),
(59, '59usuarioTemporal6766', 'N', '2017-07-07 11:46:44', '2017-07-07 11:46:44', 'usuarioTemporal6766', 1),
(60, '60usuarioTemporal4347', 'N', '2017-07-07 12:26:59', '2017-07-07 12:26:59', 'usuarioTemporal4347', 0),
(61, '61usuarioTemporal6766', 'N', '2017-07-07 12:27:11', '2017-07-07 12:27:11', 'usuarioTemporal6766', 1),
(62, '1usuarioTemporal6766', 'N', '2017-07-07 12:27:12', '2017-07-07 12:27:12', 'usuarioTemporal6766', 1),
(63, '63usuarioTemporal9226', 'N', '2017-07-07 12:28:33', '2017-07-07 12:28:33', 'usuarioTemporal9226', 0),
(64, '64usuarioTemporal4316', 'N', '2017-07-07 12:49:14', '2017-07-07 12:49:14', 'usuarioTemporal4316', 0),
(65, '65usuarioTemporal671', 'N', '2017-07-07 12:50:10', '2017-07-07 12:50:10', 'usuarioTemporal671', 0),
(66, '66usuarioTemporal2782', 'N', '2017-07-07 13:39:56', '2017-07-07 13:39:56', 'usuarioTemporal2782', 0),
(67, '67usuarioTemporal6766', 'N', '2017-07-07 14:31:33', '2017-07-07 14:31:33', 'usuarioTemporal6766', 1),
(68, '68usuarioTemporal4431', 'N', '2017-07-07 14:32:54', '2017-07-07 14:32:54', 'usuarioTemporal4431', 0),
(69, '69usuarioTemporal7641', 'N', '2017-07-07 14:42:33', '2017-07-07 14:42:33', 'usuarioTemporal7641', 0),
(70, '70usuarioTemporal8951', 'N', '2017-07-07 14:47:38', '2017-07-07 14:47:38', 'usuarioTemporal8951', 0),
(71, '71usuarioTemporal2542', 'N', '2017-07-07 14:54:28', '2017-07-07 14:54:28', 'usuarioTemporal2542', 0),
(72, '72usuarioTemporal6766', 'N', '2017-07-07 15:02:14', '2017-07-07 15:02:14', 'usuarioTemporal6766', 1),
(73, '1usuarioTemporal6766', 'N', '2017-07-07 15:02:15', '2017-07-07 15:02:15', 'usuarioTemporal6766', 1),
(74, '74usuarioTemporal1031', 'N', '2017-07-07 15:27:12', '2017-07-07 15:27:12', 'usuarioTemporal1031', 0),
(75, '75usuarioTemporal2971', 'N', '2017-07-07 15:28:39', '2017-07-07 15:28:39', 'usuarioTemporal2971', 0),
(76, '76usuarioTemporal356', 'N', '2017-07-07 15:29:39', '2017-07-07 15:29:39', 'usuarioTemporal356', 0),
(77, '77usuarioTemporal6114', 'N', '2017-07-07 15:29:54', '2017-07-07 15:29:54', 'usuarioTemporal6114', 0),
(78, '78usuarioTemporal1614', 'N', '2017-07-07 15:30:03', '2017-07-07 15:30:03', 'usuarioTemporal1614', 0),
(79, '79usuarioTemporal4160', 'N', '2017-07-07 15:40:05', '2017-07-07 15:40:05', 'usuarioTemporal4160', 0),
(80, '80usuarioTemporal4493', 'N', '2017-07-07 15:40:15', '2017-07-07 15:40:15', 'usuarioTemporal4493', 0),
(81, '81usuarioTemporal4295', 'N', '2017-07-07 15:41:34', '2017-07-07 15:41:34', 'usuarioTemporal4295', 0),
(82, '82usuarioTemporal3682', 'N', '2017-07-07 15:41:52', '2017-07-07 15:41:52', 'usuarioTemporal3682', 0),
(83, '83usuarioTemporal8708', 'N', '2017-07-07 15:52:51', '2017-07-07 15:52:51', 'usuarioTemporal8708', 0),
(84, '84usuarioTemporal8866', 'N', '2017-07-07 15:53:02', '2017-07-07 15:53:02', 'usuarioTemporal8866', 0),
(85, '85usuarioTemporal4586', 'N', '2017-07-07 15:53:32', '2017-07-07 15:53:32', 'usuarioTemporal4586', 0),
(86, '86usuarioTemporal4734', 'N', '2017-07-07 15:54:19', '2017-07-07 15:54:19', 'usuarioTemporal4734', 0),
(87, '87usuarioTemporal4116', 'N', '2017-07-07 16:05:08', '2017-07-07 16:05:08', 'usuarioTemporal4116', 0),
(88, '88usuarioTemporal973', 'N', '2017-07-07 16:05:42', '2017-07-07 16:05:42', 'usuarioTemporal973', 0),
(89, '89usuarioTemporal4486', 'N', '2017-07-07 16:05:54', '2017-07-07 16:05:54', 'usuarioTemporal4486', 0),
(90, '90usuarioTemporal2271', 'N', '2017-07-07 16:06:10', '2017-07-07 16:06:10', 'usuarioTemporal2271', 0),
(91, '91usuarioTemporal7882', 'N', '2017-07-07 16:06:26', '2017-07-07 16:06:26', 'usuarioTemporal7882', 0),
(92, '92usuarioTemporal8314', 'N', '2017-07-07 16:07:39', '2017-07-07 16:07:39', 'usuarioTemporal8314', 0),
(93, '93usuarioTemporal1495', 'N', '2017-07-07 16:08:01', '2017-07-07 16:08:01', 'usuarioTemporal1495', 0),
(94, '94usuarioTemporal3792', 'N', '2017-07-07 16:08:54', '2017-07-07 16:08:54', 'usuarioTemporal3792', 0),
(95, '95usuarioTemporal7509', 'N', '2017-07-07 16:12:36', '2017-07-07 16:12:36', 'usuarioTemporal7509', 0),
(96, '96usuarioTemporal8390', 'N', '2017-07-07 16:13:14', '2017-07-07 16:13:14', 'usuarioTemporal8390', 0),
(97, '97usuarioTemporal3114', 'N', '2017-07-07 16:13:58', '2017-07-07 16:13:58', 'usuarioTemporal3114', 0),
(98, '9898usuarioTemporal3133', 'N', '2017-07-07 16:19:54', '2017-07-07 16:19:54', '98usuarioTemporal3133', 1),
(99, '99usuarioTemporal6797', 'N', '2017-07-07 16:21:45', '2017-07-07 16:21:45', 'usuarioTemporal6797', 0),
(100, '100usuarioTemporal495', 'N', '2017-07-07 16:36:18', '2017-07-07 16:36:18', 'usuarioTemporal495', 0),
(101, '101usuarioTemporal8700', 'N', '2017-07-07 16:37:34', '2017-07-07 16:37:34', 'usuarioTemporal8700', 0),
(102, '102usuarioTemporal6841', 'N', '2017-07-07 16:39:46', '2017-07-07 16:39:46', 'usuarioTemporal6841', 0),
(103, '103usuarioTemporal8786', 'N', '2017-07-07 16:46:10', '2017-07-07 16:46:10', 'usuarioTemporal8786', 0),
(104, '104usuarioTemporal4340', 'N', '2017-07-07 16:47:16', '2017-07-07 16:47:16', 'usuarioTemporal4340', 0),
(105, '105usuarioTemporal6744', 'N', '2017-07-07 16:54:29', '2017-07-07 16:54:29', 'usuarioTemporal6744', 0),
(106, '106usuarioTemporal179', 'N', '2017-07-07 16:54:55', '2017-07-07 16:54:55', 'usuarioTemporal179', 0),
(107, '107usuarioTemporal7261', 'N', '2017-07-07 17:04:02', '2017-07-07 17:04:02', 'usuarioTemporal7261', 0),
(108, '108usuarioTemporal6545', 'N', '2017-07-07 17:04:33', '2017-07-07 17:04:33', 'usuarioTemporal6545', 0),
(109, '109usuarioTemporal24', 'N', '2017-07-07 17:06:31', '2017-07-07 17:06:31', 'usuarioTemporal24', 0),
(110, '110usuarioTemporal626', 'N', '2017-07-07 17:07:09', '2017-07-07 17:07:09', 'usuarioTemporal626', 0),
(111, '111usuarioTemporal9719', 'N', '2017-07-07 17:07:16', '2017-07-07 17:07:16', 'usuarioTemporal9719', 0),
(112, '112usuarioTemporal4609', 'N', '2017-07-07 17:07:23', '2017-07-07 17:07:23', 'usuarioTemporal4609', 0),
(113, '113usuarioTemporal1458', 'N', '2017-07-18 11:43:00', '2017-07-18 11:43:00', 'usuarioTemporal1458', 0),
(114, '114usuarioTemporal6741', 'N', '2017-07-18 11:53:39', '2017-07-18 11:53:39', 'usuarioTemporal6741', 0),
(115, '115usuarioTemporal4588', 'N', '2017-07-18 11:53:45', '2017-07-18 11:53:45', 'usuarioTemporal4588', 0),
(116, '116usuarioTemporal3818', 'N', '2017-07-18 11:58:17', '2017-07-18 11:58:17', 'usuarioTemporal3818', 0),
(117, '117usuarioTemporal5368', 'N', '2017-07-19 18:39:22', '2017-07-19 18:39:22', 'usuarioTemporal5368', 0),
(118, '118usuarioTemporal6323', 'N', '2017-07-19 18:39:57', '2017-07-19 18:39:57', 'usuarioTemporal6323', 0),
(119, '119usuarioTemporal6433', 'N', '2017-07-19 18:40:53', '2017-07-19 18:40:53', 'usuarioTemporal6433', 0),
(120, '120usuarioTemporal8107', 'N', '2017-07-19 18:41:13', '2017-07-19 18:41:13', 'usuarioTemporal8107', 0),
(121, '121usuarioTemporal2667', 'N', '2017-07-19 18:41:33', '2017-07-19 18:41:33', 'usuarioTemporal2667', 0),
(122, '122usuarioTemporal9109', 'N', '2017-07-19 18:41:34', '2017-07-19 18:41:34', 'usuarioTemporal9109', 0),
(123, '123usuarioTemporal4086', 'N', '2017-07-19 18:41:44', '2017-07-19 18:41:44', 'usuarioTemporal4086', 0),
(124, '124usuarioTemporal9523', 'N', '2017-07-19 18:41:57', '2017-07-19 18:41:57', 'usuarioTemporal9523', 0),
(125, '125usuarioTemporal7188', 'N', '2017-07-19 18:42:13', '2017-07-19 18:42:13', 'usuarioTemporal7188', 0),
(126, '126usuarioTemporal5694', 'N', '2017-07-19 18:42:24', '2017-07-19 18:42:24', 'usuarioTemporal5694', 0),
(127, '127usuarioTemporal8261', 'N', '2017-07-19 18:43:39', '2017-07-19 18:43:39', 'usuarioTemporal8261', 0),
(128, '128usuarioTemporal6470', 'N', '2017-07-19 18:44:50', '2017-07-19 18:44:50', 'usuarioTemporal6470', 0),
(129, '129usuarioTemporal1179', 'N', '2017-07-19 18:45:01', '2017-07-19 18:45:01', 'usuarioTemporal1179', 0),
(130, '130usuarioTemporal562', 'N', '2017-07-19 18:46:01', '2017-07-19 18:46:01', 'usuarioTemporal562', 0),
(131, '131usuarioTemporal8781', 'N', '2017-07-19 18:46:22', '2017-07-19 18:46:22', 'usuarioTemporal8781', 0),
(132, '132usuarioTemporal1367', 'N', '2017-07-19 18:46:40', '2017-07-19 18:46:40', 'usuarioTemporal1367', 0),
(133, '133usuarioTemporal2353', 'N', '2017-07-19 18:48:06', '2017-07-19 18:48:06', 'usuarioTemporal2353', 0),
(134, '134usuarioTemporal3922', 'N', '2017-07-19 18:48:12', '2017-07-19 18:48:12', 'usuarioTemporal3922', 0),
(135, '135usuarioTemporal7212', 'N', '2017-07-19 18:48:51', '2017-07-19 18:48:51', 'usuarioTemporal7212', 0),
(136, '136usuarioTemporal9626', 'N', '2017-07-19 18:48:53', '2017-07-19 18:48:53', 'usuarioTemporal9626', 0),
(137, '137usuarioTemporal4471', 'N', '2017-07-19 18:49:26', '2017-07-19 18:49:26', 'usuarioTemporal4471', 0),
(138, '138usuarioTemporal1143', 'N', '2017-07-19 18:50:23', '2017-07-19 18:50:23', 'usuarioTemporal1143', 0),
(139, '139usuarioTemporal8242', 'N', '2017-07-19 18:50:33', '2017-07-19 18:50:33', 'usuarioTemporal8242', 0),
(140, '140usuarioTemporal6932', 'N', '2017-07-19 18:50:46', '2017-07-19 18:50:46', 'usuarioTemporal6932', 0),
(141, '141usuarioTemporal4912', 'N', '2017-07-19 18:50:48', '2017-07-19 18:50:48', 'usuarioTemporal4912', 0),
(142, '142usuarioTemporal7282', 'N', '2017-07-19 18:50:49', '2017-07-19 18:50:49', 'usuarioTemporal7282', 0),
(143, '143usuarioTemporal1118', 'N', '2017-07-19 18:51:35', '2017-07-19 18:51:35', 'usuarioTemporal1118', 0),
(144, '144usuarioTemporal3534', 'N', '2017-07-19 18:52:06', '2017-07-19 18:52:06', 'usuarioTemporal3534', 0),
(145, '145usuarioTemporal4097', 'N', '2017-07-19 18:52:24', '2017-07-19 18:52:24', 'usuarioTemporal4097', 0),
(146, '146usuarioTemporal7839', 'N', '2017-07-19 18:53:38', '2017-07-19 18:53:38', 'usuarioTemporal7839', 0),
(147, '147usuarioTemporal7855', 'N', '2017-07-19 18:53:59', '2017-07-19 18:53:59', 'usuarioTemporal7855', 0),
(148, '148usuarioTemporal6228', 'N', '2017-07-19 18:54:03', '2017-07-19 18:54:03', 'usuarioTemporal6228', 0),
(149, '149usuarioTemporal9564', 'N', '2017-07-19 18:54:49', '2017-07-19 18:54:49', 'usuarioTemporal9564', 0),
(150, '150usuarioTemporal7516', 'N', '2017-07-19 18:55:35', '2017-07-19 18:55:35', 'usuarioTemporal7516', 0),
(151, '151usuarioTemporal873', 'N', '2017-07-19 18:56:20', '2017-07-19 18:56:20', 'usuarioTemporal873', 0),
(152, '152usuarioTemporal7251', 'N', '2017-07-19 18:56:28', '2017-07-19 18:56:28', 'usuarioTemporal7251', 0),
(153, '153usuarioTemporal207', 'N', '2017-07-19 18:58:45', '2017-07-19 18:58:45', 'usuarioTemporal207', 0),
(154, '154usuarioTemporal5149', 'N', '2017-07-19 18:58:54', '2017-07-19 18:58:54', 'usuarioTemporal5149', 0),
(155, '155usuarioTemporal5861', 'N', '2017-07-19 18:58:59', '2017-07-19 18:58:59', 'usuarioTemporal5861', 0),
(156, '156usuarioTemporal6732', 'N', '2017-07-19 18:59:27', '2017-07-19 18:59:27', 'usuarioTemporal6732', 0),
(157, '157usuarioTemporal1199', 'N', '2017-07-19 18:59:43', '2017-07-19 18:59:43', 'usuarioTemporal1199', 0),
(158, '158usuarioTemporal2414', 'N', '2017-07-20 16:11:23', '2017-07-20 16:11:23', 'usuarioTemporal2414', 0),
(159, '159usuarioTemporal4248', 'N', '2017-07-20 16:13:25', '2017-07-20 16:13:25', 'usuarioTemporal4248', 0),
(160, '160usuarioTemporal9410', 'N', '2017-07-20 16:14:34', '2017-07-20 16:14:34', 'usuarioTemporal9410', 0),
(161, '161usuarioTemporal1710', 'N', '2017-07-20 16:20:51', '2017-07-20 16:20:51', 'usuarioTemporal1710', 0),
(162, '162usuarioTemporal3038', 'N', '2017-07-20 16:21:09', '2017-07-20 16:21:09', 'usuarioTemporal3038', 0),
(163, '163usuarioTemporal611', 'N', '2017-07-20 16:25:00', '2017-07-20 16:25:00', 'usuarioTemporal611', 0),
(164, '164usuarioTemporal9398', 'N', '2017-07-20 16:25:08', '2017-07-20 16:25:08', 'usuarioTemporal9398', 0),
(165, '165usuarioTemporal7827', 'N', '2017-07-20 16:25:40', '2017-07-20 16:25:40', 'usuarioTemporal7827', 0),
(166, '166usuarioTemporal9771', 'N', '2017-07-20 16:28:44', '2017-07-20 16:28:44', 'usuarioTemporal9771', 0),
(167, '167usuarioTemporal7792', 'N', '2017-07-20 16:29:59', '2017-07-20 16:29:59', 'usuarioTemporal7792', 0),
(168, '168usuarioTemporal4925', 'N', '2017-07-20 16:30:09', '2017-07-20 16:30:09', 'usuarioTemporal4925', 0),
(169, '169usuarioTemporal7475', 'N', '2017-07-20 16:30:14', '2017-07-20 16:30:14', 'usuarioTemporal7475', 0),
(170, '170usuarioTemporal6757', 'N', '2017-07-20 16:30:50', '2017-07-20 16:30:50', 'usuarioTemporal6757', 0),
(171, '171usuarioTemporal2987', 'N', '2017-07-20 16:32:02', '2017-07-20 16:32:02', 'usuarioTemporal2987', 0),
(172, '172usuarioTemporal3757', 'N', '2017-07-20 16:33:04', '2017-07-20 16:33:04', 'usuarioTemporal3757', 0),
(173, '173usuarioTemporal1790', 'N', '2017-07-20 16:33:43', '2017-07-20 16:33:43', 'usuarioTemporal1790', 0),
(174, '174usuarioTemporal5627', 'N', '2017-07-20 16:45:48', '2017-07-20 16:45:48', 'usuarioTemporal5627', 0),
(175, '175usuarioTemporal8170', 'N', '2017-07-20 16:47:03', '2017-07-20 16:47:03', 'usuarioTemporal8170', 0),
(176, '176usuarioTemporal1647', 'N', '2017-07-20 16:48:03', '2017-07-20 16:48:03', 'usuarioTemporal1647', 0),
(177, '177usuarioTemporal8125', 'N', '2017-07-20 16:48:44', '2017-07-20 16:48:44', 'usuarioTemporal8125', 0),
(178, '178usuarioTemporal856', 'N', '2017-07-20 16:49:53', '2017-07-20 16:49:53', 'usuarioTemporal856', 0),
(179, '179usuarioTemporal9185', 'N', '2017-07-20 16:50:46', '2017-07-20 16:50:46', 'usuarioTemporal9185', 0),
(180, '180usuarioTemporal9833', 'N', '2017-07-20 17:00:14', '2017-07-20 17:00:14', 'usuarioTemporal9833', 0),
(181, '181usuarioTemporal4194', 'N', '2017-07-20 17:02:00', '2017-07-20 17:02:00', 'usuarioTemporal4194', 0),
(182, '182usuarioTemporal4291', 'N', '2017-07-20 17:03:15', '2017-07-20 17:03:15', 'usuarioTemporal4291', 0),
(183, '183usuarioTemporal3660', 'N', '2017-07-20 17:04:17', '2017-07-20 17:04:17', 'usuarioTemporal3660', 0),
(184, '184usuarioTemporal7266', 'N', '2017-07-20 17:05:17', '2017-07-20 17:05:17', 'usuarioTemporal7266', 0),
(185, '185usuarioTemporal9574', 'N', '2017-07-20 17:05:34', '2017-07-20 17:05:34', 'usuarioTemporal9574', 0),
(186, '186usuarioTemporal6947', 'N', '2017-07-20 17:05:50', '2017-07-20 17:05:50', 'usuarioTemporal6947', 0),
(187, '187usuarioTemporal2100', 'N', '2017-07-20 17:06:28', '2017-07-20 17:06:28', 'usuarioTemporal2100', 0),
(188, '188usuarioTemporal8961', 'N', '2017-07-20 19:35:19', '2017-07-20 19:35:19', 'usuarioTemporal8961', 0),
(189, '189usuarioTemporal8880', 'N', '2017-07-20 19:35:21', '2017-07-20 19:35:21', 'usuarioTemporal8880', 0),
(190, '190usuarioTemporal4584', 'N', '2017-07-20 19:37:30', '2017-07-20 19:37:30', 'usuarioTemporal4584', 0),
(191, '191usuarioTemporal2898', 'N', '2017-07-20 19:38:11', '2017-07-20 19:38:11', 'usuarioTemporal2898', 0),
(192, '192usuarioTemporal4321', 'N', '2017-07-20 19:38:47', '2017-07-20 19:38:47', 'usuarioTemporal4321', 0),
(193, '193usuarioTemporal7806', 'N', '2017-07-20 19:40:23', '2017-07-20 19:40:23', 'usuarioTemporal7806', 0),
(194, '194usuarioTemporal9977', 'N', '2017-07-20 19:41:00', '2017-07-20 19:41:00', 'usuarioTemporal9977', 0),
(195, '195usuarioTemporal4539', 'N', '2017-07-20 19:41:30', '2017-07-20 19:41:30', 'usuarioTemporal4539', 0),
(196, '196usuarioTemporal4743', 'N', '2017-07-20 19:42:18', '2017-07-20 19:42:18', 'usuarioTemporal4743', 0),
(197, '197usuarioTemporal178', 'N', '2017-07-20 19:43:07', '2017-07-20 19:43:07', 'usuarioTemporal178', 0),
(198, '198usuarioTemporal6468', 'N', '2017-07-20 19:43:25', '2017-07-20 19:43:25', 'usuarioTemporal6468', 0),
(199, '199usuarioTemporal333', 'N', '2017-07-20 19:43:36', '2017-07-20 19:43:36', 'usuarioTemporal333', 0),
(200, '200usuarioTemporal3068', 'N', '2017-07-20 19:43:46', '2017-07-20 19:43:46', 'usuarioTemporal3068', 0),
(201, '201usuarioTemporal6968', 'N', '2017-07-20 19:43:56', '2017-07-20 19:43:56', 'usuarioTemporal6968', 0),
(202, '202usuarioTemporal6248', 'N', '2017-07-20 19:44:07', '2017-07-20 19:44:07', 'usuarioTemporal6248', 0),
(203, '203usuarioTemporal3794', 'N', '2017-07-20 19:44:48', '2017-07-20 19:44:48', 'usuarioTemporal3794', 0),
(204, '204usuarioTemporal9208', 'N', '2017-07-20 19:45:10', '2017-07-20 19:45:10', 'usuarioTemporal9208', 0),
(205, '205usuarioTemporal8839', 'N', '2017-07-20 19:45:21', '2017-07-20 19:45:21', 'usuarioTemporal8839', 0),
(206, '206usuarioTemporal3797', 'N', '2017-07-20 19:45:33', '2017-07-20 19:45:33', 'usuarioTemporal3797', 0),
(207, '207usuarioTemporal5978', 'N', '2017-07-20 19:45:41', '2017-07-20 19:45:41', 'usuarioTemporal5978', 0),
(208, '208usuarioTemporal7834', 'N', '2017-07-20 19:46:46', '2017-07-20 19:46:46', 'usuarioTemporal7834', 0),
(209, '209usuarioTemporal9427', 'N', '2017-07-20 19:54:30', '2017-07-20 19:54:30', 'usuarioTemporal9427', 0),
(210, '210usuarioTemporal2426', 'N', '2017-07-20 19:56:35', '2017-07-20 19:56:35', 'usuarioTemporal2426', 0),
(211, '211usuarioTemporal8781', 'N', '2017-07-20 19:56:48', '2017-07-20 19:56:48', 'usuarioTemporal8781', 0),
(212, '212usuarioTemporal9746', 'N', '2017-07-20 19:57:08', '2017-07-20 19:57:08', 'usuarioTemporal9746', 0),
(213, '213usuarioTemporal8785', 'N', '2017-07-20 19:57:37', '2017-07-20 19:57:37', 'usuarioTemporal8785', 0),
(214, '214usuarioTemporal2184', 'N', '2017-07-20 19:57:40', '2017-07-20 19:57:40', 'usuarioTemporal2184', 0),
(215, '215usuarioTemporal9309', 'N', '2017-07-20 19:58:47', '2017-07-20 19:58:47', 'usuarioTemporal9309', 0),
(216, '216usuarioTemporal2999', 'N', '2017-07-20 20:00:01', '2017-07-20 20:00:01', 'usuarioTemporal2999', 0),
(217, '217usuarioTemporal4014', 'N', '2017-07-20 20:01:49', '2017-07-20 20:01:49', 'usuarioTemporal4014', 0),
(218, '218usuarioTemporal8967', 'N', '2017-07-20 20:02:35', '2017-07-20 20:02:35', 'usuarioTemporal8967', 0),
(219, '219usuarioTemporal6591', 'N', '2017-07-20 20:04:26', '2017-07-20 20:04:26', 'usuarioTemporal6591', 0),
(220, '220usuarioTemporal2628', 'N', '2017-07-20 20:04:59', '2017-07-20 20:04:59', 'usuarioTemporal2628', 0),
(221, '221usuarioTemporal3758', 'N', '2017-07-20 20:11:29', '2017-07-20 20:11:29', 'usuarioTemporal3758', 0),
(222, '222usuarioTemporal5098', 'N', '2017-07-20 20:13:54', '2017-07-20 20:13:54', 'usuarioTemporal5098', 0),
(223, '223usuarioTemporal7702', 'N', '2017-07-20 20:14:27', '2017-07-20 20:14:27', 'usuarioTemporal7702', 0),
(224, '224usuarioTemporal6063', 'N', '2017-07-20 20:15:14', '2017-07-20 20:15:14', 'usuarioTemporal6063', 0),
(225, '225usuarioTemporal8417', 'N', '2017-07-20 20:15:22', '2017-07-20 20:15:22', 'usuarioTemporal8417', 0),
(226, '226usuarioTemporal2441', 'N', '2017-07-20 20:17:19', '2017-07-20 20:17:19', 'usuarioTemporal2441', 0),
(227, '227usuarioTemporal7813', 'N', '2017-07-20 20:18:16', '2017-07-20 20:18:16', 'usuarioTemporal7813', 0),
(228, '228usuarioTemporal6410', 'N', '2017-07-20 20:18:45', '2017-07-20 20:18:45', 'usuarioTemporal6410', 0),
(229, '229usuarioTemporal5611', 'N', '2017-07-20 20:19:03', '2017-07-20 20:19:03', 'usuarioTemporal5611', 0),
(230, '230usuarioTemporal2992', 'N', '2017-07-20 20:19:44', '2017-07-20 20:19:44', 'usuarioTemporal2992', 0),
(231, '231usuarioTemporal9177', 'N', '2017-07-20 20:23:15', '2017-07-20 20:23:15', 'usuarioTemporal9177', 0),
(232, '232usuarioTemporal9958', 'N', '2017-07-20 20:24:15', '2017-07-20 20:24:15', 'usuarioTemporal9958', 0),
(233, '233usuarioTemporal3874', 'N', '2017-07-20 20:27:54', '2017-07-20 20:27:54', 'usuarioTemporal3874', 0),
(234, '234usuarioTemporal2627', 'N', '2017-07-20 20:28:01', '2017-07-20 20:28:01', 'usuarioTemporal2627', 0),
(235, '235usuarioTemporal8995', 'N', '2017-07-20 20:28:29', '2017-07-20 20:28:29', 'usuarioTemporal8995', 0),
(236, '236usuarioTemporal2273', 'N', '2017-07-20 20:28:35', '2017-07-20 20:28:35', 'usuarioTemporal2273', 0),
(237, '237usuarioTemporal4216', 'N', '2017-07-20 20:28:56', '2017-07-20 20:28:56', 'usuarioTemporal4216', 0),
(238, '238usuarioTemporal3448', 'N', '2017-07-20 20:29:11', '2017-07-20 20:29:11', 'usuarioTemporal3448', 0),
(239, '239usuarioTemporal3436', 'N', '2017-07-20 20:29:32', '2017-07-20 20:29:32', 'usuarioTemporal3436', 0),
(240, '240usuarioTemporal8755', 'N', '2017-07-20 20:29:48', '2017-07-20 20:29:48', 'usuarioTemporal8755', 0),
(241, '241usuarioTemporal9581', 'N', '2017-07-20 20:30:27', '2017-07-20 20:30:27', 'usuarioTemporal9581', 0),
(242, '242usuarioTemporal3628', 'N', '2017-07-20 20:30:40', '2017-07-20 20:30:40', 'usuarioTemporal3628', 0),
(243, '243usuarioTemporal3722', 'N', '2017-07-20 20:30:58', '2017-07-20 20:30:58', 'usuarioTemporal3722', 0),
(244, '244usuarioTemporal1464', 'N', '2017-07-20 20:34:30', '2017-07-20 20:34:30', 'usuarioTemporal1464', 0),
(245, '245usuarioTemporal719', 'N', '2017-07-20 20:35:49', '2017-07-20 20:35:49', 'usuarioTemporal719', 0),
(246, '246usuarioTemporal6216', 'N', '2017-07-20 20:37:15', '2017-07-20 20:37:15', 'usuarioTemporal6216', 0),
(247, '247usuarioTemporal4929', 'N', '2017-07-20 20:37:33', '2017-07-20 20:37:33', 'usuarioTemporal4929', 0),
(248, '248usuarioTemporal5776', 'N', '2017-07-20 20:38:00', '2017-07-20 20:38:00', 'usuarioTemporal5776', 0),
(249, '249usuarioTemporal7850', 'N', '2017-07-20 20:38:09', '2017-07-20 20:38:09', 'usuarioTemporal7850', 0),
(250, '250usuarioTemporal8059', 'N', '2017-07-20 20:38:14', '2017-07-20 20:38:14', 'usuarioTemporal8059', 0),
(251, '251usuarioTemporal5800', 'N', '2017-07-20 20:38:53', '2017-07-20 20:38:53', 'usuarioTemporal5800', 0),
(252, '252usuarioTemporal874', 'N', '2017-07-20 20:39:28', '2017-07-20 20:39:28', 'usuarioTemporal874', 0),
(253, '253usuarioTemporal1874', 'N', '2017-07-20 20:42:42', '2017-07-20 20:42:42', 'usuarioTemporal1874', 0),
(254, '254usuarioTemporal6736', 'N', '2017-07-20 20:43:40', '2017-07-20 20:43:40', 'usuarioTemporal6736', 0),
(255, '255usuarioTemporal8920', 'N', '2017-07-20 20:43:47', '2017-07-20 20:43:47', 'usuarioTemporal8920', 0),
(256, '256usuarioTemporal6348', 'N', '2017-07-20 20:44:15', '2017-07-20 20:44:15', 'usuarioTemporal6348', 0),
(257, '257usuarioTemporal1830', 'N', '2017-07-20 20:44:29', '2017-07-20 20:44:29', 'usuarioTemporal1830', 0),
(258, '258usuarioTemporal9270', 'N', '2017-07-20 20:44:36', '2017-07-20 20:44:36', 'usuarioTemporal9270', 0),
(259, '259usuarioTemporal1109', 'N', '2017-07-20 20:44:58', '2017-07-20 20:44:58', 'usuarioTemporal1109', 0),
(260, '260usuarioTemporal5750', 'N', '2017-07-20 20:45:07', '2017-07-20 20:45:07', 'usuarioTemporal5750', 0),
(261, '261usuarioTemporal452', 'N', '2017-07-20 20:46:34', '2017-07-20 20:46:34', 'usuarioTemporal452', 0),
(262, '262usuarioTemporal642', 'N', '2017-07-20 20:47:11', '2017-07-20 20:47:11', 'usuarioTemporal642', 0),
(263, '263usuarioTemporal2565', 'N', '2017-07-20 20:47:23', '2017-07-20 20:47:23', 'usuarioTemporal2565', 0),
(264, '264usuarioTemporal1154', 'N', '2017-07-20 20:48:17', '2017-07-20 20:48:17', 'usuarioTemporal1154', 0),
(265, '265usuarioTemporal4947', 'N', '2017-07-20 20:48:35', '2017-07-20 20:48:35', 'usuarioTemporal4947', 0),
(266, '266usuarioTemporal6621', 'N', '2017-07-20 20:50:32', '2017-07-20 20:50:32', 'usuarioTemporal6621', 0),
(267, '267usuarioTemporal1060', 'N', '2017-07-20 20:50:42', '2017-07-20 20:50:42', 'usuarioTemporal1060', 0),
(268, '268usuarioTemporal3799', 'N', '2017-07-20 20:50:58', '2017-07-20 20:50:58', 'usuarioTemporal3799', 0),
(269, '269usuarioTemporal4599', 'N', '2017-07-20 20:51:43', '2017-07-20 20:51:43', 'usuarioTemporal4599', 0),
(270, '270usuarioTemporal7377', 'N', '2017-07-20 20:52:02', '2017-07-20 20:52:02', 'usuarioTemporal7377', 0),
(271, '271usuarioTemporal443', 'N', '2017-07-20 20:55:08', '2017-07-20 20:55:08', 'usuarioTemporal443', 0),
(272, '272usuarioTemporal213', 'N', '2017-07-20 20:55:28', '2017-07-20 20:55:28', 'usuarioTemporal213', 0),
(273, '273usuarioTemporal4122', 'N', '2017-07-20 20:55:41', '2017-07-20 20:55:41', 'usuarioTemporal4122', 0),
(274, '274usuarioTemporal5769', 'N', '2017-07-20 20:55:52', '2017-07-20 20:55:52', 'usuarioTemporal5769', 0),
(275, '275usuarioTemporal9672', 'N', '2017-07-20 20:57:57', '2017-07-20 20:57:57', 'usuarioTemporal9672', 0),
(276, '276usuarioTemporal2313', 'N', '2017-07-20 20:58:10', '2017-07-20 20:58:10', 'usuarioTemporal2313', 0),
(277, '277usuarioTemporal3318', 'N', '2017-07-20 20:58:39', '2017-07-20 20:58:39', 'usuarioTemporal3318', 0),
(278, '278usuarioTemporal4475', 'N', '2017-07-20 20:58:52', '2017-07-20 20:58:52', 'usuarioTemporal4475', 0),
(279, '279usuarioTemporal7736', 'N', '2017-07-20 20:59:10', '2017-07-20 20:59:10', 'usuarioTemporal7736', 0),
(280, '280usuarioTemporal8547', 'N', '2017-07-20 20:59:21', '2017-07-20 20:59:21', 'usuarioTemporal8547', 0),
(281, '281usuarioTemporal7232', 'N', '2017-07-20 21:00:12', '2017-07-20 21:00:12', 'usuarioTemporal7232', 0),
(282, '282usuarioTemporal6676', 'N', '2017-07-20 21:06:07', '2017-07-20 21:06:07', 'usuarioTemporal6676', 0),
(283, '283usuarioTemporal3199', 'N', '2017-07-20 21:06:51', '2017-07-20 21:06:51', 'usuarioTemporal3199', 0),
(284, '284usuarioTemporal5860', 'N', '2017-07-20 21:07:09', '2017-07-20 21:07:09', 'usuarioTemporal5860', 0),
(285, '285usuarioTemporal7073', 'N', '2017-07-20 21:08:24', '2017-07-20 21:08:24', 'usuarioTemporal7073', 0),
(286, '286usuarioTemporal4214', 'N', '2017-07-20 21:09:39', '2017-07-20 21:09:39', 'usuarioTemporal4214', 0),
(287, '287usuarioTemporal1812', 'N', '2017-07-20 21:09:59', '2017-07-20 21:09:59', 'usuarioTemporal1812', 0),
(288, '288usuarioTemporal6508', 'N', '2017-07-20 21:10:17', '2017-07-20 21:10:17', 'usuarioTemporal6508', 0),
(289, '289usuarioTemporal2139', 'N', '2017-07-20 21:11:43', '2017-07-20 21:11:43', 'usuarioTemporal2139', 0),
(290, '290usuarioTemporal1142', 'N', '2017-07-20 21:12:52', '2017-07-20 21:12:52', 'usuarioTemporal1142', 0),
(291, '291usuarioTemporal8699', 'N', '2017-07-20 21:13:30', '2017-07-20 21:13:30', 'usuarioTemporal8699', 0),
(292, '292usuarioTemporal9455', 'N', '2017-07-20 21:14:28', '2017-07-20 21:14:28', 'usuarioTemporal9455', 0),
(293, '293usuarioTemporal872', 'N', '2017-07-20 21:14:51', '2017-07-20 21:14:51', 'usuarioTemporal872', 0),
(294, '294usuarioTemporal5094', 'N', '2017-07-20 21:15:30', '2017-07-20 21:15:30', 'usuarioTemporal5094', 0),
(295, '295usuarioTemporal6461', 'N', '2017-07-20 21:16:20', '2017-07-20 21:16:20', 'usuarioTemporal6461', 0),
(296, '296usuarioTemporal8994', 'N', '2017-07-20 21:17:02', '2017-07-20 21:17:02', 'usuarioTemporal8994', 0),
(297, '297usuarioTemporal3906', 'N', '2017-07-20 21:21:14', '2017-07-20 21:21:14', 'usuarioTemporal3906', 0),
(298, '298usuarioTemporal4707', 'N', '2017-07-20 21:22:30', '2017-07-20 21:22:30', 'usuarioTemporal4707', 0),
(299, '299usuarioTemporal6801', 'N', '2017-07-20 21:23:07', '2017-07-20 21:23:07', 'usuarioTemporal6801', 0),
(300, '300usuarioTemporal6507', 'N', '2017-07-20 21:24:13', '2017-07-20 21:24:13', 'usuarioTemporal6507', 0),
(301, '301usuarioTemporal1600', 'N', '2017-07-20 21:25:56', '2017-07-20 21:25:56', 'usuarioTemporal1600', 0),
(302, '302usuarioTemporal7038', 'N', '2017-07-20 21:26:15', '2017-07-20 21:26:15', 'usuarioTemporal7038', 0),
(303, '303usuarioTemporal2472', 'N', '2017-07-20 21:27:19', '2017-07-20 21:27:19', 'usuarioTemporal2472', 0),
(304, '304usuarioTemporal9737', 'N', '2017-07-20 21:31:49', '2017-07-20 21:31:49', 'usuarioTemporal9737', 0),
(305, '305usuarioTemporal357', 'N', '2017-07-20 21:47:45', '2017-07-20 21:47:45', 'usuarioTemporal357', 0),
(306, '306usuarioTemporal3042', 'N', '2017-07-20 22:25:14', '2017-07-20 22:25:14', 'usuarioTemporal3042', 0),
(307, '307usuarioTemporal1191', 'N', '2017-07-20 22:25:41', '2017-07-20 22:25:41', 'usuarioTemporal1191', 0),
(308, '308usuarioTemporal390', 'N', '2017-07-20 22:28:10', '2017-07-20 22:28:10', 'usuarioTemporal390', 0),
(309, '309usuarioTemporal5911', 'N', '2017-07-20 22:29:20', '2017-07-20 22:29:20', 'usuarioTemporal5911', 0),
(310, '310usuarioTemporal217', 'N', '2017-07-20 22:29:37', '2017-07-20 22:29:37', 'usuarioTemporal217', 0),
(311, '311usuarioTemporal456', 'N', '2017-07-20 22:30:48', '2017-07-20 22:30:48', 'usuarioTemporal456', 0),
(312, '312usuarioTemporal5963', 'N', '2017-07-20 22:31:10', '2017-07-20 22:31:10', 'usuarioTemporal5963', 0),
(313, '313usuarioTemporal5762', 'N', '2017-07-20 22:31:16', '2017-07-20 22:31:16', 'usuarioTemporal5762', 0),
(314, '314usuarioTemporal6064', 'N', '2017-07-20 22:31:43', '2017-07-20 22:31:43', 'usuarioTemporal6064', 0),
(315, '315usuarioTemporal7767', 'N', '2017-07-20 22:31:50', '2017-07-20 22:31:50', 'usuarioTemporal7767', 0),
(316, '316usuarioTemporal3959', 'N', '2017-07-20 22:33:35', '2017-07-20 22:33:35', 'usuarioTemporal3959', 0),
(317, '317usuarioTemporal7410', 'N', '2017-07-20 22:34:32', '2017-07-20 22:34:32', 'usuarioTemporal7410', 0),
(318, '318usuarioTemporal8083', 'N', '2017-07-20 22:34:56', '2017-07-20 22:34:56', 'usuarioTemporal8083', 0),
(319, '319usuarioTemporal627', 'N', '2017-07-20 22:35:36', '2017-07-20 22:35:36', 'usuarioTemporal627', 0),
(320, '320usuarioTemporal1876', 'N', '2017-07-20 22:36:07', '2017-07-20 22:36:07', 'usuarioTemporal1876', 0),
(321, '321usuarioTemporal8354', 'N', '2017-07-20 22:37:47', '2017-07-20 22:37:47', 'usuarioTemporal8354', 0),
(322, '322usuarioTemporal3774', 'N', '2017-07-20 22:38:20', '2017-07-20 22:38:20', 'usuarioTemporal3774', 0),
(323, '323usuarioTemporal6532', 'N', '2017-07-20 22:38:42', '2017-07-20 22:38:42', 'usuarioTemporal6532', 0),
(324, '324usuarioTemporal7215', 'N', '2017-07-20 22:39:04', '2017-07-20 22:39:04', 'usuarioTemporal7215', 0),
(325, '325usuarioTemporal6096', 'N', '2017-07-20 22:40:52', '2017-07-20 22:40:52', 'usuarioTemporal6096', 0),
(326, '326usuarioTemporal637', 'N', '2017-07-20 22:40:59', '2017-07-20 22:40:59', 'usuarioTemporal637', 0),
(327, '327usuarioTemporal2985', 'N', '2017-07-20 22:41:22', '2017-07-20 22:41:22', 'usuarioTemporal2985', 0),
(328, '328usuarioTemporal7476', 'N', '2017-07-20 22:42:48', '2017-07-20 22:42:48', 'usuarioTemporal7476', 0),
(329, '329usuarioTemporal8135', 'N', '2017-07-20 22:43:56', '2017-07-20 22:43:56', 'usuarioTemporal8135', 0),
(330, '330usuarioTemporal6171', 'N', '2017-07-20 22:44:24', '2017-07-20 22:44:24', 'usuarioTemporal6171', 0),
(331, '331usuarioTemporal7484', 'N', '2017-07-20 22:47:46', '2017-07-20 22:47:46', 'usuarioTemporal7484', 0),
(332, '332usuarioTemporal160', 'N', '2017-07-20 22:48:07', '2017-07-20 22:48:07', 'usuarioTemporal160', 0),
(333, '333usuarioTemporal1971', 'N', '2017-07-20 22:48:24', '2017-07-20 22:48:24', 'usuarioTemporal1971', 0),
(334, '334usuarioTemporal7878', 'N', '2017-07-20 22:48:31', '2017-07-20 22:48:31', 'usuarioTemporal7878', 0),
(335, '335usuarioTemporal7531', 'N', '2017-07-20 22:48:36', '2017-07-20 22:48:36', 'usuarioTemporal7531', 0),
(336, '336usuarioTemporal2765', 'N', '2017-07-20 22:49:06', '2017-07-20 22:49:06', 'usuarioTemporal2765', 0),
(337, '337usuarioTemporal5103', 'N', '2017-07-20 22:49:12', '2017-07-20 22:49:12', 'usuarioTemporal5103', 0),
(338, '338usuarioTemporal3257', 'N', '2017-07-20 22:49:20', '2017-07-20 22:49:20', 'usuarioTemporal3257', 0),
(339, '339usuarioTemporal625', 'N', '2017-07-20 22:50:52', '2017-07-20 22:50:52', 'usuarioTemporal625', 0),
(340, '340usuarioTemporal2792', 'N', '2017-07-20 22:52:57', '2017-07-20 22:52:57', 'usuarioTemporal2792', 0),
(341, '341usuarioTemporal5032', 'N', '2017-07-20 22:57:58', '2017-07-20 22:57:58', 'usuarioTemporal5032', 0),
(342, '342usuarioTemporal9806', 'N', '2017-07-20 22:58:20', '2017-07-20 22:58:20', 'usuarioTemporal9806', 0),
(343, '343usuarioTemporal4264', 'N', '2017-07-20 22:58:57', '2017-07-20 22:58:57', 'usuarioTemporal4264', 0),
(344, '344usuarioTemporal7740', 'N', '2017-07-20 22:59:09', '2017-07-20 22:59:09', 'usuarioTemporal7740', 0),
(345, '345usuarioTemporal9258', 'N', '2017-07-20 22:59:14', '2017-07-20 22:59:14', 'usuarioTemporal9258', 0),
(346, '346usuarioTemporal5029', 'N', '2017-07-20 22:59:22', '2017-07-20 22:59:22', 'usuarioTemporal5029', 0),
(347, '347usuarioTemporal5951', 'N', '2017-07-20 22:59:30', '2017-07-20 22:59:30', 'usuarioTemporal5951', 0),
(348, '348usuarioTemporal5111', 'N', '2017-07-20 22:59:36', '2017-07-20 22:59:36', 'usuarioTemporal5111', 0),
(349, '349usuarioTemporal5281', 'N', '2017-07-20 23:00:45', '2017-07-20 23:00:45', 'usuarioTemporal5281', 0),
(350, '350usuarioTemporal6423', 'N', '2017-07-20 23:01:06', '2017-07-20 23:01:06', 'usuarioTemporal6423', 0),
(351, '351usuarioTemporal3185', 'N', '2017-07-20 23:01:14', '2017-07-20 23:01:14', 'usuarioTemporal3185', 0),
(352, '352usuarioTemporal2404', 'N', '2017-07-20 23:02:20', '2017-07-20 23:02:20', 'usuarioTemporal2404', 0),
(353, '353usuarioTemporal601', 'N', '2017-07-20 23:03:34', '2017-07-20 23:03:34', 'usuarioTemporal601', 0),
(354, '354usuarioTemporal1489', 'N', '2017-07-20 23:04:56', '2017-07-20 23:04:56', 'usuarioTemporal1489', 0),
(355, '355usuarioTemporal3466', 'N', '2017-07-20 23:05:15', '2017-07-20 23:05:15', 'usuarioTemporal3466', 0),
(356, '356usuarioTemporal7117', 'N', '2017-07-20 23:16:57', '2017-07-20 23:16:57', 'usuarioTemporal7117', 0),
(357, '357usuarioTemporal2718', 'N', '2017-07-20 23:18:06', '2017-07-20 23:18:06', 'usuarioTemporal2718', 0),
(358, '358usuarioTemporal7094', 'N', '2017-07-20 23:24:22', '2017-07-20 23:24:22', 'usuarioTemporal7094', 0),
(359, '359usuarioTemporal8583', 'N', '2017-07-26 15:11:07', '2017-07-26 15:11:07', 'usuarioTemporal8583', 0),
(360, '360usuarioTemporal2944', 'N', '2017-07-26 16:27:14', '2017-07-26 16:27:14', 'usuarioTemporal2944', 0),
(361, '361usuarioTemporal9411', 'N', '2017-07-26 18:49:50', '2017-07-26 18:49:50', 'usuarioTemporal9411', 0),
(362, '362usuarioTemporal5418', 'N', '2017-07-27 12:47:07', '2017-07-27 12:47:07', 'usuarioTemporal5418', 0),
(363, '363usuarioTemporal2539', 'N', '2017-07-27 12:51:32', '2017-07-27 12:51:32', 'usuarioTemporal2539', 0),
(364, '364usuarioTemporal3536', 'N', '2017-07-27 14:20:57', '2017-07-27 14:20:57', 'usuarioTemporal3536', 0),
(365, '365usuarioTemporal6322', 'N', '2017-07-27 14:21:00', '2017-07-27 14:21:00', 'usuarioTemporal6322', 0),
(366, '366usuarioTemporal7602', 'N', '2017-07-27 14:22:06', '2017-07-27 14:22:06', 'usuarioTemporal7602', 0),
(367, '367usuarioTemporal7858', 'N', '2017-07-27 14:23:03', '2017-07-27 14:23:03', 'usuarioTemporal7858', 0),
(368, '368usuarioTemporal345', 'N', '2017-07-27 14:23:19', '2017-07-27 14:23:19', 'usuarioTemporal345', 0),
(369, '369usuarioTemporal5005', 'N', '2017-07-27 14:27:02', '2017-07-27 14:27:02', 'usuarioTemporal5005', 0),
(370, '370usuarioTemporal5478', 'N', '2017-07-27 14:27:37', '2017-07-27 14:27:37', 'usuarioTemporal5478', 0),
(371, '371usuarioTemporal8709', 'N', '2017-07-27 14:28:54', '2017-07-27 14:28:54', 'usuarioTemporal8709', 0),
(372, '372usuarioTemporal357', 'N', '2017-07-27 14:30:03', '2017-07-27 14:30:03', 'usuarioTemporal357', 0),
(373, '373usuarioTemporal3042', 'N', '2017-07-31 09:02:02', '2017-07-31 09:02:02', 'usuarioTemporal3042', 0),
(374, '374usuarioTemporal1191', 'N', '2017-07-31 09:04:54', '2017-07-31 09:04:54', 'usuarioTemporal1191', 0),
(375, '375usuarioTemporal2749', 'N', '2017-07-31 09:04:56', '2017-07-31 09:04:56', 'usuarioTemporal2749', 0),
(376, '376usuarioTemporal8439', 'N', '2017-07-31 09:05:19', '2017-07-31 09:05:19', 'usuarioTemporal8439', 0),
(377, '377usuarioTemporal8112', 'N', '2017-07-31 09:59:39', '2017-07-31 09:59:39', 'usuarioTemporal8112', 0),
(378, '378usuarioTemporal9574', 'N', '2017-07-31 10:07:33', '2017-07-31 10:07:33', 'usuarioTemporal9574', 0),
(379, '379usuarioTemporal9082', 'N', '2017-07-31 10:08:04', '2017-07-31 10:08:04', 'usuarioTemporal9082', 0),
(380, '380usuarioTemporal8332', 'N', '2017-07-31 10:10:53', '2017-07-31 10:10:53', 'usuarioTemporal8332', 0),
(381, '381usuarioTemporal4628', 'N', '2017-07-31 10:11:06', '2017-07-31 10:11:06', 'usuarioTemporal4628', 0),
(382, '382usuarioTemporal3528', 'N', '2017-07-31 10:15:22', '2017-07-31 10:15:22', 'usuarioTemporal3528', 0),
(383, '383usuarioTemporal8712', 'N', '2017-07-31 11:02:39', '2017-07-31 11:02:39', 'usuarioTemporal8712', 0),
(384, '384usuarioTemporal5948', 'N', '2017-07-31 11:03:32', '2017-07-31 11:03:32', 'usuarioTemporal5948', 0),
(385, '385usuarioTemporal1256', 'N', '2017-07-31 11:10:19', '2017-07-31 11:10:19', 'usuarioTemporal1256', 0),
(386, '386usuarioTemporal6128', 'N', '2017-07-31 11:46:48', '2017-07-31 11:46:48', 'usuarioTemporal6128', 0),
(387, '387usuarioTemporal6565', 'N', '2017-07-31 11:47:03', '2017-07-31 11:47:03', 'usuarioTemporal6565', 0),
(388, '388usuarioTemporal2241', 'N', '2017-07-31 12:40:02', '2017-07-31 12:40:02', 'usuarioTemporal2241', 0),
(389, '389usuarioTemporal8869', 'N', '2017-07-31 12:40:13', '2017-07-31 12:40:13', 'usuarioTemporal8869', 0),
(390, '390usuarioTemporal8441', 'N', '2017-07-31 14:30:16', '2017-07-31 14:30:16', 'usuarioTemporal8441', 0),
(391, '391usuarioTemporal8043', 'N', '2017-07-31 15:21:28', '2017-07-31 15:21:28', 'usuarioTemporal8043', 0),
(392, '392usuarioTemporal5733', 'N', '2017-07-31 16:31:02', '2017-07-31 16:31:02', 'usuarioTemporal5733', 0),
(393, '393usuarioTemporal7050', 'N', '2017-07-31 17:44:40', '2017-07-31 17:44:40', 'usuarioTemporal7050', 0),
(394, '394usuarioTemporal7894', 'N', '2017-07-31 18:00:05', '2017-07-31 18:00:05', 'usuarioTemporal7894', 0),
(395, '395usuarioTemporal4004', 'N', '2017-07-31 18:08:17', '2017-07-31 18:08:17', 'usuarioTemporal4004', 0),
(396, '396usuarioTemporal7858', 'N', '2017-07-31 18:24:26', '2017-07-31 18:24:26', 'usuarioTemporal7858', 0),
(397, '397usuarioTemporal7469', 'N', '2017-07-31 18:33:19', '2017-07-31 18:33:19', 'usuarioTemporal7469', 0),
(398, '398usuarioTemporal7117', 'N', '2017-07-31 18:46:25', '2017-07-31 18:46:25', 'usuarioTemporal7117', 0),
(399, '399usuarioTemporal2718', 'N', '2017-07-31 18:52:49', '2017-07-31 18:52:49', 'usuarioTemporal2718', 0),
(400, '400usuarioTemporal4701', 'N', '2017-07-31 19:01:25', '2017-07-31 19:01:25', 'usuarioTemporal4701', 0),
(401, '401usuarioTemporal2572', 'N', '2017-07-31 19:03:03', '2017-07-31 19:03:03', 'usuarioTemporal2572', 0),
(402, '402usuarioTemporal9430', 'N', '2017-07-31 19:09:28', '2017-07-31 19:09:28', 'usuarioTemporal9430', 0),
(403, '403usuarioTemporal7870', 'N', '2017-07-31 19:09:41', '2017-07-31 19:09:41', 'usuarioTemporal7870', 0),
(404, '404usuarioTemporal8120', 'N', '2017-07-31 19:17:22', '2017-07-31 19:17:22', 'usuarioTemporal8120', 0),
(405, '405ACNUNEZ9050', 'N', '2017-07-31 19:17:35', '2017-07-31 19:17:35', 'ACNUNEZ9050', 1),
(406, '406usuarioTemporal5463', 'N', '2017-07-31 19:59:55', '2017-07-31 19:59:55', 'usuarioTemporal5463', 0),
(407, '407usuarioTemporal5602', 'N', '2017-07-31 20:05:39', '2017-07-31 20:05:39', 'usuarioTemporal5602', 0),
(408, '408usuarioTemporal2079', 'N', '2017-08-01 09:54:34', '2017-08-01 09:54:34', 'usuarioTemporal2079', 0),
(409, '409usuarioTemporal4861', 'N', '2017-08-01 10:00:57', '2017-08-01 10:00:57', 'usuarioTemporal4861', 0),
(410, '410usuarioTemporal5070', 'N', '2017-08-01 10:48:37', '2017-08-01 10:48:37', 'usuarioTemporal5070', 0),
(411, '411ACNUNEZ9134', 'N', '2017-08-01 10:50:42', '2017-08-01 10:50:42', 'ACNUNEZ9134', 1),
(412, '412usuarioTemporal3682', 'N', '2017-08-01 10:51:47', '2017-08-01 10:51:47', 'usuarioTemporal3682', 0),
(413, '413usuarioTemporal3479', 'N', '2017-08-01 11:53:59', '2017-08-01 11:53:59', 'usuarioTemporal3479', 0),
(414, '414ACNUNEZ4697', 'N', '2017-08-01 11:54:13', '2017-08-01 11:54:13', 'ACNUNEZ4697', 1),
(415, '415usuarioTemporal8515', 'N', '2017-08-01 12:15:52', '2017-08-01 12:15:52', 'usuarioTemporal8515', 0),
(416, '416ACNUNEZ8578', 'N', '2017-08-01 12:16:03', '2017-08-01 12:16:03', 'ACNUNEZ8578', 1),
(417, '417ACNUNEZ4', 'N', '2017-08-01 12:18:08', '2017-08-01 12:18:08', 'ACNUNEZ4', 1),
(418, '418usuarioTemporal1165', 'N', '2017-08-01 12:28:18', '2017-08-01 12:28:18', 'usuarioTemporal1165', 0),
(419, '419ACNUNEZ2617', 'N', '2017-08-01 12:28:29', '2017-08-01 12:28:29', 'ACNUNEZ2617', 1),
(420, '420usuarioTemporal6787', 'N', '2017-08-01 12:45:29', '2017-08-01 12:45:29', 'usuarioTemporal6787', 0),
(421, '421ACNUNEZ6771', 'N', '2017-08-01 12:45:39', '2017-08-01 12:45:39', 'ACNUNEZ6771', 1),
(422, '422usuarioTemporal6084', 'N', '2017-08-01 12:50:50', '2017-08-01 12:50:50', 'usuarioTemporal6084', 0),
(423, '423ACNUNEZ2600', 'N', '2017-08-01 12:51:00', '2017-08-01 12:51:00', 'ACNUNEZ2600', 1),
(424, '424usuarioTemporal4287', 'N', '2017-08-01 14:28:03', '2017-08-01 14:28:03', 'usuarioTemporal4287', 0),
(425, '425ACNUNEZ6886', 'N', '2017-08-01 14:28:13', '2017-08-01 14:28:13', 'ACNUNEZ6886', 1),
(426, '426ACNUNEZ7078', 'N', '2017-08-01 14:32:17', '2017-08-01 14:32:17', 'ACNUNEZ7078', 1),
(427, '427ACNUNEZ3734', 'N', '2017-08-01 14:33:24', '2017-08-01 14:33:24', 'ACNUNEZ3734', 1),
(428, '428ACNUNEZ7785', 'N', '2017-08-01 14:33:39', '2017-08-01 14:33:39', 'ACNUNEZ7785', 1),
(429, '429ACNUNEZ6153', 'N', '2017-08-01 14:33:48', '2017-08-01 14:33:48', 'ACNUNEZ6153', 1),
(430, '430ACNUNEZ500', 'N', '2017-08-01 14:34:47', '2017-08-01 14:34:47', 'ACNUNEZ500', 1),
(431, '431ACNUNEZ9816', 'N', '2017-08-01 14:35:07', '2017-08-01 14:35:07', 'ACNUNEZ9816', 1),
(432, '432ACNUNEZ1432', 'N', '2017-08-01 14:36:10', '2017-08-01 14:36:10', 'ACNUNEZ1432', 1),
(433, '433ACNUNEZ1718', 'N', '2017-08-01 14:36:33', '2017-08-01 14:36:33', 'ACNUNEZ1718', 1),
(434, '434ACNUNEZ2730', 'N', '2017-08-01 14:37:18', '2017-08-01 14:37:18', 'ACNUNEZ2730', 1),
(435, '435ACNUNEZ6036', 'N', '2017-08-01 14:38:09', '2017-08-01 14:38:09', 'ACNUNEZ6036', 1),
(436, '436ACNUNEZ8296', 'N', '2017-08-01 14:42:31', '2017-08-01 14:42:31', 'ACNUNEZ8296', 1),
(437, '437usuarioTemporal6647', 'N', '2017-08-01 14:49:56', '2017-08-01 14:49:56', 'usuarioTemporal6647', 0),
(438, '438usuarioTemporal9225', 'N', '2017-08-01 15:49:00', '2017-08-01 15:49:00', 'usuarioTemporal9225', 0),
(439, '439usuarioTemporal2160', 'N', '2017-08-01 15:51:18', '2017-08-01 15:51:18', 'usuarioTemporal2160', 0),
(440, '440usuarioTemporal6925', 'N', '2017-08-01 15:51:34', '2017-08-01 15:51:34', 'usuarioTemporal6925', 0),
(441, '441usuarioTemporal5044', 'N', '2017-08-01 15:51:44', '2017-08-01 15:51:44', 'usuarioTemporal5044', 0),
(442, '442usuarioTemporal5229', 'N', '2017-08-01 17:58:08', '2017-08-01 17:58:08', 'usuarioTemporal5229', 0),
(443, '443usuarioTemporal878', 'N', '2017-08-01 17:58:21', '2017-08-01 17:58:21', 'usuarioTemporal878', 0),
(444, '444usuarioTemporal7576', 'N', '2017-08-01 17:58:32', '2017-08-01 17:58:32', 'usuarioTemporal7576', 0),
(445, '445usuarioTemporal599', 'N', '2017-08-01 17:59:03', '2017-08-01 17:59:03', 'usuarioTemporal599', 0),
(446, '446usuarioTemporal2405', 'N', '2017-08-01 18:01:38', '2017-08-01 18:01:38', 'usuarioTemporal2405', 0),
(447, '447usuarioTemporal144', 'N', '2017-08-01 18:10:20', '2017-08-01 18:10:20', 'usuarioTemporal144', 0),
(448, '448usuarioTemporal3436', 'N', '2017-08-01 19:16:07', '2017-08-01 19:16:07', 'usuarioTemporal3436', 0),
(449, '449ACNUNEZ8561', 'N', '2017-08-01 19:16:16', '2017-08-01 19:16:16', 'ACNUNEZ8561', 1),
(450, '450usuarioTemporal1184', 'N', '2017-08-01 19:23:48', '2017-08-01 19:23:48', 'usuarioTemporal1184', 0),
(451, '451ACNUNEZ3136', 'N', '2017-08-01 19:24:04', '2017-08-01 19:24:04', 'ACNUNEZ3136', 1),
(452, '452usuarioTemporal8838', 'N', '2017-08-01 19:37:22', '2017-08-01 19:37:22', 'usuarioTemporal8838', 0),
(453, '453ACNUNEZ5114', 'N', '2017-08-01 19:37:43', '2017-08-01 19:37:43', 'ACNUNEZ5114', 1),
(454, '454usuarioTemporal271', 'N', '2017-08-01 19:43:40', '2017-08-01 19:43:40', 'usuarioTemporal271', 0);

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
(1, 1, 'ACNUNEZ', '$2y$12$Vm1GdGIzTmZjRzl5WDIxa.2gQYe0cMPidgMxR7sEAYU17oD2RZHte', 0, 'Z', 'S', '2017-07-04 00:00:00', 1, '2017-08-01 19:37:44', 1);

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
--
CREATE TABLE `view_lista_empresa` (
`codigo` int(11)
,`nombre` varchar(500)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `view_lista_menu_principal`
--
CREATE TABLE `view_lista_menu_principal` (
`etiqueta` varchar(300)
,`url` varchar(300)
,`icono` varchar(300)
,`codUsuario` int(11)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `view_lista_empresa`
--
DROP TABLE IF EXISTS `view_lista_empresa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`jano`@`localhost` SQL SECURITY DEFINER VIEW `view_lista_empresa`  AS  select `em`.`codEmpresa` AS `codigo`,`em`.`nombreEmpresa` AS `nombre` from `empresa` `em` where (`em`.`estadoRegistro` = 'S') ;

-- --------------------------------------------------------

--
-- Estructura para la vista `view_lista_menu_principal`
--
DROP TABLE IF EXISTS `view_lista_menu_principal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`jano`@`localhost` SQL SECURITY DEFINER VIEW `view_lista_menu_principal`  AS  select `si`.`etiquetaSistema` AS `etiqueta`,`si`.`urlSistema` AS `url`,`si`.`urlIcono` AS `icono`,`us`.`codUsuario` AS `codUsuario` from (`sistema` `si` join `usuario_sistema` `us` on((`si`.`codSistema` = `us`.`codSistema`))) where (`us`.`estadoRegistro` = 'S') ;

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
-- Indices de la tabla `pruebas`
--
ALTER TABLE `pruebas`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `codError` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=294;
--
-- AUTO_INCREMENT de la tabla `parametros_generales`
--
ALTER TABLE `parametros_generales`
  MODIFY `codParametro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `pruebas`
--
ALTER TABLE `pruebas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `sistema`
--
ALTER TABLE `sistema`
  MODIFY `codSistema` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `token_usuario`
--
ALTER TABLE `token_usuario`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Esta correlativo servirá para generar el token y no realizar busquedas constantes para validar existencias de token.', AUTO_INCREMENT=455;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `codUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `datos_empresa`
--
ALTER TABLE `datos_empresa`
  ADD CONSTRAINT `fk_datos_empresa_empresa1` FOREIGN KEY (`codEmpresa`) REFERENCES `empresa` (`codEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `empresa_sistema`
--
ALTER TABLE `empresa_sistema`
  ADD CONSTRAINT `fk_empresa_has_sistemas_sistemas1` FOREIGN KEY (`codSistema`) REFERENCES `sistema` (`codSistema`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_empresa_sistema_empresa1` FOREIGN KEY (`codEmpresa`) REFERENCES `empresa` (`codEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `errores_sistema`
--
ALTER TABLE `errores_sistema`
  ADD CONSTRAINT `fk_errores_sistema_usuario_sistema1` FOREIGN KEY (`codUsuario`) REFERENCES `usuario` (`codUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `parametros_generales`
--
ALTER TABLE `parametros_generales`
  ADD CONSTRAINT `fk_parametros_generales_empresa1` FOREIGN KEY (`codEmpresa`) REFERENCES `empresa` (`codEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_empresa1` FOREIGN KEY (`codEmpresa`) REFERENCES `empresa` (`codEmpresa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuario_sistema`
--
ALTER TABLE `usuario_sistema`
  ADD CONSTRAINT `fk_usuario_has_sistema_sistema1` FOREIGN KEY (`codSistema`) REFERENCES `sistema` (`codSistema`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_usuario_has_sistema_usuario1` FOREIGN KEY (`codUsuario`) REFERENCES `usuario` (`codUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`jano`@`localhost` EVENT `evn_caducar_token` ON SCHEDULE EVERY 1 MINUTE STARTS '2017-07-26 19:02:43' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
		declare V_tiempoSesion int;
	
		select cast(valorParametro as int) 
          into V_tiempoSesion 
          from parametros_generales 
		 where identificadorParametro = 'TIME_OUT_SESSION';
    
		update token_usuario
        set estadoRegistro = 'N'
        where TIMESTAMPDIFF(MINUTE, fechaUltMov, now())>=V_tiempoSesion;
	    
	END$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
