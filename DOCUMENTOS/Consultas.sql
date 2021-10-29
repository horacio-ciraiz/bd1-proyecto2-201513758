
-- -----------Consultas

-- ----------Consulta 1 ----------Completa 

Select conAlcaldia.Nombre_Eleccion,conAlcaldia.Anio_Eleccion,conAlcaldia.Pais_Eleccion , conAlcaldia.Alcaldia_Eleccion, conAlcaldia.Porcentaje from (
	Select VotosParciales.Nombre as Nombre_Eleccion,VotosParciales.Anio as Anio_Eleccion,VotosParciales.Pais as Pais_Eleccion,(TotalSumados/TotalSuma)*100 as Porcentaje from (
		Select Pais_Eleccion,Max(Total) as TotalSumados from (
			Select e2.Nombre as Nombre_Eleccion,e2.Anio as Anio,Pais.Nombre as Pais_Eleccion,p.Nombre as Part ,sum(e.Analfabeta+e.Alfabeta) as Total from Estadistica e
			inner join Eleccion e2 on e2.ID_Eleccion =e.ID_Eleccion 
			inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
			inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
			inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
			inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
			inner join Partido p ON p.ID_Partido = e.ID_Partido 
			Group by Pais.Nombre,p.Nombre ,e2.Nombre,e2.Anio
		) as VotosTotales
	Group by Pais_Eleccion
)as Votos
inner join (
		Select e2.Nombre as Nombre,e2.Anio as Anio,Pais.Nombre as Pais,sum(e.Analfabeta + e.Alfabeta ) as TotalSuma from Estadistica e 
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Eleccion e2 ON e2.ID_Eleccion = e.ID_Eleccion 
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		inner join Partido p2 on p2.ID_Partido = e.ID_Partido 
		group by Pais.Nombre,e2.Nombre,e2.Anio
	) VotosParciales
ON VotosParciales.Pais = Votos.Pais_Eleccion
) as sinAlcaldia
Inner Join ( 
Select Parcial.Nombre_Eleccion,Parcial.Anio_Eleccion,Parcial.Pais_Eleccion,Parcial.Alcaldia_Eleccion, (Parcial.Total/Total.TotalSuma) * 100 as Porcentaje from ( 
    Select e2.Nombre as Nombre_Eleccion ,e2.Anio as Anio_Eleccion, Pais.Nombre as Pais_Eleccion,p.Nombre as Alcaldia_Eleccion ,sum(e.Analfabeta+e.Alfabeta) as Total from Estadistica e 
    inner join Eleccion e2 on e2.ID_Eleccion =e.ID_Eleccion 
    inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
    inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
    inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
    inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
    inner join Partido p ON p.ID_Partido = e.ID_Partido 
    group by e2.Nombre,e2.Anio ,Pais.Nombre,p.Nombre 
) as Parcial
inner join (
        Select e2.Nombre as Nombre_Eleccion ,e2.Anio as Anio_Eleccion ,Pais.Nombre as Pais_Eleccion,sum(e.Analfabeta + e.Alfabeta ) as TotalSuma from Estadistica e 
        inner join Eleccion e2 ON e2.ID_Eleccion = e.ID_Eleccion 
        inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
        inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
        inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
        inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
        group by e2.Nombre,e2.Anio,Pais.Nombre 
)as Total
ON  Total.Pais_Eleccion=Parcial.Pais_Eleccion
) conAlcaldia
ON sinAlcaldia.Pais_Eleccion = conAlcaldia.Pais_Eleccion and sinAlcaldia.Porcentaje = conAlcaldia.Porcentaje


-- -------------- Consulta 2 -----Completa


