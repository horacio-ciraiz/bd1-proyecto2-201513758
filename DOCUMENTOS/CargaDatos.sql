--------- TABLA TEMPORAL

CREATE TEMPORARY TABLE IF NOT EXISTS Temporal (

NOMBRE_ELECCION VARCHAR(100),
ANIO_ELECCION VARCHAR(100),
PAIS VARCHAR(100),
REGION VARCHAR(100),
DEPTO VARCHAR(100),
MUNICIPIO VARCHAR(100),
PARTIDO VARCHAR(100),
NOMBRE_PARTIDO VARCHAR(100),
SEXO VARCHAR(100),
RAZA VARCHAR(100),
ANALFABETOS VARCHAR(100),
ALFABETOS VARCHAR(100),
SEXODOS VARCHAR(100),
RAZADOS VARCHAR(100),
PRIMARIA VARCHAR(100),
NIVEL_MEDIO VARCHAR(100),
UNIVERSITARIOS VARCHAR(100)

)

----------CARGA TEMPORAL
LOAD DATA 
INFILE '/var/lib/mysql/ICE-Fuente.csv' 
INTO TABLE Temporal 
COLUMNS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
NOMBRE_ELECCION,
ANIO_ELECCION,
PAIS,
REGION,
DEPTO,
MUNICIPIO,
PARTIDO,
NOMBRE_PARTIDO,
SEXO,
RAZA,
ANALFABETOS,
ALFABETOS,
SEXODOS,
RAZADOS,
PRIMARIA,
NIVEL_MEDIO,
UNIVERSITARIOS
);


DROP TEMPORARY TABLE IF EXISTS Temporal;

-- ----------------Carga a tablas

-- ---- Eleccion --------------------------------------

INSERT INTO Eleccion (Nombre,Anio)
SELECT DISTINCT NOMBRE_ELECCION,ANIO_ELECCION from Temporal t ;

Select * from Eleccion;


-- ---------Partido ------------------------------------
INSERT INTO Partido (Nombre,Iniciales)
SELECT DISTINCT  NOMBRE_PARTIDO,PARTIDO FROM Temporal t ;

Select * from Partido;

-- ----------Raza -------------------------------------
INSERT INTO Raza(Nombre)
SELECT DISTINCT RAZA from Temporal t ;

Select * from Raza;

-- ---------Sexo---------------------------------------
INSERT INTO Sexo(Nombre)
SELECT DISTINCT SEXO FROM Temporal t ;

Select * from Sexo;


-- --------Tipo --------------

Insert into Tipo (Nombre) values ('Pais') ;
Insert into Tipo (Nombre) values ('Region');
Insert into Tipo (Nombre) values ('Departamento');
Insert into Tipo (Nombre) values ('Municipio');

Select * from Tipo;

-- --------Tipo --------------

Insert into Tipo (Nombre) values ('Pais') ;
Insert into Tipo (Nombre) values ('Region');
Insert into Tipo (Nombre) values ('Departamento');
Insert into Tipo (Nombre) values ('Municipio');

Select * from Tipo;

-- -------Zona Pais 
Insert Into Zona(Nombre,ID_Tipo,ID_Superior)
SELECT DISTINCT upper(PAIS) as MPais,1,NULL FROM Temporal t;

Select * from Zona;

-- -------Zona Region
Insert Into Zona(Nombre,ID_Tipo,ID_Superior)
SELECT DISTINCT upper(Region),2,z.ID_Zona from Temporal t 
inner Join Zona z ON z.Nombre = t.PAIS 

Select * from Zona;

-- -------Zona Departamento
Insert Into Zona(Nombre,ID_Tipo,ID_Superior)
SELECT DISTINCT upper(DEPTO) as Departamento ,3,region.ID_Zona as Region from Temporal t 
inner Join Zona region ON region.Nombre = upper(t.REGION) -- valido que las regiones sean iguales
inner Join Zona pais on pais.Nombre = upper(t.PAIS)-- valido que los paises sean iguales
where region.ID_Superior = pais.ID_Zona; -- valido que el superior de region "pais" sea el mismo que el pais de la temporal


Select * from Zona;


-- -------Zona Municipio

Insert Into Zona(Nombre,ID_Tipo,ID_Superior)
SELECT DISTINCT upper(MUNICIPIO) as Municipio ,4,departamento.ID_Zona as Departamento from Temporal t 
inner join Zona departamento on departamento.Nombre = upper(DEPTO) -- valido que los departamentos sean iguales (Temporal=Departamento)
inner Join Zona region ON region.Nombre = upper(t.REGION) -- valido que las regiones sean iguales
inner Join Zona pais on pais.Nombre = upper(t.PAIS)-- valido que los paises sean iguales
where region.ID_Superior = pais.ID_Zona and departamento.ID_Superior = region.ID_Zona ;

Select * from Zona z  where z.ID_Tipo=4;

-- --------Estadistica ------------------------------
INSERT INTO Estadistica (ID_Eleccion,ID_Zona,ID_Partido,ID_Sexo,ID_Raza,Analfabeta,Alfabeta,Primaria,Medio,Universitario)
SELECT DISTINCT e.ID_Eleccion,municipio.ID_Zona as Municipio,p.ID_Partido,s.ID_Sexo,r.ID_Raza,t.ANALFABETOS ,t.ALFABETOS ,t.PRIMARIA ,t.NIVEL_MEDIO ,t.UNIVERSITARIOS FROM Temporal t
Inner Join Eleccion e on e.Nombre = t.NOMBRE_ELECCION 
Inner Join Partido p on p.Nombre = t.NOMBRE_PARTIDO 
Inner Join Sexo s on s.Nombre = t.SEXO 
Inner Join Raza r on r.Nombre = t.RAZA
Inner Join Zona municipio on municipio.Nombre = upper(t.MUNICIPIO)
Inner Join Zona departamento on departamento.Nombre = upper(DEPTO) 
Inner Join Zona region ON region.Nombre = upper(t.REGION) 
Inner Join Zona pais on pais.Nombre = upper(t.PAIS)
where e.Anio = t.ANIO_ELECCION and region.ID_Superior = pais.ID_Zona and departamento.ID_Superior = region.ID_Zona and municipio.ID_Superior = departamento.ID_Zona ;

Select * from Estadistica;