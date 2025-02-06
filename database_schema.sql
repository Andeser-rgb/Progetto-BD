-- Tabella Utente
CREATE TABLE Utente (
    ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    passwordH VARCHAR(255) NOT NULL,
    via VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    citta VARCHAR(50) NOT NULL,
    paese VARCHAR(50) NOT NULL,
    codice_postale CHAR(5) NOT NULL,
    CHECK (email LIKE '%@%.%'),
	CHECK (codice_postale REGEXP '^[A-Za-z0-9 -]+$')
);

-- Tabella Alias
CREATE TABLE Alias (
    utente_ID INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    PRIMARY KEY (utente_ID, nome),
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID)
);

-- Tabella CartaPagamento
-- scadenza DATE o CHAR(5)?
CREATE TABLE CartaPagamento (
    numeroCarta CHAR(19) PRIMARY KEY,
    --scadenza DATE NOT NULL,
    scadenza CHAR(5) NOT NULL,
    proprietario VARCHAR(100) NOT NULL,
    utente_ID INT NOT NULL,
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    CHECK (numeroCarta REGEXP '^[0-9]{8, 19}$'),
    CHECK (proprietario REGEXP '^[A-Za-z ]+$')
);

-- Tabella Fattura
CREATE TABLE Fattura (
    numeroFattura INT AUTO_INCREMENT PRIMARY KEY,
    dataFattura DATE NOT NULL,
    -- Non sono sicuro che questo attributo vada lasciato (bonifico sicuramente richiederebbe modifiche, paypal non so)
    modalitaPagamento ENUM('carta', 'bonifico', 'paypal') NOT NULL,
    prezzo DECIMAL(10,2) NOT NULL,
    CHECK (prezzo > 0)
);

-- Tabella Lingua
-- TODO: La chiave ora è il codice della lingua, vanno cambiate le query
CREATE TABLE Lingua (
    codiceLingua CHAR(2) PRIMARY KEY,
    nomeLingua VARCHAR(30) NOT NULL
);

-- Tabella Lavoro
CREATE TABLE Lavoro (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    titolo VARCHAR(255) NOT NULL,
    rating DECIMAL(3,2) NOT NULL,
    dataPubblicazione DATE NOT NULL,
    numeroCapitoli INT NOT NULL,
    utente_ID INT NOT NULL,
    codiceLingua VARCHAR(50) NOT NULL,
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    FOREIGN KEY (codiceLingua) REFERENCES Lingua(codiceLingua),
    CHECK (rating BETWEEN 0 AND 5),
    CHECK (numeroCapitoli > 0)
);

-- Tabella InVendita
CREATE TABLE InVendita (
    lavoro_ID INT PRIMARY KEY,
    prezzoDiPartenza DECIMAL(10,2) NOT NULL,
    scadenza DATE NOT NULL,
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
    dataOfferta DATE NOT NULL,
    somma DECIMAL(10,2) NOT NULL,
    utente_ID INT NOT NULL,
    PRIMARY KEY (lavoro_ID, ID),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID),
    FOREIGN KEY (utente_ID) REFERENCES Utente(ID),
    CHECK (somma > 0)
) ;

-- Tabella MiPiace (ex Like, rinominata per evitare conflitti con parole riservate)
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
    dataCommento DATE NOT NULL,
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
    dataAggiornamento DATE NOT NULL,
    contenuto TEXT NOT NULL,
    PRIMARY KEY (lavoro_ID, numeroCapitolo),
    FOREIGN KEY (lavoro_ID) REFERENCES Lavoro(ID)
);

-- Tabella Tag
CREATE TABLE Tag (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
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
