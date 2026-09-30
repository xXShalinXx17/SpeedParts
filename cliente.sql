drop database if exists CLIENTE;
create database CLIENTE;
use CLIENTE;

Create table Rol(
ID_rol int not null auto_increment primary key,
Roles varchar(50) not null
);

INSERT INTO Rol (ID_rol, Roles) VALUES 
(1, 'Administrador'),
(2, 'Empleado'),
(3, 'Cliente');

CREATE TABLE Sub_Rol_Empleado (
    ID_sub_rol INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Nombre_puesto TEXT NOT NULL
);

INSERT INTO Sub_Rol_Empleado (ID_sub_rol, Nombre_puesto) VALUES 
(1, 'Dirección Industrial'),
(2, 'Ingeniería de Producto'),
(3, 'Matricería y Troquelado'),
(4, 'Línea de Ensamble'),
(5, 'Inyección de Plásticos'),
(6, 'Control de Calidad (Metrología)'),
(7, 'Mantenimiento Predictivo'),
(8, 'Logística y Suministros (JIT)'),
(9, 'Almacén de Productos Terminados'),
(10, 'Recursos Humanos'),
(11, 'Finanzas y Costos Industriales'),
(12, 'Seguridad e Higiene'),
(13, 'Sistemas y Automatización (PLC)'),
(14, 'Compras Técnicas'),
(15, 'Ventas a Terminales'),
(16, 'I+D y Prototipado 3D'),
(17, 'Gestión Ambiental'),
(18, 'Auditoría de Procesos'),
(19, 'Atención al Cliente (Terminales)'),
(20, 'Legales');

CREATE TABLE Usuario (
ID_usuario bigint not null auto_increment primary key,
ID_rol int not null,
Nombre text not null,
Apellido text not null,
telefono int(20) not null,
DNI int(8) not null,
Dirección text not null,
Gmail text not null,
contraseña text not null,
CONSTRAINT fk_usuario_rol FOREIGN KEY (ID_rol) REFERENCES Rol(ID_rol)
);

DELIMITER //
CREATE TRIGGER validar_datos_usuario_nuevo
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    IF NEW.Gmail NOT LIKE '%@gmail.com%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de validacion: El correo electronico ingresado no tiene un formato valido.';
    END IF;

    IF NEW.DNI <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de validacion: El numero de DNI debe ser mayor a cero.';
    END IF;
END //
DELIMITER ;

INSERT INTO Usuario (ID_usuario, ID_rol, Nombre, Apellido, telefono, DNI, Dirección, Gmail, contraseña) VALUES
(1, 1, 'Carlos', 'Gómez', 1145678901, 30123456, 'Av. Santa Fe 1234, CABA', 'carlos.gomez@gmail.com', '$2b$10$hashAdminSecret123'),
(2, 2, 'Ana', 'Martínez', 1156789012, 35789123, 'Calle Florida 550, CABA', 'ana.martinez@gmail.com', '$2b$10$hashEmpleadoWork456'),
(3, 2, 'Julian', 'Rodriguez',1195315775, 49172856, 'Av. Cordoba 2134, CABA', 'julian.rodriguez@gmail.com', '$2b$10$hashClientePass789');

DELIMITER //
CREATE TRIGGER auditar_cambios_seguridad
AFTER UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF OLD.Gmail <> NEW.Gmail OR OLD.contraseña <> NEW.contraseña THEN
        INSERT INTO registro (ID_usuario, ip_direccion, dispositivo, estado_conexion)
        VALUES (NEW.ID_usuario, '127.0.0.1', 'Sistema / Seguridad', 'Credenciales Modificadas');
    END IF;
END //
DELIMITER ;

CREATE TABLE Detalle_Empleado (
    ID_detalle BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL UNIQUE,
    ID_sub_rol INT NOT NULL,
    fecha_contratacion DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_detalle_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_sub_rol FOREIGN KEY (ID_sub_rol) REFERENCES Sub_Rol_Empleado(ID_sub_rol)
);

DELIMITER //
CREATE TRIGGER validar_puesto_solo_empleados
BEFORE INSERT ON Detalle_Empleado
FOR EACH ROW
BEGIN
    DECLARE v_id_rol INT;
    SELECT ID_rol INTO v_id_rol FROM Usuario WHERE ID_usuario = NEW.ID_usuario;
    IF v_id_rol = 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede asignar un puesto interno a un Cliente.';
    END IF;
END //
DELIMITER ;

