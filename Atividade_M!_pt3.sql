CREATE DATABASE clinica_veterinaria_pt3;

USE clinica_veterinaria_pt3;

-- CRIAÇÂO DE TABElAS
CREATE TABLE paciente (
   id_paciente INT PRIMARY KEY AUTO_INCREMENT,
   nome VARCHAR (100),
   especie VARCHAR (50),
   idade INT
);



CREATE TABLE veterinario (
   id_veterinario INT PRIMARY KEY AUTO_INCREMENT,
   nome VARCHAR (100),
   idade INT,
   email VARCHAR (50),
   especialidade VARCHAR (50)
);


CREATE TABLE consulta (
   id_consulta INT PRIMARY KEY AUTO_INCREMENT,
   id_paciente INT,
   id_veterinario INT,
   data_consulta DATE,
   custo DECIMAL (10,2),
   FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
   FOREIGN KEY (id_veterinario) REFERENCES veterinario(id_veterinario)
);

-- Procedure de repetição 1

DELIMITER $$

CREATE PROCEDURE iserir_dados_veterinario()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE especialidade VARCHAR(50);
    DECLARE especialidades VARCHAR(255) DEFAULT 'Nutrição, Clínico, Neurologia, Cirurgião, Dermatologista,Oncologia, Odontólogo, Oftalmologista';
   
    WHILE i < 100 DO
        SET @nome := CONCAT('Veterinario', i);
        SET @idade := FLOOR(RAND() * 80) + 18;  
        SET @email := CONCAT('usuario', i, '@gamil.com');
        SET @especialidade := SUBSTRING_INDEX(SUBSTRING_INDEX(especialidades, ',', FLOOR(1 + RAND() * (LENGTH(especialidades) - LENGTH(REPLACE(especialidades, ',', '')) + 1))), ',', -1);
        
        INSERT INTO veterinario (nome, idade, email, especialidade) VALUES (@nome, @idade, @email, @especialidade);
        
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL iserir_dados_veterinario();

SELECT * FROM veterinario;

-- Procedure de repetição 2

DELIMITER $$

CREATE PROCEDURE iserir_dados_paciente()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE especie VARCHAR(50);
    DECLARE especies VARCHAR(255) DEFAULT 'Híbridos, Puro';
   
    WHILE i < 1000 DO
        SET @nome := CONCAT('Paciente', i);
        SET @especie := SUBSTRING_INDEX(SUBSTRING_INDEX(especies, ',', FLOOR(1 + RAND() * (LENGTH(especies) - LENGTH(REPLACE(especies, ',', '')) + 1))), ',', -1);
        SET @idade := FLOOR(RAND() * 20) + 1; 
        
        INSERT INTO paciente (nome, especie, idade) VALUES (@nome, @especie, @idade);
        
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL iserir_dados_paciente();

SELECT * FROM paciente;

-- Procedure de repetição 3

DELIMITER //

CREATE PROCEDURE iserir_dados_consulta()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE id_paciente INT;
    DECLARE id_veterinario INT;

    SELECT COUNT(*) INTO id_paciente FROM paciente;
    SELECT COUNT(*) INTO id_veterinario FROM veterinario;

    WHILE i < 10000 DO
        BEGIN
            DECLARE paciente INT;
            DECLARE veterinario INT;
            DECLARE consulta_data DATE;
            DECLARE custo DECIMAL(10,2);

            SET paciente = FLOOR(1 + RAND() * id_paciente);
            SET veterinario = FLOOR(1 + RAND() * id_veterinario);
            SET consulta_data = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 9000) DAY);
            SET custo = ROUND(50 + (RAND() * 450), 2);
            
            INSERT INTO consulta (id_paciente, id_veterinario, data_consulta, custo)
            VALUES (paciente, veterinario, consulta_data, custo);

            SET i = i + 1;
        END;
    END WHILE;
END //

DELIMITER ;

CALL gerar_consultas();

SELECT * FROM consulta;
