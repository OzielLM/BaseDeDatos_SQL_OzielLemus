#Rogelio Ceballos Castillo 74823
#Daniel Isaí Saldaña Rocha 74949
#Oziel Imanol Lemus Montelongo 72634
#Guillermo Gonzalo Veyro Ramos 75083

use servicio_de_paquetería;

#Modificaciones para la antigua base de datos
rename table vendedor to remitente;
rename table comprador to destinatario;

show create table envio;
alter table envio drop foreign key envio_ibfk_2;
alter table remitente drop primary key, modify IdVendedor int not null;
alter table remitente change IdVendedor IdRemitente INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY;
alter table envio change IdVendedor IdRemitente INT UNSIGNED NOT NULL;
alter table envio add foreign key (IdRemitente) references remitente(IdRemitente);
alter table envio drop foreign key envio_ibfk_4;
alter table destinatario drop primary key, modify IdComprador int not null;
alter table destinatario change IdComprador IdDestinatario INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY;
alter table envio change IdComprador IdDestinatario INT UNSIGNED NOT NULL;
alter table envio add foreign key (IdDestinatario) references destinatario(IdDestinatario);

ALTER TABLE paquete ADD Tipo VARCHAR(200) NOT NULL;

#Creacion de nuevas tablas
create table historial_envio(
idHistorial INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
idEnvio INT UNSIGNED NOT NULL,
fechaHora datetime not null,
estado VARCHAR(100) NOT NULL,
codigoSeguimiento VARCHAR(16) NOT NULL,
FOREIGN KEY (idEnvio) REFERENCES envio(IdEnvio) 
);

create table ruta_repartidor(
idRuta INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
idRepartidor INT UNSIGNED NOT NULL,
descripcion VARCHAR(200) NOT NULL,
fechaAsignacion DATE NOT NULL,
idDestinatario INT UNSIGNED NOT NULL,
FOREIGN KEY (idRepartidor) REFERENCES repartidor(IdRepartidor),
FOREIGN KEY (idDestinatario) REFERENCES destinatario(IdDestinatario)
);

create table vehiculo(
idVehiculo INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
marca VARCHAR(50) NOT NULL,
modelo VARCHAR(100) NOT NULL,
matricula VARCHAR(10) NOT NULL,
capacidad_carga VARCHAR(50) NOT NULL,
estado VARCHAR(50) NOT NULL
);

#Otras modificaciones a las tablas antiguas
alter table repartidor drop column Vehiculo;
alter table repartidor add column IdVehiculo INT UNSIGNED NOT NULL;

alter table envio add column codigoSeguimiento VARCHAR(16) NOT NULL; 

#Creacion de auditorias
create table auditar_historial (
	ID					INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
	IDHISTORIAL			INT UNSIGNED NOT NULL,
    IDENVIO				VARCHAR(100),
	FECHAHORA			VARCHAR(100),
    ESTADO				VARCHAR(100),
    CODIGOSEGUIMIENTO	VARCHAR(100),
	FECHA				DATETIME,
	USUARIO				VARCHAR(25)
);

delimiter |
create trigger AUDITAR_TABLA_HISTORIALENVIO_INSERT after insert on historial_envio
for each row
	begin
		insert into auditar_historial (IDHISTORIAL, IDENVIO, FECHAHORA, ESTADO, CODIGOSEGUIMIENTO, fecha, usuario)
        values (
        new.idHistorial, 
        concat(new.idEnvio), 
        concat(new.fechaHora),  
        concat(new.estado),  
        concat(new.codigoSeguimiento), 
        now(), 
        user());
	end;
|

delimiter |
create trigger AUDITAR_TABLA_HISTORIALENVIO_UPDATE before update on historial_envio
for each row
	begin
		insert into auditar_historial (IDHISTORIAL, IDENVIO, FECHAHORA, ESTADO, CODIGOSEGUIMIENTO, fecha, usuario)
        values (
        new.idHistorial, 
        concat(old.idEnvio, " / ", new.idEnvio), 
        concat(old.fechaHora, " / ", new.fechaHora),  
        concat(old.estado, " / ", new.estado),  
        concat(old.codigoSeguimiento, " / ", new.codigoSeguimiento), 
        now(), 
        user());
	end;
