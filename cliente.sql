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

create table Usuario (
ID_usuario bigint not null auto_increment primary key,
ID_rol int not null,
Nombre text(100),
Apellido text(100),
telefono int(20) not null,
DNI int(8) not null,
Dirección text(150) not null,
Gmail text(500) not null,
contraseña text(500) not null,
CONSTRAINT fk_usuario_rol FOREIGN KEY (ID_rol) REFERENCES Rol(ID_rol)
);
INSERT INTO Usuario (ID_usuario, ID_rol, Nombre, Apellido, telefono, DNI, Dirección, Gmail, contraseña) VALUES
(1, 1, 'Carlos', 'Gómez', 1145678901, 30123456, 'Av. Santa Fe 1234, CABA', 'carlos.gomez@email.com', '$2b$10$hashAdminSecret123'),
(2, 2, 'Ana', 'Martínez', 1156789012, 35789123, 'Calle Florida 550, CABA', 'ana.martinez@email.com', '$2b$10$hashEmpleadoWork456'),
(3, 2, 'Julian', 'Rodriguez',1195315775, 49172856, 'Av. Cordoba 2134, CABA', 'julian.rodriguez@gmail.com', '$2b$10$hashClientePass789');

CREATE TABLE registro (
    ID_registro BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    ip_direccion VARCHAR(45) NOT NULL,                  
    dispositivo VARCHAR(255),                           
    estado_conexion VARCHAR(20) DEFAULT 'Exitoso',      
    CONSTRAINT fk_registro_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE CASCADE
);

INSERT INTO registro (ID_usuario, ip_direccion, dispositivo, estado_conexion) VALUES
(1, '192.168.1.50', 'Chrome OS / PC Oficina Central', 'Exitoso'),
(2, '181.44.212.10', 'Firefox / Windows 11 - Logística', 'Exitoso'),
(3, '190.2.115.88', 'Safari / iPhone 15 Pro Max', 'Fallido'); -- Ejemplo de intento de hackeo o contraseña errónea


CREATE TABLE Horario (
    ID_horario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL UNIQUE,
    Turno VARCHAR(40) NOT NULL,
    horario_de_entrada TIME NOT NULL,
    horario_de_salida TIME NOT NULL,
    fecha_de_vacaciones DATE NOT NULL,
    CONSTRAINT fk_horario_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE CASCADE
);

-- 2. Cambiar el delimitador JUSTO ANTES de empezar el Trigger
DELIMITER //

CREATE TRIGGER check_rol_antes_de_horario
BEFORE INSERT ON Horario
FOR EACH ROW
BEGIN
    DECLARE v_id_rol INT;

    SELECT ID_rol INTO v_id_rol 
    FROM Usuario 
    WHERE ID_usuario = NEW.ID_usuario;

    IF v_id_rol = 3 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error de negocio: No se le puede asignar un horario de trabajo a un Cliente.';
    END IF;
END // 

DELIMITER ; 
INSERT INTO Horario (ID_usuario, Turno, horario_de_entrada, horario_de_salida, fecha_de_vacaciones) 
VALUES (2, 'Turno Mañana Logística', '06:00:00', '14:00:00', '2027-02-10'),
       (1, 'turno tarde ADMIN', '06:00:00', '14:00:00','2026-12-24');

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

INSERT INTO recibo (ID_usuario, id_repuestos, detalle_producto, fecha_entrega, cantidad, precio) VALUES
(3, 101, 'Pastillas de Freno Brembo - Venta Mostrador', '2026-08-20', 2, 45000),
(3, 102, 'Filtro de Aceite Bosch - Repuesto Filtración', '2026-08-25', 1, 12000),
(2, 103, 'Bujias NGK Iridium - Pack x4', '2026-08-28', 1, 32000);
