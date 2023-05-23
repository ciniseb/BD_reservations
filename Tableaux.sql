DROP SCHEMA IF EXISTS bd_reservations cascade;
CREATE SCHEMA bd_reservations;
CREATE EXTENSION IF NOT EXISTS plpgsql;

SET search_path = bd_reservations, pg_catalog;

--CREATE LANGUAGE plpgsql;

--Céation des tableaux
CREATE TABLE Caractéristique
(
    description VARCHAR(64) NOT NULL,
    id_caract INT NOT NULL,
    PRIMARY KEY (id_caract)
);

CREATE TABLE Campus
(
    titre_campus VARCHAR(64) NOT NULL,
    PRIMARY KEY (titre_campus)
);

CREATE TABLE Faculté
(
    titre_fac VARCHAR(64) NOT NULL,
    PRIMARY KEY (titre_fac)
);

CREATE TABLE Catégorie
(
    titre VARCHAR(64) NOT NULL,
    id_catégorie INT NOT NULL,
    PRIMARY KEY (id_catégorie)
);

CREATE TABLE Statut
(
    titre_statut VARCHAR(32) NOT NULL,
    PRIMARY KEY (titre_statut)
);

CREATE TABLE Prévilège
(
    description VARCHAR(64) NOT NULL,
    PRIMARY KEY (description)
);

CREATE TABLE Catégories_prévilège
(
    id_catégorie INT NOT NULL,
    description VARCHAR(64) NOT NULL,
    PRIMARY KEY (id_catégorie, description),
    FOREIGN KEY (id_catégorie) REFERENCES Catégorie(id_catégorie),
    FOREIGN KEY (description) REFERENCES Prévilège(description)
);

CREATE TABLE Prévilèges_statut
(
    titre_statut VARCHAR(32) NOT NULL,
    description VARCHAR(64) NOT NULL,
    PRIMARY KEY (titre_statut, description),
    FOREIGN KEY (titre_statut) REFERENCES Statut(titre_statut),
    FOREIGN KEY (description) REFERENCES Prévilège(description)
);

CREATE TABLE Département
(
    titre_dep VARCHAR(64) NOT NULL,
    titre_fac VARCHAR(64) NOT NULL,
    PRIMARY KEY (titre_dep),
    FOREIGN KEY (titre_fac) REFERENCES Faculté(titre_fac)
);

CREATE TABLE Membre
(
    CIP CHAR(8) NOT NULL,
    nom VARCHAR(64) NOT NULL,
    titre_dep VARCHAR(64) NOT NULL,
    PRIMARY KEY (CIP),
    FOREIGN KEY (titre_dep) REFERENCES Département(titre_dep)
);

CREATE TABLE Pavillon
(
    id_pavillon VARCHAR(2) NOT NULL,
    titre_campus VARCHAR(64) NOT NULL,
    PRIMARY KEY (id_pavillon),
    FOREIGN KEY (titre_campus) REFERENCES Campus(titre_campus)
);

CREATE TABLE Statuts_membre
(
    titre_statut VARCHAR(32) NOT NULL,
    CIP CHAR(8) NOT NULL,
    PRIMARY KEY (titre_statut, CIP),
    FOREIGN KEY (titre_statut) REFERENCES Statut(titre_statut),
    FOREIGN KEY (CIP) REFERENCES Membre(CIP)
);

CREATE TABLE Local
(
    disponibilité BOOLEAN NOT NULL,
    id_pavillon VARCHAR(2) NOT NULL,
    id_local VARCHAR(16) NOT NULL,
    id_pavillon_parent VARCHAR(2) NULL,
    id_local_parent VARCHAR(16) NULL,
    capacité INT NOT NULL,
    id_catégorie INT NOT NULL,
    notes TEXT NULL,
    --sous_id_pavillon VARCHAR(2),
    PRIMARY KEY (id_pavillon, id_local),
    UNIQUE (id_pavillon, id_local, id_pavillon_parent, id_local_parent),
    FOREIGN KEY (id_pavillon) REFERENCES Pavillon(id_pavillon),
    FOREIGN KEY (id_catégorie) REFERENCES Catégorie(id_catégorie),
    FOREIGN KEY (id_pavillon_parent, id_local_parent) REFERENCES Local(id_pavillon, id_local)
);

CREATE TABLE Qté_caract
(
    quantité INT NOT NULL,
    id_local VARCHAR(16) NOT NULL,
    id_pavillon VARCHAR(2) NOT NULL,
    id_caract INT NOT NULL,
    PRIMARY KEY (id_local, id_pavillon, id_caract),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon),
    FOREIGN KEY (id_caract) REFERENCES Caractéristique(id_caract)
);

