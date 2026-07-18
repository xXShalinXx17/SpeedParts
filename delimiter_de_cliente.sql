USE CLIENTE;
DELIMITER //
CREATE PROCEDURE MostrarUsuarios()
BEGIN
    SELECT ID_usuario, Nombre, Apellido, DNI, Gmail,Dirección, contraseña FROM Usuario;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE AgregarUsuario(
    IN p_Nombre TEXT,
    IN p_Apellido TEXT,
    IN p_telefono INT,
    IN p_DNI INT,
    IN p_Direccion TEXT,
    IN p_Gmail TEXT,
    IN p_contrasena TEXT
)
BEGIN
    INSERT INTO Usuario (Nombre, Apellido, telefono, DNI, Dirección, Gmail, contraseña)
    VALUES (p_Nombre, p_Apellido, p_telefono, p_DNI, p_Direccion, p_Gmail, p_contrasena);
END //
DELIMITER ;
 CALL CLIENTE.AgregarUsuario('Julian', 'rodriguez', 19531577, 49172856, 'Av. cordoba 2134', 'julian.rodriguez@gmail.com', 'claveputo12412'
);
CALL CLIENTE.AgregarUsuario('JuAN', 'rodriguez', 19462577, 48172971, 'Av. cordoba 2224', 'juAN.rodriguez@gmail.com', 'clavelola125792');
CALL CLIENTE.MostrarUsuarios();

