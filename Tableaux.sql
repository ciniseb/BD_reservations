DROP SCHEMA IF EXISTS BD_reservations cascade;
CREATE SCHEMA BD_reservations;
CREATE EXTENSION IF NOT EXISTS plpgsql;

SET search_path = BD_reservations, pg_catalog;

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
    id_local VARCHAR(16) NOT NULL,
    capacité INT NOT NULL,
    notes TEXT,
    id_pavillon VARCHAR(2) NOT NULL,
    id_catégorie INT NOT NULL,
    sous_id_local VARCHAR(16),
    PRIMARY KEY (id_local, id_pavillon),
    FOREIGN KEY (id_pavillon) REFERENCES Pavillon(id_pavillon),
    FOREIGN KEY (id_catégorie) REFERENCES Catégorie(id_catégorie),
    FOREIGN KEY (sous_id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon)
);

CREATE TABLE Qté_caract
(
    quantité INT NOT NULL,
    id_local VARCHAR(16) NOT NULL,
    id_pavillon INT NOT NULL,
    id_caract INT NOT NULL,
    PRIMARY KEY (id_local, id_pavillon, id_caract),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon),
    FOREIGN KEY (id_caract) REFERENCES Caractéristique(id_caract)
);

CREATE TABLE Réservation
(
    date TIMESTAMP NOT NULL,
    intervalle INTERVAL NOT NULL,
    CIP CHAR(8) NOT NULL,
    id_local VARCHAR(16) NOT NULL,
    id_pavillon VARCHAR(2) NOT NULL,
    PRIMARY KEY (CIP, id_local, id_pavillon),
    FOREIGN KEY (CIP) REFERENCES Membre(CIP),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon)
);

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

INSERT INTO Local(disponibilité, id_local, capacité, notes, id_pavillon, id_catégorie, sous_id_local)
values (true, 3035, 60, null, 'C1', 0110, null),
       (true, 3027, 40, '4 cubicules', 'C1', 0111, '3027-A'),
       (true, 3027, 40, '4 cubicules', 'C1', 0111, '3027-B'),
       (true, 3027, 40, '4 cubicules', 'C1', 0111, '3027-C'),
       (true, 3027, 40, '4 cubicules', 'C1', 0111, '3027-D'),
       (true, '3027-A', 10, null, 'C1', 0121, null),
       (true, '3027-B', 10, null, 'C1', 0121, null),
       (true, '3027-C', 10, null, 'C1', 0121, null),
       (true, '3027-D', 10, null, 'C1', 0121, null);

INSERT INTO Qté_caract(quantité, id_local, id_pavillon, id_caract)
values (6, 3035, 'C1', 22),
       (6, 3035, 'C1', 9);

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
    VALUES ('DELETE', NEW.CIP, NEW.id_local, NEW.id_pavillon, NEW.date, NEW.intervalle, CURRENT_TIMESTAMP);
    RETURN NEW;
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


CREATE TABLE JournalEvenement(
    CIP CHAR(8) NOT NULL ,
    id_local INT NOT NULL ,
    id_pavillon VARCHAR(2) NOT NULL ,
    action CHAR(8) NOT NULL ,
    date TIMESTAMP NOT NULL ,
    intervalle INTERVAL NOT NULL ,
    id_evenement INT PRIMARY KEY,
    date_evenement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CIP) REFERENCES Membre(CIP),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon)
);



CREATE TABLE Réservation
(
    date TIMESTAMP NOT NULL,
    intervalle INTERVAL NOT NULL,
    CIP CHAR(8) NOT NULL,
    id_local INT NOT NULL,
    id_pavillon VARCHAR(2) NOT NULL,
    PRIMARY KEY (CIP, id_local, id_pavillon),
    FOREIGN KEY (CIP) REFERENCES Membre(CIP),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon)
);