|

delimiter |
create trigger AUDITAR_TABLA_HISTORIALENVIO_DELETE before delete on historial_envio
for each row
	begin
		insert into auditar_historial (IDHISTORIAL, IDENVIO, FECHAHORA, ESTADO, CODIGOSEGUIMIENTO, fecha, usuario)
        values (
        old.idHistorial, 
        concat(old.idEnvio, " / Eliminado"), 
        concat(old.fechaHora, " / Eliminado"),  
        concat(old.estado, " / Eliminado"),  
        concat(old.codigoSeguimiento, " / Eliminado"), 
        now(), 
        user());
	end;
|

create table auditar_envio (
	ID					INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
	IDENVIO				INT UNSIGNED NOT NULL,
    IDPAQUETE			VARCHAR(100),
	IDREMITENTE			VARCHAR(100),
    IDDESTINATARIO		VARCHAR(100),
    IDREPARTIDOR		VARCHAR(100),
    FECHAENTREGA		VARCHAR(100),
    CODIGOSEGUIMIENTO	VARCHAR(100),
	FECHA				DATETIME,
	USUARIO				VARCHAR(25)
);

delimiter |
create trigger AUDITAR_TABLA_ENVIO_INSERT after insert on envio
for each row
	begin
		insert into auditar_envio (IDENVIO, IDPAQUETE, IDREMITENTE, IDDESTINATARIO, IDREPARTIDOR, FECHAENTREGA, CODIGOSEGUIMIENTO, fecha, usuario)
        values (
        new.IdEnvio, 
        concat(new.IdPaquete), 
        concat(new.IdRemitente),  
        concat(new.IdDestinatario),  
        concat(new.IdRepartidor), 
        concat(new.FechaEntrega), 
        concat(new.codigoSeguimiento), 
        now(), 
        user());
	end;
|

delimiter |
create trigger AUDITAR_TABLA_ENVIO_UPDATE before update on envio
for each row
	begin
		insert into auditar_envio (IDENVIO, IDPAQUETE, IDREMITENTE, IDDESTINATARIO, IDREPARTIDOR, FECHAENTREGA, CODIGOSEGUIMIENTO, fecha, usuario)
        values (
        new.IdEnvio, 
        concat(old.IdPaquete, " / ", new.IdPaquete), 
        concat(old.IdRemitente, " / ", new.IdRemitente),  
        concat(old.IdDestinatario, " / ", new.IdDestinatario),
        concat(old.IdRepartidor, " / ", new.IdRepartidor),
        concat(old.FechaEntrega, " / ", new.FechaEntrega),
        concat(old.codigoSeguimiento, " / ", new.codigoSeguimiento), 
        now(), 
        user());
	end;
|

delimiter |
create trigger AUDITAR_TABLA_ENVIO_DELETE before delete on envio
for each row
	begin
		IF EXISTS (SELECT 1 FROM historial_envio WHERE historial_envio.idEnvio = OLD.IdEnvio) THEN
			DELETE FROM historial_envio WHERE historial_envio.idEnvio = OLD.IdEnvio;
		END IF;
        
		insert into auditar_envio (IDENVIO, IDPAQUETE, IDREMITENTE, IDDESTINATARIO, IDREPARTIDOR, FECHAENTREGA, CODIGOSEGUIMIENTO, fecha, usuario)
        values (
        old.IdEnvio, 
        concat(old.IdPaquete, " / Eliminado"), 
        concat(old.IdRemitente, " / Eliminado"),  
        concat(old.IdDestinatario, " / Eliminado"),  
        concat(old.IdRepartidor, " / Eliminado"),
        concat(old.FechaEntrega, " / Eliminado"),
        concat(old.codigoSeguimiento, " / Eliminado"), 
        now(), 
        user());
	end;
|