CREATE TABLE Réservation
(
    id_pavillon VARCHAR(2) NOT NULL,
    id_local VARCHAR(16) NOT NULL,
    id_pavillon_parent VARCHAR(2) NULL,
    id_local_parent VARCHAR(16) NULL,
    CIP CHAR(8) NOT NULL,
    date TIMESTAMP NOT NULL,
    intervalle INTERVAL NOT NULL,
    PRIMARY KEY (id_pavillon, id_local, CIP, date),
    FOREIGN KEY (CIP) REFERENCES Membre(CIP),
    FOREIGN KEY (id_pavillon, id_local, id_pavillon_parent, id_local_parent) REFERENCES Local(id_pavillon, id_local, id_pavillon_parent, id_local_parent)
);

CREATE TABLE JournalEvenement
(
    id_pavillon VARCHAR(2) NOT NULL,
    id_local VARCHAR(16) NOT NULL,
    CIP CHAR(8) NOT NULL,
    date TIMESTAMP NOT NULL,
    intervalle INTERVAL,
    action CHAR(8),
    id_evenement SERIAL PRIMARY KEY,
    date_evenement TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    --FOREIGN KEY (id_pavillon, id_local, CIP, date) REFERENCES Réservation(id_pavillon, id_local, CIP, date)
);


--Fonctions
CREATE OR REPLACE FUNCTION verifie_chevauchement()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS
        (
        SELECT 1
        FROM Réservation
        WHERE
            (
                (--Local déjà réservé
                NEW.id_pavillon = id_pavillon
                AND NEW.id_local = id_local
                )
            OR
                (--Cubicule déjà réservé = pas de réservation du Local
                NEW.id_pavillon = id_pavillon_parent
                AND NEW.id_local = id_local_parent
                )
            OR
                (--Local déjà réservé = pas de réservation du Cubicule
                NEW.id_pavillon_parent = id_pavillon
                AND NEW.id_local_parent = id_local
                )
            )
          --Chevauchement
          AND NEW.date < date + intervalle
          AND NEW.date + NEW.intervalle > date
    ) THEN
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*CREATE OR REPLACE FUNCTION verifie_hiérarchie_local()
    RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS --Cubicule déjà réservé = pas de réservation du Local
        (
        SELECT 1
        FROM Réservation
        WHERE id_pavillon_parent = NEW.id_pavillon
          AND id_local_parent = NEW.id_local
          AND NEW.date < date + intervalle
          AND NEW.date + NEW.intervalle > date
    ) THEN
        RETURN NULL;
    END IF;
    IF EXISTS --Local déjà réservé = pas de réservation du Cubicule
        (
            SELECT 1
            FROM Réservation
            WHERE id_pavillon = NEW.id_pavillon_parent
              AND id_local = NEW.id_local_parent
              AND NEW.date < date + intervalle
              AND NEW.date + NEW.intervalle > date
        ) THEN
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;*/

