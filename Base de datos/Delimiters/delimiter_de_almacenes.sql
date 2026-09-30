USE almacenes;

-- sp 1 --
DELIMITER //

CREATE PROCEDURE TransferirStockEntreAlmacenes(
    IN p_id_origen BIGINT,
    IN p_id_destino BIGINT,
    IN p_id_repuesto BIGINT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_stock_origen BIGINT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Critico: Fallo logistico interno. La transferencia fue cancelada y revertida.';
    END;

    START TRANSACTION;

    SELECT stock_actual INTO v_stock_origen 
    FROM stock_de_repuestos 
    WHERE ID_almacen = p_id_origen AND id_repuestos = p_id_repuesto;
    
    IF v_stock_origen IS NULL OR v_stock_origen < p_cantidad THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Logistico: El almacen de origen no cuenta con el stock solicitado.';
    ELSE
        UPDATE stock_de_repuestos 
        SET stock_actual = stock_actual - p_cantidad 
        WHERE ID_almacen = p_id_origen AND id_repuestos = p_id_repuesto;
        
        -- 4. OPERACIÓN B: Sumamos en el destino
        IF EXISTS (SELECT 1 FROM stock_de_repuestos WHERE ID_almacen = p_id_destino AND id_repuestos = p_id_repuesto) THEN
            UPDATE stock_de_repuestos 
            SET stock_actual = stock_actual + p_cantidad 
            WHERE ID_almacen = p_id_destino AND id_repuestos = p_id_repuesto;
        ELSE

            INSERT INTO stock_de_repuestos (ID_almacen, id_repuestos, stock_actual, stock_minimo) 
            VALUES (p_id_destino, p_id_repuesto, p_cantidad, 10);
        END IF;

        COMMIT;
    END IF;
END //
DELIMITER ;

 call TransferirStockEntreAlmacenes( 1, 2, 102, 50);
select * from stock_de_repuestos;


-- SP 2 --
DELIMITER //
CREATE PROCEDURE ListarRepuestosPorProveedor(
    IN p_id_proveedor BIGINT
)
BEGIN
    SELECT DISTINCT R.id_repuestos, R.codigo_sku, R.nombre, R.tipo, C.nombre AS Categoria
    FROM Repuestos R
    INNER JOIN Categoria C ON R.Categoria_id = C.Categoria_id
    INNER JOIN proveedor_categorias PC ON C.Categoria_id = PC.Categoria_id
    WHERE PC.id_provedor = p_id_proveedor;
END //
DELIMITER ;


-- SP 3 --
DELIMITER //
CREATE PROCEDURE EliminarRepuestoCatalogo(
    IN p_id_repuestos BIGINT
)
BEGIN
    IF EXISTS (SELECT 1 FROM Repuestos WHERE id_repuestos = p_id_repuestos) THEN
        -- El borrado en cascada limpiará automáticamente las tablas de stock vinculadas
        DELETE FROM Repuestos WHERE id_repuestos = p_id_repuestos;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El repuesto no existe en el catálogo.';
    END IF;
END //
DELIMITER ;


-- SP 4 --
DELIMITER //
CREATE PROCEDURE ValorizacionInventarioTotal()
BEGIN
    SELECT A.ID_almacen, A.nombre AS Almacen, COUNT(S.id_repuestos) AS Variedad_Items, SUM(S.stock_actual) AS Unidades_Totales, 
           SUM(S.stock_actual * IFNULL((SELECT costo_unitario FROM compras_proveedor WHERE id_repuestos = S.id_repuestos ORDER BY id_compra DESC LIMIT 1), 0)) AS Inversion_Estimada_Costo
    FROM stock_de_repuestos S
    INNER JOIN almacen A ON S.ID_almacen = A.ID_almacen
    GROUP BY A.ID_almacen;
END //
DELIMITER ;

-- SP 5 --
DELIMITER //
CREATE PROCEDURE CancelarEnvioLogistico(
    IN p_num_envio BIGINT
)
BEGIN
    DECLARE v_estado ENUM('Pendiente', 'En Camino', 'Entregado', 'Cancelado');
    SELECT Estado INTO v_estado FROM envios WHERE Numero_de_envio = p_num_envio;
    
    IF v_estado = 'Entregado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede cancelar un envio que ya fue recibido.';
    ELSE
        UPDATE envios SET Estado = 'Cancelado' WHERE Numero_de_envio = p_num_envio;
    END IF;
END //
DELIMITER ;


-- SP 6 --
DELIMITER //
CREATE PROCEDURE ModificarAlertaStockMinimo(
    IN p_id_almacen BIGINT,
    IN p_id_repuestos BIGINT,
    IN p_nuevo_minimo INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM stock_de_repuestos WHERE ID_almacen = p_id_almacen AND id_repuestos = p_id_repuestos) THEN
        UPDATE stock_de_repuestos SET stock_minimo = p_nuevo_minimo WHERE ID_almacen = p_id_almacen AND id_repuestos = p_id_repuestos;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se encontro el mapeo de stock especificado.';
    END IF;
END //
DELIMITER ;

-- SP 7 --
DELIMITER //
CREATE PROCEDURE HistorialComprasAProveedor(
    IN p_id_proveedor BIGINT
)
BEGIN
    SELECT CP.id_compra, R.codigo_sku, R.nombre AS Repuesto, CP.cantidad, CP.costo_unitario, (CP.cantidad * CP.costo_unitario) AS Total_Gastado, CP.fecha_compra
    FROM compras_proveedor CP
    INNER JOIN Repuestos R ON CP.id_repuestos = R.id_repuestos
    WHERE CP.id_provedor = p_id_proveedor
    ORDER BY CP.fecha_compra DESC;
END //
DELIMITER ;

-- SP 8 --
DELIMITER //
CREATE PROCEDURE ActualizarInfraestructuraAlmacen(
    IN p_id_almacen BIGINT,
    IN p_nombre TEXT,
    IN p_capacidad INT,
    IN p_direccion TEXT
)
BEGIN
    UPDATE almacen 
    SET nombre = p_nombre, capacidad_MAX = p_capacidad, dirección = p_direccion
    WHERE ID_almacen = p_id_almacen;
END //
DELIMITER ;

-- SP 9 --
DELIMITER //
CREATE PROCEDURE ConfigurarMargenCosto(
    IN p_id_proveedor BIGINT,
    IN p_categoria_id INT,
    IN p_porcentaje INT
)
BEGIN
    INSERT INTO Costos (porcentaje_ganancia, id_provedor, Categoria_id)
    VALUES (p_porcentaje, p_id_proveedor, p_categoria_id)
    ON DUPLICATE KEY UPDATE porcentaje_ganancia = p_porcentaje;
END //
DELIMITER ;

-- SP 10 --
DELIMITER //
CREATE PROCEDURE ListarEnviosPorEstado(
    IN p_Estado TEXT
)
BEGIN
    SELECT E.Numero_de_envio, A.nombre AS Almacen_Destino, E.fecha_hora_entrega, E.comfirmardor
    FROM envios E
    INNER JOIN almacen A ON E.ID_almacen = A.ID_almacen
    WHERE E.Estado = p_Estado
    ORDER BY E.Numero_de_envio DESC;
END //
DELIMITER ;


-- SP 11 --
DELIMITER //
CREATE PROCEDURE BuscarRepuestoPorSKU(
    IN p_codigo_sku TEXT
)
BEGIN
    SELECT 
        R.id_repuestos, 
        R.codigo_sku, 
        R.tipo, 
        R.nombre, 
        R.descripcion, 
        C.nombre AS Nombre_Categoria
    FROM Repuestos R
    INNER JOIN Categoria C ON R.Categoria_id = C.Categoria_id
    WHERE R.codigo_sku = p_codigo_sku;
END //
DELIMITER ;

-- SP 12 --
DELIMITER //
CREATE PROCEDURE RegistrarCompraProveedor(
    IN p_id_provedor BIGINT,
    IN p_id_repuestos BIGINT,
    IN p_id_almacen BIGINT,
    IN p_cantidad INT,
    IN p_costo_unitario BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Critico: No se pudo registrar la compra ni actualizar el stock. Operacion cancelada.';
    END;

    START TRANSACTION;

    INSERT INTO compras_proveedor (id_provedor, id_repuestos, cantidad, costo_unitario)
    VALUES (p_id_provedor, p_id_repuestos, p_cantidad, p_costo_unitario);

    IF EXISTS (SELECT 1 FROM stock_de_repuestos WHERE ID_almacen = p_id_almacen AND id_repuestos = p_id_repuestos) THEN
        UPDATE stock_de_repuestos 
        SET stock_actual = stock_actual + p_cantidad
        WHERE ID_almacen = p_id_almacen AND id_repuestos = p_id_repuestos;
    ELSE
        INSERT INTO stock_de_repuestos (ID_almacen, id_repuestos, stock_actual, stock_minimo)
        VALUES (p_id_almacen, p_id_repuestos, p_cantidad, 10);
    END IF;

    COMMIT;
END //
DELIMITER ;

--  SP 13 --
DELIMITER //
CREATE PROCEDURE ReporteBajoStock()
BEGIN
    SELECT 
        A.nombre AS Nombre_Almacen, 
        R.codigo_sku AS SKU, 
        R.nombre AS Nombre_Repuesto, 
        S.stock_actual AS Stock_Actual, 
        S.stock_minimo AS Stock_Minimo
    FROM stock_de_repuestos S
    INNER JOIN almacen A ON S.ID_almacen = A.ID_almacen
    INNER JOIN Repuestos R ON S.id_repuestos = R.id_repuestos
    WHERE S.stock_actual <= S.stock_minimo
    ORDER BY S.stock_actual ASC; 
END //
DELIMITER ;

-- Sp 14 --
DELIMITER //
CREATE PROCEDURE ActualizarEstadoEnvio(
    IN p_Numero_de_envio BIGINT,
    IN p_Nuevo_Estado ENUM('Pendiente', 'En Camino', 'Entregado', 'Cancelado')
)
BEGIN
    IF EXISTS (SELECT 1 FROM envios WHERE Numero_de_envio = p_Numero_de_envio) THEN
        UPDATE envios 
        SET Estado = p_Nuevo_Estado, fecha_hora_entrega = NOW() 
        WHERE Numero_de_envio = p_Numero_de_envio;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Logistico: El número de envío especificado no existe.';
    END IF;
END //
DELIMITER ;
