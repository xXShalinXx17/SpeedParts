drop database if exists Almacenes;
create database Almacenes;
use Almacenes;

create table Categoria (
    Categoria_id int not null primary key,
    nombre varchar (100)
);

create table almacen (
ID_almacen bigint not null auto_increment primary key,
Categoria_id int not null,
nombre text(150),
capacidad_MAX int not null,
dirección text(200),
foreign key(Categoria_id) references Categoria(Categoria_id)
);

create table Repuestos (
    id_repuestos bigint not null auto_increment primary key,
    tipo varchar (50),
    nombre varchar (50),
    descripcion text (2000),
     Categoria_id int not null,
    foreign key( Categoria_id) references Categoria ( Categoria_id)
);

create table stock_de_repuestos(
ID_almacen bigint not null,
id_repuestos bigint not null,
stock_actual bigint not null,
foreign key(ID_almacen) references almacen(ID_almacen),
foreign key(id_repuestos) references Repuestos(id_repuestos)
);

create table provedores(
id_provedor bigint not null auto_increment primary key,
nombre_del_repuesto varchar(100),
cantidad int not null,
costo bigint not null
);

create table Costos (
	ganancia int,
    id_provedor bigint,
    Categoria_id int not null,
    foreign key(Categoria_id) references Categoria(Categoria_id)
);

create table envios(
Numero_de_envio bigint not null auto_increment primary key,
ID_almacen bigint not null,
horario_de_entrega date,
Estado varchar(50),
comfimardor varchar(50),
foreign key(ID_almacen) references almacen(ID_almacen)
);