INSERT INTO Detalle_Empleado (ID_detalle, ID_usuario, ID_sub_rol) VALUES
(1, 1, 4),
(2, 2, 5),
(3, 3, 2);

CREATE TABLE registro (
    ID_registro BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    ip_direccion VARCHAR(45) NOT NULL,                  
    dispositivo VARCHAR(255),                           
    estado_conexion VARCHAR(20) DEFAULT 'Exitoso',      
    CONSTRAINT fk_registro_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER bloquear_modificacion_auditoria
BEFORE UPDATE ON registro
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error de Seguridad: Los registros de auditoria son de solo lectura y no se pueden modificar.';
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER bloquear_borrado_auditoria
BEFORE DELETE ON registro
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Usuario WHERE ID_usuario = OLD.ID_usuario) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Seguridad: No esta permitido borrar registros de auditoria de forma manual.';
    END IF;
END //
DELIMITER ;

INSERT INTO registro (ID_usuario, ip_direccion, dispositivo, estado_conexion) VALUES
(1, '192.168.1.50', 'Chrome OS / PC Oficina Central', 'Exitoso'),
(2, '181.44.212.10', 'Firefox / Windows 11 - Logística', 'Exitoso'),
(3, '190.2.115.88', 'Safari / iPhone 15 Pro Max', 'Fallido'); 


CREATE TABLE Horario (
    ID_horario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_detalle BIGINT NOT NULL UNIQUE,
    Turno TEXT NOT NULL,
    horario_de_entrada TIME NOT NULL,
    horario_de_salida TIME NOT NULL,
    fecha_de_vacaciones DATE NOT NULL,
    CONSTRAINT fk_horario_detalle FOREIGN KEY (ID_detalle) REFERENCES Detalle_Empleado(ID_detalle) ON DELETE CASCADE
);

DELIMITER //

CREATE TRIGGER validar_coherencia_horas
BEFORE INSERT ON Horario
FOR EACH ROW
BEGIN
    DECLARE v_id_sub_rol INT;
    DECLARE v_cantidad_vacaciones_coincidentes INT;

    IF NEW.horario_de_salida <= NEW.horario_de_entrada THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La salida no puede ser menor o igual a la entrada.';
    END IF;
    
    IF NEW.fecha_de_vacaciones < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La fecha de vacaciones no puede ser del pasado.';
    END IF;

    SELECT ID_sub_rol INTO v_id_sub_rol 
    FROM Detalle_Empleado 
    WHERE ID_detalle = NEW.ID_detalle;

    SELECT COUNT(*) INTO v_cantidad_vacaciones_coincidentes
    FROM Horario H
    INNER JOIN Detalle_Empleado D ON H.ID_detalle = D.ID_detalle
    WHERE D.ID_sub_rol = v_id_sub_rol 
      AND H.fecha_de_vacaciones = NEW.fecha_de_vacaciones;

    IF v_cantidad_vacaciones_coincidentes >= 4 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error RRHH: Cupo maximo alcanzado. Ya hay 4 empleados de este mismo departamento asignados a esa fecha de vacaciones.';
    END IF;

END //

DELIMITER ;


INSERT INTO Horario (ID_detalle, Turno, horario_de_entrada, horario_de_salida, fecha_de_vacaciones) VALUES
(1, 'Turno Completo', '08:00:00', '17:00:00', '2027-01-15'),
(2, 'Turno Mañana', '06:00:00', '14:00:00', '2027-02-10'),
(3, 'Turno tarde', '13:00:00', '18:00:00', '2027-01-20');

CREATE TABLE recibo (
    ID_recibo BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL, 
    detalle_producto TEXT,        
    fecha_entrega DATE NOT NULL,
    cantidad INT NOT NULL,
    precio BIGINT NOT NULL,       
    CONSTRAINT fk_recibo_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario)
);

DELIMITER //
CREATE TRIGGER validar_cantidades_recibo
BEFORE INSERT ON recibo
FOR EACH ROW
BEGIN
    IF NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Facturacion: La cantidad del producto vendido debe ser mayor a cero.';
    END IF;
    
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Facturacion: El precio unitario del producto debe ser mayor a cero.';
    END IF;
END //
DELIMITER ;

INSERT INTO recibo (ID_usuario, id_repuestos, detalle_producto, fecha_entrega, cantidad, precio) VALUES
(3, 101, 'Pastillas de Freno Brembo - Venta Mostrador', '2026-08-20', 2, 45000),
(3, 102, 'Filtro de Aceite Bosch - Repuesto Filtración', '2026-08-25', 1, 12000);
