-- Tabella Utente
CREATE TABLE Utente (
    ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    passwordH VARCHAR(255) NOT NULL,
    via VARCHAR(100) NOT NULL,
    numero VARCHAR(32) NOT NULL,
    citta VARCHAR(255) NOT NULL,
    paese VARCHAR(255) NOT NULL,
    codice_postale CHAR(16) NOT NULL,
    CHECK (email LIKE '%@%.%'),
	CHECK (codice_postale REGEXP '^[A-Za-z0-9 -]+$')
);


-- Tabella CartaPagamento
CREATE TABLE CartaPagamento (
    numeroCarta CHAR(19) PRIMARY KEY,
    scadenza CHAR(5) NOT NULL,
    proprietario VARCHAR(100) NOT NULL,
    utente_ID INT NOT NULL,
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    CHECK (numeroCarta REGEXP '^[0-9]{8,19}$'),
    CHECK (proprietario REGEXP '^[A-Za-z. ]+$')

);

-- Tabella Fattura
CREATE TABLE Fattura (
    numeroFattura INT AUTO_INCREMENT PRIMARY KEY,
    dataFattura TIMESTAMP NOT NULL,
    prezzo DECIMAL(10,2) NOT NULL,
    utente_ID INT NOT NULL,
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    CHECK (prezzo > 0)
);

-- Tabella Lingua
CREATE TABLE Lingua (
    codiceLingua CHAR(2) PRIMARY KEY,
    nomeLingua VARCHAR(30) NOT NULL UNIQUE
);

-- Tabella Lavoro
CREATE TABLE Lavoro (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    titolo VARCHAR(255) NOT NULL,
    rating enum('G', 'T', 'M', 'E') NOT NULL,
    dataPubblicazione TIMESTAMP NOT NULL,
    numeroCapitoli INT NOT NULL DEFAULT 0,
    utente_ID INT NOT NULL,
    codiceLingua CHAR(2) NOT NULL,
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    FOREIGN KEY (codiceLingua) REFERENCES Lingua(codiceLingua),
    CHECK (numeroCapitoli > 0)
);

-- Tabella InVendita
CREATE TABLE InVendita (
    lavoro_ID INT PRIMARY KEY,
    prezzoDiPartenza DECIMAL(10,2) NOT NULL,
    scadenza TIMESTAMP NOT NULL,
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID),
    CHECK (prezzoDiPartenza > 0)
);

-- Tabella Privato
CREATE TABLE Privato (
    lavoro_ID INT PRIMARY KEY,
    numeroFattura INT NOT NULL,
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID),
    FOREIGN KEY (numeroFattura) REFERENCES Fattura(numeroFattura)
);

-- Tabella Pubblico
CREATE TABLE Pubblico (
    lavoro_ID INT PRIMARY KEY,
    visualizzazioni INT NOT NULL,
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID),
    CHECK (visualizzazioni >= 0)
);

-- Tabella Offerta
CREATE TABLE Offerta (
    lavoro_ID INT NOT NULL,
    ID INT NOT NULL,
    dataOfferta TIMESTAMP NOT NULL,
    somma DECIMAL(10,2) NOT NULL,
    utente_ID INT NOT NULL,
    PRIMARY KEY (lavoro_ID, ID),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID),
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    CHECK (somma > 0)
) ;

-- Tabella MiPiace
CREATE TABLE MiPiace (
    utente_ID INT NOT NULL,
    lavoro_ID INT NOT NULL,
    PRIMARY KEY (utente_ID, lavoro_ID),
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID)
);

-- Tabella Commento
CREATE TABLE Commento (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    contenuto TEXT NOT NULL,
    dataCommento TIMESTAMP NOT NULL,
    utente_ID INT NOT NULL,
    lavoro_ID INT NOT NULL,
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID)
);

-- Tabella Risponde
CREATE TABLE Risponde (
    commentatore_ID INT NOT NULL,
    commentato_ID INT NOT NULL,
    PRIMARY KEY (commentatore_ID, commentato_ID),
    FOREIGN KEY (commentatore_ID) REFERENCES Commento(ID),
    FOREIGN KEY (commentato_ID) REFERENCES Commento(ID)
);

-- Tabella Capitolo
CREATE TABLE Capitolo (
    lavoro_ID INT NOT NULL,
    numeroCapitolo INT NOT NULL,
    dataAggiornamento TIMESTAMP NOT NULL,
    contenuto TEXT NOT NULL,
    PRIMARY KEY (lavoro_ID, numeroCapitolo),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID)
);

