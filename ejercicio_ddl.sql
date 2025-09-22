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
WITH cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY movie_id, job_id, role, person_id
            ORDER BY position ASC
        ) AS rn
    FROM casts
)
DELETE FROM casts
WHERE id IN (
    SELECT id
    FROM cte
    WHERE rn > 1
);

-- 3.Movie Abstracts
-- Para las tablas movie_abstracts_XX realizar las siguientes acciones:

-- a. En la tabla movie_abstracts_es agregue la columna language
alter table movie_abstracts_es
add column language varchar(10)

-- b. Actualice la columna language con el valor 'es'
update movie_abstracts_es
set language = 'es'

-- c. Elimine la clave primaria de la tabla movie_abstracts_es
alter table movie_abstracts_es
drop constraint movie_abstracts_es_pkey

-- d. En una sola instrucción SQL Inserte los datos de las tablas
-- movie_abstracts_en, movie_abstracts_de, movie_abstracts_fr
create table movie_abstracts (
	movie_id int,
	abstract text,
	language varchar(10)
)

insert into movie_abstracts (movie_id, abstract, language)
select
	movie_id,
	abstract,
	'en' as language
from movie_abstracts_en
union all
select
	movie_id,
	abstract,
	'de' as language
from movie_abstracts_de
union all
select
	movie_id,
	abstract,
	'fr' as language
from movie_abstracts_fr

-- e. Defina la columna language obligatoria.
alter table movie_abstracts_es
alter column language set not null

-- f. Agregue la clave primaria para movie_abstracts_es con las columnas
-- (movie_id y language)
alter table movie_abstracts_es
add constraint movie_abstracts_es_pkey
primary key (movie_id, language)

-- g. Renombre la tabla movie_abstracts_es a movie_abstracts
alter table movie_abstracts_es
rename to movie_abstracts

-- h. Elimine las tablas movie_abstracts_en, movie_abstracts_de,
-- movie_abstracts_fr
drop table if exists movie_abstracts_en;
drop table if exists movie_abstracts_de;
drop table if exists movie_abstracts_fr;