#Inserciones A las nuevas tablas
DELIMITER //
CREATE PROCEDURE InsertarHistorialEnvio()
BEGIN
    DECLARE contador INT DEFAULT 0;
    
    WHILE contador < 10 DO
        INSERT INTO historial_envio (idEnvio, fechaHora, estado, codigoSeguimiento)
        VALUES (
            (1 + RAND() * (5 - 1)),
            curdate(),
            'Entrgado',
            concat('A8493NB', contador + 1)
        );
        
        SET contador = contador + 1;
    END WHILE;
END;
//
DELIMITER ;
CALL InsertarHistorialEnvio();

DELIMITER //
CREATE PROCEDURE InsertarRutaRepartidor()
BEGIN
    DECLARE contador INT DEFAULT 0;
    
    WHILE contador < 10 DO
        INSERT INTO ruta_repartidor (idRepartidor, descripcion, fechaAsignacion, idDestinatario)
        VALUES (
            (1 + RAND() * (10 - 1)),
            'Entrega con cuidado',
            curdate(),
            (1 + RAND() * (10 - 1))
        );
        
        SET contador = contador + 1;
    END WHILE;
END;
//
DELIMITER ;
CALL InsertarRutaRepartidor();

DELIMITER //
CREATE PROCEDURE InsertarVehiculo()
BEGIN
    DECLARE contador INT DEFAULT 0;
    
    WHILE contador < 10 DO
        INSERT INTO vehiculo (marca, modelo, matricula, capacidad_carga, estado)
        VALUES (
            'Chevrolet',
            concat('Chevy ', (2010 + contador)),
            concat('GO-142-B', contador + 1),
            '100kg',
            'Disponible'
        );
        
        SET contador = contador + 1;
    END WHILE;
END;
//
DELIMITER ;
CALL InsertarVehiculo();

#Actualizaciones en los registros a las tablas antiguas
DELIMITER //
CREATE PROCEDURE ActualizacionEnlasInsercionesDeEnvio()
BEGIN
    DECLARE contador INT DEFAULT 0;
    
    WHILE contador < 5 DO
        update envio set codigoSeguimiento = concat('A8493NB', contador + 1) WHERE IdEnvio = contador + 1;
        SET contador = contador + 1;
    END WHILE;
END;
//
DELIMITER ;
call ActualizacionEnlasInsercionesDeEnvio();

DELIMITER //
CREATE PROCEDURE ActualizacionEnlasInsercionesDePaquete()
BEGIN
    DECLARE contador INT DEFAULT 0;
    
    WHILE contador < 10 DO
        update paquete set Tipo = 'Electronico/Fragil' WHERE IdPaquete = contador + 1;
        SET contador = contador + 1;
    END WHILE;
END;
//
DELIMITER ;
call ActualizacionEnlasInsercionesDePaquete();

DELIMITER //
CREATE PROCEDURE ActualizacionEnlasInsercionesDeRepartidor()
BEGIN
    DECLARE contador INT DEFAULT 0;
    
    WHILE contador < 10 DO
        update repartidor set IdVehiculo = (1 + RAND() * (10 - 1)) WHERE IdRepartidor = contador + 1;
        SET contador = contador + 1;
    END WHILE;
END;
//
DELIMITER ;
call ActualizacionEnlasInsercionesDeRepartidor();

alter table repartidor add foreign key (IdVehiculo) references vehiculo(idVehiculo);

#Comprobar si sirven las auditorias
update historial_envio set estado = "Retrasado" where idHistorial = 10;
DELETE FROM historial_envio WHERE idHistorial = 10;
DELETE FROM envio WHERE IdEnvio = 1;

#Creacion de roles
create role 'ADMINDB';
create role 'RH';
create role 'GERENTETIENDA';
create role 'GERENTEREPARTIDORES';
create role 'ENCARGADOVEHICULOS';
create role 'ATENCIONCLIENTE';
create role 'MOSTRADOR';

