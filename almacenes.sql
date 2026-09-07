drop database if exists Almacenes;
create database Almacenes;
use Almacenes;

CREATE TABLE Categoria (
    Categoria_id INT NOT NULL PRIMARY KEY,
    nombre TEXT NOT NULL
);

CREATE TABLE almacen (
    ID_almacen BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Categoria_id INT NOT NULL,
    nombre TEXT NOT NULL, 
    capacidad_MAX INT NOT NULL,
    dirección TEXT NOT NULL,
    CONSTRAINT fk_almacen_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

CREATE TABLE Repuestos (
    id_repuestos BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    codigo_sku TEXT NOT NULL, 
    tipo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    Categoria_id INT NOT NULL,
    CONSTRAINT fk_repuestos_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

CREATE TABLE stock_de_repuestos (
    ID_almacen BIGINT NOT NULL,
    id_repuestos BIGINT NOT NULL,
    stock_actual BIGINT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 10,
    PRIMARY KEY (ID_almacen, id_repuestos),
    CONSTRAINT fk_stock_almacen FOREIGN KEY (ID_almacen) REFERENCES almacen(ID_almacen) ON DELETE CASCADE,
    CONSTRAINT fk_stock_repuestos FOREIGN KEY (id_repuestos) REFERENCES Repuestos(id_repuestos) ON DELETE CASCADE
);

CREATE TABLE provedores (
    id_provedor BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa TEXT NOT NULL,
    cuit_rut TEXT NOT NULL,
    telefono TEXT,
    email TEXT
);

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

CREATE TABLE Costos (
    ID_costo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    porcentaje_ganancia INT NOT NULL,
    id_provedor BIGINT NOT NULL,
    Categoria_id INT NOT NULL,
    CONSTRAINT fk_costos_proveedor FOREIGN KEY (id_provedor) REFERENCES provedores(id_provedor),
    CONSTRAINT fk_costos_categoria FOREIGN KEY (Categoria_id) REFERENCES Categoria(Categoria_id)
);

CREATE TABLE envios (
    Numero_de_envio BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ID_almacen BIGINT NOT NULL,
    fecha_hora_entrega DATETIME,
    Estado ENUM('Pendiente', 'En Camino', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
    comfirmardor BIGINT,
    CONSTRAINT fk_envios_almacen FOREIGN KEY (ID_almacen) REFERENCES almacen(ID_almacen)
);
INSERT INTO Categoria (Categoria_id, nombre) VALUES
(10, 'Frenos y Suspension'),
(20, 'Motor y Filtracion'),
(30, 'Encendido y Electricidad');

INSERT INTO almacen (Categoria_id, nombre, capacidad_MAX, dirección) VALUES
(10, 'Almacen Central Norte', 5000, 'Ruta 9 Km 40, Benavidez'),
(20, 'Almacen Distribucion Sur', 3000, 'Av. Hipolito Yrigoyen 4500, Lanus'),
(30, 'Deposito Express CABA', 1500, 'Av. Warnes 1540, CABA');

INSERT INTO Repuestos (id_repuestos, codigo_sku, tipo, nombre, descripcion, Categoria_id) VALUES
(101, 'BRM-CER-001', 'Pastilla', 'Pastillas de Freno Brembo', 'Pastillas ceramicas de alto rendimiento', 10),
(102, 'BSH-OIL-992', 'Filtro', 'Filtro de Aceite Bosch', 'Filtro blindado de larga duracion', 20),
(103, 'NGK-IRD-555', 'Bujia', 'Bujias NGK Iridium', 'Bujia de iridio eficiente', 30);

INSERT INTO stock_de_repuestos (ID_almacen, id_repuestos, stock_actual, stock_minimo) VALUES
(1, 101, 120, 15),
(2, 102, 450, 30),
(3, 103, 80, 10);

INSERT INTO provedores (id_provedor, nombre_empresa, cuit_rut, telefono, email) VALUES
(1, 'Brembo Corp S.A.', '30-11111111-9', '4444-1234', 'ventas@brembo.com'),
(2, 'Robert Bosch Argentina', '30-22222222-9', '4444-5678', 'mayorista@bosch.com');

INSERT INTO compras_proveedor (id_provedor, id_repuestos, cantidad, costo_unitario) VALUES
(1, 101, 200, 25000),
(2, 102, 500, 7000);

INSERT INTO Costos (porcentaje_ganancia, id_provedor, Categoria_id) VALUES
(35, 1, 10),
(40, 2, 20);

INSERT INTO envios (Numero_de_envio, ID_almacen, fecha_hora_entrega, Estado, comfirmardor) VALUES
(501, 1, '2026-08-15 14:30:00', 'Entregado', 2),
(502, 2, '2026-08-27 09:15:00', 'En Camino', 2),
(503, 3, NULL, 'Pendiente', NULL);