-- Tabella Tag
CREATE TABLE Tag (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- Tabella ClassificatoDa
CREATE TABLE ClassificatoDa (
    lavoro_ID INT NOT NULL,
    tag_ID INT NOT NULL,
    PRIMARY KEY (lavoro_ID, tag_ID),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID),
    FOREIGN KEY (tag_ID) REFERENCES Tag(ID)
);

-- Trigger per controllare che un lavoro non sia in più tabelle di stato

DELIMITER //

-- Trigger per Pubblico
CREATE TRIGGER trg_pubblico_before_insert
BEFORE INSERT ON Pubblico
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Privato WHERE lavoro_ID = NEW.lavoro_ID)
       OR EXISTS (SELECT 1 FROM InVendita WHERE lavoro_ID = NEW.lavoro_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il lavoro è già registrato come Privato o in Vendita.';
    END IF;
END;
//

CREATE TRIGGER trg_pubblico_before_update
BEFORE UPDATE ON Pubblico
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Privato WHERE lavoro_ID = NEW.lavoro_ID)
       OR EXISTS (SELECT 1 FROM InVendita WHERE lavoro_ID = NEW.lavoro_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il lavoro è già registrato come Privato o in Vendita.';
    END IF;
END;
//

-- Trigger per Privato
CREATE TRIGGER trg_privato_before_insert
BEFORE INSERT ON Privato
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Pubblico WHERE lavoro_ID = NEW.lavoro_ID)
       OR EXISTS (SELECT 1 FROM InVendita WHERE lavoro_ID = NEW.lavoro_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il lavoro è già registrato come Pubblico o in Vendita.';
    END IF;
END;
//

CREATE TRIGGER trg_privato_before_update
BEFORE UPDATE ON Privato
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Pubblico WHERE lavoro_ID = NEW.lavoro_ID)
       OR EXISTS (SELECT 1 FROM InVendita WHERE lavoro_ID = NEW.lavoro_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il lavoro è già registrato come Pubblico o in Vendita.';
    END IF;
END;
//

-- Trigger per InVendita
CREATE TRIGGER trg_invendita_before_insert
BEFORE INSERT ON InVendita
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Pubblico WHERE lavoro_ID = NEW.lavoro_ID)
       OR EXISTS (SELECT 1 FROM Privato WHERE lavoro_ID = NEW.lavoro_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il lavoro è già registrato come Pubblico o Privato.';
    END IF;
END;
//

CREATE TRIGGER trg_invendita_before_update
BEFORE UPDATE ON InVendita
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Pubblico WHERE lavoro_ID = NEW.lavoro_ID)
       OR EXISTS (SELECT 1 FROM Privato WHERE lavoro_ID = NEW.lavoro_ID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il lavoro è già registrato come Pubblico o Privato.';
    END IF;
END;
//

-- Trigger dopo l'inserimento di un nuovo Capitolo: incrementa il conteggio in Lavoro
CREATE TRIGGER trg_capitolo_after_insert
AFTER INSERT ON Capitolo
FOR EACH ROW
BEGIN
    UPDATE Lavoro 
    SET numeroCapitoli = numeroCapitoli + 1 
    WHERE ID = NEW.lavoro_ID;
END;
//

-- Trigger dopo l'eliminazione di un Capitolo: decrementa il conteggio in Lavoro
CREATE TRIGGER trg_capitolo_after_delete
AFTER DELETE ON Capitolo
FOR EACH ROW
BEGIN
    UPDATE Lavoro 
    SET numeroCapitoli = numeroCapitoli - 1 
    WHERE ID = OLD.lavoro_ID;
END;
//

-- Trigger dopo l'aggiornamento di un Capitolo, se cambia il riferimento al Lavoro:
CREATE TRIGGER trg_capitolo_after_update
AFTER UPDATE ON Capitolo
FOR EACH ROW
BEGIN
    -- Se il capitolo viene spostato da un lavoro ad un altro
    IF NEW.lavoro_ID <> OLD.lavoro_ID THEN
        UPDATE Lavoro 
        SET numeroCapitoli = numeroCapitoli - 1 
        WHERE ID = OLD.lavoro_ID;
        UPDATE Lavoro 
        SET numeroCapitoli = numeroCapitoli + 1 
        WHERE ID = NEW.lavoro_ID;
    END IF;
END;
//
DELIMITER ;
