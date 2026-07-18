USE Almacenes;
DELIMITER //

CREATE PROCEDURE InsertarAlmacen(
    IN p_categoria_id INT,
    IN p_nombre VARCHAR(150),
    IN p_capacidad INT,
    IN p_dirección VARCHAR(200)
)
BEGIN
    INSERT INTO almacen (Categoria_id, nombre, capacidad_MAX, direccion)
    VALUES (p_categoria_id, p_nombre, p_capacidad, p_direccion);
END //

DELIMITER ;
INSERT INTO Categoria (Categoria_id, nombre) VALUES (10, 'Electrónica');

CALL InsertarAlmacen(10, 'Almacén Central Norte', 5000, 'Av. Principal 123');
CALL InsertarAlmacen(10, 'Almacén Secundario Sur', 2500, 'Calle Lateral 456');
