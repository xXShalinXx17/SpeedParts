DROP DATABASE IF EXISTS autopartes_db;
CREATE DATABASE autopartes_db;
USE autopartes_db;

-- ==========================================
-- MÓDULO 1: GEOGRAFÍA Y PARAMÉTRICAS
-- ==========================================

CREATE TABLE Codigos_postales(
    Codigo_postal INT NOT NULL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    ID_codigo INT NOT NULL
);

INSERT INTO Codigos_postales(ID_codigo, Nombre, Codigo_postal) VALUES
(1,'CABA', 1000),
(2,'CABA/COMUNA 1', 1427),
(3,'CABA/COMUNA 2', 1425),
(4,'CABA/COMUNA 3', 1259),
(5,'CABA/COMUNA 4', 1437),
(6,'CABA/COMUNA 5', 1257),
(7,'CABA/COMUNA 6', 1424),
(8,'CABA/COMUNA 7', 1238),
(9,'CABA/COMUNA 8', 1439),
(10,'CABA/COMUNA 9', 1440),
(11,'CABA/COMUNA 10', 1086),
(12,'CABA/COMUNA 11', 1429),
(13,'CABA/COMUNA 12', 1431),
(14,'CABA/COMUNA 13', 1430),
(15,'CABA/COMUNA 14', 1004),
(16, 'CABA/COMUNA 15',1069);

CREATE TABLE Rol(
    ID_rol INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Roles VARCHAR(50) NOT NULL
);

INSERT INTO Rol (ID_rol, Roles) VALUES 
(1, 'Administrador'),
(2, 'Empleado'),
(3, 'Cliente');

