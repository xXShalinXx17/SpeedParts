drop database if exists CLIENTE;
create database CLIENTE;
use CLIENTE;

create table Usuario (
ID_usuario bigint not null auto_increment primary key,
Nombre text(100),
Apellido text(100),
telefono int(20) not null,
DNI int(8) not null,
Dirección text(150) not null,
Gmail text(500) not null,
contraseña text(500) not null
);

Create table Rol(
ID_rol int not null auto_increment primary key,
Nombre varchar(50) not null
);

create table registro(
ID_usuario bigint not null,
ID_rol int not null,
ID_registro bigint not null auto_increment primary key,
foreign key(ID_usuario) references Usuario(ID_usuario),
foreign key(ID_rol) references Rol(ID_rol)
);

create table Horario(
ID_rol int not null,
Turno varchar(40),
horario_de_entrada time not null,
horario_de_salida time not null,
fecha_de_vacaciones date not null
);

 