Select Paises,Departamentos,TotalVotos, 
(TotalVotos/(
	Select TotalPaises from(
		Select Pais.Nombre as Paises1,sum(e.Analfabeta + e.Alfabeta) as TotalPaises from Estadistica e 
		inner join Sexo s on s.ID_Sexo = e.ID_Sexo 
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		where s.Nombre like '%mujeres%' and Pais.Nombre=tk.Paises
		group by  Pais.Nombre 
		) as Medio
	)* 100
) as Promedio from (
	Select Pais.Nombre as Paises ,Dep.Nombre Departamentos,sum(e.Analfabeta + e.Alfabeta) as TotalVotos from Estadistica e 
	inner join Sexo s on s.ID_Sexo = e.ID_Sexo 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
	where s.Nombre like '%mujeres%'
	group by  Pais.Nombre ,Dep.Nombre
	) tk
	

-- --------------Consulta 3 -------


-- -------Consulta 4-----------------COMPLETA-----
Select Maximos.ERegion,Maximos.EPais,Maximos.Mayor from (  
	Select ERegion,EPais,ERaza,Max(Votos) Mayor from ( 
		Select Reg.Nombre as ERegion,Pais.Nombre as EPais,r.Nombre ERaza ,Sum(e.Analfabeta + e.Alfabeta ) Votos from Estadistica e 	
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		inner join Raza r on r.ID_Raza = e.ID_Raza 
		group by Reg.Nombre ,Pais.Nombre ,r.Nombre 
		) cati
		where ERaza = "INDIGENAS"
		group by ERegion,EPais,ERaza
) Todos
Inner JOIN ( 
		Select ERegion,EPais,ERaza,Max(Votos) Mayor from ( 
		Select Reg.Nombre as ERegion,Pais.Nombre as EPais,r.Nombre ERaza ,Sum(e.Analfabeta + e.Alfabeta ) Votos from Estadistica e 	
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		inner join Raza r on r.ID_Raza = e.ID_Raza 
		group by Reg.Nombre ,Pais.Nombre ,r.Nombre 
		) cati
		group by ERegion,EPais,ERaza
)Maximos
ON Maximos.ERegion= Todos.ERegion AND Maximos.EPais=Todos.Epais AND Maximos.Mayor = Todos.Mayor;


-- -------Consulta 6 ----------COMPLETA------
Select Todos.Departamento,(Mujeres.Estudiantes/Todos.Estudiantes)* 100 as PorcentajeMujeres, (Todos.Estudiantes - Mujeres.Estudiantes)/Todos.Estudiantes * 100 as PorcentajeHombres from( 
	Select Dep.Nombre as Departamento, Sum(e.Universitario) as Estudiantes from Estadistica e 
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
	group by Dep.Nombre
	) as Todos
inner join (
Select Dep.Nombre as Departamento, Sum(e.Universitario) as Estudiantes from Estadistica e 
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		inner join Sexo s on s.ID_Sexo = e.ID_Sexo 
		where s.Nombre ="mujeres"
		group by Dep.Nombre
)Mujeres
ON Mujeres.Estudiantes > (Todos.Estudiantes - Mujeres.Estudiantes) and Mujeres.Departamento=Todos.Departamento


-- --------------Consulta 7 -----Completa 

Select Totales.Paises,Totales.Regiones, (Suma/Departamentos) as Promedio from ( 

	SELECT Pais.Nombre as Paises , Reg.Nombre as Regiones , Sum(e.Alfabeta + e.Analfabeta ) as Suma from Estadistica e 
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona 
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
	group by Pais.Nombre ,Reg.Nombre 
) Totales 

inner Join( 

	Select Pais.Nombre as Paises,Reg.Nombre as Regiones, COUNT(*) as Departamentos from Zona e 
		inner join Zona Dep ON Dep.ID_Zona = e.ID_Zona 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
	group by Pais.Nombre ,Reg.Nombre

)as Departa 
ON  Totales.Paises = Departa.Paises and Totales.Regiones=Departa.Regiones


-- -------------Consulta 8 ----COMPLETA

Select Pais.Nombre, sum(e.Primaria) as Primaria ,sum(e.Medio) as Medio,sum(e.Universitario) as Universitario  from Estadistica e 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
group by Pais.Nombre 



