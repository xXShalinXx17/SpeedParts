USE CLIENTE;
-- SP 1 --
DELIMITER //
CREATE PROCEDURE RegistrarClienteNuevo(
    IN p_Nombre TEXT, IN p_Apellido TEXT, IN p_telefono BIGINT, IN p_DNI INT,
    IN p_Direccion TEXT, IN p_Gmail TEXT, IN p_contrasena TEXT
)
BEGIN
    INSERT INTO Usuario (ID_rol, Nombre, Apellido, telefono, DNI, Dirección, Gmail, contraseña)
    VALUES (3, p_Nombre, p_Apellido, p_telefono, p_DNI, p_Direccion, p_Gmail, p_contrasena);
END //
DELIMITER ;

-- SP 2 --
DELIMITER //
CREATE PROCEDURE ModificarContrasenaSegura(
    IN p_ID_usuario BIGINT,
    IN p_Contrasena_Actual TEXT,
    IN p_Nueva_Contrasena TEXT
)
BEGIN
    DECLARE v_pass_guardada TEXT;
    
    SELECT contraseña INTO v_pass_guardada FROM Usuario WHERE ID_usuario = p_ID_usuario;
    
    IF v_pass_guardada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Usuario no encontrado.';
    ELSEIF v_pass_guardada <> p_Contrasena_Actual THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de validacion: La contraseña actual es incorrecta.';
    ELSE
        UPDATE Usuario SET contraseña = p_Nueva_Contrasena WHERE ID_usuario = p_ID_usuario;
    END IF;
END //
DELIMITER ;

-- SP 3 --
DELIMITER //
CREATE PROCEDURE ReporteAccesosFallidos()
BEGIN
    SELECT R.ID_registro, U.Nombre, U.Apellido, U.Gmail, R.fecha_ingreso, R.ip_direccion, R.dispositivo
    FROM registro R
    INNER JOIN Usuario U ON R.ID_usuario = U.ID_usuario
    WHERE R.estado_conexion = 'Fallido' OR R.dispositivo LIKE '[ALERTA%'
    ORDER BY R.fecha_ingreso DESC;
END //
DELIMITER ;

-- SP 4 --
DELIMITER //
CREATE PROCEDURE VerificarDisponibilidadVacaciones(
    IN p_ID_sub_rol INT,
    IN p_Fecha_Consultar DATE
)
BEGIN
    SELECT COUNT(*) AS Empleados_De_Vacaciones, (4 - COUNT(*)) AS Cupos_Disponibles
    FROM Horario H
    INNER JOIN Detalle_Empleado D ON H.ID_detalle = D.ID_detalle
    WHERE D.ID_sub_rol = p_ID_sub_rol AND H.fecha_de_vacaciones = p_Fecha_Consultar;
END //
DELIMITER ;

-- SP 5 --
DELIMITER //
CREATE PROCEDURE ObtenerFichaLaboralEmpleado(
    IN p_ID_usuario_buscar BIGINT, 
    IN p_ID_usuario_auditor BIGINT  
)
BEGIN
    DECLARE v_id_rol_auditor INT;

    SELECT ID_rol INTO v_id_rol_auditor 
    FROM Usuario 
    WHERE ID_usuario = p_ID_usuario_auditor;

    IF v_id_rol_auditor IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error de Seguridad: El usuario auditor especificado no existe.';
        
    ELSEIF v_id_rol_auditor = 3 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Acceso Denegado: Los clientes no tienen autorizacion para consultar fichas laborales del personal.';
        
    ELSE
        SELECT U.ID_usuario, U.Nombre, U.Apellido, U.DNI, U.Gmail, S.Nombre_puesto AS Departamento_Industrial,
            D.fecha_contratacion AS Fecha_Ingreso, IFNULL(H.Turno, 'Horario no asignado') AS Turno_Asignado, H.horario_de_entrada, H.horario_de_salida, H.fecha_de_vacaciones
        FROM Usuario U
        INNER JOIN Detalle_Empleado D ON U.ID_usuario = D.ID_usuario
        INNER JOIN Sub_Rol_Empleado S ON D.ID_sub_rol = S.ID_sub_rol
        LEFT JOIN Horario H ON D.ID_detalle = H.ID_detalle
        WHERE U.ID_usuario = p_ID_usuario_buscar;
    END IF;
END //

DELIMITER ;


