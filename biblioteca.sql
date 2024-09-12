CREATE DATABASE BIBLIOTECA;
use biblioteca;


CREATE TABLE LIVROS(
	ID_LIVRO INT PRIMARY KEY AUTO_INCREMENT,
    NOME_LIVRO VARCHAR(100),
    DATA_PUBLICACAO DATE
);

CREATE TABLE AUTOR(
	ID_AUTOR INT PRIMARY KEY AUTO_INCREMENT,
    NOME_AUTOR VARCHAR(100),
    ID_LIVRO INT,
    CONSTRAINT FK_LIVROS FOREIGN KEY(ID_LIVRO) REFERENCES LIVROS(ID_LIVRO)
);

CREATE TABLE LIVROS_AUTOR(
	ID_AUTOR INTEGER,
    ID_LIVRO INTEGER,
    PRIMARY KEY (ID_AUTOR, ID_LIVRO),
    CONSTRAINT FK_AUTOR FOREIGN KEY(ID_AUTOR) REFERENCES AUTOR(ID_AUTOR),
    CONSTRAINT FK_LIVRO FOREIGN KEY(ID_LIVRO) REFERENCES LIVROS(ID_LIVRO)
);

CREATE TABLE USUARIOS(
	ID_USUARIO INT PRIMARY KEY auto_increment,
    NOME_USUARIO VARCHAR(50),
    DATA_NASCIMENTO DATE,
    CPF VARCHAR(12),
    TELEFONE VARCHAR(20)
);

CREATE TABLE LOCACAO (
	ID_LOCACAO INT PRIMARY KEY AUTO_INCREMENT,
    DATA_LOCACAO DATE,
    ID_USUARIO INT,
    ID_LIVRO INT,
    
    FOREIGN KEY (ID_USUARIO) REFERENCES USUARIOS(ID_USUARIO),
    FOREIGN KEY (ID_LIVRO) REFERENCES LIVROS(ID_LIVRO)
);

CREATE TABLE DEVOLUCOES(
	ID_DEVOLUCAO INT AUTO_INCREMENT PRIMARY KEY,
    ID_LIVRO INT,
    ID_USUARIO INT,
    DATA_DEVOLUCAO DATE,
    DATA_DEVOLUCAO_ESPERADA DATE,
    FOREIGN KEY (ID_LIVRO) REFERENCES LIVROS(ID_LIVRO),
    FOREIGN KEY(ID_USUARIO) REFERENCES USUARIOS(ID_USUARIO)
);

CREATE TABLE MULTAS (
	ID_MULTAS INT AUTO_INCREMENT PRIMARY KEY,
    ID_USUARIO INT,
    VALOR_MULTAS DECIMAL (10,2),
    DATA_MULTA DATE,
    FOREIGN KEY (ID_USUARIO) REFERENCES USUARIOS(ID_USUARIO)
);

