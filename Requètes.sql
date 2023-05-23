SET search_path = bd_reservations, pg_catalog;

SELECT *
    FROM bd_reservations.Local;

SELECT *
    FROM bd_reservations.qté_caract;

SELECT *
    FROM bd_reservations.réservation;

SELECT *
    FROM journalevenement;


select *
from réservation, local
where id_catégorie = 0110;

SELECT  réservation.date, réservation.id_local, réservation.intervalle, réservation.cip, réservation.id_pavillon
FROM local, réservation
Full OUTER JOIN (
    SELECT generate_series(
                   '2023-05-22 08:30:00'::timestamp,
                   '2023-05-22 22:30:00'::timestamp,
                   '15 minutes'
               ) AS generated_time
) AS time_series ON date <= generated_time AND generated_time <= date + intervalle
where réservation.id_local = local.id_local and local.id_catégorie = 0110
ORDER BY generated_time;

CREATE OR REPLACE FUNCTION Tableau6(debut timestamp, fin timestamp, Categorie Int)
    RETURNS TABLE(
    date TIMESTAMP,
    id_pavillon VARCHAR(2),
    id_local VARCHAR(16),
    CIP CHAR(8),
    intervalle INTERVAL
    )

As $$
BEGIN
    RETURN QUERY
        SELECT  réservation.date, réservation.id_local, réservation.intervalle, réservation.cip, réservation.id_pavillon
        FROM local, réservation
                        Left JOIN (
            SELECT generate_series(
                           debut::timestamp,
                           fin::timestamp,
                           '15 minutes'
                       ) AS generated_time
        ) AS time_series ON date <= generated_time AND generated_time <= date + intervalle
        where réservation.id_local = local.id_local and local.id_catégorie = Categorie
        ORDER BY generated_time;
END
$$ language plpgsql;

select * from Tableau2('2023-05-22 08:30:00', '2023-05-22 22:30:00', 0110);

/*select réservation.id_pavillon, réservation.id_local, réservation.cip, réservation.date, réservation.intervalle
from réservation, local
where réservation.date <= debut
  and réservation.date + réservation.intervalle = fin
  and réservation.id_local = local.id_local
  and Categorie = id_catégorie;*/