-- --------------Consulta 9 ------Completa

Select Etnias.Paises,Etnia,(Voto_Razas/Votos) * 100 as Porcentaje from ( 
Select Pais.Nombre as Paises,r.Nombre as Etnia ,sum(e.Alfabeta + e.Analfabeta) as Voto_Razas from Estadistica e 
	inner join Raza r ON r.ID_Raza = e.ID_Raza 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
group by Pais.Nombre,r.Nombre 
) as Etnias
inner JOIN 
( 
Select Pais.Nombre as Paises ,sum(e.Alfabeta + e.Analfabeta) as Votos from Estadistica e 
	inner join Raza r ON r.ID_Raza = e.ID_Raza 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
	group by Pais.Nombre
) Total
ON Total.Paises = Etnias.Paises

-- --------------Consulta 11 ----Completa

Select DISTINCT PaisesMU,Mujeres.Voto_Indigenas_Mujeres , ((Voto_Indigenas_Mujeres/TotalVotos)* 100) as Porcentaje from ( 	
Select Pais.Nombre as PaisesMu,s.Nombre  as Sexualidad,r.Nombre as Etnia ,sum(e.Alfabeta) as Voto_Indigenas_Mujeres from Estadistica e 
	inner join Sexo s ON s.ID_Sexo = e.ID_Sexo 
	inner join Raza r ON r.ID_Raza = e.ID_Raza 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
	where s.Nombre like '%mujeres%' and r.Nombre like '%Indigena%'
group by s.Nombre ,r.Nombre ,Pais.Nombre
) As Mujeres
inner JOIN 
(
Select Pais.Nombre as Paises,sum(e.Alfabeta + e.Analfabeta) as TotalVotos from Estadistica e 
	inner join Sexo s ON s.ID_Sexo = e.ID_Sexo 
	inner join Raza r ON r.ID_Raza = e.ID_Raza 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
group by Pais.Nombre 
) as Total
ON Total.Paises = Mujeres.PaisesMu

-- -------------Consulta 12 ---- Completa
Select Tenias.Paises as Paises,(Tenias.Analfabeta/Todo.Total)*100 as Porcentaje from ( 
	Select Pais.Nombre  as Paises,Sum(e.Analfabeta) as Analfabeta from Estadistica e 
		inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		group by Pais.Nombre
) as Tenias	
inner JOIN 
(
		Select Pais.Nombre as Paises,Sum(e2.Analfabeta+ e2.Alfabeta) as Total from Estadistica e2 
		inner join Zona Muni ON Muni.ID_Zona = e2.ID_Zona
		inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
		inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
		inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
		group by Pais.Nombre
) as Todo
ON Tenias.Paises = Todo.Paises
order by Porcentaje Desc
Limit 1;

-- -------------Consulta 13 ---Completo

Select Paises,Departamento,Todos.Votos from( 
Select DISTINCT Pais.Nombre as Paises ,Dep.Nombre as Departamento, Sum(e.Analfabeta+e.Alfabeta) as Votos from Estadistica e 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
where Pais.Nombre = "Guatemala"
group by Pais.Nombre , Dep.Nombre 
) Todos
inner JOIN 
(
Select DISTINCT Pais.Nombre as GuaPais,Dep.Nombre as GuaDep, Sum(e.Analfabeta+e.Alfabeta) as Votos from Estadistica e 
	inner join Zona Muni ON Muni.ID_Zona = e.ID_Zona
	inner join Zona Dep ON Dep.ID_Zona = Muni.ID_Superior 
	inner join Zona Reg ON Reg.ID_Zona = Dep.ID_Superior 
	inner join Zona Pais on Pais.ID_Zona = Reg.ID_Superior 
where Pais.Nombre = "Guatemala" and Dep.Nombre = "Guatemala"
group by Pais.Nombre , Dep.Nombre 
) as Guatemala 
on Todos.Votos > Guatemala.Votos





------------------
