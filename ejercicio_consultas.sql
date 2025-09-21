-- 1. Listar el nombre y el tipo de todos los registros en la tabla movies.
select name, kind from movies

-- 2. Listar el nombre y fecha de nacimiento de las personas que ya hayan fallecido, 
-- ordenadas por fecha de nacimiento descendentemente.
select name, birthday
from people
where deathday is not null
order by birthday desc

-- 3. Listar el nombre, fecha de nacimiento, fecha de fallecimiento y la edad de las personas.
select name, birthday, deathday, (date_part('year', deathday) - date_part('year', birthday)) as edad
from people

-- 4. Listar el id y nombre de la película, y la url del trailer de youtube ordenado por el
-- nombre de la película descendentemente
select 
	id, 
	name, 
	concat('https://www.youtube.com/watch?v=', t.key) as url_trailer
from movies m
join trailers t
	on m.id = t.movie_id
order by name desc

-- 5. Para las series, "Game Of Thrones", "The Sopranos" y "Breaking Bad"; listar el nombre
-- de la serie y cuántos capítulos tiene cada una, ordenado por la cantidad de capítulos
-- ascendentemente.
select 
	name,
	count(*) as capitulos
from movies m
where name in ('Game Of Thrones', 'The Sopranos', 'Breaking Bad')
	and kind = 'episode'
group by m.name
order by capitulos desc

-- 6. Listar el nombre, el id y la ganancia (diferencia entre el presupuesto/budget y la
-- recaudación/revenue) de las películas del 2017.
select
	m.name,
	m.id,
	(revenue - budget) as ganancia,
	m.date
from movies m
where m.date between
	TO_DATE('2017/01/01', 'YYYY/MM/DD') and
	TO_DATE('2017/12/31', 'YYYY/MM/DD')

-- 7. Para cada año listar el promedio del presupuesto y recaudación de las películas.
-- Ordenadas por año descendentemente.
select 
	date_part('year', m.date) as anio,
	avg(m.budget) as promedio_presupuesto,
	avg(m.revenue) as promedio_recaudacion
from movies m
group by date_part('year', m.date)
order by anio desc

-- 8. Listar el nombre de la película, el nombre de la persona, el nombre del trabajo, el rol,
-- donde el nombre de la persona inicie con G (indiferente de mayúsculas o minúsculas)
select
	m.name as pelicula,
	p.name as persona,
	j.name as trabajo,
	c.role as rol
from movies m
join casts c
	on m.id = c.movie_id
join people p
	on c.person_id = p.id
join jobs j
	on c.job_id = j.id
where p.name ilike 'G%'

-- 9. Listar el id, nombre y año de las películas donde todos sus actores (job_id = 15) ya
-- hayan fallecido, ordenados por el año descendentemente.
select
	m.id,
	m.name,
	date_part('year', m.date) as anio
from movies m
join casts c
	on m.id = c.movie_id
join people p
	on p.id = c.person_id
where job_id = 15
group by m.id, m.name, anio
having count(*) = count(p.deathday)
order by anio desc

-- 10. Listar el nombre, id, tipo de referencia y cantidad de referencias que tienen las
-- películas, ordenadas por cantidad de referencias descendentemente.
select
	m.name,
	m.id,
	mr.type,
	count(*) as cantidad_referencias
from movies m
join movie_references mr
	on m.id = mr.movie_id
group by m.id, m.name, mr.type
order by cantidad_referencias desc

-- 11. Listar el nombre, id, cantidad de idiomas que tienen las películas, ordenadas por
-- cantidad de idiomas descendentemente.
select
	m.name,
	m.id,
	count(*) as cantidad_lenguajes
from movies m
join movie_languages ml
	on m.id = ml.movie_id
group by m.name, m.id
order by cantidad_lenguajes desc

-- 12. Listar TOP 10 de lenguajes más utilizados en películas.
select
	ml.language,
	count(*) as cantidad_peliculas
from movie_languages ml
group by ml.language
order by cantidad_peliculas desc
limit 10

-- 13. Comparar la suma total de recaudo de las películas de las décadas 1990-2000, 2000-
-- 2010 y la 2010-2020, mostrando el total recaudado por año y el porcentaje entre cada
-- uno de los años. Ordenadas por año descendentemente.
SELECT 
    (date_part('year', m.date)::int % 10) AS anio,
    
    SUM(CASE WHEN date_part('year', m.date) BETWEEN 1990 AND 1999 THEN m.revenue ELSE 0 END) AS recaudo_1990_2000,
    SUM(CASE WHEN date_part('year', m.date) BETWEEN 2000 AND 2009 THEN m.revenue ELSE 0 END) AS recaudo_2000_2010,
    SUM(CASE WHEN date_part('year', m.date) BETWEEN 2010 AND 2019 THEN m.revenue ELSE 0 END) AS recaudo_2010_2020,
    
    ROUND(
        (SUM(CASE WHEN date_part('year', m.date) BETWEEN 2000 AND 2009 THEN m.revenue ELSE 0 END) -
         SUM(CASE WHEN date_part('year', m.date) BETWEEN 1990 AND 1999 THEN m.revenue ELSE 0 END)
        ) * 100.0 / NULLIF(SUM(CASE WHEN date_part('year', m.date) BETWEEN 1990 AND 1999 THEN m.revenue ELSE 0 END),0), 2
    ) AS dif_2000_2010_vs_1990_2000,
    
    ROUND(
        (SUM(CASE WHEN date_part('year', m.date) BETWEEN 2010 AND 2019 THEN m.revenue ELSE 0 END) -
         SUM(CASE WHEN date_part('year', m.date) BETWEEN 2000 AND 2009 THEN m.revenue ELSE 0 END)
        ) * 100.0 / NULLIF(SUM(CASE WHEN date_part('year', m.date) BETWEEN 2000 AND 2009 THEN m.revenue ELSE 0 END),0), 2
    ) AS dif_2010_2020_vs_2000_2010,
    
    ROUND(
        (SUM(CASE WHEN date_part('year', m.date) BETWEEN 2010 AND 2019 THEN m.revenue ELSE 0 END) -
         SUM(CASE WHEN date_part('year', m.date) BETWEEN 1990 AND 1999 THEN m.revenue ELSE 0 END)
        ) * 100.0 / NULLIF(SUM(CASE WHEN date_part('year', m.date) BETWEEN 1990 AND 1999 THEN m.revenue ELSE 0 END),0), 2
    ) AS dif_2010_2020_vs_1990_2000

FROM movies m
WHERE date_part('year', m.date) BETWEEN 1990 AND 2019
GROUP BY anio
ORDER BY anio;
