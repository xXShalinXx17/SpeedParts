DROP DATABASE IF EXISTS Almacenes;
CREATE DATABASE Almacenes;
USE Almacenes;

CREATE TABLE Categoria (
    Categoria_id INT NOT NULL PRIMARY KEY,
    nombre TEXT NOT NULL
);

INSERT INTO Categoria (Categoria_id, nombre) VALUES
(1, 'Autos'),
(2, 'Camionetas / Pick-ups'),
(3, 'SUV'),
(4, 'Motos'),
(5, 'Lanchas / barcos'),
(6, 'Motores nauticos');

CREATE TABLE almacen (
    ID_almacen BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Categoria_id INT NOT NULL,
    nombre TEXT NOT NULL, 
    capacidad_MAX INT NOT NULL,
    dirección TEXT NOT NULL,
    CONSTRAINT fk_almacen_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

INSERT INTO almacen (Categoria_id, nombre, capacidad_MAX, dirección) VALUES
(1, 'Almacen Central Norte', 5000, 'Ruta 9 Km 40, Benavidez'),
(4, 'Deposito Express CABA', 1500, 'Av. Warnes 1540, CABA');

CREATE TABLE Repuestos (
    id_repuestos BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    codigo_sku TEXT NOT NULL, 
    tipo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    Categoria_id INT NOT NULL,
    CONSTRAINT fk_repuestos_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

INSERT INTO Repuestos (id_repuestos, codigo_sku, tipo, nombre, descripcion, Categoria_id) VALUES
(101, 'BRM-CER-001', 'Pastilla', 'Pastillas de Freno Brembo', 'Pastillas ceramicas de alto rendimiento', 1),
(102, 'BSH-OIL-992', 'Filtro', 'Filtro de Aceite Bosch', 'Filtro blindado de larga duracion', 1),
(103, 'NGK-IRD-555', 'Bujia', 'Bujias NGK Iridium', 'Bujia de iridio eficiente', 4);

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
CREATE TRIGGER bloquear_stock_negativo
BEFORE UPDATE ON stock_de_repuestos
FOR EACH ROW
BEGIN
    IF NEW.stock_actual < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Inventario: La operacion causaria un stock negativo. Accion cancelada.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER controlar_capacidad_maxima_almacen
BEFORE INSERT ON stock_de_repuestos
FOR EACH ROW
BEGIN
    DECLARE v_capacidad_max INT;
    DECLARE v_stock_total_actual BIGINT;

    SELECT capacidad_MAX INTO v_capacidad_max 
    FROM almacen 
    WHERE ID_almacen = NEW.ID_almacen;

    SELECT IFNULL(SUM(stock_actual), 0) INTO v_stock_total_actual 
    FROM stock_de_repuestos 
    WHERE ID_almacen = NEW.ID_almacen;

    IF (v_stock_total_actual + NEW.stock_actual) > v_capacidad_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error Logistico: No se puede añadir stock. Supera la capacidad maxima configurada para este almacen.';
    END IF;
END //
DELIMITER ;

INSERT INTO stock_de_repuestos (ID_almacen, id_repuestos, stock_actual, stock_minimo) VALUES
(1, 101, 120, 15),
(1, 102, 450, 30),
(2, 103, 80, 10);

CREATE TABLE provedores (
    id_provedor BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa TEXT NOT NULL,
    cuit_rut TEXT NOT NULL,
    telefono TEXT,
    email TEXT
);

INSERT INTO provedores (id_provedor, nombre_empresa, cuit_rut, telefono, email) VALUES
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
    id_provedor BIGINT NOT NULL,
    Categoria_id INT NOT NULL,
    PRIMARY KEY (id_provedor, Categoria_id),
    CONSTRAINT fk_prov_cat_proveedor FOREIGN KEY (id_provedor) REFERENCES provedores(id_provedor) ON DELETE CASCADE,
    CONSTRAINT fk_prov_cat_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id) ON DELETE CASCADE
);

INSERT INTO proveedor_categorias (id_provedor, Categoria_id) VALUES 
(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3),(4,1),(4,2),(4,3),(6,1),(6,2),(6,3),(7,1),(7,2),(7,3),(9,1),(9,2),(9,3),
(5,1),(5,3),(8,1),(8,3),(17,1),(17,3),(18,1),(18,3),(19,1),(19,3),(20,1),(20,3),(16,3),(21,2),(11,1),(12,1),(13,1),(15,1),
(10,1),(10,4),(14,1),(14,4),(32,4),(32,6),(27,4),(27,6),(22,4),(23,4),(24,4),(25,4),(26,4),(28,4),(29,4),(30,4),(31,4),(33,4),(34,4),
(35,5),(36,5),(37,5),(38,5),(39,5),(40,5),(41,5),(42,5),(43,5),(44,5),(45,5),(46,5),(47,5),(48,5),(49,5),(50,5),(51,5),
(52,6),(53,6),(54,6),(55,6),(56,6),(57,6),(58,6);

CREATE TABLE compras_proveedor (
    id_compra BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_provedor BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario BIGINT NOT NULL,
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_compras_proveedor FOREIGN KEY (id_provedor) REFERENCES provedores(id_provedor),
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

INSERT INTO compras_proveedor (id_provedor, id_repuestos, cantidad, costo_unitario) VALUES
(1, 101, 200, 25000), 
(2, 102, 500, 7000);  

CREATE TABLE Costos (
ID_costo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
porcentaje_ganancia INT NOT NULL,
id_provedor BIGINT NOT NULL,
Categoria_id INT NOT NULL,
CONSTRAINT fk_costos_proveedor FOREIGN KEY (id_provedor) REFERENCES provedores(id_provedor),
CONSTRAINT fk_costos_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

DELIMITER //

CREATE TRIGGER validar_costos_y_ganancias
BEFORE INSERT ON Costos
FOR EACH ROW
BEGIN
    IF NEW.porcentaje_ganancia <= 0 OR NEW.porcentaje_ganancia > 200 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error Financiero: El porcentaje de ganancia debe ser mayor a 0% y menor o igual a 200%.';
    END IF;
END //

DELIMITER ;

INSERT INTO Costos (porcentaje_ganancia, id_provedor, Categoria_id) 
VALUES(35, 1, 1),
      (40, 2, 1);
      
CREATE TABLE envios (
Numero_de_envio BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
ID_almacen BIGINT NOT NULL,
fecha_hora_entrega DATETIME,
Estado ENUM('Pendiente', 'En Camino', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
comfirmardor BIGINT,
CONSTRAINT fk_envios_almacen FOREIGN KEY (ID_almacen) REFERENCES almacen(ID_almacen)
);
   
   INSERT INTO envios (Numero_de_envio, ID_almacen, fecha_hora_entrega, Estado, comfirmardor)
   VALUES(501, 1, '2026-08-15 14:30:00', 'Entregado', 2),
         (502, 2, '2026-08-27 09:15:00', 'En Camino', 2),
		(503, 2, NULL, 'Pendiente', NULL);