GRANT ALL PRIVILEGES ON *.* TO 'ADMINDB' WITH GRANT OPTION;
GRANT CREATE USER, CREATE ROLE, SELECT ON *.* to 'RH' WITH GRANT OPTION;
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.repartidor TO 'RH';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.paquete TO 'GERENTETIENDA';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.envio TO 'GERENTETIENDA';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.historial_envio TO 'GERENTETIENDA';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.remitente TO 'GERENTETIENDA';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.destinatario TO 'GERENTETIENDA';
GRANT SELECT ON  servicio_de_paquetería.auditar_historial TO 'GERENTETIENDA';
GRANT SELECT ON  servicio_de_paquetería.auditar_envio TO 'GERENTETIENDA';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.repartidor TO 'GERENTEREPARTIDORES';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.ruta_repartidor TO 'GERENTEREPARTIDORES';
GRANT SELECT, UPDATE ON  servicio_de_paquetería.repartidor TO 'ENCARGADOVEHICULOS';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.vehiculo TO 'ENCARGADOVEHICULOS';
GRANT SELECT ON  servicio_de_paquetería.historial_envio TO 'ATENCIONCLIENTE';
GRANT SELECT, UPDATE, DELETE ON  servicio_de_paquetería.paquete TO 'ATENCIONCLIENTE';
GRANT INSERT, SELECT, UPDATE ON  servicio_de_paquetería.remitente TO 'ATENCIONCLIENTE';
GRANT INSERT, SELECT, UPDATE ON  servicio_de_paquetería.destinatario TO 'ATENCIONCLIENTE';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.paquete TO 'MOSTRADOR';
GRANT INSERT, SELECT, UPDATE, DELETE ON  servicio_de_paquetería.envio TO 'MOSTRADOR';
GRANT INSERT, SELECT ON  servicio_de_paquetería.remitente TO 'MOSTRADOR';
GRANT INSERT, SELECT ON  servicio_de_paquetería.destinatario TO 'MOSTRADOR';

#Creación de usuarios
create user 'adminDB'@'localhost' identified by "123456"; 
create user 'rh'@'localhost' identified by "123456"; 
create user 'gerentetienda'@'localhost' identified by "123456"; 
create user 'gerenterepartidores'@'localhost' identified by "123456"; 
create user 'encargadovehiculos'@'localhost' identified by "123456"; 
create user 'atencioncliente'@'localhost' identified by "123456"; 
create user 'mostradormatutino'@'localhost' identified by "123456"; 
create user 'mostradorvespertino'@'localhost' identified by "123456"; 
create user 'cliente'@'localhost' identified by "123456"; 

drop user 'repartidor'@'localhost';
create user 'repartidor'@'localhost' identified by "123456"; 

GRANT 'ADMINDB' TO 'adminDB'@'localhost';
GRANT 'RH' TO 'rh'@'localhost';
GRANT 'GERENTETIENDA' TO 'gerentetienda'@'localhost';
GRANT 'GERENTEREPARTIDORES' TO 'gerenterepartidores'@'localhost';
GRANT 'ENCARGADOVEHICULOS' TO 'encargadovehiculos'@'localhost';
GRANT 'ATENCIONCLIENTE' TO 'atencioncliente'@'localhost';
GRANT 'MOSTRADOR' TO 'mostradormatutino'@'localhost';
GRANT 'MOSTRADOR' TO 'mostradorvespertino'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.paquete TO 'cliente'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.historial_envio TO 'cliente'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.envio TO 'cliente'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.paquete TO 'repartidor'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.historial_envio TO 'repartidor'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.envio TO 'repartidor'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.ruta_repartidor TO 'repartidor'@'localhost';
GRANT SELECT ON  servicio_de_paquetería.vehiculo TO 'repartidor'@'localhost';

SET DEFAULT ROLE 'ADMINDB' TO 'adminDB'@'localhost';
SET DEFAULT ROLE 'RH' TO 'rh'@'localhost';
SET DEFAULT ROLE 'GERENTETIENDA' TO 'gerentetienda'@'localhost';
SET DEFAULT ROLE 'GERENTEREPARTIDORES' TO 'gerenterepartidores'@'localhost';
SET DEFAULT ROLE 'ENCARGADOVEHICULOS' TO 'encargadovehiculos'@'localhost';
SET DEFAULT ROLE 'ATENCIONCLIENTE' TO 'atencioncliente'@'localhost';
SET DEFAULT ROLE 'MOSTRADOR' TO 'mostradormatutino'@'localhost';
SET DEFAULT ROLE 'MOSTRADOR' TO 'mostradorvespertino'@'localhost';