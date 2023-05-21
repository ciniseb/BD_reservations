CREATE TABLE Caractéristique
(
    description INT NOT NULL,
    id_caract INT NOT NULL,
    PRIMARY KEY (id_caract)
);

CREATE TABLE Campus
(
    titre_campus INT NOT NULL,
    PRIMARY KEY (titre_campus)
);

CREATE TABLE Faculté
(
    titre_fac INT NOT NULL,
    PRIMARY KEY (titre_fac)
);

CREATE TABLE Catégorie
(
    titre INT NOT NULL,
    id_catégorie INT NOT NULL,
    PRIMARY KEY (id_catégorie)
);

CREATE TABLE Statut
(
    titre_statut INT NOT NULL,
    PRIMARY KEY (titre_statut)
);

CREATE TABLE Prévilège
(
    description INT NOT NULL,
    PRIMARY KEY (description)
);

CREATE TABLE Catégories_prévilège
(
    id_catégorie INT NOT NULL,
    description INT NOT NULL,
    PRIMARY KEY (id_catégorie, description),
    FOREIGN KEY (id_catégorie) REFERENCES Catégorie(id_catégorie),
    FOREIGN KEY (description) REFERENCES Prévilège(description)
);

CREATE TABLE Prévilèges_statut
(
    titre_statut INT NOT NULL,
    description INT NOT NULL,
    PRIMARY KEY (titre_statut, description),
    FOREIGN KEY (titre_statut) REFERENCES Statut(titre_statut),
    FOREIGN KEY (description) REFERENCES Prévilège(description)
);

CREATE TABLE Département
(
    titre_dep INT NOT NULL,
    titre_fac INT NOT NULL,
    PRIMARY KEY (titre_dep),
    FOREIGN KEY (titre_fac) REFERENCES Faculté(titre_fac)
);

CREATE TABLE Membre
(
    CIP INT NOT NULL,
    nom INT NOT NULL,
    titre_dep INT NOT NULL,
    PRIMARY KEY (CIP),
    FOREIGN KEY (titre_dep) REFERENCES Département(titre_dep)
);

CREATE TABLE Pavillon
(
    id_pavillon INT NOT NULL,
    titre_campus INT NOT NULL,
    PRIMARY KEY (id_pavillon),
    FOREIGN KEY (titre_campus) REFERENCES Campus(titre_campus)
);

CREATE TABLE Statuts_membre
(
    titre_statut INT NOT NULL,
    CIP INT NOT NULL,
    PRIMARY KEY (titre_statut, CIP),
    FOREIGN KEY (titre_statut) REFERENCES Statut(titre_statut),
    FOREIGN KEY (CIP) REFERENCES Membre(CIP)
);

CREATE TABLE Local
(
    disponibilité INT NOT NULL,
    id_local INT NOT NULL,
    capacité INT NOT NULL,
    notes INT NOT NULL,
    id_pavillon INT NOT NULL,
    id_catégorie INT NOT NULL,
    sous_id_local INT,
    id_pavillon INT,
    PRIMARY KEY (id_local, id_pavillon),
    FOREIGN KEY (id_pavillon) REFERENCES Pavillon(id_pavillon),
    FOREIGN KEY (id_catégorie) REFERENCES Catégorie(id_catégorie),
    FOREIGN KEY (sous_id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon)
);

CREATE TABLE Qté_caract
(
    quantité INT NOT NULL,
    id_local INT NOT NULL,
    id_pavillon INT NOT NULL,
    id_caract INT NOT NULL,
    PRIMARY KEY (quantité),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon),
    FOREIGN KEY (id_caract) REFERENCES Caractéristique(id_caract),
    UNIQUE (id_local, id_pavillon, id_caract)
);

CREATE TABLE Réservation
(
    temps INT NOT NULL,
    date INT NOT NULL,
    CIP INT NOT NULL,
    id_local INT NOT NULL,
    id_pavillon INT NOT NULL,
    PRIMARY KEY (temps),
    FOREIGN KEY (CIP) REFERENCES Membre(CIP),
    FOREIGN KEY (id_local, id_pavillon) REFERENCES Local(id_local, id_pavillon),
    UNIQUE (CIP, id_local, id_pavillon)
);