CREATE TABLE Sub_Rol_Empleado (
    ID_sub_rol INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Nombre_puesto VARCHAR(100) NOT NULL
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

CREATE TABLE Metodo_de_pago(
    ID_pago BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Tipo_de_pago VARCHAR(50) NOT NULL
);

INSERT INTO Metodo_de_pago ( ID_pago, Tipo_de_pago) VALUES
(1, "Efectivo "),
(2, "Transferencia "),
(3, "Tarjeta de Credito "),
(4, "Tarjeta de Debito ");

CREATE TABLE Categoria (
    Categoria_id INT NOT NULL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO Categoria (Categoria_id, nombre) VALUES
(1, 'Autos'),
(2, 'Camionetas / Pick-ups'),
(3, 'SUV'),
(4, 'Motos'),
(5, 'Lanchas / barcos'),
(6, 'Motores nauticos');

-- ==========================================
-- MÓDULO 2: USUARIOS Y EMPLEADOS
-- ==========================================

CREATE TABLE Usuario (
    ID_usuario BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_rol INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    DNI INT NOT NULL,
    Codigo_postal INT NOT NULL,
    Direccion VARCHAR(255) NOT NULL,
    Gmail VARCHAR(150) NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    requiere_cambio_clave BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (ID_rol) REFERENCES Rol(ID_rol),
    CONSTRAINT fk_usuario_Codigos_postales FOREIGN KEY (Codigo_postal) REFERENCES Codigos_postales(Codigo_postal)
);

DELIMITER //

CREATE TRIGGER validar_datos_usuario_nuevo
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    IF NEW.Gmail NOT LIKE '%@gmail.com%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de validacion: El correo electronico ingresado no tiene un formato valido.';
    END IF;
    IF NEW.DNI <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de validacion: El numero de DNI debe ser mayor a cero.';
    END IF;
END //
DELIMITER ;

INSERT INTO Usuario (ID_usuario, ID_rol, Nombre, Apellido, telefono, DNI, Direccion, Codigo_postal, Gmail, contraseña) VALUES
(1, 1, 'Carlos martinez', 'Gómez', 1145678901, 30123456, 'Av. Santa Fe 1234, CABA', 1430, 'carlos.gomez@gmail.com', 'helloperras9328'),
(2, 2, 'Ana', 'Martínez', 1156789012, 35789123, 'Calle Florida 550, CABA', 1004, 'ana.martinez@gmail.com', 'anana64'),
(3, 2, 'Julian', 'Rodriguez',1195315775, 49172856, 'Av. Cordoba 2134, CABA', 1069, 'julian.rodriguez@gmail.com', 'juli1990hfgd');


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
(1, 1, 13),
(2, 2, 5),
(3, 3, 2);

CREATE TABLE registro (
    ID_registro BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    ip_direccion VARCHAR(45) NOT NULL,                  
    dispositivo VARCHAR(255),                           
    estado_conexion TEXT,      
    CONSTRAINT fk_registro_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario) ON DELETE CASCADE
);

DELIMITER //

CREATE TRIGGER bloquear_modificacion_auditoria
BEFORE UPDATE ON registro
FOR EACH ROW
BEGIN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguridad: Los registros de auditoria son de solo lectura y no se pueden modificar.';
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER bloquear_borrado_auditoria
BEFORE DELETE ON registro
FOR EACH ROW
BEGIN
IF (SELECT COUNT(*) FROM Usuario WHERE ID_usuario = OLD.ID_usuario) > 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Seguridad: No esta permitido borrar registros de auditoria de forma manual.';
END IF;
END //

DELIMITER ;

INSERT INTO registro (ID_usuario, ip_direccion, dispositivo, estado_conexion) VALUES
(1, '192.168.1.50', 'Chrome OS / PC Oficina Central', 'Exitoso'),
(2, '181.44.212.10', 'Firefox / Windows 11 - Logística', 'Exitoso'),
(3, '190.2.115.88', 'Safari / iPhone 15 Pro Max', 'Fallido'); 


CREATE TABLE Horario_de_oficina(
    ID_horario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_detalle BIGINT NOT NULL UNIQUE,
    Turno VARCHAR(100) NOT NULL,
    horario_de_entrada TIME NOT NULL,
    horario_de_salida TIME NOT NULL,
    fecha_de_vacaciones DATE NOT NULL,
    lunes BOOLEAN DEFAULT TRUE,
    martes BOOLEAN DEFAULT TRUE,
    miercoles BOOLEAN DEFAULT TRUE,
    jueves BOOLEAN DEFAULT TRUE,
    viernes BOOLEAN DEFAULT TRUE,
    sabado BOOLEAN DEFAULT FALSE,
    domingo BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_horario_detalle FOREIGN KEY (ID_detalle) REFERENCES Detalle_Empleado(ID_detalle) ON DELETE CASCADE
);

DELIMITER //

CREATE TRIGGER validar_coherencia_horas
BEFORE INSERT ON Horario_de_oficina
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

SELECT ID_sub_rol INTO v_id_sub_rol FROM Detalle_Empleado WHERE ID_detalle = NEW.ID_detalle;
SELECT COUNT(*) INTO v_cantidad_vacaciones_coincidentes FROM Horario_de_oficina H
INNER JOIN Detalle_Empleado D ON H.ID_detalle = D.ID_detalle
WHERE D.ID_sub_rol = v_id_sub_rol AND H.fecha_de_vacaciones = NEW.fecha_de_vacaciones;

IF v_cantidad_vacaciones_coincidentes >= 4 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error RRHH: Cupo maximo alcanzado. Ya hay 4 empleados de este mismo departamento asignados a esa fecha de vacaciones.';
END IF;

END //

DELIMITER ;

INSERT INTO Horario_de_oficina (ID_detalle, Turno, horario_de_entrada, horario_de_salida, fecha_de_vacaciones, lunes, martes, miercoles, jueves, viernes) VALUES 
(2, 'Turno Mañana Logística', '06:00:00', '14:00:00', '2027-02-10', TRUE, TRUE, TRUE, FALSE, FALSE);

CREATE TABLE Home_Office (
    ID_home_office BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_detalle BIGINT NOT NULL, 
    fecha_inicio_remoto DATE NOT NULL, 
    cantidad_dias_remotos INT NOT NULL, 
    fecha_retorno_oficina DATE NOT NULL, 
    estado_actual ENUM('En_Oficina', 'En_Home_Office', 'Finalizado') DEFAULT 'En_Oficina',
    CONSTRAINT fk_home_office_detalle FOREIGN KEY (ID_detalle) REFERENCES Detalle_Empleado(ID_detalle) ON DELETE CASCADE
);

DELIMITER //

CREATE TRIGGER calcular_fecha_retorno
BEFORE INSERT ON Home_Office
FOR EACH ROW
BEGIN

IF NEW.cantidad_dias_remotos <= 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error RRHH: La cantidad de dias de Home Office debe ser mayor a cero.';
END IF;

SET NEW.fecha_retorno_oficina = DATE_ADD(NEW.fecha_inicio_remoto, INTERVAL NEW.cantidad_dias_remotos DAY);

SET NEW.estado_actual = 'En_Home_Office';
END //

DELIMITER ;

INSERT INTO Home_Office (ID_detalle, fecha_inicio_remoto, cantidad_dias_remotos) 
VALUES (2, CURDATE(), 4);

-- ==========================================
-- MÓDULO 3: ALMACENES, PRODUCTOS Y LOGÍSTICA
-- ==========================================

CREATE TABLE almacen (
    ID_almacen BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Categoria_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL, 
    capacidad_MAX INT NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    CONSTRAINT fk_almacen_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

INSERT INTO almacen (ID_almacen, Categoria_id, nombre, capacidad_MAX, direccion) VALUES
(1, 1, 'Almacen Central Norte', 5000, 'Ruta 9 Km 40, Benavidez'),
(2, 4, 'Deposito Express CABA', 1500, 'Av. Warnes 1540, CABA');

CREATE TABLE Repuestos (
    id_repuestos BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    codigo_sku VARCHAR(50) NOT NULL UNIQUE, -- Agregado UNIQUE para evitar duplicar SKUs
    tipo VARCHAR(50) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    Categoria_id INT NOT NULL,
    CONSTRAINT fk_repuestos_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

INSERT INTO Repuestos (id_repuestos, codigo_sku, tipo, nombre, descripcion, Categoria_id) VALUES
(101, 'BRM-CER-001', 'Pastilla', 'Pastillas de Freno Brembo', 'Pastillas ceramicas de alto rendimiento', 1),
(102, 'BSH-OIL-992', 'Filtro', 'Filtro de Aceite Bosch', 'Filtro blindado de larga duracion', 1),
(103, 'NGK-IRD-555', 'Bujia', 'Bujias NGK Iridium', 'Bujia de iridio eficiente', 4);

CREATE TABLE Marcas_Vehiculo (
    id_marca INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Marcas_Vehiculo (nombre) VALUES 
('Toyota'),             
('Volkswagen'),          
('Honda'),               
('Yamaha'),              
('Astillero Bermuda'),   
('Mercury Marine');

CREATE TABLE Modelos_Vehiculo (
    id_modelo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_marca INT NOT NULL,
    Categoria_id INT NOT NULL, -- Relación agregada
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT fk_modelo_marca FOREIGN KEY (id_marca) REFERENCES Marcas_Vehiculo(id_marca),
    CONSTRAINT fk_modelo_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

INSERT INTO Modelos_Vehiculo (id_marca, Categoria_id, nombre) VALUES 
(1, 1, 'Corolla'),  
(2, 1, 'Gol'),  
(3, 4, 'Wave 110S'),  
(4, 4, 'YBR 125'),   
(5, 5, 'Discovery'),  
(6, 6, 'SeaPro');   

CREATE TABLE Versiones_Vehiculo (
    id_version INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_modelo INT NOT NULL,
    anio_inicio INT NOT NULL,
    anio_fin INT NULL,
    motorizacion VARCHAR(100) NOT NULL,
    CONSTRAINT fk_version_modelo FOREIGN KEY (id_modelo) REFERENCES Modelos_Vehiculo(id_modelo)
);

INSERT INTO Versiones_Vehiculo (id_modelo, anio_inicio, anio_fin, motorizacion) VALUES 
(1, 2014, 2019, '1.8 Dual VVT-i Nafta'),       
(2, 2008, 2014, '1.6 8v Trend Nafta'),          
(3, 2019, 2026, '110cc Monocilíndrico 4T'),       
(4, 2015, 2023, '125cc Inyección SOHC'),    
(5, 2018, 2026, 'Eslora 5.2m - Casco Abierto'),   
(6, 2020, 2026, '60HP 4 Tiempos Fuera de Borda'); 

CREATE TABLE Compatibilidad_Repuesto (
    id_repuestos BIGINT NOT NULL,
    id_version INT NOT NULL,
    PRIMARY KEY (id_repuestos, id_version),
    CONSTRAINT fk_compat_repuesto FOREIGN KEY (id_repuestos) REFERENCES Repuestos(id_repuestos) ON DELETE CASCADE,
    CONSTRAINT fk_compat_version FOREIGN KEY (id_version) REFERENCES Versiones_Vehiculo(id_version) ON DELETE CASCADE
);

INSERT INTO Compatibilidad_Repuesto (id_repuestos, id_version) VALUES 
(101, 1), 
(102, 2), 
(103, 3),
(103, 4),
(103, 6); 

CREATE TABLE stock_de_repuestos (
    ID_almacen BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL,
    stock_actual BIGINT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 10,
    PRIMARY KEY (ID_almacen, id_repuestos),
    CONSTRAINT fk_stock_almacen FOREIGN KEY (ID_almacen) REFERENCES almacen(ID_almacen) ON DELETE CASCADE,
    CONSTRAINT fk_stock_repuestos FOREIGN KEY (id_repuestos) REFERENCES Repuestos(id_repuestos) ON DELETE CASCADE
);

DELIMITER //


CREATE TRIGGER controlar_capacidad_maxima_almacen
BEFORE INSERT ON stock_de_repuestos
FOR EACH ROW
BEGIN
DECLARE v_capacidad_max INT;
DECLARE v_stock_total_actual BIGINT;
SELECT capacidad_MAX INTO v_capacidad_max FROM almacen WHERE ID_almacen = NEW.ID_almacen;
SELECT IFNULL(SUM(stock_actual), 0) INTO v_stock_total_actual FROM stock_de_repuestos WHERE ID_almacen = NEW.ID_almacen;
IF (v_stock_total_actual + NEW.stock_actual) > v_capacidad_max THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Logistico: No se puede añadir stock. Supera la capacidad maxima configurada para este almacen.';
END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER bloquear_stock_negativo
BEFORE UPDATE ON stock_de_repuestos
FOR EACH ROW
BEGIN
IF NEW.stock_actual < 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de Inventario: La operacion causaria un stock negativo. Accion cancelada.';
END IF;
END //

DELIMITER ;

CREATE TABLE proveedores (
    id_proveedor BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(150) NOT NULL,
    cuit_rut VARCHAR(50) NOT NULL,
    telefono VARCHAR(50),
    email VARCHAR(150)
);

INSERT INTO proveedores (id_proveedor, nombre_empresa, cuit_rut, telefono, email) VALUES
(1, 'Toyota Argentina S.A.', '30-99900001-9', '0800-444-8696', 'contacto@toyota.com.ar'),
(2, 'Volkswagen Group', '30-99900002-9', '0800-888-8655', 'proveedores@vw.com.ar'),
(3, 'Fiat Stellantis', '30-99900003-9', '0800-333-3428', 'ventas@fiat.com.ar'),
(4, 'Renault Argentina', '30-99900004-9', '0800-333-7362', 'info@renault.com.ar'),
(5, 'Peugeot Argentina', '30-99900005-9', '0800-222-7384', 'contacto@peugeot.com.ar'),
(6, 'Ford Argentina', '30-99900006-9', '0800-888-3673', 'atencion@ford.com.ar'),
(7, 'Chevrolet General Motors', '30-99900007-9', '0800-122-4389', 'soporte@chevrolet.com.ar'),
(8, 'Citroen Argentina', '30-99900008-9', '0800-222-2487', 'info@citroen.com.ar'),
(9, 'Nissan Argentina', '30-99900009-9', '0800-222-6477', 'comercial@nissan.com.ar'),
(10, 'Honda Motor Argentina', '30-99900010-9', '0800-122-4663', 'repuestos@honda.com.ar'),
(11, 'Hyundai Argentina', '30-99900011-9', '011-4717-5000', 'ventas@hyundai.com.ar'),
(12, 'Kia Argentina', '30-99900012-9', '0810-333-5422', 'contacto@kia.com.ar'),
(13, 'Mercedes-Benz Argentina', '30-99900013-9', '0800-666-2369', 'info@://benz.com'),
(14, 'BMW Group Argentina', '30-99900014-9', '011-5555-6000', 'postventa@bmw.com.ar'),
(15, 'Audi Argentina', '30-99900015-9', '011-4717-8000', 'atencion@audi.com.ar'),
(16, 'Jeep Argentina', '30-99900016-9', '0800-333-5337', 'contacto@jeep.com.ar'),
(17, 'Chery Socma Argentina', '30-99900017-9', '011-5235-9500', 'ventas@chery.com.ar'),
(18, 'Haval Argentina', '30-99900018-9', '0810-222-4282', 'info@haval.com.ar'),
(19, 'BAIC Argentina', '30-99900019-9', '011-4708-3000', 'contacto@baic.com.ar'),
(20, 'GWM Great Wall Motors', '30-99900020-9', '0810-222-1111', 'repuestos@gwm.com.ar'),
(21, 'RAM Trucks Argentina', '30-99900021-9', '0800-333-7267', 'info@ram.com.ar'),
(22, 'Motomel La Emilia S.A.', '30-99900022-9', '0336-448-9000', 'ventas@motomel.com.ar'),
(23, 'Gilera Motors Argentina', '30-99900023-9', '011-4299-6900', 'contacto@gilera.com.ar'),
(24, 'Corven Motors', '30-99900024-9', '03462-43-8000', 'repuestos@corven.com.ar'),
(25, 'Zanella Hermanos', '30-99900025-9', '011-4713-3333', 'info@zanella.com.ar'),
(26, 'Bajaj Auto Argentina', '30-99900026-9', '0800-444-2252', 'soporte@bajaj.com.ar'),
(27, 'Yamaha Motor Argentina', '30-99900027-9', '011-5555-9300', 'atencion@yamaha.com.ar'),
(28, 'Keller Motors', '30-99900028-9', '0351-475-0011', 'ventas@kellermotos.com'),
(29, 'Mondial Motos', '30-99900029-9', '011-4444-8888', 'info@mondial.com.ar'),
(30, 'Guerrero Motos', '30-99900030-9', '0341-437-5555', 'contacto@guerreromotos.com'),
(31, 'Benelli Argentina', '30-99900031-9', '0800-555-2363', 'postventa@benelli.com'),
(32, 'Suzuki Motos Argentina', '30-99900032-9', '011-4500-1200', 'consultas@suzuki.com.ar'),
(33, 'Royal Enfield Argentina', '30-99900033-9', '011-5252-4400', 'info@royalenfield.com.ar'),
(34, 'Kawasaki Argentina', '30-99900034-9', '011-4848-9000', 'ventas@kawasaki.com.ar'),
(35, 'Astillero Regnicoli', '30-99900035-9', '011-4744-1234', 'info@regnicoli.com.ar'),
(36, 'Astillero Bermuda', '30-99900036-9', '011-4745-5678', 'ventas@bermuda.com.ar'),
(37, 'Canestrari Astillero', '30-99900037-9', '011-4746-9012', 'contacto@canestrari.com.ar'),
(38, 'Arco Iris Astilleros', '30-99900038-9', '011-4749-3456', 'info@astilleroarcoiris.com'),
(39, 'Trakker Astilleros', '30-99900039-9', '0341-493-1111', 'ventas@trakker.com.ar'),
(40, 'Paglietini Astillero Historico', '30-99900040-9', '011-4744-9999', 'historico@paglietini.com'),
(41, 'Klase A Yachts', '30-99900041-9', '011-4725-1500', 'info@klasea.com'),
(42, 'Astillero Campanili', '30-99900042-9', '0351-471-4444', 'contacto@campanili.com.ar'),
(43, 'Geuna Astillero', '30-99900043-9', '011-4744-8888', 'ventas@geuna.com'),
(44, 'Quicksilver Boats', '30-99900044-9', '011-4745-2222', 'info@quicksilver.com'),
(45, 'Bayliner Boats', '30-99900045-9', '001-800-443-9119', 'global@bayliner.com'),
(46, 'Sea Ray Yachts', '30-99900046-9', '001-800-367-1111', 'info@searay.com'),
(47, 'Beneteau Group', '30-99900047-9', '0033-2-51-60-5000', 'contact@beneteau.fr'),
(48, 'Jeanneau Yachts', '30-99900048-9', '0033-2-51-60-5100', 'contact@jeanneau.fr'),
(49, 'Azimut Yachts', '30-99900049-9', '0039-011-93161', 'info@azimutyachts.com'),
(50, 'Ferretti Group', '30-99900050-9', '0039-0543-787511', 'sales@ferrettigroup.com'),
(51, 'Princess Yachts', '30-99900051-9', '0044-1752-203888', 'info@princessyachts.com'),
(52, 'Mercury Marine Argentina', '30-99900052-9', '011-4717-3030', 'ventas@mercurymarine.com'),
(53, 'Tohatsu Outboards', '30-99900053-9', '0081-3-3966-3111', 'service@tohatsu.co.jp'),
(54, 'Evinrude Argentina', '30-99900054-9', '011-4848-1111', 'repuestos@evinrude.com.ar'),
(55, 'Volvo Penta Argentina', '30-99900055-9', '011-4000-8100', 'soporte@volvopenta.com'),
(56, 'Yanmar Marine', '30-99900056-9', '0081-6-6376-6211', 'global@yanmar.com'),
(57, 'Cummins Motores', '30-99900057-9', '011-4736-6000', 'info@cummins.com.ar'),
(58, 'Caterpillar Marine', '30-99900058-9', '0800-333-2288', 'marine@cat.com');

CREATE TABLE proveedor_categorias (
    id_proveedor BIGINT NOT NULL,
    Categoria_id INT NOT NULL,
    PRIMARY KEY (id_proveedor, Categoria_id),
    CONSTRAINT fk_prov_cat_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON DELETE CASCADE,
    CONSTRAINT fk_prov_cat_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id) ON DELETE CASCADE
);

INSERT INTO proveedor_categorias (id_proveedor, Categoria_id) VALUES 
(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3),(4,1),(4,2),(4,3),(6,1),(6,2),(6,3),(7,1),(7,2),(7,3),(9,1),(9,2),(9,3),
(5,1),(5,3),(8,1),(8,3),(17,1),(17,3),(18,1),(18,3),(19,1),(19,3),(20,1),(20,3),(16,3),(21,2),(11,1),(12,1),(13,1),(15,1),
(10,1),(10,4),(14,1),(14,4),(32,4),(32,6),(27,4),(27,6),(22,4),(23,4),(24,4),(25,4),(26,4),(28,4),(29,4),(30,4),(31,4),(33,4),(34,4),
(35,5),(36,5),(37,5),(38,5),(39,5),(40,5),(41,5),(42,5),(43,5),(44,5),(45,5),(46,5),(47,5),(48,5),(49,5),(50,5),(51,5),
(52,6),(53,6),(54,6),(55,6),(56,6),(57,6),(58,6);

CREATE TABLE compras_proveedor (
    id_compra BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_proveedor BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario BIGINT NOT NULL,
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_compras_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    CONSTRAINT fk_compras_repuesto FOREIGN KEY (id_repuestos) REFERENCES Repuestos(id_repuestos)
);

DELIMITER //

CREATE TRIGGER actualizar_stock_por_compra_proveedor
AFTER INSERT ON compras_proveedor
FOR EACH ROW
BEGIN

IF EXISTS (SELECT 1 FROM stock_de_repuestos WHERE ID_almacen = 1 AND id_repuestos = NEW.id_repuestos) THEN
UPDATE stock_de_repuestos
SET stock_actual = stock_actual + NEW.cantidad
WHERE ID_almacen = 1 AND id_repuestos = NEW.id_repuestos;

ELSE
INSERT INTO stock_de_repuestos (ID_almacen, id_repuestos, stock_actual, stock_minimo)
VALUES (1, NEW.id_repuestos, NEW.cantidad, 10);
END IF;

END //

DELIMITER ;

INSERT INTO compras_proveedor (id_proveedor, id_repuestos, cantidad, costo_unitario) VALUES
(1, 101, 200, 25000), 
(2, 102, 500, 7000);  

CREATE TABLE Costos (
    ID_costo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    porcentaje_ganancia INT NOT NULL,
    id_proveedor BIGINT NOT NULL,
    Categoria_id INT NOT NULL,
    CONSTRAINT fk_costos_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    CONSTRAINT fk_costos_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

DELIMITER //

CREATE TRIGGER validar_costos_y_ganancias
BEFORE INSERT ON Costos
FOR EACH ROW
BEGIN

IF NEW.porcentaje_ganancia <= 0 OR NEW.porcentaje_ganancia > 200 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Financiero: El porcentaje de ganancia debe ser mayor a 0% y menor o igual a 200%.';
END IF;

END //

DELIMITER ;

INSERT INTO Costos (porcentaje_ganancia, id_proveedor, Categoria_id) 
VALUES(35, 1, 1),
      (40, 2, 1);

-- ==========================================
-- MÓDULO 4: VENTAS, FACTURACIÓN Y ENVÍOS
-- ==========================================

CREATE TABLE Pedidos (
    id_pedido BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_usuario BIGINT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ID_pago BIGINT NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    Estado_Pago ENUM('Pendiente', 'Aprobado', 'Rechazado') DEFAULT 'Pendiente',
    CONSTRAINT fk_pedido_usuario FOREIGN KEY (ID_usuario) REFERENCES Usuario(ID_usuario),
    CONSTRAINT fk_pedido_pago FOREIGN KEY (ID_pago) REFERENCES Metodo_de_pago(ID_pago)
);

DELIMITER //
CREATE TRIGGER proteger_pedidos_aprobados
BEFORE UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    -- Si el pedido ya estaba aprobado, no se puede alterar el dinero ni el usuario
    IF OLD.Estado_Pago = 'Aprobado' AND (NEW.monto_total <> OLD.monto_total OR NEW.ID_usuario <> OLD.ID_usuario) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error Comercial: No se pueden modificar los montos de un pedido que ya fue aprobado.';
    END IF;
END //
DELIMITER ;


INSERT INTO Pedidos (id_pedido, ID_usuario, ID_pago, monto_total, Estado_Pago) 
VALUES (1001, 3, 2, 102000.00, 'Aprobado');

CREATE TABLE Detalle_Pedido (
    id_pedido BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_repuestos),
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_repuesto FOREIGN KEY (id_repuestos) REFERENCES Repuestos(id_repuestos)
);

DELIMITER //

CREATE TRIGGER validar_cantidades_detalle_pedido
BEFORE INSERT ON Detalle_Pedido
FOR EACH ROW
BEGIN
    IF NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Facturacion: La cantidad del producto vendido debe ser mayor a cero.';
    END IF;
    
    IF NEW.precio_unitario <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Facturacion: El precio unitario del producto debe ser mayor a cero.';
    END IF;
END //

DELIMITER ;

INSERT INTO Detalle_Pedido (id_pedido, id_repuestos, cantidad, precio_unitario) 
VALUES 
(1001, 101, 2, 45000.00),
(1001, 102, 1, 12000.00);

CREATE TABLE envios (
    Numero_de_envio BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_pedido BIGINT NOT NULL,         
    ID_almacen BIGINT NOT NULL,
    fecha_hora_entrega DATETIME,
    Estado ENUM('Pendiente', 'En Camino', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
    confirmador BIGINT,                 
    CONSTRAINT fk_envios_pedido FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_envios_almacen FOREIGN KEY (ID_almacen) REFERENCES almacen(ID_almacen),
    CONSTRAINT fk_envios_empleado FOREIGN KEY (confirmador) REFERENCES Detalle_Empleado(ID_detalle)
);

DELIMITER //
CREATE TRIGGER validar_confirmador_envio
BEFORE UPDATE ON envios
FOR EACH ROW
BEGIN
    -- Si pasa a estar en viaje o entregado, sí o sí tiene que haber un empleado responsable
    IF (NEW.Estado = 'En Camino' OR NEW.Estado = 'Entregado') AND NEW.confirmador IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error Logistico: Debe asignar un empleado responsable (confirmador) para despachar o entregar el envio.';
    END IF;
END //
DELIMITER ;


INSERT INTO envios (Numero_de_envio, id_pedido, ID_almacen, fecha_hora_entrega, Estado, confirmador)
VALUES (5001, 1001, 1, '2026-10-23 10:00:00', 'En Camino', 1);

CREATE TABLE Promocion (
    id_promocion BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_promocion VARCHAR(150) NOT NULL,    
    tipo_promocion ENUM('Descuento_Individual', 'Combo_Productos') NOT NULL,
    precio_fijo_combo BIGINT NULL,      
    porcentaje_descuento INT NULL,       
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

DELIMITER //
CREATE TRIGGER validar_datos_promocion
BEFORE INSERT ON Promocion
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin <= NEW.fecha_inicio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Comercial: La fecha de fin de la promocion no puede ser menor o igual a la de inicio.';
    END IF;

    IF NEW.tipo_promocion = 'Descuento_Individual' AND (NEW.porcentaje_descuento <= 0 OR NEW.porcentaje_descuento > 100) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Comercial: El porcentaje de descuento debe estar entre 1% y 100%.';
    END IF;

    IF NEW.tipo_promocion = 'Combo_Productos' AND NEW.precio_fijo_combo <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Comercial: El precio fijo del combo debe ser un monto mayor a cero.';
    END IF;
END //
DELIMITER ;

INSERT INTO Promocion (id_promocion, nombre_promocion, tipo_promocion, precio_fijo_combo, porcentaje_descuento, fecha_inicio, fecha_fin) 
VALUES (1, 'Combo Afinacion Express', 'Combo_Productos', 40000, NULL, '2026-10-01', '2026-11-30'),
       (2, 'Combo Afinacion Express', 'Descuento_Individual', 20000, NULL, '2026-10-01', '2026-11-30'),
       (3, 'Combo Afinacion Express', 'Combo_Productos', 40000, NULL, '2026-10-01', '2026-11-30');


CREATE TABLE detalle_combo_promocion (
    id_promocion BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL,
    cantidad_incluida INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_promocion, id_repuestos),
    CONSTRAINT fk_combo_promocion FOREIGN KEY (id_promocion) REFERENCES Promocion(id_promocion) ON DELETE CASCADE,
    CONSTRAINT fk_combo_repuesto FOREIGN KEY (id_repuestos) REFERENCES Repuestos(id_repuestos) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER validar_detalle_combo
BEFORE INSERT ON detalle_combo_promocion
FOR EACH ROW
BEGIN
    IF NEW.cantidad_incluida <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Logistico: La cantidad de repuestos incluidos en el combo debe ser mayor a cero.';
    END IF;
END //
DELIMITER ;

INSERT INTO detalle_combo_promocion (id_promocion, id_repuestos, cantidad_incluida) VALUES
(1, 102, 1),
(1, 103, 4);