-- SP 6 --
DELIMITER //
CREATE PROCEDURE AnularReciboVenta(
    IN p_ID_recibo BIGINT,
    IN p_id_almacen_devolucion BIGINT
)
BEGIN
    DECLARE v_cantidad INT;
    DECLARE v_id_repuesto BIGINT;
    
    SELECT cantidad, id_repuestos INTO v_cantidad, v_id_repuesto FROM recibo WHERE ID_recibo = p_ID_recibo;
    
    IF v_cantidad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El recibo especificado no existe.';
    ELSE
        UPDATE Almacenes.stock_de_repuestos 
        SET stock_actual = stock_actual + v_cantidad
        WHERE ID_almacen = p_id_almacen_devolucion AND id_repuestos = v_id_repuesto;
        
        DELETE FROM recibo WHERE ID_recibo = p_ID_recibo;
    END IF;
END //
DELIMITER ;

-- SP 7 --
DELIMITER //
CREATE PROCEDURE RankingMejoresClientes()
BEGIN
    SELECT U.ID_usuario, U.Nombre, U.Apellido, U.Gmail, COUNT(R.ID_recibo) AS Cantidad_Compras, SUM(R.cantidad * R.precio) AS Total_Invertido
    FROM Usuario U
    INNER JOIN recibo R ON U.ID_usuario = R.ID_usuario
    WHERE U.ID_rol = 3
    GROUP BY U.ID_usuario
    ORDER BY Total_Invertido DESC
    LIMIT 10;
END //
DELIMITER ;

-- SP 8 --
DELIMITER //
CREATE PROCEDURE ModificarTurnoHorario(
    IN p_ID_detalle BIGINT,
    IN p_Nuevo_Turno TEXT,
    IN p_Nueva_Entrada TIME,
    IN p_Nueva_Salida TIME
)
BEGIN
    IF EXISTS (SELECT 1 FROM Horario WHERE ID_detalle = p_ID_detalle) THEN
        UPDATE Horario 
        SET Turno = p_Nuevo_Turno, horario_de_entrada = p_Nueva_Entrada, horario_de_salida = p_Nueva_Salida
        WHERE ID_detalle = p_ID_detalle;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Este empleado no tiene un horario inicial asignado.';
    END IF;
END //
DELIMITER ;

-- SP 9 --
DELIMITER //
CREATE PROCEDURE ReporteFacturacionMensual()
BEGIN
    SELECT DATE_FORMAT(fecha_entrega, '%Y-%m') AS Mes, COUNT(ID_recibo) AS Transacciones_Totales, SUM(cantidad * precio) AS Facturacion_Total
    FROM recibo
    GROUP BY DATE_FORMAT(fecha_entrega, '%Y-%m')
    ORDER BY Mes DESC;
END //
DELIMITER ;

-- SP 10 --
DELIMITER //
CREATE PROCEDURE BuscarUsuarioFiltroDinamico(
    IN p_Busqueda TEXT
)
BEGIN
    SELECT ID_usuario, Nombre, Apellido, DNI, Gmail, ID_rol
    FROM Usuario
    WHERE Nombre LIKE CONCAT('%', p_Busqueda, '%') 
       OR Apellido LIKE CONCAT('%', p_Busqueda, '%') 
       OR Gmail LIKE CONCAT('%', p_Busqueda, '%');
END //
DELIMITER ;

-- SP 11 --
DELIMITER //
CREATE PROCEDURE HistorialAccesosUsuario(
    IN p_ID_usuario_buscar BIGINT,
    IN p_ID_usuario_auditor BIGINT 
)
BEGIN
    DECLARE v_id_rol_auditor INT;

    SELECT ID_rol INTO v_id_rol_auditor 
    FROM Usuario 
    WHERE ID_usuario = p_ID_usuario_auditor;

    IF v_id_rol_auditor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguridad: Usuario auditor no identificado.';
    ELSEIF v_id_rol_auditor = 3 THEN
        -- Bloqueo absoluto a clientes
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acceso Denegado: Los clientes no pueden auditar historiales de conexion.';
    ELSE
        SELECT ID_registro, fecha_ingreso, ip_direccion, dispositivo, estado_conexion
        FROM registro
        WHERE ID_usuario = p_ID_usuario_buscar
        ORDER BY fecha_ingreso DESC;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE EliminarUsuario(
    IN p_ID_usuario BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Critico: No se pudo dar de baja al usuario de forma segura. Operacion cancelada.';
    END;

    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM Usuario WHERE ID_usuario = p_ID_usuario) THEN
        DELETE FROM Usuario WHERE ID_usuario = p_ID_usuario;
        
        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Operacion: No se puede eliminar un usuario que no existe en el sistema.';
    END IF;
END //
DELIMITER ;
