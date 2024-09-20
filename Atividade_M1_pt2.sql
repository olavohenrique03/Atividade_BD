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


-- Atividade Parte 2

-- Criação de 3 tabelas

CREATE TABLE medicamentos (
	id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nome_medicamento VARCHAR (100),
    descricao_medicamento VARCHAR (150),
    fabricante VARCHAR (100),
    dosagem VARCHAR (50)
);

CREATE TABLE materiais (
	 id_material INT PRIMARY KEY AUTO_INCREMENT,
     nome_material VARCHAR (150),
     tipo_material VARCHAR (50),
     quant_estoque INT, 
     data_validade DATE,
     preco DECIMAL (10,2)
);

CREATE TABLE prescricoes (
    id_prescricao INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    id_medicamento INT,
    dosagem_prescrita VARCHAR(50),
    frequencia_uso VARCHAR(50),
    duracao_tratamento VARCHAR(50),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);

DROP TABLE IF EXISTS prescricoes;

DESCRIBE prescricoes;

-- Criação Triggers 1

DELIMITER //

CREATE TRIGGER verifica_validade_material
BEFORE INSERT ON materiais
FOR EACH ROW
BEGIN
    IF NEW.data_validade < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Data de validade não pode ser anterior à data atual';
    END IF;
END;

DELIMITER ;

UPDATE materiais SET data_validade = '2024-10-21' WHERE id_material = 1;

SELECT * FROM materiais;

-- Criação Triggers 2

DELIMITER //

CREATE TRIGGER atualiza_estoque_medicamento
AFTER INSERT ON prescricoes
FOR EACH ROW
BEGIN
    UPDATE materiais
    SET quant_estoque = quant_estoque - 1
    WHERE id_material = NEW.id_medicamento;
END;


DELIMITER ;

-- Criação Triggers 3

DELIMITER //

CREATE TRIGGER atualiza_estoque_material
BEFORE INSERT ON materiais
FOR EACH ROW
BEGIN
    IF NEW.quant_estoque < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A quantidade de estoque não pode ser negativa';
    END IF;
END;

DELIMITER ;

-- Criação Triggers 4

DELIMITER //

CREATE TRIGGER verifica_validade_medicamento
BEFORE INSERT ON prescricoes
FOR EACH ROW
BEGIN
    DECLARE data_validade DATE;
    
    
    SELECT data_validade INTO data_validade
    FROM materiais
    WHERE id_material = NEW.id_medicamento;
    
    
    IF data_validade < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não é possível prescrever um medicamento vencido';
    END IF;
END;

DELIMITER ;

-- Criação Triggers 5

DELIMITER //

CREATE TRIGGER log_alteracao_estoque
AFTER UPDATE ON materiais
FOR EACH ROW
BEGIN
    INSERT INTO log_estoque (id_material, quantidade_anterior, quantidade_atual, data_alteracao)
    VALUES (NEW.id_material, OLD.quant_estoque, NEW.quant_estoque, NOW());
END;

DELIMITER ;

-- Criação de Procesure 1

DELIMITER $$

CREATE PROCEDURE inserir_medicamento (
    IN nome VARCHAR(100),
    IN descricao VARCHAR(150),
    IN fabricante VARCHAR(100),
    IN dosagem VARCHAR(50)
)
BEGIN
    INSERT INTO medicamentos (nome_medicamento, descricao_medicamento, fabricante, dosagem)
    VALUES (nome, descricao, fabricante, dosagem);
END $$

DELIMITER ;

CALL inserir_medicamento('Paracetamol', 'Analgésico e antitérmico', 'Fabricante A', '500mg');

-- Criação de Procesure 2

DELIMITER $$

CREATE PROCEDURE atualizar_dosagem (
    IN id INT,
    IN nova_dosagem VARCHAR(50)
)
BEGIN
    UPDATE medicamentos
    SET dosagem = nova_dosagem
    WHERE id_medicamento = id;
END $$

DELIMITER ;

CALL atualizar_dosagem(1, '1000mg');

-- Criação de Procesure 3

DELIMITER $$

CREATE PROCEDURE deletar_medicamento (
    IN id INT
)
BEGIN
    DELETE FROM medicamentos
    WHERE id_medicamento = id;
END $$

DELIMITER ;

CALL deletar_medicamento(1);

-- Criação de Procesure 4

DELIMITER $$

CREATE PROCEDURE buscar_material (
    IN nome VARCHAR(150)
)
BEGIN
    SELECT * FROM materiais
    WHERE nome_material = nome;
END $$

DELIMITER ;

CALL buscar_material('Seringa 5ml');

-- Criação de Procesure 5

DELIMITER $$

CREATE PROCEDURE inserir_prescricao (
    IN id_consulta INT,
    IN id_medicamento INT,
    IN dosagem_prescrita VARCHAR(50),
    IN frequencia_uso VARCHAR(50),
    IN duracao_tratamento VARCHAR(50)
)
BEGIN
    INSERT INTO prescricoes (id_consulta, id_medicamento, dosagem_prescrita, frequencia_uso, duracao_tratamento)
    VALUES (id_consulta, id_medicamento, dosagem_prescrita, frequencia_uso, duracao_tratamento);
END $$

DELIMITER ;

CALL inserir_prescricao(2, 3, '500mg', '2 vezes ao dia', '7 dias');
