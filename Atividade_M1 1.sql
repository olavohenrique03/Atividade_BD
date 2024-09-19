CREATE DATABASE clinica_veterinaria;

USE clinica_veterinaria;


-- CRIAÇÂO DE TABElAS

CREATE TABLE paciente (
	id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR (100),
    especie VARCHAR (50),
    idade INT 
);

INSERT INTO paciente (nome, especie, idade) VALUES ('Pedro', 'Cachorro', 5);

CREATE TABLE veterinario (
	id_veterinario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR (100),
    especialidade VARCHAR (50)
);

INSERT INTO veterinario (nome, especialidade) VALUES ('João', 'Dermatologia');

CREATE TABLE consulta (
	id_consulta INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT, 
    id_veterinario INT, 
    data_consulta DATE, 
    custo DECIMAL (10,2),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_veterinario) REFERENCES veterinario(id_veterinario)
);

DROP PROCEDURE IF EXISTS agendar_consulta;

SHOW PROCEDURE STATUS WHERE Name = 'agendar_consulta';

-- CRIAÇÂO Stored Procedures 1 
DELIMITER //

CREATE PROCEDURE agendar_consulta (
    IN p_id_paciente INT,
    IN p_id_veterinario INT,
    IN p_data_consulta DATE,
    IN p_custo DECIMAL(10,2)
)
BEGIN
    INSERT INTO consulta (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (p_id_paciente, p_id_veterinario, p_data_consulta, p_custo);
END //

DELIMITER ;

CALL agendar_consulta (1, 1, '2024-09-17', 100.00);

SELECT * FROM consulta;

-- CRIAÇÂO Stored Procedures 2
DELIMITER //

CREATE PROCEDURE atualizar_paciente (
    IN p_id_paciente INT,
    IN p_novo_nome VARCHAR (100),
    IN p_nova_especie VARCHAR (50),
    IN p_nova_idade INT
)
BEGIN
    UPDATE paciente
    SET nome = p_novo_nome,
		especie = p_nova_especie,
        idade = p_nova_idade
	WHERE id_paciente = p_id_paciente;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS atualizar_paciente;

CALL atualizar_paciente (1, 'Pedro', 'Cachorro', 6);

SELECT * FROM paciente;

-- CRIAÇÂO Stored Procedures 3

DELIMITER //

CREATE PROCEDURE remover_consulta (
    IN p_id_consulta INT
)
BEGIN
    
    DELETE FROM consulta WHERE id_consulta = p_id_consulta;
END //

DELIMITER ;

CALL remover_consulta (1);


-- CRIAÇÂO Function 

DELIMITER //

CREATE FUNCTION total_gasto_paciente(
	p_id_paciente INT
)
RETURNS DECIMAL(10, 2)
BEGIN
    RETURN (
        SELECT SUM(custo)
        FROM consulta
        WHERE id_paciente = p_id_paciente
    );
END //

DELIMITER ;

SELECT total_gasto_paciente (1);

DROP FUNCTION IF EXISTS total_gasto_paciente;

-- Craição da Triggers 1

DELIMITER //

CREATE TRIGGER verificar_idade_paciente 
AFTER INSERT ON paciente
FOR EACH ROW
BEGIN
	IF NEW.idade < 0 THEN
        SET @msg = 'A idade do paciente deve ser um número positivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END IF;
END //

DELIMITER ;

INSERT INTO paciente (nome, especie, idade) VALUE ('Pedro', 'Cachorro', 3);

SELECT * FROM paciente;

-- Craição da Triggers 2

CREATE TABLE log_consultas(
	id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    custo_antigo DECIMAL (10,2),
    custo_novo DECIMAL (10,2),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta)
);

DELIMITER //

CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON consulta
FOR EACH ROW
BEGIN
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO log_consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (NEW.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //

DELIMITER ;

UPDATE consulta SET custo = 200.00 WHERE id_consulta = 4;

SELECT * FROM consulta;