CREATE TABLE Mensagens (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Destinatario VARCHAR(255) NOT NULL,
    Assunto VARCHAR(255) NOT NULL,
    Corpo TEXT,
    DataEnvio DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Livros_Atualizados (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_Livro INT NOT NULL,
    Titulo VARCHAR(255) NOT NULL,
    Autor VARCHAR(255),
    DataAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Livros_Excluidos (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ID_Livro INT NOT NULL,
    Titulo VARCHAR(255) NOT NULL,
    Autor VARCHAR(255),
    DataExclusao DATETIME DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO LIVROS (NOME_LIVRO, DATA_PUBLICACAO) VALUES 
('Livro A', '2020-01-01'),
('Livro B', '2021-02-15'),
('Livro C', '2022-03-20'),
('O Senhor dos Anéis', '1954-07-29'),
('1984', '1949-06-08');


INSERT INTO AUTOR (NOME_AUTOR, ID_LIVRO) VALUES 
('Autor 1', 1),
('Autor 2', 1),
('Autor 3', 2),
('Autor 4', 2),
('Autor 5', 3),
('Autor 6', 3);

INSERT INTO LIVROS_AUTOR (ID_AUTOR, ID_LIVRO) VALUES 
(1, 1),  
(1, 2),  
(2, 1),  
(2, 3), 
(3, 2),  
(3, 3);  

INSERT INTO USUARIOS (NOME_USUARIO, DATA_NASCIMENTO, CPF, TELEFONE) VALUES
('Carlos Silva', '1990-05-12', '12345678901', '(11) 98765-4321'),
('Ana Oliveira', '1985-07-24', '98765432100', '(21) 91234-5678'),
('Pedro Santos', '1992-10-30', '12312312312', '(31) 99876-5432'),
('Mariana Costa', '1995-02-15', '45645645645', '(41) 93456-7890'),
('João Souza', '1988-03-22', '78978978978', '(51) 94567-8901');


INSERT INTO LOCACAO (DATA_LOCACAO, ID_USUARIO, ID_LIVRO) VALUES
('2023-08-01', 1, 1),
('2023-08-02', 2, 2),
('2023-08-03', 3, 3),
('2023-08-04', 4, 4),
('2023-08-05', 5, 5);

INSERT INTO DEVOLUCOES (ID_LIVRO, ID_USUARIO, DATA_DEVOLUCAO, DATA_DEVOLUCAO_ESPERADA) VALUES
(1, 1, '2023-08-10', '2023-08-09'),
(2, 2, '2023-08-11', '2023-08-10'),
(3, 3, '2023-08-12', '2023-08-11'),
(4, 4, '2023-08-13', '2023-08-12'),
(5, 5, '2023-08-14', '2023-08-13');

INSERT INTO MULTAS (ID_USUARIO, VALOR_MULTAS, DATA_MULTA) VALUES
(1, 15.50, '2023-08-12'),
(2, 10.00, '2023-08-13'),
(3, 7.75, '2023-08-14'),
(4, 20.00, '2023-08-15'),
(5, 5.50, '2023-08-16');

INSERT INTO LIVROS (NOME_LIVRO, DATA_PUBLICACAO) VALUES 
('Livro D', '2019-05-05'),
('Livro E', '2018-10-10');




-- TRIGGERS
DELIMITER //

CREATE TRIGGER trg_calcula_multa
AFTER INSERT ON DEVOLUCOES
FOR EACH ROW
BEGIN
    DECLARE atraso INT;
    DECLARE valor_multa DECIMAL(10, 2);

    -- Calcula o atraso em dias
    SET atraso = DATEDIFF(NEW.DATA_DEVOLUCAO, NEW.DATA_DEVOLUCAO_ESPERADA);

    -- Verifica se houve atraso
    IF atraso > 0 THEN
        -- Calcula o valor da multa (por exemplo, R$ 2,00 por dia de atraso)
        SET valor_multa = atraso * 2.00;

        -- Insere o registro de multa na tabela Multas
        INSERT INTO MULTAS (ID_USUARIO, VALOR_MULTAS, DATA_MULTA)
        VALUES (NEW.ID_USUARIO, valor_multa, NOW());
    END IF;
END //

DELIMITER //
 CREATE TRIGGER Trigger_VerificarAtrasos
BEFORE INSERT ON Devolucoes
FOR EACH ROW
BEGIN
    DECLARE atraso INT;
    -- Calculao atraso em dias
    SET atraso= DATEDIFF(NEW.DATA_DEVOLUCAO_ESPERADA, DATA_DEVOLUCAO);
    -- Verificase há atraso
    IF atraso> 0 THEN
        -- Disparauma mensagem de alerta para o bibliotecário (exemplo genérico)
        INSERT INTO Mensagens (Destinatario, Assunto, Corpo)
        VALUES ('Bibliotecário', 'Alerta de Atraso', CONCAT('O livro com ID ', NEW.ID_Livro, ' não foi devolvido na data de devolução esperada.'));
    END IF;
END;
//

DELIMITER //
CREATE TRIGGER Trigger_AtualizarStatusEmprestado
AFTER INSERT ON LOCACAO
FOR EACH ROW
BEGIN
    UPDATE Livros
    SET StatusLivro= 'Emprestado'
    WHERE ID = NEW.ID_Livro;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER Trigger_AtualizarTotalExemplares
AFTER INSERT ON Livros
FOR EACH ROW
BEGIN
    UPDATE LIVROS
    SET TotalExemplares= TotalExemplares + 1
    WHERE ID_LIVRO = NEW.ID_LIVRO;
END;
//

DELIMITER //
CREATE TRIGGER Trigger_RegistrarAtualizacaoLivro
AFTER UPDATE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Livros_Atualizados (ID_Livro, Titulo, DataAtualizacao)
    VALUES (OLD.ID_LIVRO, OLD.NOME_LIVRO, NOW());
END;
//

DELIMITER //
CREATE TRIGGER Trigger_RegistrarExclusaoLivro
AFTER DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Livros_Excluidos (ID_Livro, Titulo, Autor, DataExclusao)
    VALUES (OLD.ID_LIVRO, OLD.NOME_LIVRO, NOW());
END;
//

SELECT L.NOME_LIVRO, A.NOME_AUTOR,LA.ID_AUTOR,LA.ID_LIVRO FROM AUTOR A
JOIN LIVROS L ON A.ID_AUTOR = L.ID_LIVRO
JOIN LIVROS_AUTOR LA ON A.ID_AUTOR =LA.ID_AUTOR;




DELIMITER //
-- FUNCTIONS

SELECT 
COUNT(ID_LIVRO) AS 'Quantidade de livros'
FROM livros;

SELECT 
COUNT(ID_DEVOLUCAO) AS 'Quantidade de livros devolvidos'
FROM devolucoes;

SELECT 
AVG(ID_LOCACAO) AS 'Média de locação',
COUNT(ID_LOCACAO) AS 'Quantidade de Locação'
FROM locacao;

SELECT 
COUNT(*) AS 'Quantidade de Usuarios cadastrados'
FROM usuarios;

SELECT 
MAX(VALOR_MULTAS) AS 'Valor máximo de multa', 
MIN(VALOR_MULTAS) AS 'Valor mínimo de multa',
AVG(VALOR_MULTAS) AS 'Média valor multa',
AVG(ID_MULTAS) AS 'Média de multas aplicadas',
SUM(VALOR_MULTAS) AS 'Soma das multas'
FROM multas;
//
-- PROCEDURES

DELIMITER //

CREATE PROCEDURE inserirusuario(
    IN nome VARCHAR(150),
    IN data_nascimento DATE,
    IN cpf VARCHAR(12),
    IN telefone VARCHAR(20)
)
BEGIN
    -- Insere um novo usuário na tabela USUARIOS
    INSERT INTO USUARIOS (NOME_USUARIO, DATA_NASCIMENTO, CPF, TELEFONE)
    VALUES (nome, data_nascimento, cpf, telefone);
END //

DELIMITER ;

CALL inserirusuario ('Olavo', '2003-01-06', '00000000000', '(00)0000-0000' );

DROP PROCEDURE IF EXISTS InserirUsuario;

SELECT * FROM usuarios;



DELIMITER //

CREATE PROCEDURE controlelivrosbiblioteca(
    IN operacao VARCHAR(20),      
    IN id_usuario INT,            
    IN id_livro INT,              
    IN data_operacao DATE         
)
BEGIN
    DECLARE atraso INT;
    DECLARE valor_multa DECIMAL(10,2);
    DECLARE data_devolucao_esperada DATE;
    
    -- 'reservar'
    IF operacao = 'reservar' THEN
        -- Verifica se o livro já está reservado
        IF (SELECT COUNT(*) FROM locacao WHERE ID_LIVRO = id_livro AND DATA_DEVOLUCAO IS NULL) = 0 THEN
            INSERT INTO locacao (ID_USUARIO, ID_LIVRO, DATA_LOCACAO)
            VALUES (id_usuario, id_livro, data_operacao);
            SELECT 'Livro reservado com sucesso!' AS Resultado;
        ELSE
            SELECT 'Livro já está reservado.' AS Resultado;
        END IF;
    
    -- 'retirar'
    ELSEIF operacao = 'retirar' THEN
        -- Verifica se o livro já está reservado pelo usuário
        IF (SELECT COUNT(*) FROM locacao WHERE ID_LIVRO = id_livro AND ID_USUARIO = id_usuario AND DATA_DEVOLUCAO IS NULL) > 0 THEN
            UPDATE locacao 
            SET DATA_LOCACAO = data_operacao
            WHERE ID_LIVRO = id_livro AND ID_USUARIO = id_usuario AND DATA_DEVOLUCAO IS NULL;
            SELECT 'Livro retirado com sucesso!' AS Resultado;
        ELSE
            SELECT 'Livro não está reservado por este usuário.' AS Resultado;
        END IF;

    -- 'devolver'
    ELSEIF operacao = 'devolver' THEN
        -- Verifica se o livro está emprestado para o usuário
        IF (SELECT COUNT(*) FROM locacao WHERE ID_LIVRO = id_livro AND ID_USUARIO = id_usuario AND DATA_DEVOLUCAO IS NULL) > 0 THEN
            -- Define a data esperada de devolução (neste exemplo, 7 dias após a retirada)
            SET data_devolucao_esperada = (SELECT DATE_ADD(DATA_LOCACAO, INTERVAL 7 DAY) FROM locacao WHERE ID_LIVRO = id_livro AND ID_USUARIO = id_usuario AND DATA_DEVOLUCAO IS NULL);
            
            -- Calcula o atraso em dias
            SET atraso = DATEDIFF(data_operacao, data_devolucao_esperada);
            
            -- Atualiza a devolução do livro
            UPDATE locacao 
            SET DATA_DEVOLUCAO = data_operacao
            WHERE ID_LIVRO = id_livro AND ID_USUARIO = id_usuario AND DATA_DEVOLUCAO IS NULL;

            -- Calcula a multa
            IF atraso > 0 THEN
                SET valor_multa = atraso * 2.00;  -- R$2,00 por dia de atraso
                INSERT INTO multas (ID_USUARIO, VALOR_MULTAS, DATA_MULTA)
                VALUES (id_usuario, valor_multa, data_operacao);
                SELECT CONCAT('Livro devolvido com atraso. Multa de R$', valor_multa) AS Resultado;
            ELSE
                SELECT 'Livro devolvido dentro do prazo.' AS Resultado;
            END IF;
        ELSE
            SELECT 'Livro não está emprestado para este usuário.' AS Resultado;
        END IF;
    ELSE
        SELECT 'Operação inválida. Escolha entre "reservar", "retirar" ou "devolver".' AS Resultado;
    END IF;
    
END //

CALL controlelivrosbiblioteca('reservar', 1, 1, '2023-09-01');

CALL controlelivrosbiblioteca('retirar', 1, 1, '2023-09-06');

CALL controlelivrosbiblioteca('devolver', 1, 1, '2023-09-15');

DELIMITER ;



