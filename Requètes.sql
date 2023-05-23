SET search_path = bd_reservations, pg_catalog;

SELECT *
    FROM bd_reservations.Local;

SELECT *
    FROM bd_reservations.qté_caract;

SELECT *
    FROM bd_reservations.réservation;

SELECT *
    FROM bd_reservations.journalevenement;


select *
from bd_reservations.réservation, bd_reservations.local
where id_catégorie = 0110;

CREATE OR REPLACE FUNCTION Tableau6(debut timestamp, fin timestamp, Categorie Int)
    RETURNS TABLE(
    date TIMESTAMP,
    id_pavillon VARCHAR(2),
    id_local VARCHAR(16),
    CIP CHAR(8),
    intervalle INTERVAL
    )

As $$
    DECLARE Categorie2 INT;
BEGIN
        if(Categorie = 0121)
        Then
            Categorie2 = 0111;
        END IF ;



        if(Categorie = 0111 or Categorie = 0110 or Categorie = 012 or Categorie = 0210 or Categorie = 0211
            or Categorie = 0212 or Categorie = 0213 or Categorie = 0214 or Categorie = 0215 or Categorie = 0216
            or Categorie = 0217 or Categorie = 0372 or Categorie = 0373 or Categorie = 0510 or Categorie = 0620
            or Categorie = 0625 or Categorie = 0640 or Categorie = 0930 or Categorie = 1030 or Categorie = 1260)
        Then
            Categorie2 = 0121;
        END IF ;

    RETURN QUERY
        SELECT  generated_time, réservation.id_pavillon, réservation.id_local, réservation.cip, réservation.intervalle
        FROM bd_reservations.local, bd_reservations.réservation
                        Left JOIN (
            SELECT generate_series(
                           debut::timestamp,
                           fin::timestamp,
                           '15 minutes'
                       ) AS generated_time
        ) AS time_series ON réservation.date <= generated_time AND generated_time <= réservation.date + réservation.intervalle
        where réservation.id_local = local.id_local and local.id_catégorie = Categorie and réservation.date <= generated_time AND generated_time <= réservation.date + réservation.intervalle
        or réservation.id_local = local.id_local and local.id_catégorie = Categorie2 and réservation.date <= generated_time AND generated_time <= réservation.date + réservation.intervalle
        ORDER BY generated_time;
END
$$ language plpgsql;

select * from Tableau6('2023-12-12 08:30:00', '2023-12-12 22:30:00', 0110);

select * from Tableau6('2023-12-12 08:30:00', '2023-12-12 22:30:00', 0121);

select * from Tableau6('2023-12-13 08:30:00', '2023-12-13 22:30:00', 0110);

