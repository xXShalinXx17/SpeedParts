DELIMITER //

CREATE PROCEDURE ConsultarStockSeguro(
    IN p_ID_usuario BIGINT
)
BEGIN
    DECLARE v_id_rol INT;

    SELECT ID_rol INTO v_id_rol 
    FROM CLIENTE.Usuario 
    WHERE ID_usuario = p_ID_usuario;

    IF v_id_rol IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Acceso: El usuario especificado no existe en el sistema.';
        
    ELSEIF v_id_rol = 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Privilegios: Acceso denegado. Los clientes no pueden consultar el stock de almacenes.';
        
    ELSE
        SELECT 
            A.nombre AS Nombre_Almacen,
            R.codigo_sku AS Codigo_SKU,
            R.nombre AS Nombre_Repuesto,
            R.tipo AS Tipo_Repuesto,
            S.stock_actual AS Stock_Disponible,
            S.stock_minimo AS Alerta_Minimo
        FROM Almacenes.stock_de_repuestos S
        INNER JOIN Almacenes.almacen A ON S.ID_almacen = A.ID_almacen
        INNER JOIN Almacenes.Repuestos R ON S.id_repuestos = R.id_repuestos
        ORDER BY A.nombre ASC, S.stock_actual DESC;
        
    END IF;
END //

DELIMITER ;
