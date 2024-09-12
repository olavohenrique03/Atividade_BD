CREATE DATABASE teatro;
USE teatro;

-- EX:1
CREATE TABLE pecas_teatro(
	id_peca INT  PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100),
    descricao VARCHAR(800),
    duracao INT,
    horario  TIME
);

DROP TABLE IF EXISTS pecas_teatro;

INSERT INTO pecas_teatro (nome_peca, descricao, duracao, horario)
VALUES ('Quatro amigos', 'Uma comédia entre quatro amigos', 120, '21:00:00');

INSERT INTO pecas_teatro (nome_peca, descricao, duracao, horario)
VALUES ('Drácula', 'È um personagem fictício que dá título ao romance de terror gótico escrito por Bram Stoker em 1897', 200, '20:00:00');

INSERT INTO pecas_teatro (nome_peca, descricao, duracao, horario)
VALUES ('Uma Ideia de Você', 'É um romance hot sobre música e glamour que explora temas importantes como o etarismo, a ação predatória da imprensa e o que somos capazes de fazer.', 260, '18:00:00');

SELECT * FROM pecas_teatro;

-- EX:2
DELIMITER $$

CREATE FUNCTION calcular_media_duracao(id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE media_duracao DECIMAL(10,2);
    
    SELECT AVG(duracao) INTO media_duracao
    FROM pecas_teatro
    WHERE id_peca = id;
    
    RETURN media_duracao;
END$$

DELIMITER ;

SELECT calcular_media_duracao(3);

-- EX:3
DELIMITER $$

CREATE FUNCTION verificar_disponibilidade(hora TIME)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE disponibilidade BOOLEAN;
    
    SELECT CASE 
        WHEN COUNT(*) > 0 THEN FALSE 
        ELSE TRUE 
    END INTO disponibilidade
    FROM pecas_teatro
    WHERE CONCAT(CURDATE(), ' ', horario) = hora;

    RETURN disponibilidade;
END$$

DELIMITER ;

SELECT verificar_disponibilidade('20:00:00');

-- EX:4
DELIMITER $$

CREATE PROCEDURE agendar_peca(
    IN p_nome_peca VARCHAR(100),
    IN p_descricao VARCHAR(800),
    IN p_duracao INT,
    IN p_data_hora DATETIME
)
BEGIN
    -- Verifica a disponibilidade
    IF verificar_disponibilidade(p_data_hora) THEN
        -- Insere a nova peça
        INSERT INTO pecas_teatro (nome_peca, descricao, duracao, horario)
        VALUES (p_nome_peca, p_descricao, p_duracao, TIME(p_data_hora));
        
        -- Exibe a mensagem de sucesso
        SELECT 'Peça agendada com sucesso!' AS mensagem;

        -- Calcula e exibe a média de duração da peça
        SELECT calcular_media_duracao(LAST_INSERT_ID()) AS media_duracao;
    ELSE
        -- Exibe a mensagem de erro
        SELECT 'Erro: Horário indisponível!' AS mensagem;
    END IF;
END$$

DELIMITER ;

-- EX:5

CALL agendar_peca('Uma Ideia de Você', 'É um romance hot sobre música e glamour que explora temas importantes como o etarismo, a ação predatória da imprensa e o que somos capazes de fazer.', 260, '18:00:00');


