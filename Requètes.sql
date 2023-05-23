SET search_path = BD_reservations, pg_catalog;

SELECT *
    FROM Local;

SELECT *
    FROM qté_caract;

SELECT *
    FROM réservation;

SELECT *
    FROM journalevenement;


select *
from réservation, local
where id_catégorie = 0110;

SELECT*
FROM réservation
RIGHT JOIN (
    SELECT generate_series(
                   '2023-05-22 08:30:00'::timestamp,
                   '2023-05-22 22:30:00'::timestamp,
                   '15 minutes'
               ) AS generated_time
) AS time_series ON date <= generated_time AND generated_time <= date + intervalle
ORDER BY generated_time;

CREATE OR REPLACE PROCEDURE Tableau(
    debut timestamp,
    fin timestamp,
    Categorie Int
)
As $$BEGIN
    select*
    from réservation, local
    where date <= debut
      and date + intervalle = fin
      and Categorie = id_catégorie;
END;
$$ language plpgsql;

select* from Tableau('2023-05-22 08:30:00', '2023-05-22 22:30:00', 0110);