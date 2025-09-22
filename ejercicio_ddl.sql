-- 1.Movie Aliases
-- Para la tabla movie_aliases_iso realizar las siguientes acciones:

-- a. Crear la vista vi_movie_aliases_iso donde se liste:
-- • movie_id
-- • movie_name,
-- • language,
-- • name,
-- • oficial (tipo boolean)
create view vi_movie_aliases_iso as
select
	ma.movie_id,
	m.name as movie_name,
	ma.language,
	ma.name,
	ma.official_translation::boolean as oficial
from movie_aliases_iso ma
join movies m
	on m.id = ma.movie_id

-- b. Eliminar la vista vi_movie_aliases_iso
DROP VIEW vi_movie_aliases_iso;

-- b. Agregar una columna oficial a la tabla movie_aliases_iso
alter table movie_aliases_iso
add column oficial boolean

-- c. Poblar la columna oficial con los datos de official_translation
update movie_aliases_iso
set oficial = official_translation::boolean

-- d. Eliminar la clave primaria de movie_aliases_iso
alter table movie_aliases_iso
drop constraint movie_aliases_iso_pkey

-- e. Eliminar la columna official_translation
alter table movie_aliases_iso
drop column official_translation

-- f. Renombrar la columna oficial a official_translation
alter table movie_aliases_iso
rename column oficial to official_translation

-- g. Agregar la clave primaria movie_aliases_iso con las columnas (movie_id,
-- language, name, official_translation)
alter table movie_aliases_iso
add constraint movie_aliases_iso_pkey
primary key (movie_id, language, name, official_translation)

-- 2.Casts
-- Para la tabla casts realizar las siguientes acciones:

-- a. Crear la vista vi_casts donde se liste:
-- • job_id
-- • job_name
-- • movie_id
-- • movie_name
-- • person_id
-- • person_name
-- • role
-- • position
create view vi_casts as
select
	c.job_id,
	j.name as job_name,
	c.movie_id,
	m.name as movie_name,
	c.person_id,
	p.name as person_name,
	c.role,
	c.position
from casts c
join jobs j
	on j.id = c.job_id
join movies m
	on m.id = c.movie_id
join people p
	on p.id = c.person_id

-- b. Eliminar la vista vi_casts
drop view vi_casts

-- b. Revise la PK de la tabla casts, ¿Realmente es necesario que la columna position
-- haga parte de la clave primaria? Defina una consulta SQL que nos muestre si
-- existen varias posiciones para el mismo rol_id, película y role.
select
	c.movie_id,
	c.person_id,
	c.role,
	count(distinct c.position) as posiciones_distintas,
	count(*) as total_filas
from casts c
group by c.movie_id, c.person_id, c.role
having count(distinct c.position) > 1

-- c. Elimine la clave primaria de casts.
alter table casts
drop constraint casts_pkey

-- d. Intente crearla clave primaria de casts sin la columna position. ¿Qué error
-- genera?
alter table casts
add constraint casts_pkey
primary key (movie_id, person_id, job_id, role)

-- e. Elimine los registros duplicados, dejando sólo la posición menor para cada
-- registro repetido.