CREATE OR REPLACE FUNCTION reservation_insert_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO JournalEvenement(action, CIP, id_local, id_pavillon, date, intervalle, date_evenement)
    VALUES ('INSERT', NEW.CIP, NEW.id_local, NEW.id_pavillon, NEW.date, NEW.intervalle, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql ;

CREATE OR REPLACE FUNCTION reservation_delete_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO JournalEvenement(action, CIP, id_local, id_pavillon, date, intervalle, date_evenement)
    VALUES ('DELETE', OLD.CIP, OLD.id_local, OLD.id_pavillon, OLD.date, OLD.intervalle, CURRENT_TIMESTAMP);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql ;

CREATE OR REPLACE FUNCTION reservation_update_trigger()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO JournalEvenement(action, CIP, id_local, id_pavillon, date, intervalle, date_evenement)
    VALUES ('UPDATE', NEW.CIP, NEW.id_local, NEW.id_pavillon, NEW.date, NEW.intervalle, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql ;

--Triggers
CREATE TRIGGER trigger_verifie_chevauchement
    BEFORE INSERT ON Réservation
    FOR EACH ROW
EXECUTE FUNCTION verifie_chevauchement();

/*CREATE TRIGGER trigger_verifie_hiérarchie_local
    BEFORE INSERT ON Réservation
    FOR EACH ROW
EXECUTE FUNCTION verifie_hiérarchie_local();*/

CREATE TRIGGER Reservation_InsertTrigger
    AFTER INSERT ON Réservation
    FOR EACH ROW
EXECUTE FUNCTION reservation_insert_trigger();
END;

CREATE TRIGGER Reservation_DeleteTrigger
    AFTER DELETE ON Réservation
    FOR EACH ROW
EXECUTE FUNCTION reservation_delete_trigger();
END;

CREATE TRIGGER Reservation_UpdateTrigger
    AFTER UPDATE ON Réservation
    FOR EACH ROW
EXECUTE FUNCTION reservation_update_trigger();
END;

--Insertions
INSERT INTO Caractéristique(id_caract, description)
values (0, 'Connexion à Internet'),
       (1, 'Tables fixes en U et chaises mobiles'),
       (2, 'Monoplaces'),
       (3, 'Tables fixes et chaises fixes'),
       (6, 'Tables pour 2 ou + et chaises mobiles'),
       (7, 'Tables mobiles et chaises mobiles'),
       (8, 'Tables hautes et chaises hautes'),
       (9, 'Tables fixes et chaises mobiles'),
       (11, 'Écran'),
       (14, 'Rétroprojecteur'),
       (15, 'Gradins'),
       (16, 'Fenêtres'),
       (17, '1 piano'),
       (18, '2 pianos'),
       (19, 'Autres instruments'),
       (20, 'Système de son'),
       (21, 'Salle réservée (spéciale)'),
       (22, 'Ordinateurs PC'),
       (23, 'Ordinateurs SUN pour génie électrique'),
       (25, 'Ordinateurs (oscillomètre et multimètre)'),
       (26, 'Ordinateurs modélisation des structures'),
       (27, 'Ordinateurs PC'),
       (28, 'Équipement pour microélectronique'),
       (29, 'Équipement pour génie électrique'),
       (30, 'Ordinateurs et équipement pour mécatroni'),
       (31, 'Équipement métrologie'),
       (32, 'Équipement de machinerie'),
       (33, 'Équipement de géologie'),
       (34, 'Équipement pour la caractérisation'),
       (35, 'Équipement pour la thermodynamique'),
       (36, 'Équipement pour génie civil'),
       (37, 'Télévision'),
       (38, 'VHS'),
       (39, 'Hauts parleurs'),
       (40, 'Micro'),
       (41, 'Magnétophone à cassette'),
       (42, 'Amplificateur audio'),
       (43, 'Local barré'),
       (44, 'Prise réseau');

INSERT INTO Campus(titre_campus)
values ('Campus de Longueuil'),
       ('Campus de l’Ouest'),
       ('Campus de l’Est');

INSERT INTO Faculté(titre_fac)
values ('Génie'),
       ('Sciences');

INSERT INTO Catégorie(id_catégorie, titre)
values (0110, 'Salle de classe générale'),
       (0111, 'Salle de classe spécialisée'),
       (0120, 'Salle de séminaire'),
       (0121, 'Cubicules'),
       (0210, 'Laboratoire informatique'),
       (0211, 'Laboratoire d’enseignement spécialisé'),
       (0212, 'Atelier'),
       (0213, 'Salle à dessin'),
       (0214, 'Atelier (civil)'),
       (0215, 'Salle de musique'),
       (0216, 'Atelier sur 2 étages, conjoint avec autre local'),
       (0217, 'Salle de conférence'),
       (0372, 'Salle de réunion'),
       (0373, 'Salle d’entrevue et de tests'),
       (0510, 'Salle de lecture ou de consultation'),
       (0620, 'Auditorium'),
       (0625, 'Salle de concert'),
       (0640, 'Salle d’audience'),
       (0930, 'Salon du personnel'),
       (1030, 'Studio d’enregistrement'),
       (1260, 'Hall d’entrée');

INSERT INTO Statut(titre_statut)
values ('Étudiant'),
       ('Enseignant'),
       ('Personnel de soutien'),
       ('Administrateur');

INSERT INTO Prévilège(description)
values ('Peut réserver plus de 24 heures'),
       ('Peut seulement voir les réservations mais pas en créer'),
       ('Peut effacer les réservations d’un autre usager');

INSERT INTO Catégories_prévilège(id_catégorie, description)
values (0217, 'Peut réserver plus de 24 heures'),
       (0620, 'Peut réserver plus de 24 heures'),
       (0625, 'Peut réserver plus de 24 heures'),
       (0211, 'Peut seulement voir les réservations mais pas en créer'),
       (0216, 'Peut seulement voir les réservations mais pas en créer'),
       (0625, 'Peut seulement voir les réservations mais pas en créer'),
       (1260, 'Peut seulement voir les réservations mais pas en créer'),
       (0930, 'Peut seulement voir les réservations mais pas en créer'),
       (0372, 'Peut effacer les réservations d’un autre usager'),
       (0620, 'Peut effacer les réservations d’un autre usager'),
       (0212, 'Peut effacer les réservations d’un autre usager');

INSERT INTO Prévilèges_statut(titre_statut, description)
values ('Étudiant', 'Peut seulement voir les réservations mais pas en créer'),
       ('Enseignant', 'Peut réserver plus de 24 heures'),
       ('Personnel de soutien', 'Peut seulement voir les réservations mais pas en créer'),
       ('Personnel de soutien', 'Peut effacer les réservations d’un autre usager'),
       ('Administrateur', 'Peut réserver plus de 24 heures'),
       ('Administrateur', 'Peut effacer les réservations d’un autre usager');

INSERT INTO Département(titre_dep, titre_fac)
values ('Génie électrique et Génie informatique', 'Génie'),
       ('Génie mécanique', 'Génie'),
       ('Génie chimique et biotechnologie', 'Génie'),
       ('Génie civil et du bâtiment', 'Génie');

INSERT INTO Membre(cip, nom, titre_dep)
values ('stds2101', 'Sébastien St-Denis', 'Génie électrique et Génie informatique'),
       ('boie0601', 'Émile Bois', 'Génie électrique et Génie informatique');

INSERT INTO Pavillon(id_pavillon, titre_campus)
values ('C1', 'Campus de l’Ouest'),
       ('C2', 'Campus de l’Ouest');

INSERT INTO Statuts_membre(titre_statut, CIP)
values ('Étudiant', 'stds2101'),
       ('Administrateur', 'stds2101'),
       ('Étudiant', 'boie0601'),
       ('Enseignant', 'boie0601');

INSERT INTO Local(disponibilité, id_pavillon, id_local, id_pavillon_parent, id_local_parent, capacité, id_catégorie, notes)
values (true, 'C1', 3035, null, null, 60, 0110, null),
       (true, 'C1', 3040, null, null, 60, 0110, null),
       (true, 'C1', 3027, null, null, 40, 0111, '4 cubicules'),
       (true, 'C1', '3027-A', 'C1', 3027, 10, 0121, null),
       (true, 'C1', '3027-B', 'C1', 3027, 10, 0121, null),
       (true, 'C1', '3027-C', 'C1', 3027, 10, 0121, null),
       (true, 'C1', '3027-D', 'C1', 3027, 10, 0121, null),
       (true, 'C1', 3032, null, null, 20, 0111, '2 cubicules'),
       (true, 'C1', '3032-A', 'C1', 3032, 10, 0121, null),
       (true, 'C1', '3032-B', 'C1', 3032, 10, 0121, null);

INSERT INTO Qté_caract(quantité, id_local, id_pavillon, id_caract)
values (6, 3035, 'C1', 22),
       (6, 3035, 'C1', 9);

--Demandes de réservations

INSERT INTO Réservation(id_pavillon, id_local, CIP, date, intervalle)
values ('C1', 3035, 'stds2101',  '2023-12-12 13:00:00', '1 hour'), --Passe
       ('C1', 3035, 'boie0601',  '2023-12-12 13:00:00', '1 hour'),
       ('C1', 3040, 'stds2101',  '2023-12-12 13:00:00', '1 hour'), --Passe
       ('C1', 3040, 'boie0601',  '2023-12-12 13:30:00', '1 hour'),
       ('C1', 3040, 'boie0601',  '2023-12-12 12:30:00', '1 hour'),
       ('C1', 3040, 'stds2101',  '2023-12-12 13:30:00', '30 minutes'),
       ('C1', 3040, 'stds2101',  '2023-12-12 14:00:00', '30 minutes'), --Passe
       ('C1', 3040, 'stds2101',  '2023-12-12 12:30:00', '30 minutes'), --Passe
       ('C1', 3040, 'stds2101',  '2023-12-13 12:30:00', '45 minutes'); --Passe


INSERT INTO Réservation(id_pavillon, id_local, id_pavillon_parent, id_local_parent, CIP, date, intervalle)
values ('C1', 3027, null, null, 'stds2101',  '2023-12-12 13:00:00', '1 hour'), --Passe
       ('C1', 3027, null, null, 'boie0601',  '2023-12-12 13:00:00', '1 hour'),
       ('C1', '3027-C', 'C1', 3027, 'boie0601',  '2023-12-12 12:30:00', '1 hour'),
       ('C1', '3027-C', 'C1', 3027, 'boie0601',  '2023-12-12 14:00:00', '1 hour'), --Passe
       ('C1', '3027-A', 'C1', 3027, 'stds2101',  '2023-12-12 14:30:00', '1 hour'), --Passe
       ('C1', '3032-A', 'C1', 3032, 'boie0601',  '2023-12-12 13:00:00', '1 hour'), --Passe
       ('C1', 3027, null, null, 'boie0601',  '2023-12-12 14:30:00', '1 hour'),
       ('C1', 3027, null, null, 'boie0601',  '2023-12-12 16:30:00', '1 hour'); --Passe

/*UPDATE  Réservation
set id_local = '3027'
    WHERE id_local = '3035';

DELETE FROM Réservation
    WHERE id_local = '3027';

INSERT INTO Réservation(id_pavillon, id_local, CIP, date, intervalle)
values ('C1', 3027, 'stds2101',  '2023-05-22 09:00:00', '1 hour'),
       ('C1', 3035, 'boie0601', '2023-05-22 15:00:00', '3 hour');*/
