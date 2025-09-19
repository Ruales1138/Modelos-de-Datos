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